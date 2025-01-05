import 'package:ebikesms/modules/global_import.dart';
import 'package:ebikesms/modules/admin/widget/reportwidget.dart';
import 'package:ebikesms/modules/admin/widget/reportdetailwidget.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool showIncidentReport = true; // Determines which main widget to show
  bool showReportDetail = false; // Determines if ReportDetailWidget should be shown
  String selectedReportId = ""; // Holds the currently selected report ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: showIncidentReport
                        ? ColorConstant.darkBlue
                        : Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      showIncidentReport = true;
                      showReportDetail = false;
                    });
                  },
                  child: Text(
                    'Incident',
                    style: TextStyle(
                      color: showIncidentReport ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: showIncidentReport
                        ? Colors.grey.shade300
                        : ColorConstant.darkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      showIncidentReport = false;
                      showReportDetail = false;
                    });
                  },
                  child: Text(
                    'User',
                    style: TextStyle(
                      color: showIncidentReport ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey.shade300,
                  child: const Center(child: Icon(Icons.image, size: 50)),
                ),
              ),
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '10',
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: ColorConstant.darkBlue),
                    ),
                    Text(
                      showReportDetail
                          ? 'Report Detail'
                          : showIncidentReport
                              ? 'Incident Report Recorded'
                              : 'User Report Recorded',
                      style: const TextStyle(
                          fontSize: 16, color: ColorConstant.darkBlue),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: showReportDetail
                ? ReportDetailWidget(
                    reportId: selectedReportId, // Pass the selected report ID
                    onBack: () {
                      setState(() {
                        showReportDetail = false;
                      });
                    },
                  )
                : (showIncidentReport
                    ? IncidentReportWidget()
                    : UserReportWidget(
                        onRowTap: (reportId) {
                          setState(() {
                            selectedReportId = reportId; // Store the selected report ID
                            showReportDetail = true; // Show the detail widget
                          });
                        },
                      )),
          ),
        ],
      ),
    );
  }
}
