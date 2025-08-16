import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_recipe_book/l10n/app_localizations.dart';

import 'providers/recipe_provider.dart';
import 'providers/cooking_mode_provider.dart';
import 'providers/recipe_calculation_provider.dart';
import 'providers/baking_calculation_provider.dart';
import 'providers/locale_provider.dart';
import 'services/recipe_derivation_service.dart';
import 'screens/user_setup_screen.dart';
import 'screens/welcome_ceremony_screen.dart';
import 'services/user_settings_service.dart';
import 'di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 서비스 로케이터 초기화
  ServiceLocator().initOnce();

  final userSettingsService =
      ServiceLocator.instance.get<UserSettingsService>();
  final userName = await userSettingsService.loadUserName();
  final languageCode = await userSettingsService.loadLanguageCode();

  runApp(MyRecipeBookApp(
      initialUserName: userName == '사용자' ? null : userName,
      initialLanguageCode: languageCode));
}

class MyRecipeBookApp extends StatefulWidget {
  final String? initialUserName;
  final String initialLanguageCode;

  const MyRecipeBookApp(
      {super.key, this.initialUserName, required this.initialLanguageCode});

  @override
  _MyRecipeBookAppState createState() => _MyRecipeBookAppState();
}

class _MyRecipeBookAppState extends State<MyRecipeBookApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RecipeProvider()),
        ChangeNotifierProvider(create: (context) => CookingModeProvider()),
        ChangeNotifierProvider(
            create: (context) => RecipeCalculationProvider()),
        ChangeNotifierProvider(
            create: (context) => BakingCalculationProvider()),
        ChangeNotifierProvider(
            create: (context) => LocaleProvider(widget.initialLanguageCode)),
        ProxyProvider<RecipeProvider, RecipeDerivationService>(
          update: (context, recipeProvider, previous) =>
              RecipeDerivationService(recipeProvider),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(414, 896),
        builder: (context, child) {
          final localeProvider = Provider.of<LocaleProvider>(context);
          return MaterialApp(
            title: 'My Recipe Book',
            theme: ThemeData(
              primaryColor: Colors.pink[300],
              primarySwatch: Colors.pink,
              scaffoldBackgroundColor: Color(0xFFFFF5F7),
              fontFamily: 'NotoSansKR',
              textTheme: TextTheme(
                bodyLarge: TextStyle(color: Color(0xFF4E342E), fontSize: 18.sp),
                bodyMedium:
                    TextStyle(color: Color(0xFF6D4C41), fontSize: 16.sp),
                titleLarge: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.sp,
                    color: Colors.pink[800]),
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.pink[300],
                centerTitle: true,
                elevation: 2,
                iconTheme: IconThemeData(color: Colors.white),
                titleTextStyle: TextStyle(
                  fontFamily: 'NotoSansKR',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              tabBarTheme: TabBarThemeData(
                labelStyle: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NotoSansKR'),
                unselectedLabelStyle:
                    TextStyle(fontSize: 16.sp, fontFamily: 'NotoSansKR'),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(color: Colors.white, width: 3),
                  insets: EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: Colors.pink[400],
                foregroundColor: Colors.white,
              ),
              iconTheme: IconThemeData(color: Colors.pink[400]),
            ),
            locale: localeProvider.locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: widget.initialUserName == null
                ? UserSetupScreen()
                : WelcomeCeremonyScreen(),
          );
        },
      ),
    );
  }
}
