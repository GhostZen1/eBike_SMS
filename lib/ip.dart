import 'package:latlong2/latlong.dart';

class ApiBase {
  // Static URLs for local development
  static String amir = "http://192.168.0.31/e-bike";
  static String king = "http://192.168.10.155/e-bike";
  static String kingHouse = "http://192.168.1.117/e-bike";
  static String kingUTeM = "http://10.131.75.68/e-bike";
  static String kingLibrary = "http://192.168.0.200/e-bike";
  static String iman = "http://192.168.0.30/e-bike";
  static String zu = "http://192.168.0.243/e-bike";
  static String hosting = "https://etourmersing.com/Ebike_API/";

  // Alternatively, if you just need the base URL as a string
  static String get baseUrl => zu;
}
