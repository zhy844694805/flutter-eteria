import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'pages/home_page.dart';
import 'pages/create_page.dart';
import 'pages/digital_life_page.dart';
import 'pages/my_page.dart';
import 'pages/login_page.dart';
import 'widgets/bottom_navigation_bar.dart';
import 'providers/memorial_provider.dart';
import 'providers/auth_provider.dart';

void main() {
  // 在调试模式下关闭溢出指示器
  WidgetsFlutterBinding.ensureInitialized();
  
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
          create: (context) => MemorialProvider(),
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
        // 关闭溢出警告（黄黑条纹）
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
            child: child!,
          );
        },
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
  bool _hasLoadedData = false;

  final List<Widget> _pages = const [
    HomePage(),
    CreatePage(),
    DigitalLifePage(),
    MyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // 如果正在加载，显示加载页面
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // 如果用户未登录，显示登录页面
        if (!authProvider.isLoggedIn) {
          _hasLoadedData = false; // 重置加载状态
          return const LoginPage();
        }
        
        // 用户已登录，自动加载纪念数据
        if (!_hasLoadedData) {
          _hasLoadedData = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final memorialProvider = Provider.of<MemorialProvider>(context, listen: false);
            memorialProvider.loadMemorials();
          });
        }
        
        // 用户已登录，显示主界面
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
      },
    );
  }
}
