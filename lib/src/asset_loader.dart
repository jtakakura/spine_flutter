// ******************************************************************************
// Copyright 2018 Junji Takakura
//
// Spine Runtime originally copyright (c) 2013-2016, Esoteric Software
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// ******************************************************************************

part of flutter_spine;

class AssetLoader {
  static Future<MapEntry<String, dynamic>> loadJson(
      String path, String raw) async {
    String data;
    if (raw != null && raw != '') {
      data = raw;
    } else {
      data = await rootBundle.loadString(path);
      if (data == null) throw StateError('Couldn\'t load texture $path');
    }
    return new MapEntry<String, dynamic>(path, json.decode(data));
  }

  static Future<MapEntry<String, String>> loadText(
      String path, String raw) async {
    String data;
    if (raw != null && raw != '') {
      data = raw;
    } else {
      data = await rootBundle.loadString(path);
      if (data == null) throw StateError('Couldn\'t load texture $path');
    }
    return new MapEntry<String, String>(path, data);
  }

  static Future<MapEntry<String, Texture>> loadTexture(
      String path, Uint8List raw) async {
    if (path == null) throw new ArgumentError('path cannot be null.');

    Uint8List data;
    if (raw != null) {
      data = raw;
    } else {
      final ByteData byteData = await rootBundle.load(path);
      if (byteData == null) throw StateError('Couldn\'t load texture $path');
      data = byteData.buffer.asUint8List();
    }
    final ui.Codec codec = await ui.instantiateImageCodec(data);
    final ui.FrameInfo frame = await codec.getNextFrame();
    return new MapEntry<String, Texture>(path, new Texture(frame.image));
  }
}
