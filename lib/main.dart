import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:lottie/lottie.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Meeting());
  }
}
class Meeting extends StatefulWidget {
  @override
  _MeetingState createState() => _MeetingState();
}

class _MeetingState extends State<Meeting> {
  final serverText = TextEditingController();
  final roomText = TextEditingController(text: "");
  final subjectText = TextEditingController(text: "");
  final nameText = TextEditingController(text: "");
  final emailText = TextEditingController(text: "fake@email.com");
  final iosAppBarRGBAColor =
  TextEditingController(text: "#0080FF80"); //transparent blue
  bool? isAudioOnly = false;
  bool isAudioMuted = false;
  bool isVideoMuted = false;

  @override
  void initState() {
    super.initState();
    JitsiMeet.addListener(JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onError: _onError));
  }

  @override
  void dispose() {
    super.dispose();
    JitsiMeet.removeAllListeners();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.white,
              systemNavigationBarColor: Colors.white,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.dark,
            ),
        ),
        primarySwatch: createColor(Colors.indigo),
        accentColor: Colors.indigo,
        backgroundColor: Colors.white
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.black,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.light,
            ),
        ),
        accentColor: Colors.indigoAccent,
        primarySwatch: createColor(Colors.indigo.shade900.withOpacity(.75)),
        backgroundColor: Colors.black
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 0,
        ),
        body: Builder(
          builder: (context)=> Container(
            color: Theme.of(context).backgroundColor,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            child: kIsWeb
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: width * 0.30,
                  child: meetConfig(context),
                ),
                Container(
                    width: width * 0.60,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                          color: Colors.white54,
                          child: SizedBox(
                            width: width * 0.60 * 0.70,
                            height: width * 0.60 * 0.70,
                            child: JitsiMeetConferencing(
                              extraJS: const [
                                // extraJs setup example
                                '<script>function echo(){console.log("echo!!!")};</script>',
                                '<script src="https://code.jquery.com/jquery-3.5.1.slim.js" integrity="sha256-DrT5NfxfbHvMHux31Lkhxg42LY6of8TaYyK50jnxRnM=" crossorigin="anonymous"></script>'
                              ],
                            ),
                          )),
                    ))
              ],
            )
                : meetConfig(context),
          ),
        )
      ),
    );
  }

  Widget meetConfig(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 44.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Meeting', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600)),
              Text('PRO', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Theme.of(context).accentColor))
            ],
          ),
          const SizedBox(
            height: 24.0,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Row(
              children: [
                Spacer(),
                Expanded(
                  flex: 10,
                  child: Lottie.asset( 'assets/json/home.json' )
                ),
                Spacer(),
              ],
            ),
          ),
          const SizedBox(
            height: 24.0,
          ),
          Container(
            margin: const EdgeInsetsDirectional.only(bottom: 20),
            child: TextField(
              maxLines: 1,
              controller: nameText,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                filled: true,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide.none,
                ),
                floatingLabelBehavior:  FloatingLabelBehavior.never,
                hintText: 'Display Name',
              ),
            ),
          ),
          const SizedBox(
            height: 14.0,
          ),
          Container(
            margin: const EdgeInsetsDirectional.only(bottom: 20),
            child: TextField(
              maxLines: 1,
              controller: roomText,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                filled: true,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide.none,
                ),
                floatingLabelBehavior:  FloatingLabelBehavior.never,
                hintText: 'Invite Link',
              ),
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          Hero(
            tag: "join_btn",
            child: ElevatedButton(
              onPressed:() {
                _joinMeeting();
              },
              style: ElevatedButton.styleFrom(
                elevation: 3,
                shape: const StadiumBorder(),
                maximumSize: const Size(double.infinity, 56),
                minimumSize: const Size(double.infinity, 56),
              ),
              child: Text(
                "Join Meeting", style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          ElevatedButton(
            onPressed:(){
              roomText.text = const Uuid().v1().toString().substring(0, 18).toUpperCase();
              _joinMeeting();
            },
            style: ElevatedButton.styleFrom(
              elevation: 3,
              shape: const StadiumBorder(),
              maximumSize: const Size(double.infinity, 56),
              minimumSize: const Size(double.infinity, 56),
            ),
            child: Text(
              "Create Meeting", style: TextStyle(color: Colors.white),
            ),
          ),

        ],
      ),
    );
  }

  _onAudioOnlyChanged(bool? value) {
    setState(() {
      isAudioOnly = value;
    });
  }

  _onAudioMutedChanged(bool value) {

  }

  _onVideoMutedChanged(bool value) {
    setState(() {
      isVideoMuted = value;
    });
  }

  _joinMeeting() async {
    String? serverUrl = serverText.text.trim().isEmpty ? null : serverText.text;

    // Enable or disable any feature flag here
    // If feature flag are not provided, default values will be used
    // Full list of feature flags (and defaults) available in the README
    Map<FeatureFlagEnum, bool> featureFlags = {
      FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
    };
    if (!kIsWeb) {
      // Here is an example, disabling features for each platform
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
      }
    }
    // Define meetings options here
    var options = JitsiMeetingOptions(room: roomText.text)
      ..serverURL = serverUrl
      ..subject = roomText.text
      ..userDisplayName = nameText.text
      ..userEmail = emailText.text
      ..iosAppBarRGBAColor = iosAppBarRGBAColor.text
      ..audioMuted = isAudioMuted
      ..videoMuted = isVideoMuted
      ..featureFlags.addAll(featureFlags)
      ..webOptions = {
        "roomName": roomText.text,
        "width": "100%",
        "height": "100%",
        "enableWelcomePage": false,
        "chromeExtensionBanner": null,
        "userInfo": {"displayName": nameText.text}
      };

    debugPrint("JitsiMeetingOptions: $options");
    await JitsiMeet.joinMeeting(
      options,
      listener: JitsiMeetingListener(
          onConferenceWillJoin: (message) {
            debugPrint("${options.room} will join with message: $message");
          },
          onConferenceJoined: (message) {
            debugPrint("${options.room} joined with message: $message");
          },
          onConferenceTerminated: (message) {
            debugPrint("${options.room} terminated with message: $message");
          },
          genericListeners: [
            JitsiGenericListener(
                eventName: 'readyToClose',
                callback: (dynamic message) {
                  debugPrint("readyToClose callback");
                }),
          ]),
    );
  }

  void _onConferenceWillJoin(message) {
    debugPrint("_onConferenceWillJoin broadcasted with message: $message");
  }

  void _onConferenceJoined(message) {
    debugPrint("_onConferenceJoined broadcasted with message: $message");
  }

  void _onConferenceTerminated(message) {
    debugPrint("_onConferenceTerminated broadcasted with message: $message");
  }

  _onError(error) {
    debugPrint("_onError broadcasted: $error");
  }
  static MaterialColor createColor(Color color) {
    List strengths = <double>[.05];
    final int r = color.red, g = color.green, b = color.blue;
    Map<int, Color> swatch = {};

    for (int i = 1; i < 10; i++) {
      strengths.add(.1 * i);
    }
    for (double strength in strengths) {
      double ds = .5 - strength;
      swatch[(strength * 1000).round()] = Color.fromARGB(
          1,
          r + ((ds < 0 ? r : 255 - r) * ds).round(),
          g + ((ds < 0 ? g : 255 - g) * ds).round(),
          b + ((ds < 0 ? b : 255 - b) * ds).round());
    }
    return MaterialColor(color.value, swatch);
  }
}