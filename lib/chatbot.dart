import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/firestore.dart';
import 'package:flutter_application_1/services/models.dart';
import 'package:flutter_application_1/shared/nav_bar.dart';


class _ChatDetailPageAppBarState extends State<ChatDetailPageAppBar> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  List<Quizz> _currentQuestions = [];
  //final List<int> _askedQuestionIndices = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;

  @override
  void initState() {
    super.initState();
    _receiveMessage("Hello, I'm your chatbot. How can I assist you?", [
      ChatActionButton(
        text: '1- FAQs',
        onPressed: () {
          _handleButtonPressed('FAQs');
        },
      ),
      ChatActionButton(
        text: '2- Quick Quiz',
        onPressed: () {
          _handleButtonPressed('Quick Quiz');
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    //  bottomNavigationBar: const NavBar(),
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF186257),
        flexibleSpace: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 2),
                CircleAvatar(
                  backgroundColor: const Color(0xFF186257),
                  maxRadius: 20,
                  child: Image.asset('images/robot.png'),
                ),
                const SizedBox(width: 12),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("TheraSenseBot",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.white)),
                    Text("Online",
                        style: TextStyle(color: Colors.green, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: const BorderSide(),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  _handleButtonPressed(_messageController.text);
                  _messageController.clear();
                },
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  void _handleUserMessage(String text) {
    _sendMessage(text, false);

    // if (text.toLowerCase() == 'faqs' || text == '1') {
    //   _handleButtonPressed('FAQs');
    // } else if (text.toLowerCase() == 'quick quiz' || text == '2') {
    //   _startQuiz();
    // } else {
    _receiveMessage('I\'m not sure how to respond to that.', null);
    //}
  }

  void _handleButtonPressed(String text) {
    if (text.toLowerCase() == 'faqs' || text == '1') {
      _sendMessage(text, false);
      _displayFAQs();
    } else if (text.toLowerCase() == 'quick quiz' || text == '2') {
      _sendMessage(text, false);
      _startQuiz();
    } else if (text.toLowerCase() == 'exit') {
      // Add condition for exit button
      _sendMessage('Goodbye, see you soon', true);
    } else {
      _handleUserMessage(text);
    }
  }

  //   _sendMessage(text, false);
  //   _receiveMessage('I\'m not sure how to respond to that.', null);
  //   _receiveMessage("Hello, I'm your chatbot. How can I assist you?", [
  //     ChatActionButton(
  //       text: '1- FAQs',
  //       onPressed: () {
  //         _handleButtonPressed('FAQs');
  //       },
  //     ),
  //     ChatActionButton(
  //       text: '2- Quick Quiz',
  //       onPressed: () {
  //         _handleButtonPressed('Quick Quiz');
  //       },
  //     ),
  //   ]);
  // }

  void _startQuiz() {
    _currentQuestions = [];
    _currentIndex = 0;
    _score = 0;
    _quizCompleted = false;
    _getRandomQuestions();
  }
  Future<void> _getRandomQuestions() async {
    var random = Random();
    List<Quizz> allquestions = await FirestoreService().getRandomQuizz();
    allquestions.shuffle(random);
    _currentQuestions = allquestions.sublist(0, min(4, allquestions.length));
    _askQuestion();
  }
  void _askQuestion() {
    var question = _currentQuestions[_currentIndex];
    _receiveMessage(
      '${_currentIndex + 1}/4 \n${question.question}',
      [
        for (var option in question.options)
          ChatActionButton(
            text: option,
            onPressed: () {
              _handleQuizAnswer(option, question.correctAns);
            },
          ),
      ],
    );
  }

  void _handleQuizAnswer(String selectedAnswer, String correctAnswer) {
    if (!_quizCompleted) {
      if (selectedAnswer == correctAnswer) {
        _score++;
      }
      // Send the selected answer text before the next question
      _sendMessage(selectedAnswer, false);
      _currentIndex++;
      if (_currentIndex < _currentQuestions.length) {
        _askQuestion();
      } else {
        _showQuizResult();
      }
    }
  }

  void _showQuizResult() {
    _quizCompleted = true;
    _receiveMessage('Quiz completed! Your score: $_score out of 4', [
      ChatActionButton(
        text: 'Show Correct Answers',
        onPressed: _showCorrectAnswers,
      ),
      ChatActionButton(
        text: 'Quick Quiz',
        onPressed: () {
          _sendMessage("Quick Quiz", false);
          _startQuiz();
        },
      ),
      ChatActionButton(
        text: 'FAQs',
        onPressed: () {
          _handleButtonPressed('FAQs');
        },
      ),
      ChatActionButton(
        text: 'Exit',
        onPressed: () {
          _handleButtonPressed('exit');
        },
      ),
    ]);
  }

  void _showCorrectAnswers() {
    for (var i = 0; i < _currentQuestions.length; i++) {
      var question = _currentQuestions[i];
      _receiveMessage(
        '${i + 1}/4 \n${question.question} - Correct Answer: ${question.correctAns}',
        null,
      );
    }
    _receiveMessage('Quiz completed! Your score: $_score out of 4', [
      ChatActionButton(
        text: 'Quick Quiz',
        onPressed: () {
          _startQuiz();
          _sendMessage("Quick Quiz", false);
        },
      ),
      ChatActionButton(
        text: 'FAQs',
        onPressed: () {
          _handleButtonPressed('FAQs');
        },
      ),
      ChatActionButton(
        text: 'Exit',
        onPressed: () {
          _handleButtonPressed('exit');
        },
      ),
    ]);
  }

  Future<void> _displayFAQs() async {
    List<FAQss> faqs = await FirestoreService().getFAQs();
    List<ChatActionButton> faqButtons = faqs.map((faq) {
      return ChatActionButton(
        text: faq.question,
        onPressed: () {
          _sendMessage(faq.question, false);
          _sendMessage(
              faq.answer, true); // Sending the answer as a chatbot message
          _receiveMessage("Do you want anything else?", [
            ChatActionButton(
              text: 'FAQs',
              onPressed: () {
                _handleButtonPressed('FAQs');
              },
            ),
            ChatActionButton(
              text: 'Quick Quiz',
              onPressed: () {
                _handleButtonPressed('Quick Quiz');
              },
            ),
            ChatActionButton(
              text: 'Exit',
              onPressed: () {
                _handleButtonPressed('exit');
              },
            ),
          ]);
        },
      );
    }).toList();
    _receiveMessage('Here are some frequently asked questions:', faqButtons);
  }

  void _sendMessage(String text, bool isChatbot) {
    setState(() {
      _messages.insert(0, ChatMessage(text: text, isChatbot: isChatbot));
    });
  }

  void _receiveMessage(String text, List<ChatActionButton>? buttons) {
    DateTime now = DateTime.now();
    String time = "${now.hour}:${now.minute}";

    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          text: text,
          isChatbot: true,
          buttons: buttons,
          time: time,
        ),
      );
    });
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isChatbot;
  final List<ChatActionButton>? buttons;
  final String? time;

  const ChatMessage(
      {super.key,
      required this.text,
      required this.isChatbot,
      this.buttons,
      this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment:
            isChatbot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isChatbot
              ? CircleAvatar(
                  backgroundColor: const Color(0xFF186257),
                  maxRadius: 20,
                  child: Image.asset(
                    'images/robot.png',
                    height: 120,
                    width: 120,
                  ),
                )
              : const Text(''),
          Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isChatbot
                    ? const Text(
                        'TheraSenseBot',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      )
                    : const Text(''),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isChatbot ? Colors.grey[200] : const Color(0xFF186257),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isChatbot) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (time != null) ...[
                              Text(
                                time!,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                      ],
                      const SizedBox(height: 6),
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        child: Text(
                          text,
                          style: TextStyle(
                              color: isChatbot ? Colors.black : Colors.white),
                        ),
                      ),
                      if (buttons != null) ...[
                        const SizedBox(height: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: buttons!.map((button) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              child: OutlinedButton(
                                onPressed: button.onPressed,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.green,
                                ),
                                child: Text(button.text),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatActionButton {
  final String text;
  final VoidCallback onPressed;

  ChatActionButton({required this.text, required this.onPressed});
}

class ChatDetailPageAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  const ChatDetailPageAppBar({super.key});

  @override
  _ChatDetailPageAppBarState createState() => _ChatDetailPageAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
