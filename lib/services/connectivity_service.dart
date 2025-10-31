import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  // Method to check internet connection status
  Future<void> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      print("Connected to Mobile Data");
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      print("Connected to Wi-Fi");
    } else {
      print("No Internet Connection");
    }
  }

  // Method to listen for connectivity changes
  void listenForConnectivityChanges() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.mobile)) {
        print("Switched to Mobile Data");
      } else if (results.contains(ConnectivityResult.wifi)) {
        print("Switched to Wi-Fi");
      } else {
        print("No Internet Connection");
      }
    });
  }
}
