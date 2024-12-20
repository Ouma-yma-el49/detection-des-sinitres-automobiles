import 'package:flutter/material.dart';

import 'menu_drawer.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('À propos', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 5,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: const MenuDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'À propos de l\'application',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 18, 16, 60),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Cette application utilise l\'intelligence artificielle pour détecter les dommages automobiles à partir de photos. Elle permet aux utilisateurs de prendre des photos des véhicules, de les analyser en temps réel et d\'enregistrer les résultats dans une base de données pour un suivi futur.',
                style: TextStyle(fontSize: 18, color: Colors.black54),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 30),

              // Fonctionnalités principales
              _buildSectionTitle('Fonctionnalités principales'),
              _buildFeatureItem(Icons.camera_alt, 'Capture de photos de véhicules'),
              _buildFeatureItem(Icons.analytics, 'Détection de sinistres avec IA'),
              _buildFeatureItem(Icons.save, 'Enregistrement des résultats dans Firestore'),
              SizedBox(height: 30),

              // Technologies utilisées
              _buildSectionTitle('Technologies utilisées'),
              _buildTechItem(Icons.code, 'Flutter (Développement mobile)'),
              _buildTechItem(Icons.cloud, 'Firebase (Stockage et authentification)'),
              _buildTechItem(Icons.device_hub, 'TensorFlow Lite (Modèle IA)'),
              SizedBox(height: 30),

              // Développeurs
              _buildSectionTitle('Développé par :'),
              Text(
                'Nom de l\'équipe : Groupe G\n\n'
                    'Membres : Oumaima - Nadia - Hamza - Abla',
                style: TextStyle(fontSize: 18, color: Colors.black54),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 30),

              // Contact
              _buildSectionTitle('Contact & Support'),
              Text(
                'Pour toute question, veuillez nous contacter à :\n',
                style: TextStyle(fontSize: 17, color: Colors.black54),
                textAlign: TextAlign.justify,
              ),
              Text(
                'support@exemple.com',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construction d'un titre de section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Color.fromARGB(255, 18, 16, 60),
        ),
      ),
    );
  }

  // Construction des éléments de fonctionnalité
  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Color.fromARGB(255, 18, 16, 60),
            size: 28,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // Construction des éléments de technologie
  Widget _buildTechItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Color.fromARGB(255, 18, 16, 60),
            size: 28,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
