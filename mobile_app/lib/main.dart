import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:bioroute_driver_app/services/offline_storage.dart';

void main() {
  runApp(const BiorouteDriverApp());
}

class BiorouteDriverApp extends StatefulWidget {
  const BiorouteDriverApp({super.key});

  @override
  State<BiorouteDriverApp> createState() => _BiorouteDriverAppState();
}

class _BiorouteDriverAppState extends State<BiorouteDriverApp> {
  Locale _currentLocale = const Locale('ta'); // Default to Tamil (TN Corridor)

  void _setLocale(Locale locale) {
    setState(() {
      _currentLocale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bioroute Driver App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF14281D),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF93C572),
          surface: Color(0xFF1C3829),
        ),
      ),
      locale: _currentLocale,
      supportedLocales: const [
        Locale('ta'), // Tamil
        Locale('ml'), // Malayalam
        Locale('te'), // Telugu
        Locale('kn'), // Kannada
        Locale('hi'), // Hindi
        Locale('en'), // English
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: DriverNavigationScreen(
        currentLocale: _currentLocale,
        onLocaleChanged: _setLocale,
      ),
    );
  }
}

class DriverNavigationScreen extends StatefulWidget {
  final Locale currentLocale;
  final Function(Locale) onLocaleChanged;

  const DriverNavigationScreen({
    super.key,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  @override
  State<DriverNavigationScreen> createState() => _DriverNavigationScreenState();
}

class _DriverNavigationScreenState extends State<DriverNavigationScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isRerouted = false;
  double _cargoTemp = 4.0;
  double _rslHours = 24.0;
  bool _isOfflineDarkzone = false;

  final Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'title': 'Bioroute Driver Navigation',
      'route_safe': '✅ Primary Path: Koyambedu Mandi Chennai (ETA 6.0 hrs)',
      'route_diverted': '🚨 DIVERTED: Ranipet Processing Plant (ETA 2.0 hrs)',
      'alert_title': '🚨 DYNAMIC REROUTE ALERT!',
      'alert_msg': 'Warning! Cargo quality is degrading. Dynamic A* Reroute initiated -> Diverting to Ranipet Processing Plant.',
      'btn_accept': 'Accept Reroute Navigation',
      'darkzone': '⚡ 4G/5G Darkzone: Telemetry Cached Locally',
    },
    'ta': {
      'title': 'பயோரூட் ஓட்டுநர் வழிகாட்டி',
      'route_safe': '✅ முதன்மை பாதை: கோயம்பேடு சந்தை சென்னை (ETA 6.0 மணி)',
      'route_diverted': '🚨 மாற்றப்பட்ட பாதை: ராணிப்பேட்டை பதப்படுத்தும் மையம் (ETA 2.0 மணி)',
      'alert_title': '🚨 அவசர பாதை மாற்ற எச்சரிக்கை!',
      'alert_msg': 'எச்சரிக்கை! சரக்கு தரம் குறைகிறது. ரானிப்பேட்டை பதப்படுத்தும் மையத்திற்கு பாதை மாற்றப்படுகிறது.',
      'btn_accept': 'புதிய பாதையை ஏற்றுக்கொள்',
      'darkzone': '⚡ இணையம் இல்லை: தரவு உள்ளூரில் சேமிக்கப்பட்டது',
    },
    'ml': {
      'title': 'ബയോറൂട്ട് ഡ്രൈവർ നാവിഗേഷൻ',
      'route_safe': '✅ പ്രധാന പാത: കോയമ്പേട് മാർക്കറ്റ് ചെന്നൈ (ETA 6.0 മണിക്കൂർ)',
      'route_diverted': '🚨 മാറ്റിയ പാത: റാണിപ്പേട്ട പ്രോസസിംഗ് പ്ലാന്റ് (ETA 2.0 മണിക്കൂർ)',
      'alert_title': '🚨 റൂട്ട് മാറ്റ മുന്നറിയിപ്പ്!',
      'alert_msg': 'മുന്നറിയിപ്പ്! ചരക്ക് ഗുണനിലവാരം കുറയുന്നു. റാണിപ്പേട്ട പ്രോസസിംഗ് പ്ലാന്റിലേക്ക് റൂട്ട് മാറ്റുന്നു.',
      'btn_accept': 'പുതിയ റൂട്ട് സ്വീകരിക്കുക',
      'darkzone': '⚡ നെറ്റ്‌വർക്ക് ഇല്ല: വിവരങ്ങൾ പ്രാദേശികമായി സൂക്ഷിച്ചു',
    },
    'te': {
      'title': 'బయోరూట్ డ్రైవర్ నావిగేషన్',
      'route_safe': '✅ ప్రాధమిక మార్గం: కోయంబేడు మార్కెట్ చెన్నై (ETA 6.0 గంటలు)',
      'route_diverted': '🚨 మళ్లించిన మార్గం: రాణిపేట ప్రాసెసింగ్ ప్లాంట్ (ETA 2.0 గంటలు)',
      'alert_title': '🚨 మార్గం మళ్లింపు హెచ్చరిక!',
      'alert_msg': 'హెచ్చరిక! సరుకు నాణ్యత తగ్గుతోంది. రాణిపేట ప్రాసెసింగ్ సెంటర్‌కు మార్గం మళ్లించబడుతోంది.',
      'btn_accept': 'కొత్త మార్గాన్ని అంగీకరించు',
      'darkzone': '⚡ నెట్‌వర్క్ లేదు: డేటా స్థానికంగా సేవ్ చేయబడింది',
    },
    'kn': {
      'title': 'ಬಯೋರೂಟ್ ಚಾಲಕ ಮಾರ್ಗದರ್ಶನ',
      'route_safe': '✅ ಪ್ರಾಥಮಿಕ ಮಾರ್ಗ: ಕೊಯಂಬೇಡು ಮಾರುಕಟ್ಟೆ ಚೆನ್ನೈ (ETA 6.0 ಗಂಟೆ)',
      'route_diverted': '🚨 ಬದಲಾಯಿಸಿದ ಮಾರ್ಗ: ರಾಣಿಪೇಟೆ ಸಂಸ್ಕರಣಾ ಘಟಕ (ETA 2.0 ಗಂಟೆ)',
      'alert_title': '🚨 ಮಾರ್ಗ ಬದಲಾವಣೆ ಎಚ್ಚರಿಕೆ!',
      'alert_msg': 'ಎಚ್ಚರಿಕೆ! ಸರಕಿನ ಗುಣಮಟ್ಟ ಕುಸಿಯುತ್ತಿದೆ. ರಾಣಿಪೇಟೆ ಸಂಸ್ಕರಣಾ ಘಟಕಕ್ಕೆ ಮಾರ್ಗ ಬದಲಾಯಿಸಲಾಗುತ್ತಿದೆ.',
      'btn_accept': 'ಹೊಸ ಮಾರ್ಗ ಸ್ವೀಕರಿಸಿ',
      'darkzone': '⚡ ನೆಟ್‌ವರ್ಕ್ ಇಲ್ಲ: ಡೇಟಾವನ್ನು ಸ್ಥಳೀಯವಾಗಿ ಉಳಿಸಲಾಗಿದೆ',
    },
    'hi': {
      'title': 'बायोरूट ड्राइवर नेविगेशन',
      'route_safe': '✅ प्राथमिक मार्ग: कोयंबेडु मंडी चेन्नई (ETA 6.0 घंटे)',
      'route_diverted': '🚨 परिवर्तित मार्ग: रानीपेट प्रोसेसिंग प्लांट (ETA 2.0 घंटे)',
      'alert_title': '🚨 मार्ग परिवर्तन चेतावनी!',
      'alert_msg': 'चेतावनी! कार्गो गुणवत्ता घट रही है। रानीपेट प्रोसेसिंग प्लांट की ओर मार्ग परिवर्तित किया जा रहा है।',
      'btn_accept': 'नया मार्ग स्वीकार करें',
      'darkzone': '⚡ नेटवर्क अनुपलब्ध: डेटा स्थानीय रूप से सहेजा गया',
    }
  };

  @override
  void initState() {
    super.initState();
    _initTTS();
  }

  void _initTTS() async {
    await _flutterTts.setLanguage(widget.currentLocale.languageCode);
    await _flutterTts.setSpeechRate(0.45);
  }

  void _triggerVoiceAlert(String alertMessage) async {
    await _flutterTts.speak(alertMessage);
  }

  void _simulateThermalStress() {
    setState(() {
      _cargoTemp = 28.5;
      _rslHours = 4.85;
      _isRerouted = true;
    });

    // Cache telemetry locally in SQLite during darkzones
    OfflineStorageService.cacheTelemetry({
      'truck_id': 'TN-01-BIO-9921',
      'temperature_c': _cargoTemp,
      'humidity_percent': 85.0,
      'ethylene_ppm': 12.0,
      'ammonia_ppm': 15.0,
      'rsl_hours': _rslHours
    });

    String currentLang = widget.currentLocale.languageCode;
    String alertMsg = _localizedStrings[currentLang]?['alert_msg'] ?? '';
    _triggerVoiceAlert(alertMsg);

    _showRerouteModal();
  }

  void _showRerouteModal() {
    String lang = widget.currentLocale.languageCode;
    Map<String, String> strings = _localizedStrings[lang] ?? _localizedStrings['en']!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C3829),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            strings['alert_title']!,
            style: const TextStyle(color: Color(0xFFE57373), fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                strings['alert_msg']!,
                style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFFF2F9F1)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black25,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.thermostat, color: Color(0xFFE57373)),
                    const SizedBox(width: 8),
                    Text("RSL: ${_rslHours} hrs (< 6.0 hrs ETA)", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF93C572),
                foregroundColor: const Color(0xFF14281D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(strings['btn_accept']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String lang = widget.currentLocale.languageCode;
    Map<String, String> strings = _localizedStrings[lang] ?? _localizedStrings['en']!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C3829),
        title: Text(
          strings['title']!,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          DropdownButton<String>(
            value: widget.currentLocale.languageCode,
            dropdownColor: const Color(0xFF1C3829),
            icon: const Icon(Icons.language, color: Color(0xFF93C572)),
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'ta', child: Text('தமிழ் (TN)')),
              DropdownMenuItem(value: 'ml', child: Text('മലയാളം (KL)')),
              DropdownMenuItem(value: 'te', child: Text('తెలుగు (AP)')),
              DropdownMenuItem(value: 'kn', child: Text('ಕನ್ನಡ (KA)')),
              DropdownMenuItem(value: 'hi', child: Text('हिंदी')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (String? newLang) {
              if (newLang != null) {
                widget.onLocaleChanged(Locale(newLang));
              }
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // 4G/5G Darkzone Status Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: _isOfflineDarkzone ? Colors.amber.shade900 : const Color(0xFF1C3829),
            child: Row(
              children: [
                Icon(_isOfflineDarkzone ? Icons.wifi_off : Icons.sensors, size: 18, color: const Color(0xFF93C572)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isOfflineDarkzone ? strings['darkzone']! : "Connected to Bioroute Telemetry Mesh",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Switch(
                  value: _isOfflineDarkzone,
                  activeColor: const Color(0xFF93C572),
                  onChanged: (val) {
                    setState(() {
                      _isOfflineDarkzone = val;
                    });
                  },
                )
              ],
            ),
          ),

          // Mapbox Vector Navigation Canvas Placeholder
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: const Color(0xFF183023),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.navigation_outlined, size: 64, color: Color(0xFF93C572)),
                        const SizedBox(height: 12),
                        Text(
                          _isRerouted ? strings['route_diverted']! : strings['route_safe']!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _isRerouted ? const Color(0xFFE57373) : const Color(0xFF81C784),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                // Floating Telemetry & Simulation Action
                Positioned(
                  bottom: 24,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C3829).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF93C572).withOpacity(0.4)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Cargo Temp: ${_cargoTemp.toStringAsFixed(1)}°C"),
                            Text("RSL: ${_rslHours.toStringAsFixed(2)} hrs", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFBAED91))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF93C572),
                            foregroundColor: const Color(0xFF14281D),
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.warning_amber_rounded),
                          label: const Text("Simulate Spoilage & Voice Reroute", style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: _simulateThermalStress,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
