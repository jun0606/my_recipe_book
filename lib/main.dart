// Dart core libraries
import 'dart:async';

// Flutter libraries
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Third-party packages
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

// Local imports
import 'di/service_locator.dart';

import 'services/sous_chef_database.dart';
import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'providers/recipe_calculation_provider.dart';
import 'providers/recipe_provider.dart';
import 'providers/text_scale_provider.dart';
import 'screens/user_setup_screen.dart';
import 'screens/welcome_ceremony_screen.dart';
import 'services/recipe_derivation_service.dart';

/// Entry point of the Recipe Book application
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize service locator
  ServiceLocator.instance.initOnce();

  // Initialize Sous Chef database
  await SousChefDatabase.initialize();

  try {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('user_name');
    final languageCode = prefs.getString('language_code') ?? 'ko';

    runApp(MyRecipeBookApp(
      initialUserName: userName,
      initialLanguageCode: languageCode,
    ));
  } on Exception catch (e) {
    // Handle initialization errors gracefully
    runApp(const MyRecipeBookApp(
      initialUserName: null,
      initialLanguageCode: 'ko',
    ));
  }
}

/// Main application widget for Recipe Book
class MyRecipeBookApp extends StatefulWidget {
  const MyRecipeBookApp({
    super.key,
    this.initialUserName,
    required this.initialLanguageCode,
  });

  final String? initialUserName;
  final String initialLanguageCode;

  @override
  State<MyRecipeBookApp> createState() => _MyRecipeBookAppState();
}

class _MyRecipeBookAppState extends State<MyRecipeBookApp> {
  @override
  void initState() {
    super.initState();
    _requestPermissions(); // ✅ 여기에 추가
  }

  Future<void> _requestPermissions() async {
    final cameraStatus = await Permission.camera.status;

    if (cameraStatus.isDenied || cameraStatus.isRestricted) {
      await Permission.camera.request();
    } else if (cameraStatus.isPermanentlyDenied) {
      await openAppSettings(); // 설정 화면 유도
    }
  }
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: _buildProviders(),
      child: ScreenUtilInit(
        designSize: _getDesignSize(context),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => _buildMaterialApp(context),
      ),
    );
  }

  /// Build provider list for dependency injection
  List<SingleChildWidget> _buildProviders() {
    return [
      ChangeNotifierProvider(create: (_) => RecipeProvider()),
      ChangeNotifierProvider(create: (_) => RecipeCalculationProvider()),
      ChangeNotifierProvider(create: (_) => TextScaleProvider()),
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(widget.initialLanguageCode),
      ),
      ProxyProvider<RecipeProvider, RecipeDerivationService>(
        update: (_, recipeProvider, __) =>
            RecipeDerivationService(recipeProvider),
      ),
    ];
  }

  /// Get appropriate design size based on screen
  Size _getDesignSize(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final aspectRatio = size.width / size.height;
    
    // 태블릿 크기 감지
    if (size.shortestSide >= 600) {
      return const Size(768, 1024); // 태블릿 기준
    }
    
    // 가로 모드 감지
    if (aspectRatio > 1.0) {
      return Size(size.width, size.height);
    }
    
    // 기본 모바일 크기
    return const Size(414, 896);
  }

  /// Build MaterialApp with theme and localization
  Widget _buildMaterialApp(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final textScaleProvider = Provider.of<TextScaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 띠 제거
      title: 'My Recipe Book',
      theme: _buildTheme(context),
      locale: localeProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        // 텍스트 스케일 팩터 적용
        final effectiveTextScale = textScaleProvider.getEffectiveTextScaleFactor(context);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: effectiveTextScale,
          ),
          child: child!,
        );
      },
      home: _buildHomeScreen(),
    );
  }

  /// Build application theme
  ThemeData _buildTheme(BuildContext context) {
    return ThemeData(
      primaryColor: Colors.pink[300],
      primarySwatch: Colors.pink,
      scaffoldBackgroundColor: const Color(0xFFFFF5F7),
      fontFamily: 'NotoSansKR',
      textTheme: _buildTextTheme(context),
      appBarTheme: _buildAppBarTheme(context),
      tabBarTheme: _buildTabBarTheme(context),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      floatingActionButtonTheme: _buildFloatingActionButtonTheme(),
      iconTheme: IconThemeData(color: Colors.pink[400]),
    );
  }

  /// Build text theme
  TextTheme _buildTextTheme(BuildContext context) {
    // 화면 크기에 따른 기본 폰트 크기 조정
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    
    final baseFontSize = isTablet ? 20.0 : 16.0;
    final largeFontSize = isTablet ? 24.0 : 18.0;
    final titleFontSize = isTablet ? 32.0 : 24.0;
    
    return TextTheme(
      bodyLarge: TextStyle(
        color: const Color(0xFF4E342E),
        fontSize: largeFontSize.sp,
      ),
      bodyMedium: TextStyle(
        color: const Color(0xFF6D4C41),
        fontSize: baseFontSize.sp,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: titleFontSize.sp,
        color: Colors.pink[800],
      ),
    );
  }

  /// Build AppBar theme
  AppBarTheme _buildAppBarTheme(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final appBarFontSize = isTablet ? 28.0 : 24.0;
    
    return AppBarTheme(
      backgroundColor: Colors.pink[300],
      centerTitle: true,
      elevation: 2,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontFamily: 'NotoSansKR',
        fontSize: appBarFontSize.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  /// Build TabBar theme
  TabBarThemeData _buildTabBarTheme(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final tabLabelSize = isTablet ? 20.0 : 18.0;
    final tabUnselectedSize = isTablet ? 18.0 : 16.0;
    
    return TabBarThemeData(
      labelStyle: TextStyle(
        fontSize: tabLabelSize.sp,
        fontWeight: FontWeight.bold,
        fontFamily: 'NotoSansKR',
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: tabUnselectedSize.sp,
        fontFamily: 'NotoSansKR',
      ),
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: Colors.white, width: 3),
        insets: EdgeInsets.symmetric(horizontal: 16.0),
      ),
    );
  }

  /// Build ElevatedButton theme
  ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pink[400],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  /// Build FloatingActionButton theme
  FloatingActionButtonThemeData _buildFloatingActionButtonTheme() {
    return FloatingActionButtonThemeData(
      backgroundColor: Colors.pink[400],
      foregroundColor: Colors.white,
    );
  }

  /// Determine home screen based on user setup status
  Widget _buildHomeScreen() {
    return widget.initialUserName == null
        ? const UserSetupScreen()
        : const WelcomeCeremonyScreen();
  }
}
