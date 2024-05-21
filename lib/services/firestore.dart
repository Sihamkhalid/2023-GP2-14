import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/services/authentic.dart';
import 'package:flutter_application_1/services/models.dart';
import 'package:path_provider/path_provider.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream for monitoring changes in the 'Therapist' collection
  Stream<Therapist> streamTherapist() {
    var user = AuthService().user;
    if (user != null) {
      var ref = _db.collection('Therapist').doc(user.uid);
      return ref.snapshots().map((doc) => Therapist.fromJson(doc.data()!));
    } else {
      return Stream.fromIterable([Therapist()]);
    }
  }

  // Update therapist data in Firestore
  Future<void> updateTherapist(Map<String, dynamic> newData) async {
    var user = AuthService().user!;
    try {
      CollectionReference therapistCollection = _db.collection('Therapist');
      await therapistCollection.doc(user.uid).update(newData);
    } catch (e) {
      print('Error updating therapist: $e');
      rethrow;
    }
  }

  // Stream for monitoring changes in the 'Patient' collection
  Stream<List<Patient>> streamPatients() {
    var ref = _db.collection('Patient');
    var user = AuthService().user!;
    return ref
        .where('TheraID', isEqualTo: user.uid)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => Patient.fromJson(doc.data()))
          .toList();
    });
  }

  // Stream for monitoring changes in a specific patient in the 'Patient' collection
  Stream<Patient> streamPatient(String pNum) {
    var user = AuthService().user;
    if (user != null) {
      var ref = _db.collection('Patient').doc(pNum);
      return ref.snapshots().map((doc) => Patient.fromJson(doc.data()!));
    } else {
      return Stream.fromIterable([Patient()]);
    }
  }

  // Add a new patient to the 'Patient' collection
  Future<void> addPatient(Patient patient) async {
    var user = AuthService().user!;
    try {
      CollectionReference patientCollection = _db.collection('Patient');
      await patientCollection.add({
        'Patient Name': patient.name,
        'Patient Number': patient.phone,
        'Email': patient.email,
        'TheraID': user.uid,
      });
    } catch (e) {
      print('Error adding patient: $e');
      rethrow;
    }
  }

  // Update patient data in the 'Patient' collection
  Future<void> updatePatient(String pNum, Map<String, dynamic> newData) async {
    try {
      CollectionReference patientCollection = _db.collection('Patient');
      await patientCollection.doc(pNum).update(newData);
    } catch (e) {
      print('Error updating patient: $e');
      rethrow;
    }
  }

  // Stream for monitoring changes in the 'Article' collection
  Stream<List<Article>> streamArticles() {
    var ref = _db.collection('Article');
    return ref.snapshots().map((QuerySnapshot snapshot) {
      List<Article> articles = [];
      for (var document in snapshot.docs) {
        Article article =
            Article.fromJson(document.data() as Map<String, dynamic>);
        articles.add(article);
      }
      return articles;
    });
  }

  // Stream for monitoring changes in the user's articles in the 'Article' collection
  Stream<List<Article>> streamMyArticles() {
    var ref = _db.collection('Article');
    var user = AuthService().user!;
    return ref
        .where('AutherID', isEqualTo: user.uid)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => Article.fromJson(doc.data()))
          .toList();
    });
  }

  // Stream for monitoring changes in a specific article in the 'Article' collection
  Stream<Article> streamArticle(String aid) {
    var user = AuthService().user;
    
    if (user != null) {
      var ref = _db.collection('Article').doc(aid);
      return ref.snapshots().map((doc) => Article.fromJson(doc.data()!));
    } else {
      return Stream.fromIterable([Article(publishTime: Timestamp.now(), pdfUrl: '')]);
    }

   
  }

  // // Add a new article to the 'Article' collection
  // Future<void> addArticle(Article article) async {
  //   var user = AuthService().user!;
  //   try {
  //     CollectionReference articleCollection = _db.collection('Article');
  //     await articleCollection.add({
  //       'Title': article.Title,
  //       'Content': article.Content,
  //       'PublishTime': article.publishTime,
  //       'authorID': article.autherID,
  //       'KeyWords': article.KeyWords,
  //     });
  //   } catch (e) {
  //     print('Error adding article: $e');
  //     rethrow;
  //   }
  // }

 Future<void> addArticle(Article article, File pdfFile) async {
  var user = AuthService().user!;
  try {
    // Upload the PDF file to Firebase Storage and get the URL
    String pdfUrl = await uploadPDF(pdfFile);

    // Add the article data along with the PDF URL to Firestore
    CollectionReference articleCollection = _db.collection('Article');
    await articleCollection.add({
      'Title': article.Title,
      'Content': article.Content,
      'PublishTime': article.publishTime,
      'authorID': article.autherID,
      'KeyWords': article.KeyWords,
      'pdfUrl': pdfUrl, // Use the URL obtained from uploadPDF function
    });
  } catch (e) {
    print('Error adding article: $e');
    rethrow;
  }
}


  Future<String> uploadPDF(File pdfFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference =
          FirebaseStorage.instance.ref().child('pdfs/$fileName.pdf');
      UploadTask uploadTask = reference.putFile(pdfFile);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => print('File Uploaded'));
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading PDF: $e');
      rethrow;
    }
  }


  // Update article data in the 'Article' collection
  Future<void> updateArticle(
      String articleId, Map<String, dynamic> newData) async {
    try {
      CollectionReference articleCollection = _db.collection('Article');
      await articleCollection.doc(articleId).update(newData);
    } catch (e) {
      print('Error updating article: $e');
      rethrow;
    }
  }

  Future<List<FAQss>> getFAQs() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('FAQs').get();

      // Map each document to a FAQss object using fromJson method
      List<FAQss> faqs = querySnapshot.docs
          .map((doc) => FAQss.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return faqs;
    } catch (error) {
      print('Error retrieving FAQs: $error');
      return [];
    }
  }

  Future<List<Quizz>> getRandomQuizz() async {
    try {
      // Get all documents from the 'Quizz' collection
      QuerySnapshot quizzSnapshot = await _db.collection('Quizz').get();

      // Check if there are any documents
      if (quizzSnapshot.docs.isEmpty) {
        print('No documents found in the Quizz collection.');
        return [];
      }

      List<Quizz> quizzes = quizzSnapshot.docs
          .map((doc) => Quizz.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return quizzes;
    } catch (error) {
      print('Error retrieving random Quizz: $error');
      return [];
    }
  }

  Future<void> uploadFile(File pdfFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference =
        FirebaseStorage.instance.ref().child('pdfs/$fileName.pdf');
    UploadTask uploadTask = reference.putFile(pdfFile);

    await uploadTask.whenComplete(() => print('File Uploaded'));
  }

  Future<String> _downloadPDF(String storagePath) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String tempPath = tempDir.path;
    final String filePath = '$tempPath/example.pdf';

    try {
      await firebase_storage.FirebaseStorage.instance
          .ref(storagePath)
          .writeToFile(File(filePath));
      return filePath;
    } catch (e) {
      print('Error downloading PDF: $e');
      return '';
    }
  }

  // Stream for monitoring changes in a specific article in the 'Program' collection
  Stream<Program> streamProgram(String aid) {
    var user = AuthService().user;
    if (user != null) {
      var ref = _db.collection('Program').doc(aid);
      return ref.snapshots().map((doc) => Program.fromJson(doc.data()!));
    } else {
      return Stream.fromIterable([
        Program(
            startDate: Timestamp.now(),
            endDate: Timestamp.now(),
            activities: [])
      ]);
    }
  }

  // Stream for monitoring changes in the user's articles in the 'patient programs' collection
  Stream<List<Program>> streamPatientPrograms(String pid) {
    var ref = _db.collection('Program');
    return ref
        .where('Patient Number', isEqualTo: pid)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => Program.fromJson(doc.data()))
          .toList();
    });
  }

  Future<void> addProgram(Program program) async {
    try {
      await _db.collection('Program').doc(program.pid).set({
        'Program ID': program.pid,
        'Patient Number': program.patientNum,
        'Start Date': program.startDate,
        'End Date': program.endDate,
        'NumberOfActivities': program.numofAct,
        'Activities': program.activities,
      });
    } catch (e) {
      print('Error adding program: $e');
      rethrow;
    }
  }

  // Stream for monitoring changes in Report
  Stream<List<Report>> streamPatientReports(String pid) {
    var ref = _db.collection('Report');
    return ref
        .where('Patient Number', isEqualTo: pid)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => Report.fromJson(doc.data()))
          .toList();
    });
  }

  Stream<Report> streamReport(String pid) {
    var ref = _db.collection('Report');
    return ref
        .where('Program ID', isEqualTo: pid)
        .limit(1) // Limit the query to one document
        .snapshots()
        .map((snapshot) => Report.fromJson(snapshot.docs.first.data()));
  }



}
