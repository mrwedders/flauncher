import 'dart:typed_data';

import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/wallpaper/common_wallpaper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

const LastUpdateDateSettingsKey = "bing_wallpaper_last_update_date";

class BingDailyWallpaperSource extends IWallpaperSource {

  final SettingsService _settingsService;
  Timer? _updateCheckTimer;

  int currentDate() {
    var currDate = DateTime.now();
    return int.parse("${currDate.year}${currDate.month}${currDate.day}");
  }

  BingDailyWallpaperSource(SettingsService settingsService) : 
    _settingsService = settingsService, 
    super((BingDailyWallpaperSource).toString());

  Future<Uint8List?> getWallpaper() async {
    update();

    var url = _settingsService.bingLastUrl;
    if (url == null)
      return null;

    final httpUrl = Uri.parse(url);
    var httpResponse = await http.get(httpUrl);
    if (httpResponse.statusCode != 200) {
      throw Exception("Failed to fetch Bing wallpaper image (${httpResponse.statusCode})");
    }

    return httpResponse.bodyBytes;
  }

  Future<bool> update() async {
    var lastUpdatedDate = _settingsService.bingLastUpdateDate;
    var currentDate = this.currentDate();
    _resetUpdateCheckTimer();

    if (lastUpdatedDate == null || currentDate > lastUpdatedDate) {
      await _settingsService.setBingLastUrl(await _fetchImageUrl());
      return true;
    }

    return false;
  }

  void _resetUpdateCheckTimer() {
    _updateCheckTimer?.cancel();
    _updateCheckTimer = Timer(Duration(hours: 1), () => update());
  }

  Future<String?> _fetchImageUrl() async {
    final httpUrl = Uri.https('bing.biturl.top', '', { 'resolution': 'UHD', 'format': 'json' });
    final httpResponse = await http.get(httpUrl);
    if (httpResponse.statusCode != 200) {
      throw Exception("Failed to read Bing wallpaper URL (${httpResponse.statusCode})");
    }

    var decodedContent = jsonDecode(httpResponse.body);
    return decodedContent['url'];
  }

}
