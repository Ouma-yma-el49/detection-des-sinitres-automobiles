import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loginapp/pages/AboutPage.dart';
import 'package:loginapp/pages/welcome_page.dart';
import 'PersonalInfoPage.dart';
import 'DeclarationSinPage.dart';
import 'SinistreHistoryPage.dart';
import 'home.dart';
import 'DetectionSinPage.dart';
import 'welcome_page.dart';
import 'AboutPage.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({Key? key}) : super(key: key);


  // Cette méthode récupère l'utilisateur actuel via FirebaseAuth
  static String _getUserName() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.displayName?.isNotEmpty ?? false
          ? user.displayName!
          : user.email?.split('@')[0] ?? 'Utilisateur';  // Récupère l'email si le displayName est vide
    }
    return 'Utilisateur';  // Si l'utilisateur n'est pas connecté
  }

  // Cette méthode est aussi devenue statique
  static String _getGreetingMessage() {
    final int hour = DateTime.now().hour;
    String userName = _getUserName();  // Récupère le nom de l'utilisateur
    if (hour < 18) {
      return 'Bonjour, $userName';  // Bonjour avant 18h
    } else {
      return 'Bonsoir, $userName';  // Bonsoir après 18h
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Partie supérieure avec les éléments de menu
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A237E),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Affichage du message personnalisé
                      Text(
                        _getGreetingMessage(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Simplifiez vos démarches automobiles',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.home,
                  label: 'Accueil',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.person,
                  label: 'Mes Infos',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PersonalInfoPage()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.warning,
                  label: 'Détection de Sinistres',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DetectionSinPage()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.report,
                  label: 'Déclaration de Sinistres',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DeclarationSinPage()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.archive,
                  label: 'Historique de Sinistres',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SinistreHistoryPage()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.person,
                  label: 'A propos',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AboutPage()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Spacer pushant "Se déconnecter" vers le bas

          // Partie inférieure avec l'élément "Se déconnecter"
          _buildDrawerItem(
            context,
            icon: Icons.exit_to_app,
            label: 'Se déconnecter',
            onPressed: () {
              // Ajoutez ici l'action pour déconnecter l'utilisateur
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const WelcomePage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon,
        required String label,
        required VoidCallback onPressed}) {
    return ListTile(
      leading: Icon(icon, color: const Color.fromARGB(255, 18, 16, 60)),
      title: Text(label, style: const TextStyle(fontSize: 18)),
      onTap: onPressed,
    );
  }
}
