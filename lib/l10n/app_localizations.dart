import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'The Pink Club'**
  String get appName;

  /// No description provided for @choosePackage.
  ///
  /// In en, this message translates to:
  /// **'Choose a package'**
  String get choosePackage;

  /// No description provided for @enjoyExclusive.
  ///
  /// In en, this message translates to:
  /// **'Enjoy exclusive premium features'**
  String get enjoyExclusive;

  /// No description provided for @subscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribeNow;

  /// No description provided for @choosePackageBtn.
  ///
  /// In en, this message translates to:
  /// **'Choose Package'**
  String get choosePackageBtn;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// No description provided for @eWallet.
  ///
  /// In en, this message translates to:
  /// **'E-Wallet'**
  String get eWallet;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// No description provided for @cashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get cashOnDelivery;

  /// No description provided for @termsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **' and Privacy Policy'**
  String get termsAndPrivacy;

  /// No description provided for @compSubscription.
  ///
  /// In en, this message translates to:
  /// **'Complete the subscription'**
  String get compSubscription;

  /// No description provided for @detailSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscriber information'**
  String get detailSubscription;

  /// No description provided for @confirmSubscription.
  ///
  /// In en, this message translates to:
  /// **'Confirm Subscription'**
  String get confirmSubscription;

  /// No description provided for @subscriptionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Subscription Successful!'**
  String get subscriptionSuccess;

  /// No description provided for @iRefuse.
  ///
  /// In en, this message translates to:
  /// **'I refuse'**
  String get iRefuse;

  /// No description provided for @iAgree.
  ///
  /// In en, this message translates to:
  /// **'I agree'**
  String get iAgree;

  /// No description provided for @subscriptionSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'Thank you for subscribing with us! You will receive a confirmation email.'**
  String get subscriptionSuccessMsg;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// No description provided for @weAreHappy.
  ///
  /// In en, this message translates to:
  /// **'We are happy to hear from you'**
  String get weAreHappy;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @serviceDetails.
  ///
  /// In en, this message translates to:
  /// **'Service Details'**
  String get serviceDetails;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// No description provided for @callUs.
  ///
  /// In en, this message translates to:
  /// **'Call Us'**
  String get callUs;

  /// No description provided for @readMoreTerms.
  ///
  /// In en, this message translates to:
  /// **'Read more about Terms & Conditions'**
  String get readMoreTerms;

  /// No description provided for @ourTeam.
  ///
  /// In en, this message translates to:
  /// **'Our Team'**
  String get ourTeam;

  /// No description provided for @ourVision.
  ///
  /// In en, this message translates to:
  /// **'Our Vision'**
  String get ourVision;

  /// No description provided for @ourMission.
  ///
  /// In en, this message translates to:
  /// **'Our Mission'**
  String get ourMission;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @pinkPackage.
  ///
  /// In en, this message translates to:
  /// **'Pink Package'**
  String get pinkPackage;

  /// No description provided for @diamondPackage.
  ///
  /// In en, this message translates to:
  /// **'Diamond Package'**
  String get diamondPackage;

  /// No description provided for @vipPackage.
  ///
  /// In en, this message translates to:
  /// **'VIP Package'**
  String get vipPackage;

  /// No description provided for @pinkPrice.
  ///
  /// In en, this message translates to:
  /// **'249 EGP/month'**
  String get pinkPrice;

  /// No description provided for @diamondPrice.
  ///
  /// In en, this message translates to:
  /// **'499 EGP/month'**
  String get diamondPrice;

  /// No description provided for @vipPrice.
  ///
  /// In en, this message translates to:
  /// **'999 EGP/month'**
  String get vipPrice;

  /// No description provided for @visionText.
  ///
  /// In en, this message translates to:
  /// **'We strive to be the premier destination for integrated services with unmatched quality and exceptional customer service.'**
  String get visionText;

  /// No description provided for @missionText.
  ///
  /// In en, this message translates to:
  /// **'To provide innovative solutions that meet our customers\' needs while maintaining the highest standards of quality and efficiency.'**
  String get missionText;

  /// No description provided for @serviceOverview.
  ///
  /// In en, this message translates to:
  /// **'Service Overview'**
  String get serviceOverview;

  /// No description provided for @keyFeatures.
  ///
  /// In en, this message translates to:
  /// **'Key Features'**
  String get keyFeatures;

  /// No description provided for @customerReviews.
  ///
  /// In en, this message translates to:
  /// **'Customer Reviews'**
  String get customerReviews;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsTitle;

  /// No description provided for @termsApprove.
  ///
  /// In en, this message translates to:
  /// **'I agree to'**
  String get termsApprove;

  /// No description provided for @termsContent.
  ///
  /// In en, this message translates to:
  /// **'Here are the terms of service and privacy policy for the application. \nThe user must agree to these terms before proceeding.\n\n1. Compliance with terms of use\n2. Respect for privacy policy\n3. Not to misuse the service\n4. Pay subscription on time\n5. Compliance with local laws'**
  String get termsContent;

  /// No description provided for @nameValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter full name'**
  String get nameValidation;

  /// No description provided for @emailValidation.
  ///
  /// In en, this message translates to:
  /// **'Date of birth cannot be left blank.'**
  String get emailValidation;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @phoneValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get phoneValidation;

  /// No description provided for @phoneLengthValidation.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be  11 digits'**
  String get phoneLengthValidation;

  /// No description provided for @addressValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter address'**
  String get addressValidation;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @governorate.
  ///
  /// In en, this message translates to:
  /// **'Governorate'**
  String get governorate;

  /// No description provided for @paymentValidation.
  ///
  /// In en, this message translates to:
  /// **'Please select payment method'**
  String get paymentValidation;

  /// No description provided for @termsValidation.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms of service first'**
  String get termsValidation;

  /// No description provided for @messageValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter your message'**
  String get messageValidation;

  /// No description provided for @carServices.
  ///
  /// In en, this message translates to:
  /// **'Roadside Assistance'**
  String get carServices;

  /// No description provided for @medicalServices.
  ///
  /// In en, this message translates to:
  /// **'Medical Services'**
  String get medicalServices;

  /// No description provided for @conciergeServices.
  ///
  /// In en, this message translates to:
  /// **'Concierge Services'**
  String get conciergeServices;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @conciergeTitle.
  ///
  /// In en, this message translates to:
  /// **'Concierge Services'**
  String get conciergeTitle;

  /// No description provided for @hotelBooking.
  ///
  /// In en, this message translates to:
  /// **'Hotel Reservations'**
  String get hotelBooking;

  /// No description provided for @hotelDesc.
  ///
  /// In en, this message translates to:
  /// **'Exclusive hotel bookings at luxury hotels worldwide'**
  String get hotelDesc;

  /// No description provided for @flightTickets.
  ///
  /// In en, this message translates to:
  /// **'Flight Tickets'**
  String get flightTickets;

  /// No description provided for @flightDesc.
  ///
  /// In en, this message translates to:
  /// **'Book flights with exclusive discounts on all airlines'**
  String get flightDesc;

  /// No description provided for @eventPlanning.
  ///
  /// In en, this message translates to:
  /// **'Event Planning'**
  String get eventPlanning;

  /// No description provided for @eventDesc.
  ///
  /// In en, this message translates to:
  /// **'Full event planning with a professional touch'**
  String get eventDesc;

  /// No description provided for @driverServices.
  ///
  /// In en, this message translates to:
  /// **'Driver Services'**
  String get driverServices;

  /// No description provided for @driverDesc.
  ///
  /// In en, this message translates to:
  /// **'Private driver with a luxury car available 24/7'**
  String get driverDesc;

  /// No description provided for @restaurantBooking.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Reservations'**
  String get restaurantBooking;

  /// No description provided for @restaurantDesc.
  ///
  /// In en, this message translates to:
  /// **'Book the best tables in top restaurants'**
  String get restaurantDesc;

  /// No description provided for @personalServices.
  ///
  /// In en, this message translates to:
  /// **'Personal Services'**
  String get personalServices;

  /// No description provided for @personalDesc.
  ///
  /// In en, this message translates to:
  /// **'Handle your personal tasks with full confidentiality'**
  String get personalDesc;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @yourMessage.
  ///
  /// In en, this message translates to:
  /// **'Your message has been sent successfully.'**
  String get yourMessage;

  /// No description provided for @insuranceAdvice.
  ///
  /// In en, this message translates to:
  /// **'Insurance Advice'**
  String get insuranceAdvice;

  /// No description provided for @insuranceAdviceDesc.
  ///
  /// In en, this message translates to:
  /// **'Consult with experts to choose the best insurance plan for your car.'**
  String get insuranceAdviceDesc;

  /// No description provided for @emergencySupport.
  ///
  /// In en, this message translates to:
  /// **'Emergency Car Support'**
  String get emergencySupport;

  /// No description provided for @emergencySupportDesc.
  ///
  /// In en, this message translates to:
  /// **'Quick technician dispatch and emergency aid for roadside troubles.'**
  String get emergencySupportDesc;

  /// No description provided for @carPaperHelp.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Paperwork Help'**
  String get carPaperHelp;

  /// No description provided for @carPaperHelpDesc.
  ///
  /// In en, this message translates to:
  /// **'Support with renewing licenses, ownership transfer, and paperwork processing.'**
  String get carPaperHelpDesc;

  /// No description provided for @homeCarServices.
  ///
  /// In en, this message translates to:
  /// **'At-Home Car Services'**
  String get homeCarServices;

  /// No description provided for @homeCarServicesDesc.
  ///
  /// In en, this message translates to:
  /// **'Get maintenance and car services at your location with ease and convenience.'**
  String get homeCarServicesDesc;

  /// No description provided for @features_car_services_1.
  ///
  /// In en, this message translates to:
  /// **'24/7 rapid response'**
  String get features_car_services_1;

  /// No description provided for @features_car_services_2.
  ///
  /// In en, this message translates to:
  /// **'Certified technicians'**
  String get features_car_services_2;

  /// No description provided for @features_car_services_3.
  ///
  /// In en, this message translates to:
  /// **'Emergency first aid services'**
  String get features_car_services_3;

  /// No description provided for @features_car_services_4.
  ///
  /// In en, this message translates to:
  /// **'Coverage in all areas'**
  String get features_car_services_4;

  /// No description provided for @features_car_services_5.
  ///
  /// In en, this message translates to:
  /// **'Competitive prices'**
  String get features_car_services_5;

  /// No description provided for @features_paper_services_1.
  ///
  /// In en, this message translates to:
  /// **'Remote transaction processing'**
  String get features_paper_services_1;

  /// No description provided for @features_paper_services_2.
  ///
  /// In en, this message translates to:
  /// **'Traffic specialists'**
  String get features_paper_services_2;

  /// No description provided for @features_paper_services_3.
  ///
  /// In en, this message translates to:
  /// **'Save time and effort'**
  String get features_paper_services_3;

  /// No description provided for @features_paper_services_4.
  ///
  /// In en, this message translates to:
  /// **'Follow-up until completion'**
  String get features_paper_services_4;

  /// No description provided for @features_paper_services_5.
  ///
  /// In en, this message translates to:
  /// **'Competitive prices'**
  String get features_paper_services_5;

  /// No description provided for @features_insurance_services_1.
  ///
  /// In en, this message translates to:
  /// **'Certified experts'**
  String get features_insurance_services_1;

  /// No description provided for @features_insurance_services_2.
  ///
  /// In en, this message translates to:
  /// **'Free consultations'**
  String get features_insurance_services_2;

  /// No description provided for @features_insurance_services_3.
  ///
  /// In en, this message translates to:
  /// **'Compare insurance companies'**
  String get features_insurance_services_3;

  /// No description provided for @features_insurance_services_4.
  ///
  /// In en, this message translates to:
  /// **'Periodic maintenance tips'**
  String get features_insurance_services_4;

  /// No description provided for @features_insurance_services_5.
  ///
  /// In en, this message translates to:
  /// **'Continuous support'**
  String get features_insurance_services_5;

  /// No description provided for @features_paperwork_1.
  ///
  /// In en, this message translates to:
  /// **'Remote transaction processing'**
  String get features_paperwork_1;

  /// No description provided for @features_paperwork_2.
  ///
  /// In en, this message translates to:
  /// **'Traffic specialists'**
  String get features_paperwork_2;

  /// No description provided for @features_paperwork_3.
  ///
  /// In en, this message translates to:
  /// **'Save time and effort'**
  String get features_paperwork_3;

  /// No description provided for @features_paperwork_4.
  ///
  /// In en, this message translates to:
  /// **'Follow-up until completion'**
  String get features_paperwork_4;

  /// No description provided for @features_paperwork_5.
  ///
  /// In en, this message translates to:
  /// **'Competitive pricing'**
  String get features_paperwork_5;

  /// No description provided for @hospital.
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get hospital;

  /// No description provided for @radiologyCenters.
  ///
  /// In en, this message translates to:
  /// **'Scan Centers'**
  String get radiologyCenters;

  /// No description provided for @labs.
  ///
  /// In en, this message translates to:
  /// **'Medical Labs'**
  String get labs;

  /// No description provided for @specializedCenters.
  ///
  /// In en, this message translates to:
  /// **'Specialized Centers'**
  String get specializedCenters;

  /// No description provided for @clinics.
  ///
  /// In en, this message translates to:
  /// **'Clinics'**
  String get clinics;

  /// No description provided for @pharmacies.
  ///
  /// In en, this message translates to:
  /// **'Pharmacies'**
  String get pharmacies;

  /// No description provided for @physiotherapy.
  ///
  /// In en, this message translates to:
  /// **'Physiotherapy'**
  String get physiotherapy;

  /// No description provided for @optometry.
  ///
  /// In en, this message translates to:
  /// **'Optometry'**
  String get optometry;

  /// No description provided for @communication.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get communication;

  /// No description provided for @medicalMap.
  ///
  /// In en, this message translates to:
  /// **'Medical map'**
  String get medicalMap;

  /// No description provided for @medicalNetwork.
  ///
  /// In en, this message translates to:
  /// **'Medical network'**
  String get medicalNetwork;

  /// No description provided for @allState.
  ///
  /// In en, this message translates to:
  /// **'An integrated medical network covering all governorates'**
  String get allState;

  /// No description provided for @egb.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get egb;

  /// No description provided for @carDetails.
  ///
  /// In en, this message translates to:
  /// **'Car Details'**
  String get carDetails;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @yearMade.
  ///
  /// In en, this message translates to:
  /// **'Year of manufacture'**
  String get yearMade;

  /// No description provided for @plant.
  ///
  /// In en, this message translates to:
  /// **'Plate number'**
  String get plant;

  /// No description provided for @chases.
  ///
  /// In en, this message translates to:
  /// **'Chassis number'**
  String get chases;

  /// No description provided for @noServicesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No services available at the moment'**
  String get noServicesAvailable;

  /// No description provided for @newServicesComingSoon.
  ///
  /// In en, this message translates to:
  /// **'New services will be added soon'**
  String get newServicesComingSoon;

  /// No description provided for @failedToLoadServices.
  ///
  /// In en, this message translates to:
  /// **'Failed to load services'**
  String get failedToLoadServices;

  /// No description provided for @discountedMedicalServices.
  ///
  /// In en, this message translates to:
  /// **'Home medical care'**
  String get discountedMedicalServices;

  /// No description provided for @advisoryServices.
  ///
  /// In en, this message translates to:
  /// **'Advisory services'**
  String get advisoryServices;

  /// No description provided for @licenseAssistance.
  ///
  /// In en, this message translates to:
  /// **'License Services'**
  String get licenseAssistance;

  /// No description provided for @moreServices.
  ///
  /// In en, this message translates to:
  /// **'More Services'**
  String get moreServices;

  /// No description provided for @package.
  ///
  /// In en, this message translates to:
  /// **'Package'**
  String get package;

  /// No description provided for @medicalDiscounts.
  ///
  /// In en, this message translates to:
  /// **'Medical Discounts'**
  String get medicalDiscounts;

  /// No description provided for @iHave.
  ///
  /// In en, this message translates to:
  /// **'I have a car'**
  String get iHave;

  /// No description provided for @automotiveSupplies.
  ///
  /// In en, this message translates to:
  /// **'Automotive Supplies'**
  String get automotiveSupplies;

  /// No description provided for @automotiveSuppliesDesc.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive automotive supplies and maintenance services to keep your vehicle in optimal condition. We provide quality parts, tools, and professional services for all your automotive needs.'**
  String get automotiveSuppliesDesc;

  /// No description provided for @secondMedicalOpinion.
  ///
  /// In en, this message translates to:
  /// **'Second Medical Opinion'**
  String get secondMedicalOpinion;

  /// No description provided for @secondMedicalOpinionDesc.
  ///
  /// In en, this message translates to:
  /// **'Get a second medical opinion from experienced specialists to ensure accurate diagnosis and treatment plans. Our network of qualified doctors provides comprehensive medical consultations.'**
  String get secondMedicalOpinionDesc;

  /// No description provided for @availableServices.
  ///
  /// In en, this message translates to:
  /// **'Available Services'**
  String get availableServices;

  /// No description provided for @oilChange.
  ///
  /// In en, this message translates to:
  /// **'Oil Change Service'**
  String get oilChange;

  /// No description provided for @tireService.
  ///
  /// In en, this message translates to:
  /// **'Tire Services'**
  String get tireService;

  /// No description provided for @batteryService.
  ///
  /// In en, this message translates to:
  /// **'Battery Services'**
  String get batteryService;

  /// No description provided for @brakeService.
  ///
  /// In en, this message translates to:
  /// **'Brake Services'**
  String get brakeService;

  /// No description provided for @filterService.
  ///
  /// In en, this message translates to:
  /// **'Filter Services'**
  String get filterService;

  /// No description provided for @consultationReview.
  ///
  /// In en, this message translates to:
  /// **'Medical Consultation Review'**
  String get consultationReview;

  /// No description provided for @diagnosisReview.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis Review'**
  String get diagnosisReview;

  /// No description provided for @treatmentPlan.
  ///
  /// In en, this message translates to:
  /// **'Treatment Plan Review'**
  String get treatmentPlan;

  /// No description provided for @surgeryConsultation.
  ///
  /// In en, this message translates to:
  /// **'Surgery Consultation'**
  String get surgeryConsultation;

  /// No description provided for @followUpCare.
  ///
  /// In en, this message translates to:
  /// **'Follow-up Care'**
  String get followUpCare;

  /// No description provided for @features_automotive_1.
  ///
  /// In en, this message translates to:
  /// **'Quality automotive parts'**
  String get features_automotive_1;

  /// No description provided for @features_automotive_2.
  ///
  /// In en, this message translates to:
  /// **'Professional technicians'**
  String get features_automotive_2;

  /// No description provided for @features_automotive_3.
  ///
  /// In en, this message translates to:
  /// **'Competitive pricing'**
  String get features_automotive_3;

  /// No description provided for @features_automotive_4.
  ///
  /// In en, this message translates to:
  /// **'Warranty on all parts'**
  String get features_automotive_4;

  /// No description provided for @features_automotive_5.
  ///
  /// In en, this message translates to:
  /// **'24/7 emergency support'**
  String get features_automotive_5;

  /// No description provided for @features_second_opinion_1.
  ///
  /// In en, this message translates to:
  /// **'Experienced specialists'**
  String get features_second_opinion_1;

  /// No description provided for @features_second_opinion_2.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive medical review'**
  String get features_second_opinion_2;

  /// No description provided for @features_second_opinion_3.
  ///
  /// In en, this message translates to:
  /// **'Quick response time'**
  String get features_second_opinion_3;

  /// No description provided for @features_second_opinion_4.
  ///
  /// In en, this message translates to:
  /// **'Detailed medical reports'**
  String get features_second_opinion_4;

  /// No description provided for @features_second_opinion_5.
  ///
  /// In en, this message translates to:
  /// **'Follow-up consultations'**
  String get features_second_opinion_5;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @oilChangeService.
  ///
  /// In en, this message translates to:
  /// **'Oil Change Service'**
  String get oilChangeService;

  /// No description provided for @oilChangeDesc.
  ///
  /// In en, this message translates to:
  /// **'Professional oil change service with high-quality oils and filters'**
  String get oilChangeDesc;

  /// No description provided for @tireServiceDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete tire services including rotation, balancing, and replacement'**
  String get tireServiceDesc;

  /// No description provided for @batteryServiceDesc.
  ///
  /// In en, this message translates to:
  /// **'Battery testing, charging, and replacement services'**
  String get batteryServiceDesc;

  /// No description provided for @brakeServiceDesc.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive brake system inspection and repair'**
  String get brakeServiceDesc;

  /// No description provided for @filterServiceDesc.
  ///
  /// In en, this message translates to:
  /// **'Air, oil, and fuel filter replacement services'**
  String get filterServiceDesc;

  /// No description provided for @loadServicesError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load services. Tap to retry.'**
  String get loadServicesError;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @comparePlans.
  ///
  /// In en, this message translates to:
  /// **'Compare plans'**
  String get comparePlans;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @save20.
  ///
  /// In en, this message translates to:
  /// **'Save 20%'**
  String get save20;

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most popular'**
  String get mostPopular;

  /// No description provided for @billedMonthly.
  ///
  /// In en, this message translates to:
  /// **'Billed monthly'**
  String get billedMonthly;

  /// No description provided for @billedYearly.
  ///
  /// In en, this message translates to:
  /// **'Billed yearly'**
  String get billedYearly;

  /// No description provided for @saveEstimated.
  ///
  /// In en, this message translates to:
  /// **'Save more with yearly billing'**
  String get saveEstimated;

  /// No description provided for @unknownPlan.
  ///
  /// In en, this message translates to:
  /// **'Unknown Plan'**
  String get unknownPlan;

  /// No description provided for @planComparison.
  ///
  /// In en, this message translates to:
  /// **'Plan comparison'**
  String get planComparison;

  /// No description provided for @feature.
  ///
  /// In en, this message translates to:
  /// **'Feature'**
  String get feature;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @roadsideAssistance.
  ///
  /// In en, this message translates to:
  /// **'Roadside Assistance'**
  String get roadsideAssistance;

  /// No description provided for @homecareServices.
  ///
  /// In en, this message translates to:
  /// **'Homecare Services'**
  String get homecareServices;

  /// No description provided for @healthAndBeauty.
  ///
  /// In en, this message translates to:
  /// **'Health and Beauty'**
  String get healthAndBeauty;

  /// No description provided for @entertainmentLeisure.
  ///
  /// In en, this message translates to:
  /// **'Entertainment & Leisure'**
  String get entertainmentLeisure;

  /// No description provided for @fashion.
  ///
  /// In en, this message translates to:
  /// **'Fashion'**
  String get fashion;

  /// No description provided for @restaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get restaurants;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @searchServices.
  ///
  /// In en, this message translates to:
  /// **'Search services...'**
  String get searchServices;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
