import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ebikesms/ip.dart';
import 'package:intl/intl.dart';

// Class to represent a single transaction
class Transaction {
  final String transactionId;
  final String transactionDate;
  final String transactionTotal;
  final String obtainedRideTime;
  final String userName;

  Transaction({
    required this.transactionId,
    required this.transactionDate,
    required this.transactionTotal,
    required this.obtainedRideTime,
    required this.userName,
  });

  // Factory constructor to create a Transaction from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['transaction_id'],
      transactionDate: json['transaction_date'],
      transactionTotal: json['transaction_total'],
      obtainedRideTime: json['obtained_ride_time'],
      userName: json['user_name'],
    );
  }
}

// Class to represent the monthly grouped data
class MonthlyGroupedData {
  final String month;
  final String totalRevenue;
  final String totalTransactions;

  MonthlyGroupedData({
    required this.month,
    required this.totalRevenue,
    required this.totalTransactions,
  });

  // Factory constructor to create a MonthlyGroupedData from JSON
  factory MonthlyGroupedData.fromJson(Map<String, dynamic> json) {
    return MonthlyGroupedData(
      month: json['month'],
      totalRevenue: json['total_revenue'],
      totalTransactions: json['total_transactions'],
    );
  }
}

// Transaction service to fetch data
class TransactionService {
  // Fetch transaction details from the PHP backend
  static Future<Map<String, List<Transaction>>>
      fetchTransactionDetails() async {
    try {
      final url = Uri.parse("${ApiBase.baseUrl}/fetch_transaction.php");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Check if the response contains 'transaction_details' and parse the list
        if (jsonData is Map && jsonData.containsKey('transaction_details')) {
          final List<dynamic> transactionList = jsonData['transaction_details'];

          // Group transactions by month and year
          Map<String, List<Transaction>> groupedTransactions =
              _groupTransactionsByMonth(transactionList);

          return groupedTransactions; // Returning grouped transactions
        } else {
          throw Exception('Unexpected response format: ${response.body}');
        }
      } else {
        throw Exception("Failed to load transactions: ${response.statusCode}");
      }
    } catch (error) {
      throw Exception("Error fetching transactions: $error");
    }
  }

  // Group the transactions by month (e.g. "January 2025")
  static Map<String, List<Transaction>> _groupTransactionsByMonth(
      List<dynamic> transactions) {
    Map<String, List<Transaction>> grouped = {};

    for (var transactionJson in transactions) {
      // Parse transaction date
      DateTime transactionDate =
          DateTime.parse(transactionJson['transaction_date']);
      String monthYear = DateFormat('MMMM yyyy')
          .format(transactionDate); // Format as "January 2025"

      // Add to the corresponding month-year group
      if (!grouped.containsKey(monthYear)) {
        grouped[monthYear] = [];
      }
      grouped[monthYear]!.add(Transaction.fromJson(transactionJson));
    }

    return grouped;
  }
}
