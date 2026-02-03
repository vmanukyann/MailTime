import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/capsule/capsule_confirmation_screen.dart';
import 'screens/capsule/create_capsule_screen.dart';
import 'screens/capsule/view_capsule_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/landing/landing_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'services/auth_service.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  SupabaseConfig.validate();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const MailTimeApp());
}

class MailTimeApp extends StatelessWidget {
  const MailTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: RoutePaths.root,
    );
  }
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? RoutePaths.root;
    final uri = Uri.parse(name);

    if (uri.pathSegments.length == 2 &&
        uri.pathSegments.first == RoutePaths.capsuleBase.replaceAll('/', '')) {
      final capsuleId = uri.pathSegments[1];
      return _protectedRoute(ViewCapsuleScreen(capsuleId: capsuleId));
    }

    switch (name) {
      case RoutePaths.root:
        if (AuthService.instance.isSignedIn) {
          return MaterialPageRoute(builder: (_) => const DashboardScreen());
        }
        return MaterialPageRoute(builder: (_) => const LandingScreen());
      case RoutePaths.login:
        if (AuthService.instance.isSignedIn) {
          return MaterialPageRoute(builder: (_) => const DashboardScreen());
        }
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case RoutePaths.signup:
        if (AuthService.instance.isSignedIn) {
          return MaterialPageRoute(builder: (_) => const DashboardScreen());
        }
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case RoutePaths.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case RoutePaths.dashboard:
        return _protectedRoute(const DashboardScreen());
      case RoutePaths.createCapsule:
        return _protectedRoute(const CreateCapsuleScreen());
      case RoutePaths.capsuleCreated:
        final args = settings.arguments as CapsuleConfirmationArgs?;
        if (args == null) {
          return _protectedRoute(const DashboardScreen());
        }
        return _protectedRoute(
          CapsuleConfirmationScreen(args: args),
        );
      case RoutePaths.profile:
        return _protectedRoute(const ProfileScreen());
      default:
        return MaterialPageRoute(builder: (_) => const LandingScreen());
    }
  }

  static Route<dynamic> _protectedRoute(Widget child) {
    if (!AuthService.instance.isSignedIn) {
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
    return MaterialPageRoute(builder: (_) => child);
  }
}
