import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:skilltrackit/pages/dashboard_page.dart';
import 'package:skilltrackit/pages/login_page.dart';
import 'package:skilltrackit/providers/auth_provider.dart';
import 'package:skilltrackit/providers/skill_provider.dart';
import 'package:skilltrackit/providers/schedule_provider.dart';
import 'package:skilltrackit/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Firebase
  await Firebase.initializeApp();

  // Register background FCM handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Init local notifications + FCM foreground handler
  await NotificationService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SkillProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return MaterialApp(
      title: 'SkillTrackIT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          primary: Colors.cyan.shade600,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: authProvider.isLoggedIn ? const DashboardPage() : const LoginPage(),
    );
  }
}
