import 'package:flutter/material.dart';
import 'package:amazingym_app/api_connection/api_connection.dart';
import 'package:amazingym_app/detail.dart';
import 'dart:convert';
import 'package:amazingym_app/bottom_navigation_bar.dart';
import 'package:amazingym_app/login.dart'; // Import trang login

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;

  Future<List<dynamic>> fetchCustomers() async {
    final response = await API.getRequest('customer/customers');
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return jsonResponse['data'];
      } else {
        throw Exception('Failed to load customers: ${jsonResponse['message']}');
      }
    } else {
      throw Exception(
          'Failed to load customers, status code: ${response.statusCode}, body: ${response.body}');
    }
  }

  /// Nút log out
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
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Amazing Gym', style: TextStyle(color: Colors.green)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentPageIndex,
        onItemSelected: (index) {
          setState(() {
            currentPageIndex = index;
          });
        },
      ),
      body: _getPage(currentPageIndex),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return _buildCustomerList();
      case 1:
        return const WorkoutsContent();
      case 2:
        return const ProfileContent();
      default:
        return _buildCustomerList();
    }
  }

  Widget _buildCustomerList() {
    return FutureBuilder<List<dynamic>>(
      future: fetchCustomers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No customers found', style: TextStyle(color: Colors.white)));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final customer = snapshot.data![index];
              return Card(
                color: Colors.black,
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.green)),
                child: ListTile(
                  title: Text(customer['fullName'], style: const TextStyle(color: Colors.white)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${customer['email']}', style: const TextStyle(color: Colors.white70)),
                      Text('Phone: ${customer['phoneNumber']}', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerDetailPage(
                              customerId: customer['customerId']),
                        ),
                      );
                    },
                    child: const Text('Detail'),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}

/// Workout Page
class WorkoutsContent extends StatelessWidget {
  const WorkoutsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Workouts Page Content',
        style: TextStyle(fontSize: 24, color: Colors.green),
      ),
    );
  }
}

/// Profile Page
class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Profile Page Content',
        style: TextStyle(fontSize: 24, color: Colors.green),
      ),
    );
  }
}
