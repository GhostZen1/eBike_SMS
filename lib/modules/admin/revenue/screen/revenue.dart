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
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  double totalRevenue = 0.0;
  bool isLoading = false; // Added loading state

  @override
  void initState() {
    super.initState();
    _fetchTransactions(); // Default to the current month
    _searchController.addListener(() {
      _filterTransactions(_searchController.text);
    });
  }

  Map<int, double> weeklyRevenue = {}; // To hold revenue for each week (1–5).

  void _fetchTransactions([String? selectedMonthYear]) async {
    try {
      setState(() {
        isLoading = true;  // Start loading
      });

      final fetchedTransactionsMap =
          await TransactionService.fetchTransactionDetails();

      String monthYear =
          selectedMonthYear ?? DateFormat('MMMM yyyy').format(DateTime.now());

      List<Transaction> currentMonthTransactions =
          fetchedTransactionsMap[monthYear] ?? [];

      // Initialize weeklyRevenue map for the selected month
      weeklyRevenue = {for (var i = 1; i <= 5; i++) i: 0.0};

      for (var transaction in currentMonthTransactions) {
        DateTime transactionDate = DateTime.parse(transaction.transactionDate);

        // Calculate the week number within the month
        int weekNumber = ((transactionDate.day - 1) / 7).floor() + 1;
        if (weekNumber >= 1 && weekNumber <= 5) {
          weeklyRevenue[weekNumber] = (weeklyRevenue[weekNumber] ?? 0.0) +
              (double.tryParse(transaction.transactionTotal) ?? 0.0);
        }
      }

      setState(() {
        groupedTransactions = fetchedTransactionsMap;
        transactions = currentMonthTransactions;
        filteredTransactions = transactions;

        // Calculate total revenue for the current month
        totalRevenue = _calculateTotalRevenueForMonth(monthYear);
        isLoading = false;  // Stop loading
      });
    } catch (e) {
      setState(() {
        isLoading = false;  // Stop loading in case of error
      });
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

  List<double> _calculateWeeklyTotalsForMonth(int monthIndex) {
    List<double> weeklyTotals = List.filled(5, 0.0); // Supports up to 5 weeks
    for (var transaction in transactions) {
      DateTime transactionDate = DateTime.parse(transaction.transactionDate);
      if (transactionDate.month == monthIndex + 1) {
        int weekNumber =
            ((transactionDate.day - 1) ~/ 7); // Calculate week number
        weeklyTotals[weekNumber] +=
            double.tryParse(transaction.transactionTotal) ?? 0.0;
      }
    }
    return weeklyTotals;
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
    if (isLoading) return;  // Prevent clicks while loading
    setState(() {
      // Update the current month index when the donut chart is clicked
      currentMonthIndex = (currentMonthIndex + 1) % 12;

      // Update the selected month and year
      String selectedMonthYear =
          "${monthNames[currentMonthIndex]} ${DateTime.now().year}";

      // Fetch transactions for the new month
      _fetchTransactions(selectedMonthYear);

      // Recalculate the total revenue for the selected month
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
                  isLoading
                      ? const Center(child: CircularProgressIndicator())  // Show loading spinner
                      : GestureDetector(
                          onTap: _onDonutChartClick,
                          child: PieChartWidget(
                            monthName: '${monthNames[currentMonthIndex]}',
                            weeklyTotals:
                                _calculateWeeklyTotalsForMonth(currentMonthIndex),
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
              transactions.isEmpty
                  ? const Text(
                      'No Data Available for this month',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    )
                  : Text(
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
