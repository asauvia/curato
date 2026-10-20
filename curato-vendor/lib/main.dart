import 'package:flutter/material.dart';
import 'package:curato_vendor/core/routing/app_router.dart';
import 'package:curato_vendor/core/theme/app_theme.dart';
import 'package:curato_vendor/core/services/service_locator.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const CuratoVendorApp());
}

class CuratoVendorApp extends StatelessWidget {
  const CuratoVendorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Curato Vendor Panel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}
