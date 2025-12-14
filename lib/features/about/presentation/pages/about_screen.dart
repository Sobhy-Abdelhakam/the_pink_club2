import 'package:flutter/material.dart';
import 'package:the_pink_club2/core/services/data_service.dart';
import '/l10n/app_localizations.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _floatAnimation;

  String _visionText = '';
  String _missionText = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _loadAboutData();
  }

  Future<void> _loadAboutData() async {
    try {
      final about = await SecureApiService.getAbout(context);
      setState(() {
        _visionText = about['vision'] ?? '';
        _missionText = about['mission'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: _buildGirlishAppBar(loc),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFD31F75)),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildAnimatedCuteLogo(),
                    const SizedBox(height: 20),
                    _buildGirlishSection(
                      title: loc.ourVision,
                      content: _visionText,
                      icon: Icons.favorite_rounded,
                    ),
                    _buildGirlishSection(
                      title: loc.ourMission,
                      content: _missionText,
                      icon: Icons.auto_awesome_rounded,
                    ),
                  ],
                ),
              ),
    );
  }

  // --------------------------------------------------------------------------
  // GIRLISH APP BAR
  // --------------------------------------------------------------------------
  PreferredSizeWidget _buildGirlishAppBar(AppLocalizations loc) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.pink.shade300,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      title: Text(
        loc.aboutUs,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
    );
  }

  // --------------------------------------------------------------------------
  // CUTE FLOATING LOGO
  // --------------------------------------------------------------------------
  Widget _buildAnimatedCuteLogo() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (_, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.pink.shade100, Colors.pink.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.shade200.withOpacity(0.5),
              blurRadius: 22,
              spreadRadius: 4,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.favorite_rounded,
          size: 70,
          color: Color(0xFFD31F75),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // GIRLISH SECTION CARD
  // --------------------------------------------------------------------------
  Widget _buildGirlishSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.shade200.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.pink.shade100, width: 1.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.pink.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 26, color: Colors.pink.shade600),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Colors.pink.shade700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Content
          Text(
            content,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 16,
              height: 1.55,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
