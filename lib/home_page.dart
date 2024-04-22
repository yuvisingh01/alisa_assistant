import 'package:allen/feature_box.dart';
import 'package:allen/openai_service.dart';
import 'package:allen/pallete.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText=SpeechToText();
  String lastWords='';
  
  // final flutterTts=FlutterTts();

  String? generatedContent;
  String? generatedUrl;

  @override
  void initState() { 
    super.initState();
    initSpeechToText();
    // initTextToSpeech();
  }

  Future<void> initSpeechToText()async{
    speechToText.initialize();
    setState(() {
    });
  }

  // Future<void> initTextToSpeech()async{
  //   await flutterTts.setSharedInstance(true);
  //   setState(() {
  //   });

  // }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  Future<void> onSpeechResult(SpeechRecognitionResult result) async {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }


  // Future<void> systemSpeak(String content)async{
  //   await flutterTts.speak(content);
  // }

  @override
  void dispose() {
    speechToText.stop();
    // flutterTts.stop();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(child: const Text('Alisa')),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //virtul assistant picture
            ZoomIn(
              child: Stack(
                children: [
                  Align(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    height: 123,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/virtualAssistant.png'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //chat header bubble
            FadeInRight(
              child: Visibility(
                visible:generatedUrl==null ,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 40,
                  ).copyWith(top: 30),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Pallete.borderColor,
                      ),
                      borderRadius:
                          BorderRadius.circular(20).copyWith(topLeft: Radius.zero)),
                  child:  Padding(
                    padding:const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      generatedContent==null?'Good Morning, what task I can help you with!':generatedContent!,
                      style: TextStyle(
                        color: Pallete.mainFontColor,
                        fontSize: generatedContent==null?25:18,
                        fontFamily: 'Cera Pro',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            //image
            if(generatedUrl!=null) Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipRRect(borderRadius:BorderRadius.circular(20), child: Image.network(generatedUrl!)),
            ),

            //features header
            SlideInLeft(
              child: Visibility(
                visible: generatedContent==null && generatedUrl==null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(top: 10, left: 22),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Here are a few features',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //Features list
            Visibility(
              visible: generatedContent==null && generatedUrl==null,
              child: Column(
                children: [
                  SlideInLeft(
                    child: const FeatureBox(
                      color: Pallete.firstSuggestionBoxColor,
                      headerText: 'Chat GPT',
                      descriptionText:
                          'A smarter way to stay organized and informed with ChatGPT',
                    ),
                  ),
                  SlideInLeft(
                    child: const FeatureBox(
                      color: Pallete.secondSuggestionBoxColor,
                      headerText: 'Dall-E',
                      descriptionText:
                          'Get inspired and stay creative with your personal assistant powered by Dall-E',
                    ),
                  ),
                  SlideInLeft(
                    child: const FeatureBox(
                      color: Pallete.firstSuggestionBoxColor,
                      headerText: 'Smart Voice Assistant',
                      descriptionText:
                          'Get the best of both world with a voice assistant powered by Dall-E and ChatGPT',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          if(await speechToText.hasPermission && speechToText.isNotListening){
            await startListening();
            print('start listening');
          }else if(speechToText.isListening ){
            final speech=await OpenAIService.isArtPromptApi(lastWords);
            if(speech.contains('https')){
              generatedUrl=speech;
              generatedContent=null;
              setState(() {
              });
            }else{
              generatedUrl=null;
              generatedContent=speech;
              // systemSpeak(speech);
              setState(() {
              });
            }
            await stopListening();
            print(lastWords);
            print('stop listening');
          }else{
            await initSpeechToText();
            print('init listening');
          }
        },
        backgroundColor: Pallete.firstSuggestionBoxColor,
        child: Icon(speechToText.isListening?Icons.stop:Icons.mic),
      ),
    );
  }
}
