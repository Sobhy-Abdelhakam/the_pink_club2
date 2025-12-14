import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:the_pink_club2/features/about/presentation/pages/about_screen.dart';
import 'package:the_pink_club2/features/contact/presentation/pages/contact_us_page.dart';
import 'package:the_pink_club2/features/home/presentation/pages/home_screen.dart';
import 'package:the_pink_club2/features/subscription/presentation/pages/subscriptions_page.dart';
import 'package:the_pink_club2/l10n/app_localizations.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;
  late final List<Widget> _pages = [
    const HomeScreen(),
    const SubscriptionsPage(),
    const ContactUsPage(),
    const AboutUsPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBody: true,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(FontAwesomeIcons.idCard),
            activeIcon: const Icon(FontAwesomeIcons.idCardClip),
            label: AppLocalizations.of(context)!.subscriptions,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.mail_outline),
            activeIcon: const Icon(Icons.mail),
            label: AppLocalizations.of(context)!.contactUs,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.info_outline),
            activeIcon: const Icon(Icons.info),
            label: AppLocalizations.of(context)!.aboutUs,
          ),
        ],
      ),
    );
  }
}
