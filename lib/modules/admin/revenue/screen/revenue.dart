import 'package:intl/intl.dart'; // Add this import for DateFormat
import 'package:ebikesms/modules/global_import.dart';
import 'package:ebikesms/modules/admin/revenue/controller/transaction_detail.dart'; // Import your transaction detail file

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  _RevenueScreenState createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  // List of transactions for the selected month
  List<Transaction> transactions = [];
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
  }

  // Fetch the transactions and group them by month-year
void _fetchTransactions([String? selectedMonthYear]) async {
  try {
    final fetchedTransactionsMap = await TransactionService.fetchTransactionDetails();

    // If selectedMonthYear is provided, we use it, otherwise use the current month
    String monthYear = selectedMonthYear ?? DateFormat('MMMM yyyy').format(DateTime.now());
    
    // Log the transactions for debugging
    print('Fetched transactions for: $monthYear');
    print(fetchedTransactionsMap);

    // Fetch the transactions for the selected month-year
    List<Transaction> currentMonthTransactions = fetchedTransactionsMap[monthYear] ?? [];

    // Ensure that we are updating the state with the correct data
    setState(() {
      groupedTransactions = fetchedTransactionsMap; // Update grouped transactions
      transactions = currentMonthTransactions; // Set transactions for the selected month
  totalRevenue = _calculateTotalRevenueForMonth(selectedMonthYear ?? DateFormat('MMMM yyyy').format(DateTime.now())); // Recalculate total revenue for the selected month
    });

    print("Transactions for $monthYear: ${transactions.length}");
  } catch (e) {
    print("Error fetching transactions: $e");
  }
}


  // Calculate the total revenue for the selected month
double _calculateTotalRevenueForMonth(String selectedMonthYear) {
  double total = 0.0;
  // Use selectedMonthYear to calculate total for the chosen month
  for (var transaction in groupedTransactions[selectedMonthYear] ?? []) {
    total += double.tryParse(transaction.transactionTotal) ?? 0.0;
  }
  return total;
}

  // Handle month switching when donut chart is clicked
  void _onDonutChartClick() {
  setState(() {
    // Cycle through months
    currentMonthIndex = (currentMonthIndex + 1) % 12;
    String selectedMonthYear =
        "${monthNames[currentMonthIndex]} ${DateTime.now().year}"; // Get selected month

    print('Selected Month: $selectedMonthYear'); // Debug: Check selected month

    // Fetch transactions for the new month
    _fetchTransactions(selectedMonthYear); 

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
              // Donut Chart Placeholder
              Column(
                children: [
                  const Text(
                    'Revenue',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Replace with an actual chart widget
                  GestureDetector(
                    onTap: _onDonutChartClick,
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                      ),
                      child: Center(
                        child: Text(
                          'Month\n${monthNames[currentMonthIndex]}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
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
                style: const TextStyle(
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
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 20),

              // Transaction History for the current month
              groupedTransactions.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[
                            index]; // Access the transaction for the current month
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
                    )
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