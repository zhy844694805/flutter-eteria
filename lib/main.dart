import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'pages/home_page.dart';
import 'pages/create_page.dart';
import 'pages/digital_life_page.dart';
import 'pages/my_page.dart';
import 'widgets/bottom_navigation_bar.dart';
import 'providers/memorial_provider.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(const EteriaApp());
}

class EteriaApp extends StatelessWidget {
  const EteriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (context) => MemorialProvider()..initialize(),
        ),
      ],
      child: MaterialApp(
        title: '永恒回忆 - 纪念APP',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        // 添加中文本地化支持
        locale: const Locale('zh', 'CN'),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh', 'CN'), // 中文简体
          Locale('en', 'US'), // 英文（备用）
        ],
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    CreatePage(),
    DigitalLifePage(),
    MyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppDecorations.backgroundDecoration,
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
