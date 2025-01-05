import 'package:ebikesms/shared/utils/shared_state.dart';
import 'package:ebikesms/shared/widget/loading_animation.dart';
import 'package:flutter/material.dart';

import '../../../../../shared/constants/app_constants.dart';
import '../../../../../shared/utils/custom_icon.dart';
import '../widget/destination_card.dart';
import 'nav_confirm_pinpoint.dart';
import '../../../controller/landmark_controller.dart';
import 'nav_confirm_selected.dart';

enum DataState { loading, hasResult, failure, noResult }

class NavDestinationScreen extends StatefulWidget {
  const NavDestinationScreen({super.key});

  @override
  State<NavDestinationScreen> createState() => _NavDestinationScreenState();
}

class _NavDestinationScreenState extends State<NavDestinationScreen> {
  late final TextEditingController _controller = TextEditingController();
  late List<dynamic> _allLandmarks;
  late List<dynamic> _displayingLandmarks;
  bool _isSearchHasText = false;
  DataState _dataState = DataState.loading; // To display loading animation

  void _fetchLocations() async {
    var results = await LocationController.getLocations();
    if (results['status'] == 0) {
      // Failed
      _allLandmarks = results['data'];
      setState(() {
        _dataState = DataState.failure; // To display if fetch had a failure
      });
    } else if (results['status'] == 1) {
      // hasResultful
      _allLandmarks = results['data'];
      _displayingLandmarks = _allLandmarks;
      setState(() {
        _dataState = DataState.hasResult; // To display the locations
      });
    }
  }

  void _searchBarListener() {
    setState(() {
      // Setting the flag for UI behavior
      _isSearchHasText = _controller.text.isNotEmpty;

      // Setting displaying locations based on search query
      if (_isSearchHasText) {
        _displayingLandmarks.clear();
        String query = _controller.text.toLowerCase();
        _displayingLandmarks = _allLandmarks.where((landmark) {
          // This "where" method acts similarly to an SQL where clause
          return landmark['landmark_name_malay']
                  .toLowerCase()
                  .contains(query) ||
              landmark['landmark_name_english'].toLowerCase().contains(query) ||
              landmark['landmark_type'].toLowerCase().contains(query) ||
              landmark['address'].toLowerCase().contains(query);
        }).toList();

        if (_displayingLandmarks.isEmpty) {
          _dataState = DataState.noResult;
        } else {
          _dataState = DataState.hasResult;
        }
      } else {
        _displayingLandmarks = _allLandmarks.toList();
        _dataState = DataState.hasResult;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchLocations();
    _controller.addListener(_searchBarListener);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: IconButton(
          onPressed: () {
            _closeScreen();
          },
          icon: CustomIcon.close(20, color: ColorConstant.black)),
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Headings
          Visibility(
            visible: (_isSearchHasText) ? false : true,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 30, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Let's begin navigating",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ColorConstant.darkBlue),
                  ),
                  Text(
                    "Choose your destination",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: ColorConstant.black),
                  ),
                ],
              ),
            ),
          ),

          // Destination text field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 0, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 4),
                      CustomIcon.locationCurrent(20,
                          color: ColorConstant.black),
                      const SizedBox(width: 18),
                      const Text(
                        "From your location",
                        style: TextStyle(
                          fontSize: 14,
                          color: ColorConstant.black,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                      color: ColorConstant.white,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                            color: ColorConstant.shadow,
                            offset: Offset(0, 2),
                            blurRadius: 2)
                      ]),
                  child: ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -4),
                      leading: const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          "To",
                          style: TextStyle(
                              color: ColorConstant.darkBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: SizedBox(
                        height: 35,
                        child: TextField(
                          keyboardType: TextInputType.text,
                          controller: _controller,
                          maxLines: 1,
                          style: const TextStyle(
                              color: ColorConstant.black, fontSize: 14),
                          decoration: const InputDecoration(
                              hintText: "Search destination",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  color: ColorConstant.grey, fontSize: 14),
                              contentPadding: EdgeInsets.only(bottom: 11.5)),
                        ),
                      ),
                      trailing:
                          CustomIcon.search(14, color: ColorConstant.black)),
                )
              ],
            ),
          ),

          // Gridview for destination cards
          Container(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 10),
            decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: ColorConstant.lightGrey))),
            alignment:
                (_isSearchHasText) ? Alignment.center : Alignment.centerLeft,
            child: Text(
              (_isSearchHasText) ? "Search results" : "Recommendations",
              style: const TextStyle(
                color: ColorConstant.darkBlue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Builder(
            builder: (context) {
              switch (_dataState) {
                case DataState.loading:
                  return const Center(child: LoadingAnimation(dimension: 50));
                case DataState.failure:
                  return const Center(
                      child: Text(
                    "An unexpected failure occurred",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ));
                case DataState.noResult:
                  return displayLocationNotFound();
                case DataState.hasResult:
                  return displayDestinationCards();
                default:
                  return const Center(child: Text("Unknown state"));
              }
            },
          )),
          // Pin point button
          TextButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: ColorConstant.darkBlue,
                foregroundColor: ColorConstant.white,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
              ),
              onPressed: () {
                if(_dataState == DataState.loading) {
                  return;
                }
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NavConfirmPinpointScreen(
                              allLocations: _allLandmarks,
                            )));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIcon.location(16, color: ColorConstant.white),
                  const SizedBox(width: 10),
                  const Text(
                    "Choose on map", // Editable
                    style: TextStyle(fontSize: 13), // Editable
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(width: 4),
                ],
              )),
        ],
      ),
    );
  }

  Widget displayLocationNotFound() {
    return Expanded(
        child: Center(
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Expanded(
                        child: Center(
                      child: Text(
                        "We couldn't find the place you provided.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    )),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "Try pinpointing it on the map",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13,
                              color: ColorConstant.darkBlue,
                              fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                          child: CustomIcon.downArrow(25,
                              color: ColorConstant.darkBlue),
                        )
                      ],
                    )
                  ],
                ))));
  }

  Widget displayDestinationCards() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            shrinkWrap:
                true, // Make sure the GridView fits inside the CustomScrollView
            physics:
                const NeverScrollableScrollPhysics(), // Prevent grid from scrolling independently
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns
              crossAxisSpacing: 15, // Horizontal space between grid items
              mainAxisSpacing: 15, // Vertical space between grid items
              childAspectRatio:
                  0.7, // Ratio of width to height of each grid item (the lesser, the longer)
            ),
            itemCount: _displayingLandmarks.length, // Total number of items
            itemBuilder: (BuildContext context, int index) {
              //return Container(color: ColorConstant.black);
              return DestinationCard(
                landmarkNameMalay: _displayingLandmarks[index]
                    ['landmark_name_malay'],
                landmarkNameEnglish: _displayingLandmarks[index]
                    ['landmark_name_english'],
                landmarkType: _displayingLandmarks[index]['landmark_type'],
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NavConfirmSelectedScreen(
                                //allLocations: _allLandmarks,
                                selectedLandmark: _displayingLandmarks[index],
                              )));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _closeScreen() {
    Navigator.pop(context);
  }
}
