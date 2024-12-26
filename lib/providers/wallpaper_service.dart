/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:ffi';
import 'dart:io';

import 'package:flauncher/flauncher_channel.dart';
import 'package:flauncher/gradients.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/wallpaper/bing_wallpaper.dart';
import 'package:flauncher/providers/wallpaper/common_wallpaper.dart';
import 'package:flauncher/providers/wallpaper/file_picker_wallpaper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class WallpaperService extends ChangeNotifier {
  final FLauncherChannel _fLauncherChannel;
  final SettingsService _settingsService;

  late File _wallpaperFile;

  ImageProvider? _wallpaper;

  ImageProvider?  get wallpaper     => _wallpaper;

  IWallpaperSource? _wallpaperSource;

  FLauncherGradient get gradient => FLauncherGradients.all.firstWhere(
        (gradient) => gradient.uuid == _settingsService.gradientUuid,
        orElse: () => FLauncherGradients.greatWhale,
      );

  WallpaperService(this._fLauncherChannel, this._settingsService) :
    _wallpaper = null, _wallpaperSource = null
  {
    _init();
  }

  Future<void> _init() async {
    // Setup wallpaper file
    final directory = await getApplicationDocumentsDirectory();
    _wallpaperFile = File("${directory.path}/wallpaper");

    // Init wallpaper source
    setWallpaperSource(await _settingsService.wallpaperSource);

    // Load wallpaper
    if (await _wallpaperFile.exists()) {
      _wallpaper = FileImage(_wallpaperFile);
      notifyListeners();
    }
  }

  Future<void> _updateWallpaperFromSource() async {
    if (await _wallpaperSource?.update() ?? false) {
      Uint8List? bytes = await _wallpaperSource?.getWallpaper();
      if (bytes == null || bytes.length == 0) 
        throw Exception("Got null bytes from wallpaper source");

      await _wallpaperFile.writeAsBytes(bytes);
      _wallpaper = MemoryImage(bytes);
      notifyListeners();
    }
  }

  IWallpaperSource? _getWallpaperSourceFromName(String? name) {
    switch (name) {
      case "BingDailyWallpaperSource":
        return new BingDailyWallpaperSource(_settingsService);
    }

    return null;
  }

  Future<void> setWallpaperSource(String? sourceName) async {
    _wallpaperSource = _getWallpaperSourceFromName(sourceName);
    await _updateWallpaperFromSource();
  }

  Future<void> setGradient(FLauncherGradient fLauncherGradient) async {
    if (await _wallpaperFile.exists()) {
      await _wallpaperFile.delete();
    }

    _settingsService.setGradientUuid(fLauncherGradient.uuid);
    notifyListeners();
  }
}

class NoFileExplorerException implements Exception {}
