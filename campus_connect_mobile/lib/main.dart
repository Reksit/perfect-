import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/app_providers.dart';
import 'providers/feature_providers.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/verify_otp_screen.dart';
import 'screens/dashboards/student_dashboard.dart';
import 'screens/dashboards/professor_dashboard.dart';
import 'screens/dashboards/alumni_dashboard.dart';
import 'screens/dashboards/management_dashboard.dart';
import 'screens/assessments/ai_assessment_screen.dart';
import 'screens/alumni/alumni_directory_screen.dart';
import 'screens/jobs/job_board_screen.dart';
import 'screens/chat/ai_chat_screen.dart';
import 'screens/analytics/analytics_dashboard_screen.dart';
import 'screens/notifications/notification_center_screen.dart';
import 'screens/files/file_management_screen.dart';
import 'screens/events/event_management_screen.dart';
import 'screens/career/resume_builder_screen.dart';
import 'screens/networking/connections_screen.dart';
import 'screens/profile_management_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/features/task_management_screen.dart';
import 'screens/features/user_chat_screen.dart';
import 'screens/features/password_change_screen.dart';
import 'screens/features/advanced_attendance_screen.dart';
import 'screens/admin/admin_management_screen.dart';
import 'services/notification_service.dart';
import 'services/api_service.dart';
import 'utils/app_theme.dart';
import 'utils/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API service
  ApiService.initialize();
  
  // Initialize notification service
  await NotificationService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AssessmentProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => AlumniProvider()),
        ChangeNotifierProvider(create: (_) => EventsProvider()),
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
        ChangeNotifierProvider(create: (_) => ManagementProvider()),
        ChangeNotifierProvider(create: (_) => ProfessorProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Campus Connect',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: Routes.splash,
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case Routes.splash:
                  return MaterialPageRoute(builder: (_) => const SplashScreen());
                case Routes.login:
                  return MaterialPageRoute(builder: (_) => const LoginScreen());
                case Routes.register:
                  return MaterialPageRoute(builder: (_) => const RegisterScreen());
                case Routes.verifyOtp:
                  return MaterialPageRoute(builder: (_) => const VerifyOtpScreen());
                case Routes.studentDashboard:
                  return MaterialPageRoute(builder: (_) => const StudentDashboard());
                case Routes.professorDashboard:
                  return MaterialPageRoute(builder: (_) => const ProfessorDashboard());
                case Routes.alumniDashboard:
                  return MaterialPageRoute(builder: (_) => const AlumniDashboard());
                case Routes.managementDashboard:
                  return MaterialPageRoute(builder: (_) => const ManagementDashboard());
                case '/ai-assessment':
                  return MaterialPageRoute(builder: (_) => const AIAssessmentScreen());
                case '/alumni-directory':
                  return MaterialPageRoute(builder: (_) => const AlumniDirectoryScreen());
                case '/job-board':
                  return MaterialPageRoute(builder: (_) => const JobBoardScreen());
                case '/ai-chat':
                  return MaterialPageRoute(builder: (_) => const AIChatScreen());
                case '/analytics':
                  return MaterialPageRoute(builder: (_) => const AnalyticsDashboardScreen());
                case '/notifications':
                  return MaterialPageRoute(builder: (_) => const NotificationCenterScreen());
                case '/files':
                  return MaterialPageRoute(builder: (_) => const FileManagementScreen());
                case '/events':
                  return MaterialPageRoute(builder: (_) => const EventManagementScreen());
                case '/resume-builder':
                  return MaterialPageRoute(builder: (_) => const ResumeBuilderScreen());
                case '/connections':
                  return MaterialPageRoute(builder: (_) => const ConnectionsScreen());
                case '/profile-management':
                  return MaterialPageRoute(builder: (_) => const ProfileManagementScreen());
                case '/settings':
                  return MaterialPageRoute(builder: (_) => const SettingsScreen());
                case '/notifications-new':
                  return MaterialPageRoute(builder: (_) => const NotificationsScreen());
                case '/profile':
                  return MaterialPageRoute(builder: (_) => const ProfileManagementScreen());
                case '/admin':
                  return MaterialPageRoute(builder: (_) => const AdminManagementScreen());
                case '/tasks':
                  return MaterialPageRoute(builder: (_) => const TaskManagementScreen());
                case '/user-chat':
                  return MaterialPageRoute(builder: (_) => const UserChatScreen());
                case '/password-change':
                  return MaterialPageRoute(builder: (_) => const PasswordChangeScreen());
                case '/attendance':
                  return MaterialPageRoute(builder: (_) => const AdvancedAttendanceScreen());
                default:
                  return MaterialPageRoute(builder: (_) => const SplashScreen());
              }
            },
          );
        },
      ),
    );
  }
}
