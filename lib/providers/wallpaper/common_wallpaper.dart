import 'dart:typed_data';

import 'package:flutter/widgets.dart';

abstract class IWallpaperSource {
  final String name;
  
  IWallpaperSource(String _name) : name = _name;

  Future<bool> update() async => false;

  Future<Uint8List?> getWallpaper() async {}

}