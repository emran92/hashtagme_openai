import 'dart:async';
import 'dart:developer';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hashtagme',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.tajawalTextTheme(),
      ),
      home: const MyHomePage(title: 'HashTagMe'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> _socialMediaList = ['Facebook', 'Twitter', 'Instagram'];
  final List<String> _numberOfHashtagsList = ['5', '10', '15', '20'];

  String? _selectedSocialMedia;
  String? _selectedNumberOfHashtag;

  bool _isGenerating = false;

  String? _generatedText;

  final TextEditingController _textEditingController = TextEditingController();

  ChatGPT? chatGPT;

  FToast? fToast;

  @override
  void initState() {
    fToast = FToast();
    fToast!.init(context);
    chatGPT = ChatGPT.instance.builder(
      dotenv.env['APIKEY']!,
    );
    _selectedSocialMedia = _socialMediaList.first;
    _selectedNumberOfHashtag = _numberOfHashtagsList.first;
    super.initState();
  }

  Future generate() async {
    try {
      setState(() {
        _isGenerating = true;
      });
      final request = CompleteReq(
          prompt:
              'Create $_selectedNumberOfHashtag hashtags to post in $_selectedSocialMedia for this text in a single line in English based on most used hashtags: ${_textEditingController.text}',
          model: kTranslateModelV3,
          max_tokens: 200);

      chatGPT!
          .onCompleteStream(request: request)
          .asBroadcastStream()
          .listen((response) {
        log(response!.choices[0].text);

        setState(() {
          _generatedText =
              '${_textEditingController.text}\n${response.choices.first.text.toString()}';
          _isGenerating = false;
        });
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      throw Exception(e);
    }
  }

  _showToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check),
          SizedBox(
            width: 12.0,
          ),
          Text("Text copied to clipboard"),
        ],
      ),
    );

    fToast!.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 80,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.tag,
              color: Colors.black,
              size: 30,
            ),
            const SizedBox(
              width: 5,
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.headline6!.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const Icon(
              Icons.tag,
              color: Colors.black,
              size: 30,
            ),
            const SizedBox(
              width: 5,
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 600,
                child: Text(
                  'Generate Hashtags for Social Media in seconds',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline3!.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 600,
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          FontAwesomeIcons.diceOne,
                          size: 24,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          'Copy and paste your text',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      maxLines: 10,
                      controller: _textEditingController,
                      decoration: customInputDecoration(context,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20)),
                    ),

                    //** SOCIAL MEDIA LIST */
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          FontAwesomeIcons.diceTwo,
                          size: 24,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          'Select Social Media',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    DropdownButtonHideUnderline(
                      child: InputDecorator(
                        decoration: customInputDecoration(context,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 0)),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedSocialMedia,
                          onChanged: ((value) {
                            setState(() {
                              _selectedSocialMedia = value!;
                            });
                          }),
                          items: _socialMediaList
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    //** SOCIAL MEDIA LIST */
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          FontAwesomeIcons.diceThree,
                          size: 24,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          'Select Number of Hashtags',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    DropdownButtonHideUnderline(
                      child: InputDecorator(
                        decoration: customInputDecoration(context,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 0)),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedNumberOfHashtag,
                          onChanged: ((value) {
                            setState(() {
                              _selectedNumberOfHashtag = value!;
                            });
                          }),
                          items: _numberOfHashtagsList
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 40,
                    ),
                    SizedBox(
                        width: 600,
                        height: 45,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                alignment: Alignment.center,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12))),
                            onPressed: generate,
                            child: _isGenerating
                                ? CupertinoActivityIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    "Generate",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ))),
                    const SizedBox(
                      height: 40,
                    ),
                    _generatedText != null
                        ? Container(
                            width: 600,
                            alignment: Alignment.center,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Your Generated Text with Hashtags',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                SizedBox(
                                  width: double.maxFinite,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.copy,
                                    child: GestureDetector(
                                      onTap: () async {
                                        await Clipboard.setData(ClipboardData(
                                                text: _generatedText))
                                            .then((value) {
                                          _showToast();
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Colors.white,
                                        ),
                                        child: Text(
                                          "$_generatedText",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black,
                                                  fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 600,
                child: Row(children: [
                  Text(
                    'Powered by OpenAI & Flutter',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Spacer(),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: Colors.black54,
                              ))),
                      onPressed: () async {
                        final _url = Uri.parse('uri');
                        if (!await launchUrl(_url)) {
                          throw 'Could not launch $_url';
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.github,
                            color: Colors.black,
                            size: 16,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            'Star on Github',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  )
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration customInputDecoration(BuildContext context,
    {EdgeInsets contentPadding = EdgeInsets.zero}) {
  return InputDecoration(
    contentPadding: contentPadding,
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black38)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black38)),
    disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black38)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black38)),
  );
}
