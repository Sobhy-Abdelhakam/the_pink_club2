import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:the_pink_club2/core/di/injection_container.dart';
import 'package:the_pink_club2/core/presentation/widgets/clean_service_appbar.dart';
import 'package:the_pink_club2/core/utils/color.dart';
import 'package:the_pink_club2/features/concierge/domain/entities/concierge_service.dart';
import 'package:the_pink_club2/features/concierge/presentation/bloc/concierge_bloc.dart';
import 'package:the_pink_club2/features/concierge/presentation/bloc/concierge_event.dart';
import 'package:the_pink_club2/features/concierge/presentation/bloc/concierge_state.dart';
import 'package:url_launcher/url_launcher.dart';
import '/l10n/app_localizations.dart';

class ConciergeServicesPage extends StatefulWidget {
  const ConciergeServicesPage({Key? key}) : super(key: key);

  @override
  _ConciergeServicesPageState createState() => _ConciergeServicesPageState();
}

class _ConciergeServicesPageState extends State<ConciergeServicesPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_fadeController);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;

    return BlocProvider(
      create: (_) => sl<ConciergeBloc>()..add(GetConciergeServicesEvent(lang: lang)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CleanServiceAppBar(title: loc.conciergeServices),
        body: SafeArea(
          child: _buildBody(loc),
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations loc) {
    return BlocBuilder<ConciergeBloc, ConciergeState>(
      builder: (context, state) {
        if (state is ConciergeLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFD31F75)),
          );
        } else if (state is ConciergeError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                TextButton.icon(
                  onPressed: () {
                     final lang = Localizations.localeOf(context).languageCode;
                     context.read<ConciergeBloc>().add(GetConciergeServicesEvent(lang: lang));
                  },
                  icon: const Icon(Icons.refresh, color: Colors.red),
                  label: Text(loc.retry),
                )
              ],
            ),
          );
        } else if (state is ConciergeLoaded) {
          return _buildContent(state.services);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(List<ConciergeService> services) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (_, __) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              itemCount: services.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 20,
                childAspectRatio: .88,
              ),
              itemBuilder: (_, i) => _buildGirlishServiceCard(i, services),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGirlishServiceCard(int index, List<ConciergeService> list) {
    final service = list[index];
    final color = _parseColor(service.color);
    final icon = _getIconFromString(service.icon);

    return InkWell(
      onTap: () => _showServiceDetails(service),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, size: 28, color: color),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                service.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  service.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back, size: 12, color: color),
                    const SizedBox(width: 4),
                    Text(
                      'عرض',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showServiceDetails(ConciergeService service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.shade200.withOpacity(.3),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          service.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  Text(
                    service.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        final Uri phoneUri = Uri(
                          scheme: 'tel',
                          path: '+20233001166',
                        );
                        if (await canLaunchUrl(phoneUri)) {
                          launchUrl(phoneUri);
                        }
                      },
                      child: const Text(
                        'احجز الآن',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (_) {
      return Colors.pink.shade300;
    }
  }

  IconData _getIconFromString(String name) {
    switch (name) {
      case 'hotel':
        return FontAwesomeIcons.hotel;
      case 'plane':
        return FontAwesomeIcons.plane;
      case 'calendar-check':
        return FontAwesomeIcons.calendarCheck;
      case 'car-side':
        return FontAwesomeIcons.carSide;
      case 'utensils':
        return FontAwesomeIcons.utensils;
      case 'user-tie':
        return FontAwesomeIcons.userTie;
      default:
        return FontAwesomeIcons.questionCircle;
    }
  }
}
