import 'dart:convert';

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

  void _returnToHomelist() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          color: Colors.white,
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
                              } else if (questionResult.result ==
                                  BooleanResult.POSITIVE) {
                                print('True');
                              } else if (questionResult.result ==
                                  BooleanResult.NONE) {
                                print('No Answer');
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
                            } else if (questionResult
                                is InstructionStepResult) {
                              print('Instruction Step - no result');
                            } else if (questionResult is CompletionStepResult) {
                              print('Completed');
                            }
                          }
                        }
                      }

                      _returnToHomelist();
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
                                      color: Colors.grey,
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
          title: 'How old are you?',
          answerFormat: IntegerAnswerFormat(
            defaultValue: 25,
            hint: 'Please enter your age',
          ),
          isOptional: true,
        ),
        QuestionStep(
          title: 'Single or Family Home',
          text:
              'Are you interested in properties for singles or families/groups?',
          answerFormat: BooleanAnswerFormat(
            positiveAnswer: 'Single',
            negativeAnswer: 'Family/Group',
            result: BooleanResult.POSITIVE,
          ),
        ),
        QuestionStep(
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
        ),
        QuestionStep(
          title: 'Property Type',
          text: 'Check all property types you are seeking',
          answerFormat: MultipleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: 'HDB', value: 'HDB'),
              TextChoice(text: 'Condo', value: 'Condo'),
              TextChoice(text: 'Landed', value: 'Landed'),
              TextChoice(text: 'Apartment', value: 'Apartment'),
            ],
          ),
        ),
        QuestionStep(
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
        ),
        CompletionStep(
          stepIdentifier: StepIdentifier(id: '321'),
          text:
              'Thanks for taking the survey. You can retake this survey anytime.',
          title: 'Done!',
          buttonText: 'Submit survey',
        ),
      ],
    );
    task.addNavigationRule(
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
    );

    return Future.value(task);
  }

  Future<Task> getJsonTask() async {
    final taskJson = await rootBundle.loadString('assets/example_json.json');
    final taskMap = json.decode(taskJson);

    return Task.fromJson(taskMap);
  }
}
