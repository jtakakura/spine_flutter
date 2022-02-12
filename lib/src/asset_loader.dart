part of spine_flutter;

class AssetLoader {
  static Future<MapEntry<String, dynamic>> loadJson(
      String path, String? raw) async {
    String data;
    if (raw != null && raw != '') {
      data = raw;
    } else {
      data = await rootBundle.loadString(path);
    }
    return MapEntry<String, dynamic>(path, json.decode(data));
  }

  static Future<MapEntry<String, String>> loadText(
      String path, String? raw) async {
    String data;
    if (raw != null && raw != '') {
      data = raw;
    } else {
      data = await rootBundle.loadString(path);
    }
    return MapEntry<String, String>(path, data);
  }

  static Future<MapEntry<String, Texture>> loadTexture(
      String path, Uint8List? raw) async {
    Uint8List data;
    if (raw != null) {
      data = raw;
    } else {
      final ByteData byteData = await rootBundle.load(path);
      data = byteData.buffer.asUint8List();
    }
    final ui.Codec codec = await ui.instantiateImageCodec(data);
    final ui.FrameInfo frame = await codec.getNextFrame();
    return MapEntry<String, Texture>(path, Texture(frame.image));
  }
}
