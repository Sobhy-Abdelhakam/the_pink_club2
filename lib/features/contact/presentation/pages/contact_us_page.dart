import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:the_pink_club2/core/services/data_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '/l10n/app_localizations.dart';


class ContactUsPage extends StatefulWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isSending = false;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 12,
    ).chain(CurveTween(curve: Curves.elasticOut)).animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // SUCCESS POPUP (UNCHANGED)
  // ---------------------------------------------------------------------------
  void _showSuccessDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.80,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.shade200.withOpacity(0.40),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 90, color: Colors.pink.shade400),
                const SizedBox(height: 18),
                Text(
                  AppLocalizations.of(context)!.sendMessage,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                    color: Color(0xFFD31F75),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context)!.ok,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    decoration: TextDecoration.none,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade400,
                    minimumSize: const Size(150, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.done,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(scale: anim, child: child),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // SUBMIT FORM (UNCHANGED)
  // ---------------------------------------------------------------------------
  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _shakeController.forward(from: 0);
      return;
    }

    setState(() => _isSending = true);

    try {
      final response = await SecureApiService.sendContactMessage(
        context: context,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        message: _messageController.text.trim(),
      );

      if (response['success'] == true) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? AppLocalizations.of(context)!.error,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to send"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  // ---------------------------------------------------------------------------
  // URL LAUNCHER (UNCHANGED)
  // ---------------------------------------------------------------------------
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await Clipboard.setData(ClipboardData(text: url));
      }
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: url));
    }
  }

  // ---------------------------------------------------------------------------
  // UI (GIRLISH ENHANCED VERSION)
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.pink.shade50,
      appBar: _buildGirlishAppBar(loc),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 120,
          left: 20,
          right: 20,
          bottom: 20,
        ),
        child: Column(
          children: [
            _buildCuteHeaderIcon(),
            const SizedBox(height: 15),
            _buildCuteFormContainer(loc),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Girlish AppBar
  // ---------------------------------------------------------------------------
  PreferredSizeWidget _buildGirlishAppBar(AppLocalizations loc) {
    return AppBar(
      backgroundColor: Colors.pink.shade300,
      elevation: 0,
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      title: Text(
        loc.contactUs,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Cute Floating Icon
  // ---------------------------------------------------------------------------
  Widget _buildCuteHeaderIcon() {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.pink.shade200, Colors.pink.shade300],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.shade200.withOpacity(0.35),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(Icons.mail_rounded, size: 60, color: Colors.white),
    );
  }

  // ---------------------------------------------------------------------------
  // Cute Form Container with soft animation shake
  // ---------------------------------------------------------------------------
  Widget _buildCuteFormContainer(AppLocalizations loc) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder:
          (_, child) => Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: child,
          ),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.pink.shade100, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.shade200.withOpacity(0.20),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                loc.weAreHappy,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 25),

              // Fields
              _buildCuteField(
                controller: _nameController,
                label: loc.fullName,
                icon: Icons.person_rounded,
                validator:
                    (v) => v == null || v.isEmpty ? loc.nameValidation : null,
              ),
              const SizedBox(height: 18),

              _buildCuteField(
                controller: _emailController,
                label: loc.email,
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return loc.emailValidation;
                  if (!v.contains('@')) return loc.invalidEmail;
                  return null;
                },
              ),
              const SizedBox(height: 18),

              _buildCuteField(
                controller: _phoneController,
                label: loc.phone,
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 18),

              _buildCuteField(
                controller: _messageController,
                label: loc.message,
                maxLines: 4,
                icon: Icons.message_rounded,
                validator:
                    (v) =>
                        v == null || v.isEmpty ? loc.messageValidation : null,
              ),

              const SizedBox(height: 30),

              _buildCuteSendButton(loc),
              const SizedBox(height: 25),

              _buildSocialIconsRow(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Cute Input Field
  // ---------------------------------------------------------------------------
  Widget _buildCuteField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 14,
          color: Colors.pink.shade400,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: Colors.pink.shade50.withOpacity(0.5),
        prefixIcon: Container(
          margin: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Colors.pink.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.pink.shade600),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.pink.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD31F75), width: 2),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Cute Send Button
  // ---------------------------------------------------------------------------
  Widget _buildCuteSendButton(AppLocalizations loc) {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pink.shade400,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 6,
        shadowColor: Colors.pink.shade200,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child:
            _isSending
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white),
                )
                : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.send_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      loc.sendMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Social Row
  // ---------------------------------------------------------------------------
  Widget _buildSocialIconsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _cuteSocialIcon(
          FontAwesomeIcons.whatsapp,
          Colors.green,
          'https://wa.me/+201111768519/',
        ),
        _cuteSocialIcon(
          FontAwesomeIcons.facebook,
          Colors.blue,
          'https://www.facebook.com/thepinkclub.eg',
        ),
        _cuteSocialIcon(
          FontAwesomeIcons.instagram,
          Colors.purple,
          'https://www.instagram.com/thepinkclub.eg',
        ),
        _cuteSocialIcon(
          FontAwesomeIcons.tiktok,
          Colors.black,
          'https://www.tiktok.com/@thepinkclub.eg',
        ),
      ],
    );
  }

  Widget _cuteSocialIcon(IconData icon, Color color, String url) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IconButton(
        icon: FaIcon(icon, size: 28, color: color),
        onPressed: () => _launchURL(url),
      ),
    );
  }
}
