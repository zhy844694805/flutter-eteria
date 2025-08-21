import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'theme/glassmorphism_theme.dart';
import 'pages/glass_home_page.dart';
import 'pages/glass_create_page.dart';
import 'pages/digital_life_page.dart';
import 'pages/glass_personal_page.dart';
import 'pages/glass_login_page.dart';
import 'pages/welcome_page.dart';
import 'widgets/glass_bottom_navigation.dart';
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
        theme: GlassmorphismTheme.theme,
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
  bool _showWelcome = true; // 是否显示欢迎页面

  List<Widget> get _pages => [
    GlassHomePage(
      onNavigateToCreate: () {
        setState(() {
          _currentIndex = 1; // 切换到创建页面
        });
      },
    ),
    const GlassCreatePage(),
    const DigitalLifePage(),
    const GlassPersonalPage(),
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
        
        // 首次进入应用，显示欢迎页面让用户选择
        if (_showWelcome && !authProvider.isLoggedIn) {
          return WelcomePage(
            onLoginPressed: () {
              setState(() {
                _showWelcome = false;
              });
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const GlassLoginPage(),
                ),
              );
            },
            onGuestMode: () {
              setState(() {
                _showWelcome = false;
              });
            },
          );
        }
        
        // 如果用户选择了登录但未登录成功，显示登录页面
        if (!_showWelcome && !authProvider.isLoggedIn) {
          _hasLoadedData = false; // 重置加载状态
          return const GlassLoginPage();
        }
        
        // 用户已登录或处于游客模式，自动加载纪念数据
        if (!_hasLoadedData) {
          _hasLoadedData = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final memorialProvider = Provider.of<MemorialProvider>(context, listen: false);
            // 只有在登录状态下才加载用户的纪念数据，游客模式可以查看公开的纪念内容
            if (authProvider.isLoggedIn) {
              memorialProvider.loadMemorials();
            } else {
              // 游客模式：加载公开的纪念内容
              memorialProvider.loadPublicMemorials();
            }
          });
        }
        
        // 用户已登录或处于游客模式，显示主界面
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              gradient: GlassmorphismColors.backgroundGradient,
            ),
            child: _pages[_currentIndex],
          ),
          bottomNavigationBar: GlassBottomNavigation(
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
