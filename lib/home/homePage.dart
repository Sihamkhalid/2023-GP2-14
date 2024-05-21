import 'package:flutter/material.dart';
import 'package:flutter_application_1/Community/View_article.dart';
import 'package:flutter_application_1/home/loadingpage.dart';
import 'package:flutter_application_1/shared/bottom_nav.dart';
import '../services/models.dart';
import '../services/firestore.dart';
import '../patient/patientPage.dart';
import 'package:carousel_slider/carousel_slider.dart';

class homePage extends StatefulWidget {
  const homePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<homePage> with TickerProviderStateMixin {
  bool isPatientClicked =
      false; // Add a boolean variable to track whether the patient section is clicked
  bool isLoading = true;

  void loading() {
    Future.delayed(Duration(seconds: 4), () {});
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loading();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF186257),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('AddpatientScreen');
        },
        backgroundColor: const Color(0xFF186257),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        icon: const Icon(Icons.add),
        label: const Text('Add patient'),
      ),
      body: isLoading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 40, 25, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StreamBuilder<Therapist>(
                            stream: FirestoreService().streamTherapist(),
                            builder: (context, snapshot) {
                              String n = snapshot.data!.name;
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const LoadingPage();
                              }

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hi $n!👋',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(
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
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
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
                                                      BorderRadius.circular(
                                                          13.0),
                                                ),
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 255, 255, 255),
                                                title: const Text(
                                                  'Log out',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                content: const Text(
                                                  'Are you sure you want to log out?',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text(
                                                      'Cancel',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color: Color.fromRGBO(
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
                                                    child: const Text(
                                                      'Yes',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color: Color.fromRGBO(
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
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            'Recent Articles',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          StreamBuilder<List<Article>>(
                            stream: FirestoreService().streamArticles(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const LoadingPage();
                              }

                              List<Article> cardData = snapshot.data ?? [];

                              // Sort the list based on publishtime in descending order
                              cardData.sort((a, b) =>
                                  b.publishTime.compareTo(a.publishTime));

                              // Take the first 5 articles
                              List<Article> recentArticles =
                                  cardData.take(5).toList();

                              return Center(
                                child: CarouselSlider(
                                  items: recentArticles.map((card) {
                                    //String key = card.KeyWords;
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  View_article(id: card.id)),
                                        );
                                      },
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        ),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            // Image at the right side of the card
                                            Positioned(
                                              top: 15.0,
                                              right: 15.0,
                                              bottom: 15.0,
                                              width: 125.0,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(30.0),
                                                child: Image.network(
                                                  card.image,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            // Title beside the image
                                            Positioned(
                                              top: 40.0,
                                              left: 15.0,
                                              right: 150.0,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    card.Title,
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.account_circle,
                                                        size: 20,
                                                        color:
                                                            Colors.yellow[900],
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        card.name,
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 13,
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  View_article(
                                                                      id: card
                                                                          .id),
                                                            ),
                                                          );
                                                        },
                                                        child: const Text(
                                                          'View more',
                                                          style: TextStyle(
                                                            color: Colors.blue,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  options: CarouselOptions(
                                    height: 200.0,
                                    enlargeCenterPage: true,
                                    autoPlay: true,
                                    aspectRatio: 16 / 9,
                                    autoPlayCurve: Curves.fastOutSlowIn,
                                    enableInfiniteScroll: true,
                                    autoPlayAnimationDuration:
                                        const Duration(milliseconds: 2000),
                                    viewportFraction: 0.8,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                    // SearchWidget now only requires the key to access allPatients
                    SearchWidget(
                        isPatientClicked:
                            isPatientClicked), // Pass the boolean variable to the SearchWidget
                  ],
                ),
              ),
            ),
    );
  }
}

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

class SearchWidget extends StatefulWidget {
  final bool
      isPatientClicked; // Add a boolean variable to receive the clicked state
  const SearchWidget({Key? key, required this.isPatientClicked})
      : super(key: key);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController searchController = TextEditingController();
  late List<Patient> allPatients;
  late List<Patient> filteredPatients = [];
  String dropdownvalue = 'all';

  @override
  void initState() {
    super.initState();
    FirestoreService().streamPatients().listen((List<Patient> data) {
      setState(() {
        allPatients = data;
        filteredPatients = List.from(allPatients);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Color patientColor = widget.isPatientClicked ? Colors.blue : Colors.white;
    return SingleChildScrollView(
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(50),
          topRight: Radius.circular(50),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
          color: Colors.grey[100],
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: patientColor, // Use the new color variable
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 13,
                    ),
                    Icon(
                      Icons.search,
                      color: const Color(0xFF414141).withOpacity(0.9),
                      size: 26,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: updatePatientList,
                        decoration: const InputDecoration(
                          labelText: 'Search by name or number',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 13),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Patients',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  DropdownButton<String>(
                    value: dropdownvalue,
                    items: [
                      DropdownMenuItem<String>(
                        value: 'all',
                        child: Text('All patients'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'highToLow',
                        child: Text('Performance (High to Low)'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'lowToHigh',
                        child: Text('Performance (Low to High)'),
                      ),
                    ],
                    onChanged: (String? value) {
                      setState(() {
                        Patient temp;
                        if (filteredPatients.isNotEmpty) {
                          if (value == 'highToLow') {
                            dropdownvalue = value!;
                            //Sort by performance high to low and exclude patients with -1 performance
                            for (int i = 0; i < filteredPatients.length; i++) {
                              for (int j = i + 1;
                                  j < filteredPatients.length;
                                  j++) {
                                if (filteredPatients[i].performance <
                                    filteredPatients[j].performance) {
                                  temp = filteredPatients[i];
                                  filteredPatients[i] = filteredPatients[j];
                                  filteredPatients[j] = temp;
                                }
                              }
                            }
                          } else if (value == 'lowToHigh') {
                            dropdownvalue = value!;
                            //Sort by performance low to high and exclude patients with -1 performance
                            for (int i = 0; i < filteredPatients.length; i++) {
                              for (int j = i + 1;
                                  j < filteredPatients.length;
                                  j++) {
                                if (filteredPatients[i].performance >
                                    filteredPatients[j].performance) {
                                  temp = filteredPatients[i];
                                  filteredPatients[i] = filteredPatients[j];
                                  filteredPatients[j] = temp;
                                }
                              }
                            }
                          } else if (value == 'all') {
                            dropdownvalue = value!;
                            filteredPatients = allPatients;
                          }
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: filteredPatients.length,
                  itemBuilder: (context, index) {
                    // Widget for patient item...

                    Patient patient = filteredPatients[index];
                    Text('\n\npatient name is : ${patient.name}');
                    Text('\n\nlength is : ${filteredPatients.length}');
                    String pname = patient.name;
                    String pnum = patient.patientNum;
                    String gender = patient.gender;
                    int performance = patient.performance;
                    String avatar = 'man';
                    switch (gender) {
                      case 'F':
                        avatar = 'woman';
                        break;
                      case 'M':
                        avatar = 'man';
                        break;
                    }

                    return Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: Image.asset(
                              'images/$avatar.png',
                              height: 40,
                              width: 40,
                            ),
                            title: Text(pname),
                            subtitle: Text('Patient #$pnum'),
                            trailing: Text(
                              '${performance == -1 ? ' No report available' : '$performance%'}',
                              style: TextStyle(
                                fontSize: performance == -1 ? 11 : 15,
                                color: performance > 50
                                    ? Colors.green
                                    : performance == -1
                                        ? Colors.black54
                                        : Colors.red,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PatientPage(pid: pnum),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updatePatientList(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredPatients = List.from(allPatients);
      } else {
        filteredPatients = allPatients
            .where((patient) =>
                patient.patientNum
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                patient.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }
}
