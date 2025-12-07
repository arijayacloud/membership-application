import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'app/presentation/pages/dashboard_user_page.dart';
import 'config/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // 👈 hilangkan error const
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BSM Clinic Center',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Poppins",
        scaffoldBackgroundColor: const Color(0xFFF6F9FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1F3C88),
          elevation: 0,
          centerTitle: true,
        ),
      ),
      routes: {
        AppRoutes.login: (_) => LoginPage(),
        AppRoutes.register: (_) => RegisterPage(),
        AppRoutes.dashboard: (_) => const DashboardUserPage(),
      },
      initialRoute: AppRoutes.login,
    );
  }
}
