import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'menu_drawer.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({Key? key}) : super(key: key);

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isEditing = false; // Ajout d'un état pour le mode édition

  // Contrôleurs de texte pour permettre l'édition des informations
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController carPlateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Récupérer les données de l'utilisateur depuis Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          // Mettre à jour l'état avec les données récupérées
          setState(() {
            userData = userDoc.data(); // Données de l'utilisateur
            nameController.text = userData?['name'] ?? '';
            emailController.text = userData?['email'] ?? '';
            phoneController.text = userData?['phone'] ?? '';
            addressController.text = userData?['address'] ?? '';
            carPlateController.text = userData?['carPlate'] ?? '';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération des données utilisateur: $e');
      setState(() {
        isLoading = false;
      });
    }
  }


  // Fonction pour sauvegarder les modifications dans Firestore
  Future<void> saveUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': nameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'address': addressController.text,
          'carPlate': carPlateController.text,
        });

        setState(() {
          isEditing = false; // Désactiver le mode édition
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Données sauvegardées avec succès')),
        );
      }
    } catch (e) {
      print('Erreur lors de la sauvegarde des données: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Infos'),
          backgroundColor: Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      drawer: const MenuDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
          ? const Center(child: Text('Aucune donnée utilisateur trouvée.'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Affichage du nom
            TextField(
              controller: nameController,
              enabled:
              isEditing, // Rendre le champ éditable en mode écriture
              decoration: const InputDecoration(
                labelText: 'Nom',
              ),
            ),
            const SizedBox(height: 16),
            // Affichage de l'email
            TextField(
              controller: emailController,
              enabled: isEditing,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 16),
            // Affichage du téléphone
            TextField(
              controller: phoneController,
              enabled: isEditing,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
              ),
            ),
            const SizedBox(height: 16),
            // Affichage de l'adresse
            TextField(
              controller: addressController,
              enabled: isEditing,
              decoration: const InputDecoration(
                labelText: 'Adresse',
              ),
            ),
            const SizedBox(height: 16),
            // Affichage de la plaque de la voiture
            TextField(
              controller: carPlateController,
              enabled: isEditing,
              decoration: const InputDecoration(
                labelText: 'Matricule de la voiture',
              ),
            ),
            const SizedBox(height: 32),
            // Bouton Modifier / Sauvegarder
            Center(
              child: ElevatedButton(
                onPressed: isEditing
                    ? saveUserData
                    : () {
                  setState(() {
                    isEditing = true; // Passer en mode édition
                  });
                },
                child: Text(
                    isEditing ? 'Sauvegarder' : 'Modifier mes infos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
