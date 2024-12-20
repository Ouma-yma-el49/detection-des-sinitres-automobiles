import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import 'menu_drawer.dart';

class DeclarationSinPage extends StatefulWidget {
  const DeclarationSinPage({Key? key}) : super(key: key);

  @override
  _DeclarationSinPageState createState() => _DeclarationSinPageState();
}

class _DeclarationSinPageState extends State<DeclarationSinPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _damagesController = TextEditingController();
  final TextEditingController _witnessesController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();
  final TextEditingController _carPlateController = TextEditingController();
  File? _detectedImage;
  String? _detectionResult;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _declarationsHistory = [];
  List<Map<String, dynamic>> _savedResults = [];
  bool _isAccidentInfoExpanded = false;
  bool _isVehicleInfoExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadDeclarationsHistory();
    _fetchSavedResults();
  }

  Future<void> _fetchSavedResults() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('detection_results')
            .where('userId', isEqualTo: user.uid)
            .get();
        final results = querySnapshot.docs.map((doc) {
          return {
            'result': doc['result'],
            'timestamp': doc['timestamp'].toDate(),
          };
        }).toList();

        setState(() {
          _savedResults = results;
        });
      }
      } catch (e) {
      print('Error fetching results: $e');
    }
  }

  Future<void> _loadDeclarationsHistory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;

        final querySnapshot = await FirebaseFirestore.instance
            .collection('declarations')
            .where('userId', isEqualTo: userId)
            .get(); // Fixed query
        setState(() {
          _declarationsHistory = querySnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      }
    } catch (e) {
      _showSnackbar('Erreur lors du chargement des déclarations : $e');
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _detectedImage = File(image.path);
        _detectionResult = "Dommage détecté"; // Simule un résultat
      });
    }
  }

  void _saveDeclaration() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final declaration = {
            'description': _descriptionController.text,
            'damages': _damagesController.text,
            'witnesses': _witnessesController.text,
            'date': _dateController.text,
            'time': _timeController.text,
            'carModel': _carModelController.text,
            'carPlate': _carPlateController.text,
            'result': _detectionResult,
            'imagePath': _detectedImage?.path,
            'timestamp': FieldValue.serverTimestamp(),
            'userId': user.uid, // Ajout de l'ID de l'utilisateur
          };

          await FirebaseFirestore.instance.collection('declarations').add(declaration);

          _resetForm();
          await _loadDeclarationsHistory();
          _showSnackbar('Déclaration enregistrée avec succès');
        } else {
          _showSnackbar("Erreur : L'utilisateur n'est pas authentifié");
        }
      } catch (e) {
        _showSnackbar('Erreur lors de l\'enregistrement : $e');
      }
    }
  }

  void _resetForm() {
    setState(() {
      _descriptionController.clear();
      _damagesController.clear();
      _witnessesController.clear();
      _dateController.clear();
      _timeController.clear();
      _carModelController.clear();
      _carPlateController.clear();
      _detectedImage = null;
      _detectionResult = null;
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Déclaration de Sinistre"),
        backgroundColor: Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      drawer: const MenuDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Card(
                elevation: 4,
                child: ExpansionTile(
                  title: const Text("Détails de l'accident"),
                  trailing: Icon(
                    _isAccidentInfoExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.blue,
                  ),
                  onExpansionChanged: (bool expanded) {
                    setState(() {
                      _isAccidentInfoExpanded = expanded;
                    });
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description de l\'accident',
                              prefixIcon: Icon(Icons.description),
                            ),
                            validator: (value) => value!.isEmpty
                                ? 'Veuillez entrer une description'
                                : null,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _damagesController,
                            decoration: const InputDecoration(
                              labelText: 'Dommages',
                              prefixIcon: Icon(Icons.dangerous),
                            ),
                            validator: (value) => value!.isEmpty
                                ? 'Veuillez entrer des dommages'
                                : null,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _witnessesController,
                            decoration: const InputDecoration(
                              labelText: 'Témoins',
                              prefixIcon: Icon(Icons.people),
                            ),
                            validator: (value) => value!.isEmpty
                                ? 'Veuillez entrer les témoins'
                                : null,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _dateController,
                            decoration: InputDecoration(
                              labelText: 'Date',
                              prefixIcon: const Icon(Icons.date_range),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () => _selectDate(context),
                              ),
                            ),
                            validator: (value) => value!.isEmpty
                                ? 'Veuillez entrer la date'
                                : null,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _timeController,
                            decoration: InputDecoration(
                              labelText: 'Heure',
                              prefixIcon: const Icon(Icons.access_time),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.watch_later),
                                onPressed: () => _selectTime(context),
                              ),
                            ),
                            validator: (value) => value!.isEmpty
                                ? 'Veuillez entrer l\'heure'
                                : null,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                elevation: 4,
                child: ExpansionTile(
                  title: const Text("Détails du véhicule"),
                  trailing: Icon(
                    _isVehicleInfoExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.blue,
                  ),
                  onExpansionChanged: (bool expanded) {
                    setState(() {
                      _isVehicleInfoExpanded = expanded;
                    });
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _carModelController,
                            decoration: const InputDecoration(
                                labelText: 'Modèle du véhicule',
                                prefixIcon: Icon(Icons.directions_car)),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _carPlateController,
                            decoration: const InputDecoration(
                                labelText: 'Numéro d\'immatriculation',
                                prefixIcon: Icon(Icons.confirmation_number)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Résultats de la détection enregistrés",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      if (_savedResults.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _savedResults.length,
                          itemBuilder: (context, index) {
                            final detectionResult = _savedResults[index];
                            final result = detectionResult['result'] ?? "Aucun résultat";
                            final timestamp = detectionResult['timestamp'] ?? DateTime.now();
                            return CheckboxListTile(
                              title: Text("$result"),
                              subtitle: Text("Date : $timestamp"),
                              value: _detectionResult  == result, // Vérifier si ce résultat est sélectionné
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {

                                    _detectionResult = result; // Mettre à jour la sélection
                                  } else {
                                    _detectionResult = null; // Désélectionner
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ] else ...[
                        const Text("Aucun résultat de détection enregistré."),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveDeclaration,
                child: const Text('Soumettre'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != initialDate) {
      setState(() {
        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay.now();
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (pickedTime != null) {
      setState(() {
        _timeController.text = pickedTime.format(context);
      });
    }
  }
}
