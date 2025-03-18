import 'package:amazingym_app/api_connection/api_connection.dart';
import 'package:amazingym_app/notification_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class CheckinCustomersPage extends StatefulWidget {
  const CheckinCustomersPage({super.key});

  @override
  _CheckinCustomersPageState createState() => _CheckinCustomersPageState();
}

class _CheckinCustomersPageState extends State<CheckinCustomersPage> {
  List<dynamic> _customers = [];
  int _customerCount = 0;

  @override
  void initState() {
    super.initState();
    fetchInitialCustomerCount();
    API.sseService?.stream.listen((data) {
      fetchActiveCustomers();
    });
  }

  Future<void> fetchInitialCustomerCount() async {
    try {
      final response = await fetchCustomers();
      setState(() {
        _customers = response['customers'];
        _customerCount = response['count'];
      });
    } catch (e) {
      // Handle error
      print('Error fetching initial customer count: $e');
    }
  }

  Future<void> fetchActiveCustomers() async {
    try {
      final response = await fetchCustomers();
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
    } catch (e) {
      // Handle error
      print('Error fetching customers: $e');
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
      } else {
        throw Exception('Failed to load customers: ${jsonResponse['message']}');
      }
    } else {
      throw Exception(
          'Failed to load customers, status code: ${response.statusCode}, body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check-in Customers ($_customerCount)'),
      ),
      body: _buildCustomerList(),
    );
  }

  Widget _buildCustomerList() {
    if (_customers.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return ListView.builder(
        itemCount: _customers.length,
        itemBuilder: (context, index) {
          final customer = _customers[index];
          return Card(
            child: ListTile(
              title: Text(customer['fullName']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${customer['email']}'),
                  Text('Phone: ${customer['phoneNumber']}'),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  // Navigate to customer detail page
                },
                child: Text('Detail'),
              ),
            ),
          );
        },
      );
    }
  }
}
