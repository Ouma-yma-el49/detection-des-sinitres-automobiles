import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'menu_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetectionSinPage extends StatefulWidget {
  const DetectionSinPage({Key? key}) : super(key: key);

  @override
  _DetectionSinPageState createState() => _DetectionSinPageState();
}

class _DetectionSinPageState extends State<DetectionSinPage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  late Interpreter _interpreter;
  List<String> _labels = [];
  List<Map<String, dynamic>> _savedResults = [];
  String _result = "No Result";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadModelAndLabels();
    _fetchSavedResults();
  }

  Future<void> _fetchSavedResults() async {
    try {
      final querySnapshot = await _firestore.collection('detection_results').get();
      final results = querySnapshot.docs.map((doc) {
        return {
          'result': doc['result'],
          'timestamp': doc['timestamp'].toDate(),
        };
      }).toList();

      setState(() {
        _savedResults = results;
      });
    } catch (e) {
      print('Error fetching results: $e');
    }
  }

  Future<void> _loadModelAndLabels() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      final labelData = await DefaultAssetBundle.of(context).loadString('assets/labels.txt');
      _labels = labelData.split('\n');
      print('Model and labels loaded successfully');
    } catch (e) {
      print('Error loading model or labels: $e');
    }
  }

  Future<void> _runModelOnImage() async {
    if (_image == null) {
      setState(() {
        _result = "Aucune image sélectionnée";
      });
      return;
    }

    try {
      final img.Image imageInput = img.decodeImage(await _image!.readAsBytes())!;
      final img.Image resizedImage = img.copyResize(imageInput, width: 224, height: 224);
      final input = _preprocessImage(resizedImage);
      final output = List.generate(1, (_) => List.filled(2, 0.0), growable: false);

      _interpreter.run(input.reshape([1, 224, 224, 3]), output);
      final topResult = _getTopRecognition(output);
      setState(() {
        _result = "Résultat : ${topResult['label']} (Confiance : ${(topResult['confidence'] * 100).toStringAsFixed(2)}%)";
      });
    } catch (e) {
      print('Error during inference: $e');
      setState(() {
        _result = "Erreur pendant l'inférence";
      });
    }
  }

  Future<void> _saveResultToFirestore() async {
    if (_result == "No Result" || _result == "Aucune image sélectionnée") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Aucun résultat à enregistrer')));
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Utilisateur non authentifié')));
      return;
    }

    try {
      await _firestore.collection('detection_results').add({
        'result': _result,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user.uid,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Résultat enregistré avec succès')));
    } catch (e) {
      print('Erreur lors de l\'enregistrement du résultat : $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de l\'enregistrement')));
    }
  }

  Float32List _preprocessImage(img.Image image) {
    final input = Float32List(1 * 224 * 224 * 3);
    int index = 0;

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = image.getPixel(x, y);
        input[index++] = (pixel.r / 127.5) - 1.0; // Red
        input[index++] = (pixel.g / 127.5) - 1.0; // Green
        input[index++] = (pixel.b / 127.5) - 1.0; // Blue
      }
    }
    return input;
  }

  Map<String, dynamic> _getTopRecognition(List<List<double>> output) {
    final scores = output[0];
    int maxIndex = 0;
    double maxScore = scores[0];
    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > maxScore) {
        maxScore = scores[i];
        maxIndex = i;
      }
    }
    return {
      'label': _labels[maxIndex],
      'confidence': maxScore,
    };
  }

  Future<void> _pickImage({required ImageSource source}) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = "Analyser..";
      });
      await _runModelOnImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détection des Sinistres'),
        backgroundColor: Color(0xFF1A237E), // Un bleu foncé élégant
        foregroundColor: Colors.white,
        elevation: 4, // Légère ombre pour un effet moderne
      ),
      drawer: const MenuDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'La détection des sinistres consiste à analyser les images de véhicules pour identifier des dommages. Utilisez la caméra ou la galerie pour télécharger une image.',
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.grey[700]),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 24),
              if (_image != null)
                Image.file(
                  _image!,
                  width: 300,
                  height: 300,
                ),
              SizedBox(height: 16),
              Text(
                _result,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _pickImage(source: ImageSource.camera),
                icon: Icon(Icons.camera_alt),
                label: Text('Prendre une photo'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color(0xFF1A237E),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),

              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _pickImage(source: ImageSource.gallery),
                icon: Icon(Icons.photo_album),
                label: Text('Sélectionner depuis la galerie'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _saveResultToFirestore,
                icon: Icon(Icons.save_alt),
                label: Text('Enregistrer le résultat'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
