import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logger/logger.dart';
import 'package:muscle_rivals/enums/signaling_type.dart';
import 'package:muscle_rivals/models/game/signaling_message.dart';
import 'package:muscle_rivals/providers/auth_provider.dart';
import 'package:muscle_rivals/providers/common_providers.dart';
import 'package:muscle_rivals/providers/match_provider.dart';
import 'package:muscle_rivals/providers/multiplayer_provider.dart';
import 'package:signalr_netcore/hub_connection.dart';

/// Web rtc can only be initialized and displayed if a match is running and the user is connected to the server
class WebRTCNotifier extends AsyncNotifier<String?> {
  final localRenderer = RTCVideoRenderer();
  final remoteRenderer = RTCVideoRenderer();
  late final Logger logger;
  late final HubConnection hubConnection;

  RTCPeerConnection? pc;
  MediaStream? mediaStream;

  /// Starts the web rtc stream between the two users, with the invoker as the caller
  void startStream() async {
    // return;
    // If theres no match we return
    bool isMatchRunning = ref.read(isMatchRunningProvider);

    // If user isn't logged we return
    bool isLoggedIn = ref.read(isLoggedProvider);

    // If no match or we aren't logged in or the state is loading (the initialization is not done yet) we return
    if (!isMatchRunning || !isLoggedIn || pc == null) {
      return;
    }

    // If we are in a loading state (usually for initializing) we await it
    if (state.isLoading) {
      await Future.doWhile(() async {
        await Future.delayed(Duration(seconds: 2));

        return state.isLoading;
      });
    }

    // print(pc.);
    RTCSessionDescription offer = await pc!.createOffer();
    await pc!.setLocalDescription(offer);

    logger.d("Sending offer");
    hubConnection.invoke(
      "SendSignaling",
      args: [SignalingMessage(SignalingType.offer, offer.sdp!).toEncodedJson()],
    );
  }

  void _onSignalingReceived(List<Object?>? data) {
    try {
      if (data == null || data.isEmpty || data[0] is! String) {
        logger.e("Failed to map signaling");
        return;
      }
      logger.w(
        "Got signal on peer connection ${pc.hashCode}, current signaling status is ${pc?.signalingState}",
      );

      SignalingMessage message = SignalingMessage.fromJsonEncoded(
        data[0] as String,
      );

      // logger.d("Received signaling: ${message.toString()}");
      switch (message.type) {
        case SignalingType.answer:
          _handleAnswer(message.data as String);
          break;
        case SignalingType.iceCandidate:
          _handleCandidate(message.data as Map<String, dynamic>);
          break;
        case SignalingType.offer:
          _handleOffer(message.data as String);
          break;
      }
    } catch (e, stackTrace) {
      logger.e(e, stackTrace: stackTrace);
    }
  }

  /// Handles the call from the other user and returns the answer
  void _handleOffer(String sdp) async {
    try {
      logger.d("Received offer");
      RTCSessionDescription offer = RTCSessionDescription(sdp, 'offer');
      await pc!.setRemoteDescription(offer);
      RTCSessionDescription answer = await pc!.createAnswer();
      await pc!.setLocalDescription(answer);

      logger.d("Returning answer");

      hubConnection.invoke(
        "SendSignaling",
        args: [
          SignalingMessage(SignalingType.answer, answer.sdp!).toEncodedJson(),
        ],
      );
    } catch (e, stackTrace) {
      logger.e(e, stackTrace: stackTrace);
    }
  }

  void _handleAnswer(String sdp) async {
    try {
      logger.d("Received answer");
      RTCSessionDescription answer = RTCSessionDescription(sdp, 'answer');
      await pc!.setRemoteDescription(answer);
    } catch (e, stackTrace) {
      logger.e(e, stackTrace: stackTrace);
    }
  }

  void _handleCandidate(Map<String, dynamic> data) async {
    try {
      logger.d("Received candidate");
      RTCIceCandidate candidate = RTCIceCandidate(
        data['candidate'],
        data['sdpMid'],
        data['sdpMLineIndex'],
      );
      await pc!.addCandidate(candidate);
    } catch (e, stackTrace) {
      logger.e(e, stackTrace: stackTrace);
    }
  }

  // void _onOffer

  @override
  FutureOr<String?> build() async {
    // If user isn't logged we return nothing and dispose if we have a peer connection
    bool isLoggedIn = ref.watch(isLoggedProvider);

    if (!isLoggedIn) {
      await pc?.dispose();
      return null;
    }

    // If peer connection isn't initialized we initialize it
    if (pc == null) {
      logger = ref.read(loggerProvider);
      hubConnection = ref.read(hubProvider);
      logger.i("Peer connection initialization started");

      // Initializing renderers
      await remoteRenderer.initialize();
      await localRenderer.initialize();

      // Creating a peer connection and adding our media stream
      pc = await createPeerConnection({
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ],
      });
      print(pc.hashCode);

      // Hooking up our own local renderer src object to be our video media
      if (!kIsWeb) {
        mediaStream = await navigator.mediaDevices.getUserMedia({
          'video': true,
          'audio': false,
        });
        // Adding our video track
        pc!.addTrack(mediaStream!.getVideoTracks().first, mediaStream!);
      } else {
        mediaStream = await navigator.mediaDevices.getDisplayMedia({
          'video': true,
          'audio': false,
        });
        pc!.addTrack(mediaStream!.getVideoTracks().first, mediaStream!);
      }

      localRenderer.srcObject = mediaStream;

      // Receiving remote track(s) and hooking it to our remoteRenderer, we are expecting one video
      pc!.onTrack = (event) {
        remoteRenderer.srcObject = event.streams[0];
        logger.w("Received remote track");

        state = AsyncValue.data("Connected");
      };

      // Debugging peer connection
      pc!.onConnectionState = (state) => logger.d('connection: $state');
      pc!.onIceConnectionState = (state) => logger.d('ice: $state');

      // Sending our signaling
      pc!.onIceCandidate = (RTCIceCandidate c) {
        logger.d("Sending ice candidate");

        hubConnection.invoke(
          "SendSignaling",
          args: [
            SignalingMessage(
              SignalingType.iceCandidate,
              c.toMap(),
            ).toEncodedJson(),
          ],
        );
      };

      // Linking up receiving signaling
      hubConnection.on(
        "onSignalingReceived",
        (data) => _onSignalingReceived(data),
      );
    }

    // // If theres no match we return nothing
    // bool isMatchRunning = ref.watch(isMatchRunningProvider);

    // // If we aren't in a match stop the stream if running, else we start it
    // if (!isMatchRunning) {
    //   await pc?.dispose();
    //   return null;
    // } else {
    //   startStream();
    // }

    ref.onDispose(() {
      try {
        logger.i("Peer connection disposed");
        mediaStream?.getTracks().forEach((t) => t.stop());
        mediaStream?.dispose();
        print(pc.hashCode);
        pc?.close();
        pc = null;
        localRenderer.dispose();
        remoteRenderer.dispose();
        hubConnection.off("onSignalingReceived");
      } catch (e, stackTrace) {
        logger.e(e, stackTrace: stackTrace);
      }
    });

    return null;
  }
}

final webRTCProvider =
    AsyncNotifierProvider.autoDispose<WebRTCNotifier, String?>(
      WebRTCNotifier.new,
    );
