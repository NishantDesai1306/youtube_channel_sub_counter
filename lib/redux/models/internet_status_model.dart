import 'package:meta/meta.dart';

@immutable
class InternetStatus {
  final bool isConnected;
  
  const InternetStatus({ required this.isConnected });

  InternetStatus copyWith({ isConnected = false }) {
    return InternetStatus(isConnected: isConnected);
  }
}
