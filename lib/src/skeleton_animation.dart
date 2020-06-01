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

class SkeletonAnimation extends core.Skeleton {
  SkeletonAnimation(core.SkeletonData data)
      : state = core.AnimationState(core.AnimationStateData(data)),
        super(data);

  final core.AnimationState state;

  void applyState() {
    state.apply(this);
  }

  void updateState(double delta) {
    state.update(delta);
  }

  static Future<SkeletonAnimation> createWithFiles(
    String atlasDataFile,
    String skeltonDataFile,
    String textureDataFile, {
    String pathPrefix = '',
    String rawAtlas = '',
    String rawSkeleton = '',
    Uint8List rawTexture,
  }) async {
    if (atlasDataFile == null)
      throw ArgumentError('atlasDataFile cannot be null.');
    if (skeltonDataFile == null)
      throw ArgumentError('skeltonDataFile cannot be null.');
    if (textureDataFile == null)
      throw ArgumentError('textureDataFile cannot be null.');
    if (pathPrefix == null) throw ArgumentError('pathPrefix cannot be null.');

    final Map<String, dynamic> assets = <String, dynamic>{};
    final List<Future<MapEntry<String, dynamic>>> futures =
        <Future<MapEntry<String, dynamic>>>[
      AssetLoader.loadJson(pathPrefix + skeltonDataFile, rawSkeleton),
      AssetLoader.loadText(pathPrefix + atlasDataFile, rawAtlas),
      AssetLoader.loadTexture(pathPrefix + textureDataFile, rawTexture),
    ];
    await Future.wait(futures).then(assets.addEntries);

    final core.TextureAtlas atlas = core.TextureAtlas(
        assets[pathPrefix + atlasDataFile],
        (String path) => assets[pathPrefix + path]);
    final core.AtlasAttachmentLoader atlasLoader =
        core.AtlasAttachmentLoader(atlas);
    final core.SkeletonJson skeletonJson = core.SkeletonJson(atlasLoader);
    final core.SkeletonData skeletonData =
        skeletonJson.readSkeletonData(assets[pathPrefix + skeltonDataFile]);
    return SkeletonAnimation(skeletonData);
  }
}
