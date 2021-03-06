import 'dart:convert' as convert;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:survey_kit/survey_kit.dart';

class LivingCoSurvey extends StatefulWidget {
  const LivingCoSurvey({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user; // keep this in case want to show username in survey

  @override
  _LivingCoSurveyState createState() => _LivingCoSurveyState();
}

class _LivingCoSurveyState extends State<LivingCoSurvey> {
  late User _user;
  String urlString = '';
  bool _invest = false;
  void _returnToHomelist(String urlStr, bool invest) {
    //pass two values back using class or a MAP
    //
    final data = {"url": urlStr, "invest": invest};
    Navigator.of(context).pop(data); // pass the URLString back to homelist
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: 'Georgia',
          textTheme: const TextTheme(
            headline5: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.normal,
                textBaseline: TextBaseline.alphabetic),
          )),
      home: Scaffold(
        body: Container(
          color: Colors.blue,
          child: Align(
            alignment: Alignment.center,
            child: FutureBuilder<Task>(
              future: getSampleTask(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    snapshot.data != null) {
                  final task = snapshot.data!;
                  return SurveyKit(
                    onResult: (SurveyResult result) {
                      print(result.finishReason);

                      if (result.finishReason == FinishReason.DISCARDED) {
                        print('cancel pressed');
                        //Navigator.pop(context);
                        String urlStr = '';
                        _returnToHomelist(urlStr, _invest);
                      } else if (result.finishReason ==
                          FinishReason.COMPLETED) {
                        print(result.endDate);

                        for (var stepResult in result.results) {
                          for (var questionResult in stepResult.results) {
                            if (questionResult is IntegerQuestionResult) {
                              print('Integer Anwer is');
                              print(questionResult.valueIdentifier);
                            } else if (questionResult
                                is BooleanQuestionResult) {
                              print('Boolean Answer is');
                              if (questionResult.result ==
                                  BooleanResult.NEGATIVE) {
                                print('False');
                                urlString =
                                    urlString + questionResult.id!.id + '=0&';
                              } else if (questionResult.result ==
                                  BooleanResult.POSITIVE) {
                                print('True');
                                urlString =
                                    urlString + questionResult.id!.id + '=1&';
                                if (questionResult.id!.id == 'investment') {
                                  _invest = true;
                                }
                              } else if (questionResult.result ==
                                  BooleanResult.NONE) {
                                print('No Answer');
                                urlString =
                                    urlString + questionResult.id!.id + '=NaN&';
                              }
                            } else if (questionResult is TextQuestionResult) {
                              print('Text Aswer is');
                              print(questionResult.result);
                            } else if (questionResult is ScaleQuestionResult) {
                              print('Scale result is');
                              print(questionResult.result);
                            } else if (questionResult
                                is MultipleChoiceQuestionResult) {
                              for (var listResult in questionResult.result!) {
                                print(listResult.value);
                              }
                            } else if (questionResult
                                is SingleChoiceQuestionResult) {
                              print(questionResult.result!.value);
                              urlString = urlString +
                                  questionResult.id!.id +
                                  '=' +
                                  questionResult.result!.value +
                                  '&';
                            } else if (questionResult
                                is InstructionStepResult) {
                              print('Instruction Step - no result');
                            } else if (questionResult is CompletionStepResult) {
                              print('Completed');
                            }
                          }
                        }
                      }
                      urlString = urlString.substring(
                          0, urlString.length - 1); // remove last '&'
                      //getPrediction(urlString);
                      print('the investment value is ');
                      print(_invest);
                      _returnToHomelist(urlString, _invest);
                    },
                    task: task,
                    themeData: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.fromSwatch(
                        primarySwatch: Colors.cyan,
                      ).copyWith(
                        onPrimary: Colors.white,
                      ),
                      primaryColor: Colors.cyan,
                      backgroundColor: Colors.white,
                      //typography: ,
                      appBarTheme: const AppBarTheme(
                        color: Colors.white,
                        iconTheme: IconThemeData(
                          color: Colors.cyan,
                        ),
                        textTheme: TextTheme(
                          button: TextStyle(
                            color: Colors.cyan,
                          ),
                        ),
                      ),
                      iconTheme: const IconThemeData(
                        color: Colors.cyan,
                      ),
                      outlinedButtonTheme: OutlinedButtonThemeData(
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(
                            Size(100.0, 40.0),
                          ),
                          side: MaterialStateProperty.resolveWith(
                            (Set<MaterialState> state) {
                              if (state.contains(MaterialState.disabled)) {
                                return BorderSide(
                                  color: Colors.grey,
                                );
                              }
                              return BorderSide(
                                color: Colors.black45,
                              );
                            },
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          textStyle: MaterialStateProperty.resolveWith(
                            (Set<MaterialState> state) {
                              if (state.contains(MaterialState.disabled)) {
                                return Theme.of(context)
                                    .textTheme
                                    .button
                                    ?.copyWith(
                                      color: Colors.cyan,
                                    );
                              }
                              return Theme.of(context)
                                  .textTheme
                                  .button
                                  ?.copyWith(
                                    color: Colors.cyan,
                                  );
                            },
                          ),
                        ),
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: ButtonStyle(
                          textStyle: MaterialStateProperty.all(
                            Theme.of(context).textTheme.button?.copyWith(
                                  color: Colors.cyan,
                                ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                //_returnToHomelist('');
                return CircularProgressIndicator.adaptive();
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<Task> getSampleTask() {
    var task = NavigableTask(
      id: TaskIdentifier(),
      steps: [
        InstructionStep(
          title: 'Welcome to the\nLivingCo Properties App\nUser Survey',
          text: 'These questions will help us suggest some properties to you',
          buttonText: 'Let\'s go!',
        ),
        QuestionStep(
          title: 'Purpose of Property',
          text: 'Are you looking to purchase the property for',
          stepIdentifier: StepIdentifier(id: 'investment'),
          answerFormat: BooleanAnswerFormat(
            positiveAnswer: 'Investment Purposes',
            negativeAnswer: 'Own Stay',
            result: BooleanResult.NEGATIVE,
          ),
        ),
        QuestionStep(
          title: 'Your Age Range',
          text: 'Select your age range',
          stepIdentifier: StepIdentifier(id: 'age'),
          answerFormat: SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: '<26', value: '<26'),
              TextChoice(text: '26~30', value: '26~30'),
              TextChoice(text: '31~35', value: '31~35'),
              TextChoice(text: '36~40', value: '36~40'),
              TextChoice(text: '41~45', value: '41~45'),
              TextChoice(text: '46~50', value: '46~50'),
              TextChoice(text: '51~55', value: '51~55'),
            ],
            defaultSelection: TextChoice(text: '<26', value: '<26'),
          ),
        ),
        QuestionStep(
          title: 'Marrital Status',
          text: 'Are You Married?',
          stepIdentifier: StepIdentifier(id: 'married'),
          answerFormat: BooleanAnswerFormat(
            positiveAnswer: 'Yes',
            negativeAnswer: 'No/Other',
            result: BooleanResult.NEGATIVE,
          ),
        ),
        /*QuestionStep(
          title: 'Tell us about you',
          text:
              'Tell us about yourself and why you want to improve your health.',
          answerFormat: TextAnswerFormat(
            maxLines: 5,
            validationRegEx: "^(?!\s*\$).+",
          ),
        ),
        QuestionStep(
          title: 'Select approximate property price range in SGD',
          answerFormat: ScaleAnswerFormat(
            step: 100000,
            minimumValue: 100000,
            maximumValue: 1000000,
            defaultValue: 500000,
            minimumValueDescription: '<SGD 100k',
            maximumValueDescription: '>SGD 1m',
          ),
        ),*/
        QuestionStep(
          title: 'Kids below 7',
          text: 'How many kids do you have below 7',
          stepIdentifier: StepIdentifier(id: 'kids_below_7'),
          answerFormat: SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: '0', value: '0'),
              TextChoice(text: '1', value: '1'),
              TextChoice(text: '2', value: '2'),
              TextChoice(text: '3', value: '3'),
              TextChoice(text: '4', value: '4'),
              TextChoice(text: '5', value: '5'),
              TextChoice(text: '6', value: '6'),
              TextChoice(text: '7 or more', value: '7'),
            ],
            defaultSelection: TextChoice(text: '0', value: '0'),
          ),
        ),
        QuestionStep(
          title: 'Kids between 7 and 12',
          text: 'How many kids do you have between 7 and 12',
          stepIdentifier: StepIdentifier(id: 'kids_between_7_and_12'),
          answerFormat: SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: '0', value: '0'),
              TextChoice(text: '1', value: '1'),
              TextChoice(text: '2', value: '2'),
              TextChoice(text: '3', value: '3'),
              TextChoice(text: '4', value: '4'),
              TextChoice(text: '5', value: '5'),
              TextChoice(text: '6', value: '6'),
              TextChoice(text: '7 or more', value: '7'),
            ],
            defaultSelection: TextChoice(text: '0', value: '0'),
          ),
        ),
        QuestionStep(
          title: 'Household Size',
          text: 'What is the size of your household?',
          stepIdentifier: StepIdentifier(id: 'household_size'),
          answerFormat: SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: '1', value: '1'),
              TextChoice(text: '2', value: '2'),
              TextChoice(text: '3', value: '3'),
              TextChoice(text: '4 or more', value: '4'),
            ],
            defaultSelection: TextChoice(text: '1', value: '1'),
          ),
        ),
        QuestionStep(
          title: 'Household Income',
          text: 'What is the range of your household income?',
          stepIdentifier: StepIdentifier(id: 'household_income'),
          answerFormat: SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: '3000~5000', value: '3000~5000'),
              TextChoice(text: '5001~7000', value: '5001~7000'),
              TextChoice(text: '7001~10000', value: '7001~10000'),
              TextChoice(text: '10001~15000', value: '10001~15000'),
              TextChoice(text: '15001~20000', value: '15001~20000'),
            ],
            defaultSelection: TextChoice(text: '3000~5000', value: '3000~5000'),
          ),
        ),
        /*QuestionStep(
          title: 'Done?',
          text: 'We are done, do you mind to tell us more about yourself?',
          answerFormat: SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: 'Yes', value: 'Yes'),
              TextChoice(text: 'No', value: 'No'),
            ],
            defaultSelection: TextChoice(text: 'No', value: 'No'),
          ),
        ),
        QuestionStep(
          title: 'When did you wake up?',
          answerFormat: TimeAnswerFormat(
            defaultValue: TimeOfDay(
              hour: 12,
              minute: 0,
            ),
          ),
        ),
        QuestionStep(
          title: 'When was your last holiday?',
          answerFormat: DateAnswerFormat(
            minDate: DateTime.utc(1970),
            defaultDate: DateTime.now(),
            maxDate: DateTime.now(),
          ),
        ),*/
        CompletionStep(
          stepIdentifier: StepIdentifier(id: '321'),
          text:
              'Thanks for taking the survey. You can retake this survey anytime.',
          title: 'Done!',
          buttonText: 'Submit survey',
        ),
      ],
    );
    /*task.addNavigationRule(
      forTriggerStepIdentifier: task.steps[6].stepIdentifier,
      navigationRule: ConditionalNavigationRule(
        resultToStepIdentifierMapper: (input) {
          switch (input) {
            case "Yes":
              return task.steps[9].stepIdentifier;
            case "No":
              return task.steps[7].stepIdentifier;
            default:
              return null;
          }
        },
      ),
    );*/

    return Future.value(task);
  }

  Future<Task> getJsonTask() async {
    final taskJson = await rootBundle.loadString('assets/example_json.json');
    final taskMap = convert.json.decode(taskJson);

    return Task.fromJson(taskMap);
  }
}
