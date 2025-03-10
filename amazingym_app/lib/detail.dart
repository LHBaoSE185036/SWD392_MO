import 'package:flutter/material.dart';
import 'package:amazingym_app/api_connection/api_connection.dart';
import 'dart:convert';

class CustomerDetailPage extends StatefulWidget {
  final int customerId;

  const CustomerDetailPage({Key? key, required this.customerId}) : super(key: key);

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

  Future<Map<String, dynamic>> fetchCustomerDetails(int customerId) async {
    final response = await API.getRequest('customer/$customerId');
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return jsonResponse['data'];
      } else {
        throw Exception('Failed to load customer details: ${jsonResponse['message']}');
      }
    } else {
      throw Exception('Failed to load customer details, status code: ${response.statusCode}, body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Nền màu đen
      appBar: AppBar(
        title: const Text('Customer Detail', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green, // AppBar màu xanh lá
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: customer,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'No customer details found',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            final customer = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Hiển thị ảnh khách hàng nếu có
                  if (customer['faceURL'] != null)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 3),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.green.withOpacity(0.5), blurRadius: 8, spreadRadius: 2),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          customer['faceURL'],
                          height: 300,
                          width: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    const Text('No face image available', style: TextStyle(fontSize: 18, color: Colors.white70)),
                  
                  const SizedBox(height: 20),

                  
                  Card(
                    color: Colors.black,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.green),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Full Name', customer['fullName']),
                          _buildInfoRow('Email', customer['email']),
                          _buildInfoRow('Phone', customer['phoneNumber']),
                          _buildInfoRow('Status', customer['status']),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // Widget để tạo dòng thông tin
  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(fontSize: 18, color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
