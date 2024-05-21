// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Community/View_article.dart';
import 'package:flutter_application_1/home/loadingpage.dart';
import 'package:flutter_application_1/shared/bottom_nav.dart';
import 'package:intl/intl.dart';
import '../../shared/nav_bar.dart';
import '../../services/models.dart';
import '../../services/firestore.dart';

// Define a StatefulWidget for the 'community' screen
class Community extends StatefulWidget {
  const Community({Key? key}) : super(key: key);

  @override
  State<Community> createState() => _CommunityState();
}

// Define the corresponding State class for the 'community' screen
class _CommunityState extends State<Community> with TickerProviderStateMixin {
  // Controller for handling the search functionality
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 3, vsync: this);

    // Build the main scaffold for the 'community' screen
    return Scaffold(
      backgroundColor: Color(0xFF186257),
      //bottomNavigationBar: const NavBar(),
     floatingActionButton: FloatingActionButton.extended(
    onPressed: () {
      // Navigate to the 'Write_article' screen on button press
      Navigator.of(context).pushNamed('Write_article');
    },
    backgroundColor: Color(0xFF186257),
    foregroundColor: Color.fromARGB(255, 255, 255, 255),
    icon: Icon(Icons.add),
    label: Text('Add article'),
  ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top section of the screen with user information and search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 40, 25, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // StreamBuilder to get therapist information
                    StreamBuilder<Therapist>(
                      stream: FirestoreService().streamTherapist(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          String n = snapshot.data!.name;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hi $n!👋',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    '${DateTime.now().day} ${_getMonth(DateTime.now().month)}, ${DateTime.now().year}',
                                    style: TextStyle(
                                      color: Colors.grey[200],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.power_settings_new,
                                      color: Colors.white,
                                      size: 27,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(13.0),
                                            ),
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 255, 255, 255),
                                            title: Text(
                                              'Log out',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            content: Text(
                                              'Are you sure you want to log out?',
                                              style: TextStyle(
                                                fontSize: 20,
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: const Color.fromRGBO(
                                                        0, 0, 0, 1),
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          'signinScreen');
                                                },
                                                child: Text(
                                                  'Yes',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: const Color.fromRGBO(
                                                        244, 67, 54, 1),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else {
                          // Display a loading page while fetching therapist data
                          return LoadingPage();
                        }
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    // Search bar for filtering community articles
                    Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(17),
                            color: Color.fromARGB(255, 29, 116, 106),
                          ),
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: searchController,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                  cursorColor: Colors.white,
                                  onChanged: (value) {
                                    // Update searchQuery when the user types
                                    setState(() {
                                      searchQuery = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Search by keyword or title',
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),

              // Main content section with community articles
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: EdgeInsets.all(30),
                  height: 4000,
                  color: Colors.grey[100],
                  child: Column(
                    children: [
                      // TabBar for filtering articles (All, My Articles, Favourite)
                      TabBar(
                        controller: tabController,
                        tabs: [
                          Tab(text: 'All'),
                          Tab(text: 'My Articles'),
                       //   Tab(text: 'Favourite'),
                        ],
                        labelColor: Color(0xFF186257),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        indicatorColor: Colors.black,
                      ),
                      SizedBox(height: 15),
                      // TabBarView to display content based on the selected tab
                      SizedBox(
                        width: double.maxFinite,
                        height: 3500,
                        child: TabBarView(
                          controller: tabController,
                          children: [
                            // Tab: All Articles
                            StreamBuilder<List<Article>>(
                              stream: FirestoreService().streamArticles(),
                              builder: (context,
                                  AsyncSnapshot<List<Article>> snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(child: LoadingPage());
                                }

                                if (snapshot.data == null ||
                                    snapshot.data!.isEmpty) {
                                  return Text('No community articles found');
                                }

                                // Extracted common code for building article cards
                                List<Widget> buildArticleCards(
                                    List<Article> articles) {
                                  return articles.map((card) {
                                    String title = card.Title;
                                    String keys = card.KeyWords;
                                    Timestamp publishTime = card.publishTime;
                                    String authername = card.name;

                                    return Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            // Navigate to the 'View_article' screen on card tap
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    View_article(id: card.id),
                                              ),
                                            );
                                          },
                                          child: Stack(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(10),
                                                height: 180,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                        card.image),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Positioned.fill(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                ),
                                              ),
                                              // Content section within the article card
                                              Container(
                                                height: 180,
                                                padding: EdgeInsets.all(10),
                                                child: Align(
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      // Title of the article
                                                      Column(
                                                        children: [
                                                          Text(
                                                            title,
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'RobotoSerif',
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 6),
                                                      // Author name section
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .account_circle,
                                                            size: 15,
                                                            color: Colors
                                                                .yellow[900],
                                                          ),
                                                          SizedBox(width: 5),
                                                          Text(
                                                            authername,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontFamily:
                                                                  'RobotoSerif',
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // Keywords section at the bottom-right
                                              Container(
                                                height: 180,
                                                padding: EdgeInsets.all(10),
                                                child: Align(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: Text(
                                                    'Keywords: $keys',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontFamily: 'RobotoSerif',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Published date section at the top-right
                                              Container(
                                                height: 140,
                                                padding: EdgeInsets.all(10),
                                                child: Align(
                                                  alignment: Alignment.topRight,
                                                  child: Text(
                                                    publishTime != null
                                                        ? DateFormat(
                                                                'yyyy-MM-dd')
                                                            .format(publishTime
                                                                .toDate())
                                                        : '',
                                                    style: TextStyle(
                                                      fontFamily: 'RobotoSerif',
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                      ],
                                    );
                                  }).toList();
                                }

                                // Filtered list will be executed once the user interacts with the search bar
                                List<Article> cards = snapshot.data ?? [];
                                List<Article> filteredCards = cards
                                    .where((article) =>
                                        article.Title.toLowerCase().contains(
                                            searchQuery.toLowerCase()) ||
                                        article.KeyWords.toLowerCase().contains(
                                            searchQuery.toLowerCase()))
                                    .toList();
                                //Return "No Result" if there is no matchin Title/Keywords
                                if (filteredCards.isEmpty) {
                                  return Text('No Result');
                                }
                                // Display the filtered articles using the common buildArticleCards function
                                return Column(
                                  children: buildArticleCards(filteredCards),
                                );
                              },
                            ),
                            // Tab: My Articles
                            StreamBuilder<List<Article>>(
                              stream: FirestoreService().streamMyArticles(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(child: LoadingPage());
                                }
                                List<Widget> buildArticleCards(
                                    List<Article> articles) {
                                  return articles.map((card) {
                                    String title = card.Title;
                                    String keys = card.KeyWords;
                                    Timestamp publishTime = card.publishTime;
                                    String authername = card.name;

                                    return Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            // Navigate to the 'View_article' screen on card tap
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    View_article(id: card.id),
                                              ),
                                            );
                                          },
                                          child: Stack(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(10),
                                                height: 180,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                        card.image),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Positioned.fill(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                ),
                                              ),
                                              // Content section within the article card
                                              Container(
                                                height: 180,
                                                padding: EdgeInsets.all(10),
                                                child: Align(
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      // Title of the article
                                                      Column(
                                                        children: [
                                                          Text(
                                                            title,
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'RobotoSerif',
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 6),
                                                      // Author name section
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .account_circle,
                                                            size: 15,
                                                            color: Colors
                                                                .yellow[900],
                                                          ),
                                                          SizedBox(width: 5),
                                                          Text(
                                                            authername,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontFamily:
                                                                  'RobotoSerif',
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // Keywords section at the bottom-right
                                              Container(
                                                height: 180,
                                                padding: EdgeInsets.all(10),
                                                child: Align(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: Text(
                                                    'Keywords: $keys',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontFamily: 'RobotoSerif',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Published date section at the top-right
                                              Container(
                                                height: 140,
                                                padding: EdgeInsets.all(10),
                                                child: Align(
                                                  alignment: Alignment.topRight,
                                                  child: Text(
                                                    publishTime != null
                                                        ? DateFormat(
                                                                'yyyy-MM-dd')
                                                            .format(publishTime
                                                                .toDate())
                                                        : '',
                                                    style: TextStyle(
                                                      fontFamily: 'RobotoSerif',
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                      ],
                                    );
                                  }).toList();
                                }

                                // Filtered list will be executed once the user interacts with the search bar
                                List<Article> cards = snapshot.data ?? [];
                                List<Article> filteredCards = cards
                                    .where((article) =>
                                        article.Title.toLowerCase().contains(
                                            searchQuery.toLowerCase()) ||
                                        article.KeyWords.toLowerCase().contains(
                                            searchQuery.toLowerCase()))
                                    .toList();

                                // Display the filtered articles using the common buildArticleCards function
                                return Column(
                                  children: buildArticleCards(filteredCards),
                                );
                              },
                            ),
                            // Tab: Favourite (Placeholder text for now)
                          //  Text('No Favourite yet')
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function to get the month abbreviation
String _getMonth(int month) {
  switch (month) {
    case 1:
      return 'Jan';
    case 2:
      return 'Feb';
    case 3:
      return 'Mar';
    case 4:
      return 'Apr';
    case 5:
      return 'May';
    case 6:
      return 'Jun';
    case 7:
      return 'Jul';
    case 8:
      return 'Aug';
    case 9:
      return 'Sep';
    case 10:
      return 'Oct';
    case 11:
      return 'Nov';
    case 12:
      return 'Dec';
    default:
      return '';
  }
}
