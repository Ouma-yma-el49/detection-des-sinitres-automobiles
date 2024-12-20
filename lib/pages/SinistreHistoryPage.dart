import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'menu_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SinistreHistoryPage extends StatefulWidget {
  const SinistreHistoryPage({Key? key}) : super(key: key);

  @override
  _SinistreHistoryPageState createState() => _SinistreHistoryPageState();
}

class _SinistreHistoryPageState extends State<SinistreHistoryPage> {
  List<Map<String, dynamic>> _declarationsHistory = [];

  @override
  void initState() {
    super.initState();
    _loadDeclarationsHistory();
  }

  Future<void> _loadDeclarationsHistory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('declarations')
            .where('userId', isEqualTo: user.uid)  // Filtrer par userId
            .orderBy('timestamp', descending: true)
            .get();

        setState(() {
          _declarationsHistory = querySnapshot.docs.map((doc) {
            // Inclure l'ID dans les données
            var data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Ajouter l'ID du document
            return data;
          }).toList();
        });
      } else {
        _showSnackbar("Erreur : L'utilisateur n'est pas connecté");
      }
    } catch (e) {
      _showSnackbar('Erreur lors du chargement des déclarations : $e');
    }
  }
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique des Sinistres"),
        backgroundColor: Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      drawer: const MenuDrawer(),
      body: ListView.builder(
        itemCount: _declarationsHistory.length,
        itemBuilder: (context, index) {
          final declaration = _declarationsHistory[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(declaration['description'] ?? ''),
              subtitle: Text(declaration['date'] ?? ''),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  if (await _showDeleteConfirmation()) {
                    await _deleteDeclaration(declaration);
                  }
                },
              ),
              onTap: () {
                _showDeclarationDetails(declaration);
              },

            ),
          );
        },
      ),
    );
  }

  void _showDeclarationDetails(Map<String, dynamic> declaration) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Détails de la Déclaration"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Modèle véhicule: ${declaration['carModel']}'),
                Text('Matricule: ${declaration['carPlate']}'),
                Text('Dommages: ${declaration['damages']}'),
                Text('Témoins: ${declaration['witnesses']}'),
                Text('Date: ${declaration['date']}'),
                Text('Heure: ${declaration['time']}'),
                Text('Résultat de la détection: ${declaration['result']}'),
              ],
            ),
          ),
          actions: [

            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _downloadDeclaration(declaration); // Télécharger la déclaration
              },
              child: Row(
                children: [
                  Icon(Icons.download,
                      color: Colors.blue), // Icône de téléchargement en bleu
                  const SizedBox(width: 8),
                  const Text('Télécharger'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
  Future<void> _downloadDeclaration(Map<String, dynamic> declaration) async {
    try {
      // Obtenir le chemin du répertoire des documents
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/declaration_${DateTime.now().millisecondsSinceEpoch}.txt';

      // Créer le contenu du fichier
      final content = '''
    Description: ${declaration['description']}
    Dommages: ${declaration['damages']}
    Témoins: ${declaration['witnesses']}
    Date: ${declaration['date']}
    Heure: ${declaration['time']}
    Résultat de la détection: ${declaration['result']}
    ''';

      // Créer le fichier et y écrire le contenu
      final file = File(filePath);
      await file.writeAsString(content);

      // Afficher un message de succès
      _showSnackbar('Déclaration téléchargée avec succès: $filePath');
    } catch (e) {
      _showSnackbar('Erreur lors du téléchargement : $e');
    }
  }
  Future<void> _deleteDeclaration(Map<String, dynamic> declaration) async {
    final declarationId =
    declaration['id']; // L'ID est inclus dans chaque déclaration
    if (declarationId == null) {
      _showSnackbar('L\'ID de la déclaration est introuvable');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('declarations')
          .doc(declarationId) // Utiliser l'ID pour la suppression
          .delete();
      _showSnackbar('Déclaration supprimée avec succès');
      await _loadDeclarationsHistory(); // Recharger l'historique après suppression
    } catch (e) {
      _showSnackbar('Erreur lors de la suppression : $e');
    }
  }
  Future<bool> _showDeleteConfirmation() async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmer la suppression"),
          content: const Text(
              "Êtes-vous sûr de vouloir supprimer cette déclaration ?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
    return confirmDelete ?? false;
  }
}
