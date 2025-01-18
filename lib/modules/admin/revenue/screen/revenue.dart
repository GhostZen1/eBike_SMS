import 'package:intl/intl.dart'; // Add this import for DateFormat
import 'package:ebikesms/modules/global_import.dart';
import 'package:ebikesms/modules/admin/revenue/controller/transaction_detail.dart'; // Import your transaction detail file
import 'package:ebikesms/modules/admin/stat/statisticScreen.dart'; // Import your transaction detail file

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  _RevenueScreenState createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  // Add a TextEditingController to control the search input
  TextEditingController _searchController = TextEditingController();

  // List of transactions for the selected month
  List<Transaction> transactions = [];
  List<Transaction> filteredTransactions = []; // Store filtered transactions
  // Map of transactions grouped by month-year
  Map<String, List<Transaction>> groupedTransactions = {};
  // Current month and index for month switching
  int currentMonthIndex = DateTime.now().month - 1;
  // List of month names
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

  // Total revenue for the selected month
  double totalRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();

    // Listen for changes in the search bar
    _searchController.addListener(() {
      _filterTransactions(_searchController.text);
    });
  }

  // Fetch the transactions and group them by month-year
  void _fetchTransactions([String? selectedMonthYear]) async {
    try {
      final fetchedTransactionsMap =
          await TransactionService.fetchTransactionDetails();

      // If selectedMonthYear is provided, we use it, otherwise use the current month
      String monthYear =
          selectedMonthYear ?? DateFormat('MMMM yyyy').format(DateTime.now());

      // Log the transactions for debugging
      print('Fetched transactions for: $monthYear');
      print(fetchedTransactionsMap);

      // Fetch the transactions for the selected month-year
      List<Transaction> currentMonthTransactions =
          fetchedTransactionsMap[monthYear] ?? [];

      setState(() {
        groupedTransactions =
            fetchedTransactionsMap; // Update grouped transactions
        transactions =
            currentMonthTransactions; // Set transactions for the selected month
        filteredTransactions = transactions; // Initialize filtered transactions
        totalRevenue = _calculateTotalRevenueForMonth(selectedMonthYear ??
            DateFormat('MMMM yyyy')
                .format(DateTime.now())); // Recalculate total revenue
      });

      print("Transactions for $monthYear: ${transactions.length}");
    } catch (e) {
      print("Error fetching transactions: $e");
    }
  }

  // Filter transactions based on the search text (Transaction ID)
  void _filterTransactions(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredTransactions =
            transactions; // Show all transactions when search is empty
      });
    } else {
      setState(() {
        filteredTransactions = transactions
            .where((transaction) =>
                transaction.transactionId.toString().contains(query))
            .toList(); // Filter transactions by matching the ID
      });
    }
  }

  // Calculate the total revenue for the selected month
  double _calculateTotalRevenueForMonth(String selectedMonthYear) {
    double total = 0.0;
    for (var transaction in groupedTransactions[selectedMonthYear] ?? []) {
      total += double.tryParse(transaction.transactionTotal) ?? 0.0;
    }
    return total;
  }

  // Handle month switching when donut chart is clicked
  void _onDonutChartClick() {
    setState(() {
      currentMonthIndex = (currentMonthIndex + 1) % 12;
      String selectedMonthYear =
          "${monthNames[currentMonthIndex]} ${DateTime.now().year}";

      print('Selected Month: $selectedMonthYear');

      _fetchTransactions(
          selectedMonthYear); // Fetch transactions for the new month
      totalRevenue = _calculateTotalRevenueForMonth(selectedMonthYear);

      print("Total revenue for $selectedMonthYear: $totalRevenue");
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
              // Donut Chart Placeholder this is the chart
              Column(
                children: [
                  const Text(
                    'Revenue',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                      onTap: _onDonutChartClick,
                      child: PieChartWidget(monthName: '${monthNames[currentMonthIndex]}')
                      ),
                  // GestureDetector(
                  //   onTap: _onDonutChartClick,
                  //   child: Container(
                  //     height: 150,
                  //     width: 150,
                  //     decoration: BoxDecoration(
                  //       shape: BoxShape.circle,
                  //       color: Colors.grey.shade200,
                  //     ),
                  //     child: Center(
                  //       child: Text(
                  //         'Month\n${monthNames[currentMonthIndex]}',
                  //         textAlign: TextAlign.center,
                  //         style: const TextStyle(
                  //             fontSize: 18, fontWeight: FontWeight.bold),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [],
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
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ColorConstant.darkBlue),
              ),
              const SizedBox(height: 20),

              // Search Bar
              TextField(
                controller:
                    _searchController, // Attach controller to the text field
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
                        print(
                            'Displaying transaction: ${transaction.toString()}');

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
    return Row(
      children: [
        Container(
          height: 8,
          width: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 5),
        Text(label),
        const SizedBox(width: 15),
      ],
    );
  }
}
