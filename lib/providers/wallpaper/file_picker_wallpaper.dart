import 'dart:typed_data';

import 'package:flauncher/providers/wallpaper/common_wallpaper.dart';
import 'package:flutter/painting.dart';

class FilePickerWallpaperSource extends IWallpaperSource {

  FilePickerWallpaperSource() : super((FilePickerWallpaperSource).toString());

  Future<Uint8List?> getWallpaper() async {
    return null;


    // if (!await _fLauncherChannel.checkForGetContentAvailability()) {
    //   throw NoFileExplorerException();
    // }

    // final imagePicker = ImagePicker();
    // final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
  }

}