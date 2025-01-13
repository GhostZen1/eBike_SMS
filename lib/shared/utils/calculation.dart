import 'package:ebikesms/shared/constants/app_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import 'package:ntp/ntp.dart';

class Calculation {
  // Convert the amount of money to ride time format (x hours x minutes, or x minutes)
  static String? convertMoneyToLongRideTime(int amount) {
    return convertMinutesToLongRideTime(amount ~/ PricingConstant.priceRate);
  }

  // Convert minutes to a long ride time format (x hours x minutes, or x minutes)
  static String convertMinutesToLongRideTime(int totalMinutes) {
    if (totalMinutes < 1) return "< 1 min";

    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    String hoursPart = hours > 0 ? "$hours hour${hours > 1 ? 's' : ''}" : "";
    String minutesPart = minutes > 0 ? "$minutes minute${minutes > 1 ? 's' : ''}" : "";

    return [hoursPart, minutesPart].where((part) => part.isNotEmpty).join(" ");
  }

  // Convert minutes to a short ride time format (e.g., 2h 10m)
  static String convertMinutesToShortRideTime(int totalMinutes) {
    if (totalMinutes < 1) return "< 1 min";

    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return "${hours}h ${minutes == 1 ? '1 min' : '${minutes} mins'}";
    } else if (hours > 0) {
      return "${hours}h";
    } else {
      return minutes == 1 ? "1 min" : "${minutes} mins";
    }
  }

  // Convert the amount of money to total minutes
  static int convertMoneyToMinutes(int amount) {
    return amount ~/ PricingConstant.priceRate;
  }

  // Get current DateTime from NTP service in MySQL-compatible format
  static Future<String> getCurrentDateTime() async {
    try {
      DateTime ntpTime = await NTP.now();
      return ntpTime.toIso8601String().split('.')[0]; // Format to "YYYY-MM-DD HH:mm:ss"
    } catch (e) {
      debugPrint("Failed to fetch NTP datetime: $e");
      return "";
    }
  }

  // Convert distance in meters to a formatted string (m or km)
  static String formatDistance(double meters) {
    if (meters >= 1000) {
      return "${(meters / 1000).toStringAsFixed(meters % 1000 == 0 ? 0 : 2)} km";
    }
    return "${meters.toStringAsFixed(meters % 1 == 0 ? 0 : 2)} m";
  }

  // Convert formatted distance string (e.g., "1.5 km" or "500 m") back to meters
  static int parseDistance(String distance) {
    if (distance == "< 1 meter") return 0;

    if (distance.endsWith(" km")) {
      return (double.parse(distance.replaceAll(" km", "")) * 1000).toInt();
    } else if (distance.endsWith(" m")) {
      return double.parse(distance.replaceAll(" m", "")).toInt();
    } else {
      throw FormatException('Invalid distance format. Must end with "m" or "km".');
    }
  }

  // Decode a polyline string into a list of LatLng points
  static List<LatLng> decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int result = 0, shift = 0;
      int byte;
      do {
        byte = polyline.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int deltaLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      result = shift = 0;
      do {
        byte = polyline.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int deltaLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}
