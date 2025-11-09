import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../screens/recipe_list_screen.dart';
import '../../utils/navigation.dart';

class WelcomeCeremonyScreen extends StatefulWidget {
  const WelcomeCeremonyScreen({super.key});

  @override
  _WelcomeCeremonyScreenState createState() => _WelcomeCeremonyScreenState();
}

class _WelcomeCeremonyScreenState extends State<WelcomeCeremonyScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  String _userName = '';
  String _userTitle = '';
  int _currentMessageIndex = 0;
  List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: Duration(milliseconds: 1200), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _controller,
            curve: Interval(0.0, 0.7, curve: Curves.easeIn)));
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _controller,
            curve: Interval(0.3, 1.0, curve: Curves.easeOut)));
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _loadUserDataAndStartCeremony();
  }

  Future<void> _loadUserDataAndStartCeremony() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _userName = prefs.getString('user_name') ?? ' ';
      _userTitle = prefs.getString('user_title') ?? 'Chef';
      _messages = [
        '환영합니다 \n$_userName $_userTitle님!',
        'My Recipe Book과 함께\n즐거운 요리 여정을 \n시작해 보세요.',
      ];
    });
    _startMessageSequence();
  }

  Future<void> _startMessageSequence() async {
    await Future.delayed(Duration(milliseconds: 500));
    for (int i = 0; i < _messages.length; i++) {
      if (!mounted) return;
      setState(() {
        _currentMessageIndex = i;
      });
      _controller.forward(from: 0.0);
      await Future.delayed(
          Duration(seconds: i == _messages.length - 1 ? 4 : 3));
      if (!mounted) return;
      if (i < _messages.length - 1) {
        _controller.reverse();
        await Future.delayed(Duration(milliseconds: 800));
      }
    }
    if (mounted) {
      Navigator.pushReplacement(context, buildPageRoute(RecipeListScreen()));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink[100]!, Colors.pink[300]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  'assets/icon/dinner_dining.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 30),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: AutoSizeText(
                      _messages.isNotEmpty
                          ? _messages[_currentMessageIndex]
                          : "",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.4,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      minFontSize: 18,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
