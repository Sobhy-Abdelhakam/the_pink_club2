import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/animation.dart';
import 'package:the_pink_club2/core/services/data_service.dart';
import '/l10n/app_localizations.dart';

import 'package:intl/intl.dart';

class SubscriptionFormPage extends StatefulWidget {
  final String selectedPackage;
  final String packagePrice;
  final int packageId;

  const SubscriptionFormPage({
    Key? key,
    required this.selectedPackage,
    required this.packagePrice,
    required this.packageId,
  }) : super(key: key);

  @override
  _SubscriptionFormPageState createState() => _SubscriptionFormPageState();
}

class _SubscriptionFormPageState extends State<SubscriptionFormPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  TextEditingController _birthDateController = TextEditingController();

  // بيانات المستخدم
  String _fullName = '';
  String _birthday = '';
  String _phone = '';
  String _gender = '';
  String _carBrand = '';
  String _carModel = '';
  String _carMadeYear = '';
  String _carChassis = '';
  String _carPlate = '';
  String _paymentMethod = 'دفع عند الاستلام';
  bool _termsAccepted = false;
  bool _hasCar = false; // إضافة متغير التحكم بوجود سيارة
  String? _selectedGovernorate;
  String? _selectedCity;

  // حالات التحميل والأخطاء
  bool _isLoading = false;

  // Animation controllers
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  // قائمة طرق الدفع
  late List<String> _paymentMethods;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _paymentMethods = [
      AppLocalizations.of(context)!.cashOnDelivery,
      AppLocalizations.of(context)!.bankTransfer,
      AppLocalizations.of(context)!.eWallet,
      AppLocalizations.of(context)!.creditCard,
    ];

    if (_paymentMethod.isEmpty || !_paymentMethods.contains(_paymentMethod)) {
      _paymentMethod = AppLocalizations.of(context)!.creditCard;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        backgroundColor: Colors.grey[50],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: AnimatedText(
        text: AppLocalizations.of(context)!.compSubscription,
        duration: const Duration(milliseconds: 500),
      ),
      centerTitle: true,
      backgroundColor: Colors.pink,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الباقة المختارة مع حركة
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.5),
                  end: Offset.zero,
                ).animate(_controller),
                child: _buildPackageCard(),
              ),
            ),

            const SizedBox(height: 30),

            // معلومات المشترك مع حركة متتابعة
            _buildAnimatedSection(
              title: AppLocalizations.of(context)!.detailSubscription,
              icon: Icons.person_outline,
              child: Column(
                children: [
                  _buildAnimatedTextField(
                    label: AppLocalizations.of(context)!.fullName,
                    icon: Icons.person,
                    validator: _validateName,
                    onSaved: (value) => _fullName = value!,
                  ),
                  const SizedBox(height: 20),
                  _buildAnimatedTextFieldDate(
                    context: context,
                    label: AppLocalizations.of(context)!.birthday,
                    icon: FontAwesomeIcons.birthdayCake,
                    controller: _birthDateController,
                    animationController: _controller,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.emailValidation;
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _birthday = value!;
                    },
                  ),

                  const SizedBox(height: 20),
                  _buildAnimatedTextFieldGender(
                    context: context,
                    label: AppLocalizations.of(context)!.gender,
                    icon: FontAwesomeIcons.venusMars,
                    selectedGender: _gender,
                    animationController: _controller,
                    onSaved: (value) => _gender = value!,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى اختيار الجنس';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),
                  _buildAnimatedTextField(
                    label: AppLocalizations.of(context)!.phone,
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: _validatePhone,
                    onSaved: (value) => _phone = value!,
                  ),
                  const SizedBox(height: 20),
                  _buildAnimatedTextFieldCity(
                    context: context,
                    selectedGovernorate: _selectedGovernorate,
                    selectedCity: _selectedCity,
                    animationController: _controller,
                    onGovernorateChanged: (value) {
                      setState(() {
                        _selectedGovernorate = value;
                        _selectedCity = null;
                      });
                    },
                    onCityChanged: (value) {
                      setState(() {
                        _selectedCity = value;
                      });
                    },
                    onCitySaved: (value) {
                      // Store address in a local variable or use _selectedGovernorate/_selectedCity directly where needed
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.addressValidation;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _buildHasCarCheckbox(),

            if (_hasCar) ...[
              const SizedBox(height: 20),
              _buildAnimatedSection(
                title: AppLocalizations.of(context)!.carDetails,
                icon: FontAwesomeIcons.car,
                child: Column(
                  children: [
                    _buildAnimatedTextField(
                      label: AppLocalizations.of(context)!.brand,
                      icon: Icons.directions_car_filled,
                      validator: _hasCar ? _validateBrand : (_) => null,
                      onSaved: (value) => _carBrand = value!,
                    ),

                    const SizedBox(height: 20),
                    _buildAnimatedTextField(
                      label: AppLocalizations.of(context)!.model,
                      icon: FontAwesomeIcons.carSide,
                      validator: _hasCar ? _validateModel : (_) => null,
                      onSaved: (value) => _carModel = value!,
                    ),
                    const SizedBox(height: 20),
                    _buildAnimatedTextField(
                      label: AppLocalizations.of(context)!.yearMade,
                      icon: FontAwesomeIcons.calendarAlt,
                      keyboardType: TextInputType.phone,
                      validator: _hasCar ? _validateMadeYear : (_) => null,
                      onSaved: (value) => _carMadeYear = value!,
                    ),
                    const SizedBox(height: 20),
                    _buildAnimatedTextField(
                      label: AppLocalizations.of(context)!.chases,
                      icon: FontAwesomeIcons.idCard,
                      maxLines: 2,
                      validator: _hasCar ? _validateChassis : (_) => null,
                      onSaved: (value) => _carChassis = value!,
                    ),
                    const SizedBox(height: 20),
                    _buildAnimatedTextField(
                      label: AppLocalizations.of(context)!.plant,
                      icon: FontAwesomeIcons.idBadge,
                      maxLines: 2,
                      validator: _hasCar ? _validatePlate : (_) => null,
                      onSaved: (value) => _carPlate = value!,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),

            // معلومات الدفع مع حركة متتابعة
            _buildAnimatedSection(
              title: AppLocalizations.of(context)!.paymentMethod,
              icon: Icons.payment,
              child: Column(
                children: [
                  _buildAnimatedDropdown(),
                  const SizedBox(height: 20),
                  _buildTermsCheckbox(),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // زر التأكيد مع حركة
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(_controller),
                child: _buildSubmitButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHasCarCheckbox() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.5, 1, curve: Curves.easeOut),
          ),
        ),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: _hasCar,
                    onChanged: (value) {
                      setState(() {
                        _hasCar = value!;
                      });
                    },
                    activeColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.iHave,
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPackageCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      shadowColor: Colors.pink.withOpacity(0.2),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.pink[50]!, Colors.purple[50]!],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: Colors.pink, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context)!.package,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                widget.selectedPackage,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink[800],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.packagePrice,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.purple[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-0.5, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 1, curve: Curves.easeOut),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.pink, size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required String label,
    required IconData icon,
    required FormFieldValidator<String> validator,
    required FormFieldSetter<String> onSaved,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.5, 1, curve: Curves.easeOut),
        ),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.pink),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.pink, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildAnimatedTextFieldDate({
    required BuildContext context,
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required AnimationController animationController,
    FormFieldValidator<String>? validator,
    FormFieldSetter<String>? onSaved,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animationController,
          curve: const Interval(0.5, 1, curve: Curves.easeOut),
        ),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          FocusScope.of(context).unfocus();

          DateTime now = DateTime.now();
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: initialDate ?? now,
            firstDate: firstDate ?? DateTime(1900),
            lastDate: lastDate ?? now,
            locale: Localizations.localeOf(context),
          );

          if (pickedDate != null) {
            controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          }
        },
        validator: validator,
        onSaved: onSaved,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.pink),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.pink, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextFieldCity({
    required BuildContext context,
    required String? selectedGovernorate,
    required String? selectedCity,
    required AnimationController animationController,
    required ValueChanged<String?> onGovernorateChanged,
    required ValueChanged<String?> onCityChanged,
    required FormFieldSetter<String> onCitySaved,
    String? Function(String?)? validator,
  }) {
    final Map<String, List<String>> cityMap = {
      'القاهرة': [
        'وسط البلد',
        'مدينة نصر',
        'مصر الجديدة',
        'المعادي',
        'حلوان',
        'عين شمس',
      ],
      'الجيزة': ['الدقي', 'العجوزة', 'الهرم', 'فيصل', '6 أكتوبر', 'الشيخ زايد'],
      'الإسكندرية': [
        'سيدي جابر',
        'محرم بك',
        'العصافرة',
        'سموحة',
        'المنتزه',
        'ميامي',
      ],
      'الدقهلية': ['المنصورة', 'طلخا', 'ميت غمر', 'دكرنس', 'نبروه'],
      'البحيرة': ['دمنهور', 'كفر الدوار', 'إيتاي البارود', 'رشيد'],
      'الشرقية': ['الزقازيق', 'العاشر من رمضان', 'بلبيس', 'أبو كبير'],
      'الغربية': ['طنطا', 'المحلة الكبرى', 'كفر الزيات', 'زفتى'],
      'المنوفية': ['شبين الكوم', 'السادات', 'منوف', 'قويسنا'],
      'كفر الشيخ': ['كفر الشيخ', 'دسوق', 'سيدي سالم', 'الحامول'],
      'دمياط': ['دمياط', 'رأس البر', 'فارسكور', 'كفر سعد'],
      'بورسعيد': ['بورسعيد', 'الزهور', 'العرب', 'الضواحي'],
      'الإسماعيلية': ['الإسماعيلية', 'فايد', 'التل الكبير'],
      'السويس': ['السويس', 'عتاقة', 'العين السخنة'],
      'بني سويف': ['بني سويف', 'الواسطى', 'الفشن'],
      'الفيوم': ['الفيوم', 'طامية', 'سنورس'],
      'المنيا': ['المنيا', 'ملوي', 'أبو قرقاص'],
      'أسيوط': ['أسيوط', 'ديروط', 'البداري'],
      'سوهاج': ['سوهاج', 'طهطا', 'جرجا'],
      'قنا': ['قنا', 'نجع حمادي', 'دشنا'],
      'الأقصر': ['الأقصر', 'إسنا', 'أرمنت'],
      'أسوان': ['أسوان', 'كوم أمبو', 'إدفو'],
      'الوادي الجديد': ['الخارجة', 'الداخلة', 'الفرافرة'],
      'مطروح': ['مرسى مطروح', 'الحمام', 'السلوم'],
      'شمال سيناء': ['العريش', 'الشيخ زويد', 'رفح'],
      'جنوب سيناء': ['شرم الشيخ', 'الطور', 'دهب', 'نويبع'],
      'البحر الأحمر': ['الغردقة', 'سفاجا', 'القصير', 'مرسى علم'],
    };

    List<String> governorates = cityMap.keys.toList();
    List<String> cities =
        selectedGovernorate != null ? cityMap[selectedGovernorate] ?? [] : [];

    return Column(
      children: [
        /// اختيار المحافظة
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animationController,
              curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
            ),
          ),
          child: DropdownButtonFormField<String>(
            value:
                governorates.contains(selectedGovernorate)
                    ? selectedGovernorate
                    : null,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.governorate,
              prefixIcon: const Icon(Icons.location_city, color: Colors.pink),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items:
                governorates.map((g) {
                  return DropdownMenuItem<String>(value: g, child: Text(g));
                }).toList(),
            onChanged: onGovernorateChanged,
          ),
        ),
        const SizedBox(height: 16),

        /// اختيار المدينة
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animationController,
              curve: const Interval(0.6, 1, curve: Curves.easeOut),
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: cities.contains(selectedCity) ? selectedCity : null,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.area,
              prefixIcon: const Icon(Icons.location_on, color: Colors.pink),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items:
                cities.map((city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
            validator: validator,
            onChanged: onCityChanged,
            onSaved: onCitySaved,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedTextFieldGender({
    required BuildContext context,
    required String label,
    required IconData icon,
    required String? selectedGender,
    required AnimationController animationController,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
  }) {
    final genderOptions = [
      AppLocalizations.of(context)!.male,
      AppLocalizations.of(context)!.female,
    ];

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animationController,
          curve: const Interval(0.5, 1, curve: Curves.easeOut),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: genderOptions.contains(selectedGender) ? selectedGender : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.pink),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.pink, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.pink),
        validator: validator,
        onChanged: (value) {
          setState(() {
            _gender = value!;
          });
        },
        onSaved: onSaved,
        items:
            genderOptions.map((gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildAnimatedDropdown() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.6, 1, curve: Curves.easeOut),
        ),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.paymentMethod,
          prefixIcon: Icon(Icons.payment, color: Colors.pink),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.pink, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
        value: _paymentMethod,
        items:
            _paymentMethods.map((method) {
              return DropdownMenuItem<String>(
                value: method,
                child: Text(method),
              );
            }).toList(),
        onChanged: (value) {
          setState(() {
            _paymentMethod = value!;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context)!.paymentValidation;
          }
          return null;
        },
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down, color: Colors.pink),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.7, 1, curve: Curves.easeOut),
          ),
        ),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: _termsAccepted,
                    onChanged: (value) {
                      setState(() {
                        _termsAccepted = value!;
                      });
                    },
                    activeColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showTermsDialog(),
                    child: RichText(
                      text: TextSpan(
                        text: AppLocalizations.of(context)!.termsApprove,
                        style: TextStyle(color: Colors.grey[800], fontSize: 14),
                        children: [
                          TextSpan(
                            text: AppLocalizations.of(context)!.termsTitle,
                            style: const TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(
                            text: AppLocalizations.of(context)!.termsAndPrivacy,
                            style: const TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
          shadowColor: Colors.pink.withOpacity(0.3),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child:
              _isLoading
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Color(0xFFD31F75)),
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context)!.confirmSubscription,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  // Validation functions
  String? _validateName(String? value) {
    if (value == null || value.isEmpty || value.length < 10) {
      return AppLocalizations.of(context)!.nameValidation;
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.phoneValidation;
    }
    if (value.length < 11) {
      return AppLocalizations.of(context)!.phoneLengthValidation;
    }
    return null;
  }

  // Car validation functions
  String? _validateBrand(String? value) {
    if (_hasCar && (value == null || value.isEmpty)) {
      return 'يجب إدخال ماركة السيارة';
    }
    return null;
  }

  String? _validateModel(String? value) {
    if (_hasCar && (value == null || value.isEmpty)) {
      return 'يجب إدخال موديل السيارة';
    }
    return null;
  }

  String? _validateMadeYear(String? value) {
    if (_hasCar && (value == null || value.isEmpty)) {
      return 'يجب إدخال سنة صنع السيارة';
    }
    return null;
  }

  String? _validateChassis(String? value) {
    if (_hasCar && (value == null || value.isEmpty)) {
      return 'يجب إدخال رقم الشاسيه';
    }
    return null;
  }

  String? _validatePlate(String? value) {
    if (_hasCar && (value == null || value.isEmpty)) {
      return 'يجب إدخال رقم اللوحة';
    }
    return null;
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.description, size: 50, color: Colors.pink),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.termsTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        AppLocalizations.of(context)!.termsContent,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          AppLocalizations.of(context)!.iRefuse,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => _termsAccepted = true);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(AppLocalizations.of(context)!.iAgree),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      _showErrorDialog("يجب الموافقة على الشروط والأحكام أولاً");
      return;
    }

    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final success = await SecureApiService.submitSubscription(
        context: context,
        fullName: _fullName,
        birthday: _birthday,
        gender: _gender,
        phone: _phone,
        address: '$_selectedGovernorate, $_selectedCity',
        carBrand: _hasCar ? _carBrand : '',
        carModel: _hasCar ? _carModel : '',
        carMadeYear: _hasCar ? _carMadeYear : '',
        carChassis: _hasCar ? _carChassis : '',
        carPlate: _hasCar ? _carPlate : '',
        packageId: widget.packageId,
        paymentMethod: _paymentMethod,
      );

      if (success) {
        _showSuccessDialog();
      } else {
        _showErrorDialog("فشل في إرسال الطلب. الرجاء المحاولة لاحقاً.");
      }
    } catch (e) {
      debugPrint('Error: ${e.toString()}');
      _showErrorDialog(
        "حدث خطأ: ${e.toString().replaceAll('Exception:', '').trim()}",
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LottieAnimation(animation: 'assets/success.json'),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.subscriptionSuccess,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  AppLocalizations.of(context)!.subscriptionSuccessMsg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.done),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return ScaleTransition(
          scale: anim,
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Error", style: TextStyle(color: Colors.red)),
            content: Text(message, style: const TextStyle(fontSize: 16)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
    );
  }
}

class AnimatedText extends StatefulWidget {
  final String text;
  final Duration duration;

  const AnimatedText({Key? key, required this.text, required this.duration})
    : super(key: key);

  @override
  _AnimatedTextState createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _displayText = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final textLength = (widget.text.length * _animation.value).round();
        _displayText = widget.text.substring(0, textLength);
        return Text(
          _displayText,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        );
      },
    );
  }
}

class LottieAnimation extends StatelessWidget {
  final String animation;

  const LottieAnimation({Key? key, required this.animation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(color: Colors.pink[50], shape: BoxShape.circle),
      child: const Icon(Icons.check_circle, size: 80, color: Colors.pink),
    );
  }
}
