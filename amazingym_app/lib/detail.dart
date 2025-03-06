import 'package:flutter/material.dart';
import 'package:amazingym_app/api_connection/api_connection.dart';
import 'dart:convert';

class CustomerDetailPage extends StatefulWidget {
  final String customerId;

  const CustomerDetailPage({Key? key, required this.customerId})
      : super(key: key);

  @override
  _CustomerDetailPageState createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  late Future<Map<String, dynamic>> customer;

  @override
  void initState() {
    super.initState();
    customer = fetchCustomerDetails(widget.customerId);
  }

  Future<Map<String, dynamic>> fetchCustomerDetails(String customerId) async {
    final response = await API.getRequest('v1/customer/customer/$customerId');
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return jsonResponse['data'];
      } else {
        throw Exception(
            'Failed to load customer details: ${jsonResponse['message']}');
      }
    } else {
      throw Exception(
          'Failed to load customer details, status code: ${response.statusCode}, body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Detail'),
        backgroundColor: Colors.deepOrange,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: customer,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No customer details found'));
          } else {
            final customer = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Full Name: ${customer['fullName']}',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Email: ${customer['email']}',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Phone: ${customer['phoneNumber']}',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Status: ${customer['status']}',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  customer['faceURL'] != null
                      ? Image.network(customer['faceURL'])
                      : Text('No face image available',
                          style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
