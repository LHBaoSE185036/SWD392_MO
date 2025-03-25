import 'package:flutter/material.dart';
import 'package:amazingym_app/api_connection/api_connection.dart';
import 'package:amazingym_app/notification_service.dart';
import 'package:amazingym_app/login.dart';
import 'package:amazingym_app/bottom_navigation_bar.dart'; // Import Navbar
import 'dart:convert';

class CheckinCustomersPage extends StatefulWidget {
  const CheckinCustomersPage({super.key});

  @override
  _CheckinCustomersPageState createState() => _CheckinCustomersPageState();
}

class _CheckinCustomersPageState extends State<CheckinCustomersPage> {
  List<dynamic> _customers = [];
  int _customerCount = 0;
  int _selectedIndex = 2;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    API.sseService?.stream.listen((data) {
      fetchActiveCustomers();
    });
  }

  Future<void> _loadInitialData() async {
    final response = await fetchCustomers();
    if (mounted) {
      setState(() {
        _customers = response['customers'];
        _customerCount = response['count'];
        _isLoading = false;
      });
    }
  }

  Future<void> fetchActiveCustomers() async {
    final response = await fetchCustomers();
    if (mounted) {
      setState(() {
        if (response['count'] > _customerCount) {
          NotificationService.instance.showLocalNotification(
            title: 'Customer Check-in',
            body: 'A new customer has checked in.',
          );
        }
        _customers = response['customers'];
        _customerCount = response['count'];
      });
    }
  }

  Future<Map<String, dynamic>> fetchCustomers() async {
    final response = await API.getRequest('customer/in-gym');
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return {
          'count': jsonResponse['data']['count'],
          'customers': jsonResponse['data']['customers']
        };
      }
    }
    return {'count': 0, 'customers': []};
  }

  void _checkoutCustomer(int customerId) async {
    final response = await API.postRequest(
      'customer-membership/check-out-manual/$customerId',
      {},
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true && mounted) {
        setState(() {
          _customers.removeWhere((customer) => customer['customerId'] == customerId);
          _customerCount = _customers.length;
        });

        NotificationService.instance.showLocalNotification(
          title: 'Customer Checked-Out',
          body: 'Customer has been checked out successfully.',
        );
      }
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _buildCustomerList(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildCustomerList() {
    if (_customers.isEmpty) {
      return const Center(
        child: Text('No customers checked in.', style: TextStyle(color: Colors.white)),
      );
    } else {
      return ListView.builder(
        itemCount: _customers.length,
        itemBuilder: (context, index) {
          final customer = _customers[index];
          return Card(
            color: Colors.black,
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.green),
            ),
            child: ListTile(
              title: Text(customer['fullName'], style: const TextStyle(color: Colors.white)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${customer['email']}', style: const TextStyle(color: Colors.white70)),
                  Text('Phone: ${customer['phoneNumber']}', style: const TextStyle(color: Colors.white70)),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      // Navigate to customer detail page
                    },
                    child: const Text('Detail'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _checkoutCustomer(customer['customerId']),
                    child: const Text('Check-Out'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
