import 'package:flutter/material.dart';
import 'package:amazingym_app/api_connection/api_connection.dart';
import 'dart:convert';
import 'package:amazingym_app/bottom_navigation_bar.dart';
import 'package:amazingym_app/login.dart';


class MembershipsPage extends StatefulWidget {
  const MembershipsPage({super.key});

  @override
  _MembershipsPageState createState() => _MembershipsPageState();
}

class _MembershipsPageState extends State<MembershipsPage> {
  Future<List<dynamic>> fetchMemberships() async {
    final response = await API.getRequest('membership/memberships');
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return jsonResponse['data'];
      } else {
        throw Exception(
            'Failed to load memberships: ${jsonResponse['message']}');
      }
    } else {
      throw Exception(
          'Failed to load memberships, status code: ${response.statusCode}, body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Memberships', style: TextStyle(color: Colors.green)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
          ),
        ],
      ),
      body: _buildMembershipList(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onItemSelected: (index) {},
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.green),
          ),
          title: const Text('Logout', style: TextStyle(color: Colors.green)),
          content: const Text('Are you sure you want to log out?',
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Logout',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMembershipList() {
    return FutureBuilder<List<dynamic>>(
      future: fetchMemberships(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.green));
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.white)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text('No memberships found',
                  style: TextStyle(color: Colors.white)));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final membership = snapshot.data![index];
              return Card(
                color: Colors.black,
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.green)),
                child: ListTile(
                  title: Text(membership['name'],
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text('Price: ${membership['price']} VND',
                      style: const TextStyle(color: Colors.white70)),
                ),
              );
            },
          );
        }
      },
    );
  }
}
