import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final storage = const FlutterSecureStorage();

  String userId = "";
  String username = "";

  @override
  void initState() {
    super.initState();
    _loadProfileFromToken();
  }

  Future<void> _loadProfileFromToken() async {
    final token = await storage.read(key: "auth_token");

    if (token == null) {
      _logout();
      return;
    }

    try {
      final parts = token.split('.');
      if (parts.length != 3) throw Exception("Invalid token format");

      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final data = jsonDecode(payload);

      setState(() {
        userId = data["nameidentifier"]?.toString() ?? "";
        username = data["name"]?.toString() ?? "";
      });
    } catch (e) {
      debugPrint("JWT decode error: $e");
      _logout();
    }
  }

  Future<void> _logout() async {
    await storage.delete(key: 'auth_token');
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  Future<void> _deleteAccount() async {
    final token = await storage.read(key: "auth_token");
    if (token == null) return;

    try {
      final res = await http.delete(
        Uri.parse(""), //TODO: Change to api url
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        await storage.deleteAll();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete account"))
        );
      }
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel")
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              const CircleAvatar(
                radius: 45,
                backgroundColor: Color.fromRGBO(79, 152, 255, 1),
                child: Icon(Icons.person, size: 48, color: Colors.white),
              ),

              const SizedBox(height: 20),

              Text(
                username,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Text(
                "User ID: $userId",
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.3),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text("Logout", style: TextStyle(color: Colors.white)),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _confirmDelete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.3),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text("Delete Account", style: TextStyle(color: Colors.white)),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
