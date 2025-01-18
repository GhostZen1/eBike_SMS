import 'package:intl/intl.dart'; // Add this import for DateFormat
import 'package:flutter/material.dart'; // Assuming the rest of the imports are already there
import 'package:ebikesms/modules/global_import.dart';
import 'package:ebikesms/modules/admin/revenue/controller/transaction_detail.dart';
import 'package:ebikesms/modules/admin/stat/statisticScreen.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  _RevenueScreenState createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  TextEditingController _searchController = TextEditingController();

  List<Transaction> transactions = [];
  List<Transaction> filteredTransactions = [];
  Map<String, List<Transaction>> groupedTransactions = {};

  int currentMonthIndex = DateTime.now().month - 1;
  List<String> monthNames = [
    "January", "February", "March", "April", "May", "June", "July",
    "August", "September", "October", "November", "December"
  ];

  double totalRevenue = 0.0;
  double totalToday = 0.0;
  double totalWeek = 0.0;
  double totalMonth = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();

    _searchController.addListener(() {
      _filterTransactions(_searchController.text);
    });
  }

  void _fetchTransactions([String? selectedMonthYear]) async {
    try {
      final fetchedTransactionsMap =
          await TransactionService.fetchTransactionDetails();

      String monthYear =
          selectedMonthYear ?? DateFormat('MMMM yyyy').format(DateTime.now());

      List<Transaction> currentMonthTransactions =
          fetchedTransactionsMap[monthYear] ?? [];

      setState(() {
        groupedTransactions = fetchedTransactionsMap;
        transactions = currentMonthTransactions;
        filteredTransactions = transactions;
        totalRevenue = _calculateTotalRevenueForMonth(selectedMonthYear ?? DateFormat('MMMM yyyy').format(DateTime.now()));

        // Calculate total for today, this week, and this month
        totalToday = _calculateTotalRevenueForToday();
        totalWeek = _calculateTotalRevenueForWeek();
        totalMonth = totalRevenue; // Use the total revenue for the selected month
      });
    } catch (e) {
      print("Error fetching transactions: $e");
    }
  }

  double _calculateTotalRevenueForMonth(String selectedMonthYear) {
    double total = 0.0;
    for (var transaction in groupedTransactions[selectedMonthYear] ?? []) {
      total += double.tryParse(transaction.transactionTotal) ?? 0.0;
    }
    return total;
  }

  double _calculateTotalRevenueForToday() {
    double total = 0.0;
    DateTime today = DateTime.now();
    for (var transaction in transactions) {
      DateTime transactionDate = DateTime.parse(transaction.transactionDate);
      if (transactionDate.year == today.year &&
          transactionDate.month == today.month &&
          transactionDate.day == today.day) {
        total += double.tryParse(transaction.transactionTotal) ?? 0.0;
      }
    }
    return total;
  }

  double _calculateTotalRevenueForWeek() {
    double total = 0.0;
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    for (var transaction in transactions) {
      DateTime transactionDate = DateTime.parse(transaction.transactionDate);
      if (transactionDate.isAfter(startOfWeek) && transactionDate.isBefore(now)) {
        total += double.tryParse(transaction.transactionTotal) ?? 0.0;
      }
    }
    return total;
  }

  void _filterTransactions(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredTransactions = transactions;
      });
    } else {
      setState(() {
        filteredTransactions = transactions
            .where((transaction) =>
                transaction.transactionId.toString().contains(query))
            .toList();
      });
    }
  }

  void _onDonutChartClick() {
    setState(() {
      currentMonthIndex = (currentMonthIndex + 1) % 12;
      String selectedMonthYear =
          "${monthNames[currentMonthIndex]} ${DateTime.now().year}";

      _fetchTransactions(selectedMonthYear);
      totalRevenue = _calculateTotalRevenueForMonth(selectedMonthYear);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Donut Chart Placeholder
              Column(
                children: [
                  const Text(
                    'Revenue',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _onDonutChartClick,
                    child: PieChartWidget(
                      monthName: '${monthNames[currentMonthIndex]}',
                      monthIndex: currentMonthIndex,
                      totalToday: totalToday,
                      totalWeek: totalWeek,
                      totalMonth: totalMonth,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              const SizedBox(height: 20),

              // Transaction Summary for the current month
              const Text(
                'Transaction Made',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ColorConstant.darkBlue),
              ),
              Text(
                'RM ${totalRevenue.toStringAsFixed(2)}', 
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ColorConstant.darkBlue),
              ),
              const SizedBox(height: 20),

              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  labelText: 'Search User Transaction',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 20),

              // Display "No data" message if there are no transactions
              filteredTransactions.isEmpty
                  ? const Center(
                      child: Text(
                        'No Transaction for this month',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = filteredTransactions[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Transaction ID #${transaction.transactionId}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text('UserName: ${transaction.userName}'),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        'Date: ${transaction.transactionDate}'),
                                    Text(
                                        'Time: ${transaction.obtainedRideTime}'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: ColorConstant.lightBlue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          'Transaction Detail\n#${transaction.transactionId}'),
                                      Text(
                                          'RM ${transaction.transactionTotal}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
