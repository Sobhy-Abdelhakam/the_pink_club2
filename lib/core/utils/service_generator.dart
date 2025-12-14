// lib/utils/service_generator.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:the_pink_club2/l10n/app_localizations.dart';


Map<String, List<Map<String, dynamic>>> generateCategorizedServices(AppLocalizations loc) {
  return {
    // 1. Roadside Assistance (from old "car")
    'roadsideAssistance': [
      _serviceEntry(
        title: loc.carTowing,
        icon: 'directions-car', // Fallback
        image: 'assets/images/roadsideAssistance/Car_towing_in_case_of_breakdown.jpg',
        route: '/car_services',
      ),
      _serviceEntry(
        title: loc.carReturning,
        icon: 'directions-car',
        image: 'assets/images/roadsideAssistance/Returning_the_car_to_the_road.png',
        route: '/car_services',
      ),
      _serviceEntry(
        title: loc.batteryRecharge,
        icon: 'battery-three-quarters',
        image: 'assets/images/roadsideAssistance/Battery_recharge.png',
        route: '/car_services',
      ),
      _serviceEntry(
        title: loc.tireChange,
        icon: 'tire',
        image: 'assets/images/roadsideAssistance/tire_replacement.png',
        route: '/car_services',
      ),
      _serviceEntry(
        title: loc.urgentMessages,
        icon: 'comments',
        image: 'assets/images/roadsideAssistance/Reporting_urgent_messages.png',
        route: '/car_services',
      ),
      _serviceEntry(
        title: loc.providingInfo,
        icon: 'circle-info', // Assume circle-info exists or fallback
        image: 'assets/images/roadsideAssistance/Providing_information.png',
        route: '/car_services',
      ),
      _serviceEntry(
        title: loc.carMaintenance,
        icon: 'screwdriverWrench',
        image: 'assets/images/roadsideAssistance/Car_maintenance_arrangements_under_the_house.png',
        route: '/car_services',
      ),
      _serviceEntry(
        title: loc.replacementCar,
        icon: 'car-side',
        image: 'assets/images/roadsideAssistance/Assistance_in_providing_a_replacement_vehicle.png',
        route: '/car_services',
      ),
      _serviceEntry(
        title: loc.ambulanceArrangements,
        icon: 'truck-medical', // Assume exists
        image: 'assets/images/roadsideAssistance/Ambulance_arrangements.png',
        route: '/car_services',
      ),
      _serviceEntry(
        title: loc.fuelDelivery,
        icon: 'local-gas-station',
        image: 'assets/images/roadsideAssistance/Fuel_delivery.png',
        route: '/car_services',
      ),
    ],

    // 2. Medical Discounts (from old "medical")
    'medicalDiscounts': [
      _serviceEntry(
        title: loc.medicalServices,
        icon: 'stethoscope',
        route: '/medical_services',
        subtitle: loc.medicalDiscounts,
      ),
      _serviceEntry(
        title: loc.secondMedicalOpinion,
        icon: 'user-doctor',
        route: '/second_medical_opinion',
        subtitle: loc.secondMedicalOpinionDesc,
      ),
      _serviceEntry(
        title: loc.discountedMedicalServices,
        icon: 'home',
        route: '/medical_advisory',
        subtitle: loc.followUpCare,
      ),
    ],

    // 3. Automotive Supplies (from old "car")
    'automotiveSupplies': [
      _serviceEntry(
        title: loc.automotiveSupplies,
        icon: 'screwdriverWrench',
        route: '/automotive_supplies',
        subtitle: loc.automotiveSuppliesDesc,
      ),
      _serviceEntry(
        title: loc.licenseAssistance,
        icon: 'id-card',
        route: '/license',
        subtitle: loc.carPaperHelpDesc,
      ),
    ],

    // 4. Homecare Services → empty for now
    'homecareServices': [],

    // 5. Health & Beauty → empty for now
    'healthAndBeauty': [],

    // 6. Concierge Services (from old advisor)
    'conciergeServices': [
      _serviceEntry(
        title: loc.conciergeServices,
        icon: 'concierge',
        route: '/concierge',
        subtitle: loc.personalDesc,
      ),
    ],

    // 7. Entertainment & Leisure (from old more)
    'entertainmentLeisure': [
      _serviceEntry(
        title: loc.moreServices,
        icon: 'more',
        route: '/more',
        subtitle: loc.newServicesComingSoon,
      ),
    ],

    // 8. Fashion → empty
    'fashion': [],

    // 9. Restaurants → empty
    'restaurants': [],
  };
}


// Map<String, List<Map<String, dynamic>>> generateCategorizedServices(AppLocalizations loc) {
//   return {
//     'medical': [
//       _serviceEntry(title: loc.medicalServices, icon: FontAwesomeIcons.stethoscope, route: '/medical_services', subtitle: loc.medicalDiscounts, category: 'medical'),
//       _serviceEntry(title: loc.secondMedicalOpinion, icon: FontAwesomeIcons.userDoctor, route: '/second_medical_opinion', subtitle: loc.secondMedicalOpinionDesc, category: 'medical'),
//       _serviceEntry(title: loc.discountedMedicalServices, icon: FontAwesomeIcons.house, route: '/medical_advisory', subtitle: loc.followUpCare, category: 'medical'),
//     ],
//     'car': [
//       _serviceEntry(title: loc.carServices, icon: FontAwesomeIcons.car, route: '/car_services', subtitle: loc.emergencySupportDesc, category: 'car'),
//       _serviceEntry(title: loc.automotiveSupplies, icon: FontAwesomeIcons.wrench, route: '/automotive_supplies', subtitle: loc.automotiveSuppliesDesc, category: 'car'),
//       _serviceEntry(title: loc.licenseAssistance, icon: FontAwesomeIcons.idCard, route: '/license', subtitle: loc.carPaperHelpDesc, category: 'car'),
//     ],
//     'advisor': [
//       _serviceEntry(title: loc.advisoryServices, icon: FontAwesomeIcons.comments, route: '/advisory', subtitle: loc.insuranceAdviceDesc, category: 'advisor'),
//       _serviceEntry(title: loc.conciergeServices, icon: FontAwesomeIcons.bellConcierge, route: '/concierge', subtitle: loc.personalDesc, category: 'advisor'),
//     ],
//     'more': [
//       _serviceEntry(title: loc.moreServices, icon: FontAwesomeIcons.ellipsisH, route: '/more', subtitle: loc.newServicesComingSoon, category: 'more'),
//     ],
//   };
// }

Map<String, dynamic> _serviceEntry({required String title, required String icon, required String route, String? subtitle, String? category, String? image}) {
  return {
    'title': title, 
    'icon': icon, 
    'route': route, 
    if (subtitle != null) 'subtitle': subtitle, 
    if (category != null) 'category': category,
    if (image != null) 'image': image,
  };
}

// Helpers used by widgets
Color parseColor(String hex) {
  try {
    return Color(int.parse(hex.replaceFirst('#', '0xff')));
  } catch (_) {
    return Colors.pink.shade300;
  }
}

IconData iconFromString(String name) {
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
      return FontAwesomeIcons.circleQuestion;
  }
}
