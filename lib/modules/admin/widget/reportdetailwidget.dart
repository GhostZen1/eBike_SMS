import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ebikesms/modules/global_import.dart';

class ReportDetailWidget extends StatefulWidget {
  final String reportId; // Receive report_id
  final VoidCallback onBack;
  const ReportDetailWidget(
      {Key? key, required this.reportId, required this.onBack})
      : super(key: key);

  @override
  _ReportDetailWidgetState createState() => _ReportDetailWidgetState();
}

class _ReportDetailWidgetState extends State<ReportDetailWidget> {
  bool isLoading = true;
  Map<String, dynamic>? reportData;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchReportDetails();
  }

  // Fetch report details from API
  Future<void> _fetchReportDetails() async {
    final response = await http.get(Uri.parse(
        '${ApiBase.baseUrl}/get_report_detail.php?report_id=${widget.reportId}')); // Pass report_id as a query parameter

    print('Fetching report details for report_id: ${widget.reportId}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          isLoading = false;
          reportData = data['data'];
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = data['message'];
        });
      }
    } else {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load report details';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // User Info
                                Padding(
                                  padding: const EdgeInsets.only(top: 40.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: 'User ID ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  '#${reportData?['user_id']}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: 'Date ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  '${reportData?['report_date']}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Username\t',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          TextSpan(
                                            text: reportData != null
                                                ? reportData!['user_name']
                                                : 'Walker', // If the username is not available, fallback to 'Walker'
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Time\t\t',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '${reportData?['report_time']}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),

                                // Report Box (Full width container)
                                Container(
                                  width: double.infinity, // Full width
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: ColorConstant.lightBlue2,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Report ID',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '#${reportData?['report_id']}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(height: 16),
                                      const Text(
                                        'Report Description',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        reportData != null
                                            ? reportData!['report_detail']
                                            : '',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 24),

                                // Acknowledge Button
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween, // Space between the buttons
                                    children: [
                                      // Acknowledge Button (Larger Button)
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                ColorConstant.darkBlue,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 40,
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () {
                                            // Add acknowledge functionality
                                          },
                                          child: const Text(
                                            'Acknowledge',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width:
                                              16), // Space between the two buttons

                                      // Trashcan Icon Button (Smaller button)
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors
                                              .grey, // Color for trash button
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                            horizontal: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () {
                                          // Add delete functionality
                                        },
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                          size: 20, // Icon size
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Positioned(
                            top: 16,
                            right: 16,
                            child: GestureDetector(
                              onTap: () {
                                widget.onBack();
                              },
                              child: const Icon(
                                Icons.close,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
