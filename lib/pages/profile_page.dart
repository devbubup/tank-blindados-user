import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref().child('users');
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (_user != null) {
      DataSnapshot snapshot = await _userRef.child(_user!.uid).get();
      Map userData = snapshot.value as Map;
      setState(() {
        _nameController.text = userData['name'];
        _phoneController.text = userData['phone'];
        _emailController.text = _user!.email ?? '';
      });
    }
  }

  Future<void> _updateUserProfile() async {
    if (_user != null) {
      String newName = _nameController.text;
      String newPhone = _phoneController.text;
      String newEmail = _emailController.text;

      // Update email in Firebase Authentication
      if (newEmail != _user!.email) {
        await _user!.updateEmail(newEmail);
      }

      // Update user data in Firebase Realtime Database
      await _userRef.child(_user!.uid).update({
        'name': newName,
        'phone': newPhone,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Telefone'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserProfile,
              child: const Text('Atualizar'),
            ),
          ],
        ),
      ),
    );
  }
}
