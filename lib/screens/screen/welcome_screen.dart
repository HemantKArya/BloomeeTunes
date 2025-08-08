import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/services/first_time_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<WelcomePageData> _pages = [
    WelcomePageData(
      title: "Welcome to Bloomee",
      subtitle: "Your Ultimate Music Experience",
      description:
          "Discover, play, and enjoy your favorite music with our powerful and intuitive music player.",
      icon: Icons.music_note_rounded,
    ),
    WelcomePageData(
      title: "Stream & Download",
      subtitle: "Music from Multiple Sources",
      description:
          "Access music from YouTube, Spotify, and more. Download your favorites for offline listening.",
      icon: Icons.cloud_download_rounded,
    ),
    WelcomePageData(
      title: "Create Playlists",
      subtitle: "Organize Your Music",
      description:
          "Build custom playlists, manage your library, and keep your music organized just the way you like.",
      icon: Icons.playlist_play_rounded,
    ),
    WelcomePageData(
      title: "Ready to Rock?",
      subtitle: "Let's Get Started",
      description:
          "Everything is set up and ready to go. Start exploring your new music experience!",
      icon: Icons.rocket_launch_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishWelcome();
    }
  }

  void _finishWelcome() async {
    // Save that user has seen welcome screen
    await FirstTimeService.setWelcomeSeen();
    if (mounted) {
      context.go('/Explore');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Default_Theme.themeColor,
              Default_Theme.accentColor1.withValues(alpha: 0.05),
              Default_Theme.accentColor2.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextButton(
                    onPressed: _finishWelcome,
                    child: Text(
                      'Skip',
                      style: Default_Theme.secondoryTextStyle.copyWith(
                        color:
                            Default_Theme.primaryColor1.withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildWelcomePage(_pages[index]),
                      ),
                    );
                  },
                ),
              ),
              // Page Indicators
              _buildPageIndicators(),
              const SizedBox(height: 30),
              // Next/Get Started Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Default_Theme.accentColor2,
                      foregroundColor: Default_Theme.primaryColor1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 8,
                      shadowColor:
                          Default_Theme.accentColor2.withValues(alpha: 0.3),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: Default_Theme.secondoryTextStyleMedium.copyWith(
                        fontSize: 18,
                        color: Default_Theme.primaryColor1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage(WelcomePageData pageData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Default_Theme.accentColor1,
                  Default_Theme.accentColor2,
                ],
              ),
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: Default_Theme.accentColor2.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              pageData.icon,
              size: 60,
              color: Default_Theme.primaryColor1,
            ),
          ),
          const SizedBox(height: 50),
          // Title
          Text(
            pageData.title,
            textAlign: TextAlign.center,
            style: Default_Theme.primaryTextStyle.copyWith(
              fontSize: 28,
              color: Default_Theme.primaryColor1,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          // Subtitle
          Text(
            pageData.subtitle,
            textAlign: TextAlign.center,
            style: Default_Theme.secondoryTextStyleMedium.copyWith(
              fontSize: 18,
              color: Default_Theme.accentColor1,
            ),
          ),
          const SizedBox(height: 25),
          // Description
          Text(
            pageData.description,
            textAlign: TextAlign.center,
            style: Default_Theme.secondoryTextStyle.copyWith(
              fontSize: 16,
              color: Default_Theme.primaryColor1.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Default_Theme.accentColor2
                : Default_Theme.primaryColor1.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class WelcomePageData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;

  WelcomePageData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });
}
