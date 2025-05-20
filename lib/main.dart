import 'dart:async';
import 'package:flutter/foundation.dart'; // ← for kIsWeb
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'app/routes/app_pages.dart';
import 'app/utils/theme.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- core inits ---
  if (kIsWeb) {
    // Web needs explicit FirebaseOptions
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDEVJlc0gfPQWsoW3PRYmhQ5mcfEMPEkiU",
        authDomain: "pomodorotasks-4bf4f.firebaseapp.com",
        projectId: "pomodorotasks-4bf4f",
        storageBucket: "pomodorotasks-4bf4f.firebasestorage.app",
        messagingSenderId: "636338387586",
        appId: "1:636338387586:web:a918411f83190f4d8f529b",
      ),
    );
  } else {
    // Mobile (Android/iOS) can use default options from native config files
    await Firebase.initializeApp();
  }

  await GetStorage.init();
  await WakelockPlus.enable();
  await _initNotifications();

  runApp(
    GetMaterialApp(
      title: "Pomodoro App",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}

Future<void> _initNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  await notificationsPlugin.initialize(
    const InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    ),
  );

  // create channel on Android
  const channel = AndroidNotificationChannel(
    'pomodoro_service',
    'Pomodoro Timer',
    description: 'Channel for Pomodoro notifications',
    importance: Importance.high,
    playSound: true,
  );
  await notificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}
