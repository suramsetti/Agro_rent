import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'Agro-Rent',
      'login': 'Login',
      'register': 'Register',
      'phoneNumber': 'Phone Number',
      'sendOtp': 'Send OTP',
      'verifyOtp': 'Verify OTP',
      'machinery': 'Machinery',
      'supplies': 'Supplies',
      'tracking': 'Tracking',
      'profile': 'Profile',
      'logout': 'Logout',
      'buyer': 'Buyer',
      'seller': 'Seller',
      'renter': 'Renter',
      'owner': 'Owner',
      'myListings': 'My Listings',
      'addMachine': 'Add Machine',
      'addItem': 'Add Item',
      'myMachines': 'My Machines',
      'myItems': 'My Items',
      'bookings': 'Bookings',
      'orders': 'Orders',
      'language': 'Language',
      'selectLanguage': 'Select Language',
    },
    'hi': {
      'appName': 'एग्रो-रेंट',
      'login': 'लॉगिन',
      'register': 'रजिस्टर',
      'phoneNumber': 'फोन नंबर',
      'sendOtp': 'OTP भेजें',
      'verifyOtp': 'OTP सत्यापित करें',
      'machinery': 'मशीनरी',
      'supplies': 'सामग्री',
      'tracking': 'ट्रैकिंग',
      'profile': 'प्रोफ़ाइल',
      'logout': 'लॉगआउट',
      'buyer': 'खरीदार',
      'seller': 'विक्रेता',
      'renter': 'किरायेदार',
      'owner': 'मालिक',
      'myListings': 'मेरी सूची',
      'addMachine': 'मशीन जोड़ें',
      'addItem': 'आइटम जोड़ें',
      'myMachines': 'मेरी मशीनें',
      'myItems': 'मेरे आइटम',
      'bookings': 'बुकिंग',
      'orders': 'ऑर्डर',
      'language': 'भाषा',
      'selectLanguage': 'भाषा चुनें',
    },
    'te': {
      'appName': 'ఎగ్రో-రెంట్',
      'login': 'లాగిన్',
      'register': 'నమోదు',
      'phoneNumber': 'ఫోన్ నంబర్',
      'sendOtp': 'OTP పంపండి',
      'verifyOtp': 'OTP ధృవీకరించండి',
      'machinery': 'యంత్రాలు',
      'supplies': 'సరఫరాలు',
      'tracking': 'ట్రాకింగ్',
      'profile': 'ప్రొఫైల్',
      'logout': 'లాగ్అవుట్',
      'buyer': 'కొనుగోలుదారు',
      'seller': 'విక్రేత',
      'renter': 'అద్దెదారు',
      'owner': 'యజమాని',
      'myListings': 'నా జాబితాలు',
      'addMachine': 'యంత్రం జోడించండి',
      'addItem': 'ఐటెమ్ జోడించండి',
      'myMachines': 'నా యంత్రాలు',
      'myItems': 'నా ఐటెమ్లు',
      'bookings': 'బుకింగ్',
      'orders': 'ఆర్డర్లు',
      'language': 'భాష',
      'selectLanguage': 'భాష ఎంచుకోండి',
    },
    'ta': {
      'appName': 'அக்ரோ-ரெண்ட்',
      'login': 'உள்நுழை',
      'register': 'பதிவு',
      'phoneNumber': 'தொலைபேசி எண்',
      'sendOtp': 'OTP அனுப்ப',
      'verifyOtp': 'OTP சரிபார்க்க',
      'machinery': 'இயந்திரங்கள்',
      'supplies': 'வழங்கல்கள்',
      'tracking': 'கண்காணிப்பு',
      'profile': 'சுயவிவரம்',
      'logout': 'வெளியேற',
      'buyer': 'வாங்குபவர்',
      'seller': 'விற்பனையாளர்',
      'renter': 'வாடகைதாரர்',
      'owner': 'உரிமையாளர்',
      'myListings': 'எனது பட்டியல்கள்',
      'addMachine': 'இயந்திரம் சேர்',
      'addItem': 'உருப்படி சேர்',
      'myMachines': 'எனது இயந்திரங்கள்',
      'myItems': 'எனது உருப்படிகள்',
      'bookings': 'முன்பதிவு',
      'orders': 'ஆர்டர்கள்',
      'language': 'மொழி',
      'selectLanguage': 'மொழியைத் தேர்ந்தெடுக்கவும்',
    },
    'kn': {
      'appName': 'ಎಗ್ರೋ-ರೆಂಟ್',
      'login': 'ಲಾಗಿನ್',
      'register': 'ನೋಂದಣಿ',
      'phoneNumber': 'ಫೋನ್ ಸಂಖ್ಯೆ',
      'sendOtp': 'OTP ಕಳುಹಿಸಿ',
      'verifyOtp': 'OTP ಪರಿಶೀಲಿಸಿ',
      'machinery': 'ಯಂತ್ರಗಳು',
      'supplies': 'ಸರಬರಾಜು',
      'tracking': 'ಟ್ರ್ಯಾಕಿಂಗ್',
      'profile': 'ಪ್ರೊಫೈಲ್',
      'logout': 'ಲಾಗ್ ಔಟ್',
      'buyer': 'ಖರೀದಿದಾರ',
      'seller': 'ವಿಕ್ರೇತ',
      'renter': 'ಬಾಡಿಗೆದಾರ',
      'owner': 'ಮಾಲೀಕ',
      'myListings': 'ನನ್ನ ಪಟ್ಟಿಗಳು',
      'addMachine': 'ಯಂತ್ರ ಸೇರಿಸಿ',
      'addItem': 'ಐಟಂ ಸೇರಿಸಿ',
      'myMachines': 'ನನ್ನ ಯಂತ್ರಗಳು',
      'myItems': 'ನನ್ನ ಐಟಂಗಳು',
      'bookings': 'ಬುಕಿಂಗ್',
      'orders': 'ಆರ್ಡರ್ಗಳು',
      'language': 'ಭಾಷೆ',
      'selectLanguage': 'ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ',
    },
    'ml': {
      'appName': 'എഗ്രോ-റെന്റ്',
      'login': 'ലോഗിൻ',
      'register': 'രജിസ്റ്റർ',
      'phoneNumber': 'ഫോൺ നമ്പർ',
      'sendOtp': 'OTP അയയ്ക്കുക',
      'verifyOtp': 'OTP പരിശോധിക്കുക',
      'machinery': 'യന്ത്രങ്ങൾ',
      'supplies': 'വിതരണം',
      'tracking': 'ട്രാക്കിംഗ്',
      'profile': 'പ്രൊഫൈൽ',
      'logout': 'ലോഗൗട്ട്',
      'buyer': 'വാങ്ങുന്നയാൾ',
      'seller': 'വിൽപ്പനക്കാരൻ',
      'renter': 'വാടകക്കാരൻ',
      'owner': 'ഉടമ',
      'myListings': 'എന്റെ പട്ടികകൾ',
      'addMachine': 'യന്ത്രം ചേർക്കുക',
      'addItem': 'ഇനം ചേർക്കുക',
      'myMachines': 'എന്റെ യന്ത്രങ്ങൾ',
      'myItems': 'എന്റെ ഇനങ്ങൾ',
      'bookings': 'ബുക്കിംഗ്',
      'orders': 'ഓർഡറുകൾ',
      'language': 'ഭാഷ',
      'selectLanguage': 'ഭാഷ തിരഞ്ഞെടുക്കുക',
    },
    'bn': {
      'appName': 'এগ্রো-রেন্ট',
      'login': 'লগইন',
      'register': 'নিবন্ধন',
      'phoneNumber': 'ফোন নম্বর',
      'sendOtp': 'OTP পাঠান',
      'verifyOtp': 'OTP যাচাই করুন',
      'machinery': 'যন্ত্রপাতি',
      'supplies': 'সরবরাহ',
      'tracking': 'ট্র্যাকিং',
      'profile': 'প্রোফাইল',
      'logout': 'লগআউট',
      'buyer': 'ক্রেতা',
      'seller': 'বিক্রেতা',
      'renter': 'ভাড়াটে',
      'owner': 'মালিক',
      'myListings': 'আমার তালিকা',
      'addMachine': 'যন্ত্র যোগ করুন',
      'addItem': 'আইটেম যোগ করুন',
      'myMachines': 'আমার যন্ত্র',
      'myItems': 'আমার আইটেম',
      'bookings': 'বুকিং',
      'orders': 'অর্ডার',
      'language': 'ভাষা',
      'selectLanguage': 'ভাষা নির্বাচন করুন',
    },
    'gu': {
      'appName': 'એગ્રો-રેન્ટ',
      'login': 'લોગઇન',
      'register': 'નોંધણી',
      'phoneNumber': 'ફોન નંબર',
      'sendOtp': 'OTP મોકલો',
      'verifyOtp': 'OTP ચકાસો',
      'machinery': 'મશીનરી',
      'supplies': 'સપ્લાય',
      'tracking': 'ટ્રેકિંગ',
      'profile': 'પ્રોફાઇલ',
      'logout': 'લોગઆઉટ',
      'buyer': 'ખરીદદાર',
      'seller': 'વિક્રેતા',
      'renter': 'ભાડુઆત',
      'owner': 'માલિક',
      'myListings': 'મારી યાદી',
      'addMachine': 'મશીન ઉમેરો',
      'addItem': 'આઇટમ ઉમેરો',
      'myMachines': 'મારી મશીનો',
      'myItems': 'મારી આઇટમ્સ',
      'bookings': 'બુકિંગ',
      'orders': 'ઓર્ડર',
      'language': 'ભાષા',
      'selectLanguage': 'ભાષા પસંદ કરો',
    },
    'mr': {
      'appName': 'एग्रो-रेंट',
      'login': 'लॉगिन',
      'register': 'नोंदणी',
      'phoneNumber': 'फोन नंबर',
      'sendOtp': 'OTP पाठवा',
      'verifyOtp': 'OTP सत्यापित करा',
      'machinery': 'यंत्रसामग्री',
      'supplies': 'पुरवठा',
      'tracking': 'ट्रॅकिंग',
      'profile': 'प्रोफाइल',
      'logout': 'लॉगआउट',
      'buyer': 'खरेदीदार',
      'seller': 'विक्रेता',
      'renter': 'भाडेकरू',
      'owner': 'मालक',
      'myListings': 'माझी यादी',
      'addMachine': 'यंत्र जोडा',
      'addItem': 'आयटम जोडा',
      'myMachines': 'माझी यंत्रे',
      'myItems': 'माझी आयटम्स',
      'bookings': 'बुकिंग',
      'orders': 'ऑर्डर',
      'language': 'भाषा',
      'selectLanguage': 'भाषा निवडा',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? 
           _localizedValues['en']?[key] ?? key;
  }

  // Getters for common translations
  String get appName => translate('appName');
  String get login => translate('login');
  String get register => translate('register');
  String get phoneNumber => translate('phoneNumber');
  String get sendOtp => translate('sendOtp');
  String get verifyOtp => translate('verifyOtp');
  String get machinery => translate('machinery');
  String get supplies => translate('supplies');
  String get tracking => translate('tracking');
  String get profile => translate('profile');
  String get logout => translate('logout');
  String get buyer => translate('buyer');
  String get seller => translate('seller');
  String get renter => translate('renter');
  String get owner => translate('owner');
  String get myListings => translate('myListings');
  String get addMachine => translate('addMachine');
  String get addItem => translate('addItem');
  String get myMachines => translate('myMachines');
  String get myItems => translate('myItems');
  String get bookings => translate('bookings');
  String get orders => translate('orders');
  String get language => translate('language');
  String get selectLanguage => translate('selectLanguage');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'te', 'ta', 'kn', 'ml', 'bn', 'gu', 'mr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

