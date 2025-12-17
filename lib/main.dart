import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/users/users_screen.dart';
import 'screens/properties/properties_screen.dart';
import 'screens/banned_users/banned_users_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/rate_limit/rate_limit_screen.dart';
import 'screens/security/security_screen.dart';
import 'screens/messages/conversations_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase removed

  await AuthService.loadUser();

  // FCM Service removed

  runApp(EvAtlasManager());
}

// ignore: use_key_in_widget_constructors
class EvAtlasManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EvAtlas Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: AuthService.isLoggedIn ? '/dashboard' : '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/users': (context) => UsersScreen(),
        '/properties': (context) => PropertiesScreen(),
        '/banned-users': (context) => BannedUsersScreen(),
        '/reports': (context) => ReportsScreen(),
        '/rate-limit': (context) => RateLimitScreen(),
        '/security': (context) => SecurityScreen(),
        '/messages': (context) => ConversationsScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
