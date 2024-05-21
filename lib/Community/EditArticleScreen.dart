import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditArticleScreen extends StatefulWidget {
  final String articleId;
  const EditArticleScreen({Key? key, required this.articleId}) : super(key: key);

  @override
  _EditArticleScreenState createState() => _EditArticleScreenState();
}

class _EditArticleScreenState extends State<EditArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _articleController = TextEditingController();
  final _keywordsController = TextEditingController();

  bool _isLoading = true;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadArticleData();
  }

/////////
  Future<void> _loadArticleData() async {
    var articleSnapshot = await FirebaseFirestore.instance
        .collection('Article')
        .doc(widget.articleId)
        .get();

    if (articleSnapshot.exists) {
      Map<String, dynamic> data = articleSnapshot.data()!;
      setState(() {
        _titleController.text = data['Title'];
        _articleController.text = data['Content'];
        _keywordsController.text = data['KeyWords'];
        _imageUrl = data['image'];
        _isLoading = false;
      });
    } else {
      print("Article not found!");
    }
  }

////
  Future<void> _saveArticle() async {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore.instance
          .collection('Article')
          .doc(widget.articleId)
          .update({
        'Title': _titleController.text,
        'Content': _articleController.text,
        'KeyWords': _keywordsController.text,
        // Update other fields as necessary
      }).then((_) {
        Navigator.of(context).pop(); // Return to the previous screen
      }).catchError((error) {
        // Handle errors
        print("Error updating article: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Article'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                // add validator if needed
              ),
              TextFormField(
                controller: _articleController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: null,
                // add validator if needed
              ),
              TextFormField(
                controller: _keywordsController,
                decoration: const InputDecoration(labelText: 'Keywords'),
                // add validator if needed
              ),
              // Add other fields as necessary
              ElevatedButton(
                onPressed: _saveArticle,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
