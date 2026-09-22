import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const BiorouteDriverApp());
}

class BiorouteDriverApp extends StatefulWidget {
  const BiorouteDriverApp({super.key});

  @override
  State<BiorouteDriverApp> createState() => _BiorouteDriverAppState();
}

class _BiorouteDriverAppState extends State<BiorouteDriverApp> {
  Locale _currentLocale = const Locale('ta'); // Default to Tamil

  void _setLocale(Locale locale) {
    setState(() {
      _currentLocale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bioroute',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF14281D),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF93C572),
          surface: Color(0xFF1C3829),
        ),
        fontFamily: 'Roboto',
      ),
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
  double _temp = 4.0;
  double _rh = 85.0;
  double _eth = 0.5;
  double _amm = 2.0;
  bool _isOfflineDarkzone = false;

  final Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'title': 'Bioroute Driver',
      'produce_condition': 'PRODUCE CONDITION',
      'safe_status': 'SAFE & FRESH',
      'warning_status': 'WARNING: RISKY',
      'critical_status': 'CRITICAL SPOILAGE',
      'route_safe': '✅ Primary Route: Koyambedu Mandi Chennai (ETA 6.0 hrs)',
      'route_diverted': '🚨 Diverted Route: Ranipet Processing Plant (ETA 2.0 hrs)',
      'sim_title': '🎛️ Live Sensor Simulation Sliders',
      'temp_lbl': 'Temperature',
      'rh_lbl': 'Humidity',
      'eth_lbl': 'Ethylene Gas',
      'amm_lbl': 'Ammonia / VOC',
      'telemetry_title': '📡 Telemetry Metrics',
      'alert_title': '🚨 DYNAMIC REROUTE ALERT!',
      'alert_msg': 'Warning! Cargo quality is degrading. Dynamic A* Reroute initiated -> Diverting to Ranipet Processing Plant.',
      'btn_accept': 'Accept Reroute Navigation',
      'darkzone': '⚡ Darkzone Mode',
      'btn_ngo': '📞 Contact Food Recovery NGO',
      'btn_staff': '🍲 Log Staff Meals Dispatch',
    },
    'ta': {
      'title': 'பயோரூட் ஓட்டுநர்',
      'produce_condition': 'சரக்கு தரம் மற்றும் நிலை',
      'safe_status': 'பாதுகாப்பானது மற்றும் புதியது',
      'warning_status': 'எச்சரிக்கை: தரம் குறைகிறது',
      'critical_status': 'அவசர தரம் இழப்பு',
      'route_safe': '✅ முதன்மை பாதை: கோயம்பேடு சந்தை சென்னை (ETA 6.0 மணி)',
      'route_diverted': '🚨 மாற்றப்பட்ட பாதை: ராணிப்பேட்டை பதப்படுத்தும் மையம் (ETA 2.0 மணி)',
      'sim_title': '🎛️ நேரடி சென்சார் கட்டுப்பாடுகள்',
      'temp_lbl': 'வெப்பநிலை',
      'rh_lbl': 'ஈரப்பதம்',
      'eth_lbl': 'எத்திலீன் வாயு',
      'amm_lbl': 'அம்மோனியா வாயு',
      'telemetry_title': '📡 தொலைநிலை அளவீடுகள்',
      'alert_title': '🚨 அவசர பாதை மாற்ற எச்சரிக்கை!',
      'alert_msg': 'எச்சரிக்கை! சரக்கு தரம் குறைகிறது. ரானிப்பேட்டை பதப்படுத்தும் மையத்திற்கு பாதை மாற்றப்படுகிறது.',
      'btn_accept': 'புதிய பாதையை ஏற்றுக்கொள்',
      'darkzone': '⚡ இணையமில்லா நிலை',
      'btn_ngo': '📞 உணவு தொண்டு நிறுவனத்தை தொடர்பு கொள்',
      'btn_staff': '🍲 ஊழியர் உணவுகளை பதிவு செய்',
    },
    'ml': {
      'title': 'ബയോറൂട്ട് ഡ്രൈവർ',
      'produce_condition': 'ചരക്ക് ഗുണനിലവാരം',
      'safe_status': 'സുരക്ഷിതം & പുതിയത്',
      'warning_status': 'മുന്നറിയിപ്പ്: കുറയുന്നു',
      'critical_status': 'അടിയന്തര ഗുണനിലവാര തകർച്ച',
      'route_safe': '✅ പ്രധാന പാത: കോയമ്പേട് മാർക്കറ്റ് (ETA 6.0 മണിക്കൂർ)',
      'route_diverted': '🚨 മാറ്റിയ പാത: റാണിപ്പേട്ട പ്ലാന്റ് (ETA 2.0 മണിക്കൂർ)',
      'sim_title': '🎛️ സെൻസർ നിയന്ത്രണങ്ങൾ',
      'temp_lbl': 'താപനില',
      'rh_lbl': 'ആർദ്രത',
      'eth_lbl': 'എഥിലിൻ ഗ്യാസ്',
      'amm_lbl': 'അമോണിയ ഗ്യാസ്',
      'telemetry_title': '📡 ടെലിമെട്രി ഡാറ്റ',
      'alert_title': '🚨 റൂട്ട് മാറ്റ മുന്നറിയിപ്പ്!',
      'alert_msg': 'മുന്നറിയിപ്പ്! ചരക്ക് ഗുണനിലവാരം കുറയുന്നു. റാണിപ്പേട്ട പ്രോസസിംഗ് പ്ലാന്റിലേക്ക് റൂട്ട് മാറ്റുന്നു.',
      'btn_accept': 'പുതിയ റൂട്ട് സ്വീകരിക്കുക',
      'darkzone': '⚡ ഓഫ്‌ലൈൻ മോഡ്',
      'btn_ngo': '📞 എൻ‌ജി‌ഒ ഹെൽപ്പ് ലൈൻ വിളിക്കുക',
      'btn_staff': '🍲 ജീവനക്കാരുടെ ഭക്ഷണം ലോഗ് ചെയ്യുക',
    },
    'te': {
      'title': 'బయోరూట్ డ్రైవర్',
      'produce_condition': 'సరుకు నాణ్యత స్థితి',
      'safe_status': 'సురక్షితం & తాజాది',
      'warning_status': 'హెచ్చరిక: తగ్గుతోంది',
      'critical_status': 'క్లిష్టమైన నాణ్యత తగ్గింపు',
      'route_safe': '✅ ప్రాధమిక మార్గం: కోయంబేడు మార్కెట్ (ETA 6.0 గంటలు)',
      'route_diverted': '🚨 మళ్లించిన మార్గం: రాణిపేట ప్లాంట్ (ETA 2.0 గంటలు)',
      'sim_title': '🎛️ సెన్సార్ కంట్రోల్స్',
      'temp_lbl': 'ఉష్ణోగ్రత',
      'rh_lbl': 'తేమ',
      'eth_lbl': 'ఇథిలీన్ గ్యాస్',
      'amm_lbl': 'అమ్మోనియా గ్యాస్',
      'telemetry_title': '📡 టెలిమెట్రీ డేటా',
      'alert_title': '🚨 మార్గం మళ్లింపు హెచ్చరిక!',
      'alert_msg': 'హెచ్చరిక! సరుకు నాణ్యత తగ్గుతోంది. రాణిపేట ప్రాసెసింగ్ సెంటర్‌కు మార్గం మళ్లించబడుతోంది.',
      'btn_accept': 'కొత్త మార్గాన్ని అంగీకరించు',
      'darkzone': '⚡ ఆఫ్‌లైన్ మోడ్',
      'btn_ngo': '📞 ఆహార సహాయక సంస్థకు కాల్ చేయండి',
      'btn_staff': '🍲 స్టాఫ్ భోజన నమోదు',
    },
    'kn': {
      'title': 'ಬಯೋರೂಟ್ ಚಾಲಕ',
      'produce_condition': 'ಸರಕಿನ ಗುಣಮಟ್ಟ ಸ್ಥಿತಿ',
      'safe_status': 'ಸುರಕ್ಷಿತ ಮತ್ತು ತಾಜಾ',
      'warning_status': 'ಎಚ್ಚರಿಕೆ: ಕುಸಿಯುತ್ತಿದೆ',
      'critical_status': 'ತುರ್ತು ಗುಣಮಟ್ಟದ ಕುಸಿತ',
      'route_safe': '✅ ಪ್ರಾಥಮಿಕ ಮಾರ್ಗ: ಕೊಯಂಬೇಡು ಮಾರುಕಟ್ಟೆ (ETA 6.0 ಗಂಟೆ)',
      'route_diverted': '🚨 ಬದಲಾಯಿಸಿದ ಮಾರ್ಗ: ರಾಣಿಪೇಟೆ ಘಟಕ (ETA 2.0 ಗಂಟೆ)',
      'sim_title': '🎛️ ಸೆನ್ಸರ್ ನಿಯಂತ್ರಣಗಳು',
      'temp_lbl': 'ತಾಪಮಾನ',
      'rh_lbl': 'ಆರ್ದ್ರತೆ',
      'eth_lbl': 'ಎಥಿಲಿನ್ ಅನಿಲ',
      'amm_lbl': 'ಅಮೋನಿಯಾ ಅನಿಲ',
      'telemetry_title': '📡 ಟೆಲಿಮೆಟ್ರಿ ಮಾಹಿತಿ',
      'alert_title': '🚨 ಮಾರ್ಗ ಬದಲಾವಣೆ ಎಚ್ಚರಿಕೆ!',
      'alert_msg': 'ಎಚ್ಚರಿಕೆ! ಸರಕಿನ ಗುಣಮಟ್ಟ ಕುಸಿಯುತ್ತಿದೆ. ರಾಣಿಪೇಟೆ ಸಂಸ್ಕರಣಾ ಘಟಕಕ್ಕೆ ಮಾರ್ಗ ಬದಲಾಯಿಸಲಾಗುತ್ತಿದೆ.',
      'btn_accept': 'ಹೊಸ ಮಾರ್ಗ ಸ್ವೀಕರಿಸಿ',
      'darkzone': '⚡ ಆಫ್‌ಲೈನ್ ಮೋಡ್',
      'btn_ngo': '📞 ಆಹಾರ ಸಂಸ್ಥೆ ಸಂಪರ್ಕಿಸಿ',
      'btn_staff': '🍲 ಸಿಬ್ಬಂದಿ ಊಟದ ದಾಖಲೆ',
    },
    'hi': {
      'title': 'बायोरूट ड्राइवर',
      'produce_condition': 'कार्गो गुणवत्ता स्थिति',
      'safe_status': 'सुरक्षित और ताजा',
      'warning_status': 'चेतावनी: गिरावट',
      'critical_status': 'आपातकालीन गुणवत्ता गिरावट',
      'route_safe': '✅ प्राथमिक मार्ग: कोयंबेडु मंडी (ETA 6.0 घंटे)',
      'route_diverted': '🚨 परिवर्तित मार्ग: रानीपेट प्लांट (ETA 2.0 घंटे)',
      'sim_title': '🎛️ लाइव सेंसर कंट्रोल',
      'temp_lbl': 'तापमान',
      'rh_lbl': 'आर्द्रता',
      'eth_lbl': 'इथाइलीन गैस',
      'amm_lbl': 'अमोनिया गैस',
      'telemetry_title': '📡 टेलीमेट्री डेटा',
      'alert_title': '🚨 मार्ग परिवर्तन चेतावनी!',
      'alert_msg': 'चेतावनी! कार्गो गुणवत्ता घट रही है। रानीपेट प्रोसेसिंग प्लांट की ओर मार्ग परिवर्तित किया जा रहा है।',
      'btn_accept': 'नया मार्ग स्वीकार करें',
      'darkzone': '⚡ ऑफलाइन मोड',
      'btn_ngo': '📞 एनजीओ को कॉल करें',
      'btn_staff': '🍲 स्टाफ मील दर्ज करें',
    }
  };
  };

  Map<String, dynamic> _calculateKinetics() {
    double ea = 52000.0, r = 8.314;
    double refT = 277.15, currT = _temp + 273.15;
    double kThermal = currT > refT ? math.exp((ea / r) * ((1.0 / refT) - (1.0 / currT))) : 1.0;
    double kEth = _eth > 5.0 ? 1.0 + (_eth - 5.0) * 0.12 : 1.0;
    double kAmm = _amm > 10.0 ? 1.0 + (_amm - 10.0) * 0.08 : 1.0;
    double kRh = 1.0 + ((_rh - 85.0).abs() * 0.005);

    double decayIndex = kThermal * kEth * kAmm * kRh;
    double rsl = 24.0 / decayIndex;

    String status = "SAFE";
    if (rsl < 6.0) {
      status = "CRITICAL";
    } else if (rsl < 12.0) {
      status = "WARNING";
    }

    return {"rsl": rsl, "status": status, "isDiverted": rsl < 6.0};
  }

  @override
  Widget build(BuildContext context) {
    String lang = widget.currentLocale.languageCode;
    Map<String, String> strings = _localizedStrings[lang] ?? _localizedStrings['en']!;
    Map<String, dynamic> kinetics = _calculateKinetics();
    double rsl = kinetics['rsl'];
    String status = kinetics['status'];
    bool isDiverted = kinetics['isDiverted'];

    Color statusColor = status == "SAFE"
        ? const Color(0xFF81C784)
        : (status == "WARNING" ? const Color(0xFFFFB74D) : const Color(0xFFE57373));

    String statusText = status == "SAFE"
        ? strings['safe_status']!
        : (status == "WARNING" ? strings['warning_status']! : strings['critical_status']!);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C3829),
        elevation: 4,
        title: Row(
          children: [
            const Text('🌱 ', style: TextStyle(fontSize: 22)),
            Text(
              strings['title']!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.white),
            ),
          ],
        ),
        actions: [
          DropdownButton<String>(
            value: widget.currentLocale.languageCode,
            dropdownColor: const Color(0xFF1C3829),
            icon: const Icon(Icons.language, color: Color(0xFF93C572)),
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'ta', child: Text('தமிழ்')),
              DropdownMenuItem(value: 'ml', child: Text('മലയാളം')),
              DropdownMenuItem(value: 'te', child: Text('తెలుగు')),
              DropdownMenuItem(value: 'kn', child: Text('ಕನ್ನಡ')),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 4G/5G Darkzone Mode Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _isOfflineDarkzone ? Colors.amber.shade900 : const Color(0xFF1C3829),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF93C572).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(_isOfflineDarkzone ? Icons.wifi_off : Icons.sensors, color: const Color(0xFF93C572), size: 18),
                        const SizedBox(width: 8),
                        Text(strings['darkzone']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
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

              const SizedBox(height: 16),

              // ==============================================================
              // MAJOR SECTION: PRODUCE CONDITION & RSL DISPLAY
              // ==============================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C3829),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor, width: 2),
                  boxShadow: [
                    BoxShadow(color: statusColor.withOpacity(0.15), blurRadius: 16, spreadRadius: 2)
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      strings['produce_condition']!,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFACE1AF), letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      statusText,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.extrabold, color: statusColor),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "${rsl.toStringAsFixed(2)} HRS",
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: statusColor, fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 4),
                    const Text("Remaining Shelf Life (Baseline 24.0h @ 4°C)", style: TextStyle(fontSize: 11, color: Color(0xFFACE1AF))),
                    const SizedBox(height: 14),

                    // Quality Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (rsl / 24.0).clamp(0.0, 1.0),
                        minHeight: 10,
                        backgroundColor: Colors.black26,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==============================================================
              // MAP UI DISPLAY: ACTIVE HIGHWAY CORRIDOR & A* REROUTE
              // ==============================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C3829),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF93C572).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "🗺️ Highway Spatial Route Map",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                    ),
                    const SizedBox(height: 12),

                    // Map SVG/Canvas representation
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF14281D),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFACE1AF).withOpacity(0.2)),
                      ),
                      child: CustomPaint(
                        painter: MapPainter(isDiverted: isDiverted),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Route Status Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDiverted ? const Color(0xFFE57373).withOpacity(0.15) : const Color(0xFF81C784).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDiverted ? const Color(0xFFE57373) : const Color(0xFF81C784)),
                      ),
                      child: Text(
                        isDiverted ? strings['route_diverted']! : strings['route_safe']!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDiverted ? const Color(0xFFE57373) : const Color(0xFF81C784),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    if (isDiverted) ...[
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE57373),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${strings['btn_accept']} - Active!"),
                              backgroundColor: const Color(0xFF1C3829),
                            ),
                          );
                        },
                        icon: const Icon(Icons.navigation),
                        label: Text(strings['btn_accept']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],

                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: const Color(0xFF93C572).withOpacity(0.5)),
                              foregroundColor: const Color(0xFFACE1AF),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${strings['btn_ngo']} - Connected!"),
                                  backgroundColor: const Color(0xFF1C3829),
                                ),
                              );
                            },
                            child: Text(strings['btn_ngo']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: const Color(0xFF93C572).withOpacity(0.5)),
                              foregroundColor: const Color(0xFFACE1AF),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${strings['btn_staff']} - Logged!"),
                                  backgroundColor: const Color(0xFF1C3829),
                                ),
                              );
                            },
                            child: Text(strings['btn_staff']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==============================================================
              // MINOR SECTION: TELEMETRY METRICS CARDS
              // ==============================================================
              Text(strings['telemetry_title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
              const SizedBox(height: 10),

              Row(
                children: [
                  _buildMetricTile(strings['temp_lbl']!, "${_temp.toStringAsFixed(1)} °C", Colors.orangeAccent),
                  const SizedBox(width: 8),
                  _buildMetricTile(strings['rh_lbl']!, "${_rh.toStringAsFixed(1)} %", const Color(0xFF81C784)),
                  const SizedBox(width: 8),
                  _buildMetricTile(strings['eth_lbl']!, "${_eth.toStringAsFixed(1)} ppm", Colors.amber),
                  const SizedBox(width: 8),
                  _buildMetricTile(strings['amm_lbl']!, "${_amm.toStringAsFixed(1)} ppm", Colors.redAccent),
                ],
              ),

              const SizedBox(height: 20),

              // ==============================================================
              // SIMULATION SLIDERS SECTION FOR LIVE DEMO
              // ==============================================================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C3829),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF93C572).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(strings['sim_title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                    const SizedBox(height: 12),

                    _buildSliderRow(strings['temp_lbl']!, _temp, 2.0, 40.0, "°C", (val) {
                      setState(() {
                        _temp = val;
                      });
                    }),
                    _buildSliderRow(strings['rh_lbl']!, _rh, 30.0, 95.0, "%", (val) {
                      setState(() {
                        _rh = val;
                      });
                    }),
                    _buildSliderRow(strings['eth_lbl']!, _eth, 0.0, 50.0, "ppm", (val) {
                      setState(() {
                        _eth = val;
                      });
                    }),
                    _buildSliderRow(strings['amm_lbl']!, _amm, 0.0, 100.0, "ppm", (val) {
                      setState(() {
                        _amm = val;
                      });
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1C3829),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFACE1AF).withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFFACE1AF), fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderRow(String label, double val, double min, double max, String unit, Function(double) onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFFACE1AF), fontWeight: FontWeight.bold)),
            Text("${val.toStringAsFixed(1)} $unit", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFBAED91))),
          ],
        ),
        Slider(
          value: val,
          min: min,
          max: max,
          activeColor: const Color(0xFF93C572),
          inactiveColor: Colors.black38,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// Custom Painter for Map UI rendering
class MapPainter extends CustomPainter {
  final bool isDiverted;

  MapPainter({required this.isDiverted});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = const Color(0xFFACE1AF).withOpacity(0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Paint activePathPaint = Paint()
      ..color = isDiverted ? const Color(0xFFE57373) : const Color(0xFF81C784)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final Paint nodePaint = Paint()..style = PaintingStyle.fill;

    // Node Positions
    final Offset nodeA = Offset(size.width * 0.1, size.height * 0.5);
    final Offset nodeB = Offset(size.width * 0.4, size.height * 0.3);
    final Offset nodeC = Offset(size.width * 0.65, size.height * 0.2);
    final Offset nodeD = Offset(size.width * 0.88, size.height * 0.7);

    // Draw background dashed corridor edges
    canvas.drawLine(nodeA, nodeB, linePaint);
    canvas.drawLine(nodeB, nodeD, linePaint);
    canvas.drawLine(nodeB, nodeC, linePaint);

    // Draw active dynamic route
    Path path = Path();
    path.moveTo(nodeA.dx, nodeA.dy);
    path.lineTo(nodeB.dx, nodeB.dy);

    if (isDiverted) {
      path.lineTo(nodeC.dx, nodeC.dy);
    } else {
      path.lineTo(nodeD.dx, nodeD.dy);
    }
    canvas.drawPath(path, activePathPaint);

    // Draw Node Markers
    nodePaint.color = const Color(0xFFD4B296);
    canvas.drawCircle(nodeA, 8, nodePaint);

    nodePaint.color = const Color(0xFF93C572);
    canvas.drawCircle(nodeB, 7, nodePaint);

    nodePaint.color = isDiverted ? const Color(0xFFE57373) : const Color(0xFFD4B296);
    canvas.drawCircle(nodeC, 8, nodePaint);

    nodePaint.color = isDiverted ? const Color(0xFFD4B296) : const Color(0xFF81C784);
    canvas.drawCircle(nodeD, 8, nodePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
