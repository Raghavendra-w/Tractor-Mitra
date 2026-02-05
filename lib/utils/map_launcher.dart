import 'package:url_launcher/url_launcher.dart';

class MapLauncher {
  static Future<void> openMap({
    required double latitude,
    required double longitude,
  }) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open Google Maps';
    }
  }
}
