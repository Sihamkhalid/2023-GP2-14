import 'package:flutter/material.dart';
import 'package:flutter_application_1/PdfViewerPage.dart';
import 'package:flutter_application_1/shared/bottom_nav.dart';
import 'package:intl/intl.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/Community/EditArticleScreen.dart';
import 'package:flutter_application_1/services/authentic.dart';
import 'package:flutter_application_1/services/firestore.dart';
import 'package:flutter_application_1/services/models.dart';
import 'package:flutter_application_1/shared/nav_bar.dart';
import '../home/loadingpage.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class View_article extends StatefulWidget {
  final String id;
  const View_article({Key? key, required this.id}) : super(key: key);

  @override
  ViewArticleState createState() => ViewArticleState();
}

class ViewArticleState extends State<View_article> {
  late Stream<Article> articleStream =
      FirestoreService().streamArticle(widget.id);

  Future<void> deleteArticle(String id) async {
    bool? deleteConfirmed = await showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to delete this article?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Yes',
                style: TextStyle(color: Color.fromRGBO(244, 67, 54, 1)),
              ),
            ),
          ],
        );
      },
    );

    if (deleteConfirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('Article').doc(id).delete();
        Navigator.of(context).pushNamed('communitypage');
        QuickAlert.show(
          context: context,
          text: "The article is deleted successfully!",
          type: QuickAlertType.success,
        );
      } catch (e) {
        print('Error deleting article: $e');
        QuickAlert.show(
          context: context,
          text: "Failed to delete the article!",
          type: QuickAlertType.error,
        );
      }
    }
  }

  bool isFavorite = false;
  bool isAuthor = false;
  var user = AuthService().user;

  @override
  Widget build(BuildContext context) => StreamBuilder<Article>(
        stream: articleStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingPage();
          }
          Article article = snapshot.data!;
          String title = article.Title;
          String content = article.Content;
          String authorID = article.autherID;
          bool isMyArticle = authorID == AuthService().user!.uid;
          String name = article.name;
          Timestamp publishTime = article.publishTime;
          String pdfUrl = article.pdfUrl;

          return Scaffold(
            body: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: MediaQuery.of(context).size.height / 2,
                    color: const Color.fromRGBO(24, 98, 87, 1),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: 0.7,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(7, 0, 6, 0),
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'RobotoSerif',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(
                                Icons.account_circle,
                                size: 23,
                                color: Colors.yellow[900],
                              ),
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'RobotoSerif',
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 150),
                              Text(
                                publishTime != null
                                    ? DateFormat('yyyy-MM-dd')
                                        .format(publishTime.toDate())
                                    : '',
                                style: const TextStyle(
                                  fontFamily: 'RobotoSerif',
                                  fontSize: 13,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Text(
                                "Note: ",
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 21, 22, 52),
                                  fontSize: 15,
                                  fontFamily: 'RobotoSerif',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "The article reflects the author's opinion",
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 21, 22, 52),
                                  fontSize: 15,
                                  fontFamily: 'RobotoSerif',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
                            child: Text(
                              content,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 62, 62, 62),
                                fontSize: 15,
                                fontFamily: 'RobotoSerif',
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                          SizedBox(height: 10),
                          article.pdfUrl.isNotEmpty ?
                          ElevatedButton(child: Text('View Article'), onPressed: () {
                            Navigator.push(context,
                            MaterialPageRoute(builder: (context) => PdfViewerPage(filePath: pdfUrl)));

                          }, style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                const Color(0xFF186257)),
                            foregroundColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 255, 255, 255)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),) : SizedBox(),
                          
                          // if (pdfUrl.isNotEmpty)
                          //   Container(
                          //     height: 400, // Adjust the height as needed
                          //     child: PDFView(
                          //       filePath: pdfUrl,
                          //       onError: (error) {
                          //         // Display an error message if PDF cannot be loaded
                          //         print("Error loading PDF: $error");
                          //       },
                          //     ),
                          //   ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 235,
                  right: 30,
                  child: isMyArticle
                      ? PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'Edit':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditArticleScreen(
                                      articleId: widget.id,
                                    ),
                                  ),
                                );
                                break;
                              case 'Delete':
                                deleteArticle(widget.id);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'Edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'Delete',
                              child: Text('Delete'),
                            ),
                          ],
                          offset: const Offset(0, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: const Icon(
                            Icons.more_vert,
                            size: 35,
                            color: Colors.black,
                          ),
                        )
                      : Container(),
                ),
                Positioned(
                  top: 20,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 25,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            bottomNavigationBar: const NavBar(),
          );
        },
      );
}
