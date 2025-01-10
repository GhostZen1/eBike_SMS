import 'package:intl/intl.dart'; // Add this import for DateFormat
import 'package:ebikesms/modules/global_import.dart';
import 'package:ebikesms/modules/admin/revenue/controller/transaction_detail.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  _RevenueScreenState createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  // Map to hold the grouped transactions by month
  List<Transaction> transactions = [];
  // Grouped transactions by month-year
  Map<String, List<Transaction>> groupedTransactions = {};
  // Current month
  String currentMonth = '';
  // Variable to hold the total revenue for the current month
  double totalRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
    currentMonth = _getCurrentMonth();
  }

  // Method to fetch the transaction details
  void _fetchTransactions() async {
    try {
      final fetchedTransactionsMap =
          await TransactionService.fetchTransactionDetails();

      // Access the current month's transactions
      String currentMonthYear = DateFormat('MMMM yyyy').format(DateTime.now());
      List<Transaction> currentMonthTransactions =
          fetchedTransactionsMap[currentMonthYear] ??
              []; // This gives you the List<Transaction>

      setState(() {
        groupedTransactions = fetchedTransactionsMap;
        transactions = currentMonthTransactions;
        totalRevenue = _calculateTotalRevenueForCurrentMonth();
        print(groupedTransactions);
      });
    } catch (e) {
      print("Error fetching transactions: $e");
    }
  }

  // Group the transactions by month-year
  Map<String, List<Transaction>> _groupTransactionsByMonth(
      List<Transaction> transactions) {
    Map<String, List<Transaction>> grouped = {};
    for (var transaction in transactions) {
      DateTime transactionDate = DateTime.parse(transaction.transactionDate);
      String monthYear =
          DateFormat('MMMM yyyy').format(transactionDate); // "JANUARY 2025"
      if (!grouped.containsKey(monthYear)) {
        grouped[monthYear] = [];
      }
      grouped[monthYear]!.add(transaction);
    }
    return grouped;
  }

  // Calculate the total revenue for the current month
  double _calculateTotalRevenueForCurrentMonth() {
    double total = 0.0;
    DateTime now = DateTime.now();
    String currentMonthYear = DateFormat('MMMM yyyy')
        .format(now); // Get current month and year, e.g., "JANUARY 2025"
    for (var transaction in groupedTransactions[currentMonthYear] ?? []) {
      total += double.tryParse(transaction.transactionTotal) ?? 0.0;
    }
    return total;
  }

  // Get current month in a readable format
  String _getCurrentMonth() {
    DateTime now = DateTime.now();
    List<String> monthNames = [
      "JANUARY",
      "FEBRUARY",
      "MARCH",
      "APRIL",
      "MAY",
      "JUNE",
      "JULY",
      "AUGUST",
      "SEPTEMBER",
      "OCTOBER",
      "NOVEMBER",
      "DECEMBER"
    ];
    return monthNames[now.month - 1];
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
                  // Replace this container with an actual chart widget
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                    ),
                    child: Center(
                      child: Text(
                        'Month\n$currentMonth', // Dynamic month
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendIndicator(Colors.pink, 'Today'),
                      _buildLegendIndicator(Colors.yellow, 'Week'),
                      _buildLegendIndicator(ColorConstant.darkBlue, 'Month'),
                    ],
                  ),
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
                'RM ${totalRevenue.toStringAsFixed(2)}', // Dynamically calculated revenue
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ColorConstant.darkBlue),
              ),
              const SizedBox(height: 20),

              // Search Bar
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  labelText: 'Search User Transaction',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Transaction History for the current month
              groupedTransactions.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactions
                          .length, // Use `transactions` instead of `groupedTransactions`
                      itemBuilder: (context, index) {
                        final transaction = transactions[
                            index]; // Access the transaction for current month
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

  Widget _buildLegendIndicator(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
}
