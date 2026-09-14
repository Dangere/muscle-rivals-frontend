import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider used to initialize other providers while the splash screen is loading
final appInitializeProvider = FutureProvider<void>((ref) async {
  // Preloading SVGs
  // await ref.read(imageServiceProvider).preloadSvg([
  //   "assets/logos/google-icon.svg",
  //   "assets/logos/syncora-logo.svg",
  // ]);
  // await ref.read(diagnosticsServiceProvider).initialize();

  // ref.read(isOnlineProvider);
  // ref.read(authProvider);

  // ref.read(googleSignInProvider);

  // ref.read(syncBackendProvider);

  // if (kIsWeb) {
  //   await ErrorMapper.initializeSourceMap();
  // }
  // Delay to avoid builds when transitions are needed
  await Future.delayed(const Duration(seconds: 2));
});
