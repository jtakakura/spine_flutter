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

part of spine_flutter;

class SkeletonAnimation extends core.Skeleton {
  final core.AnimationState state;

  SkeletonAnimation(core.SkeletonData data)
      : state = new core.AnimationState(new core.AnimationStateData(data)),
        super(data);

  void applyState() {
    state.apply(this);
  }

  void updateState(double delta) {
    state.update(delta);
  }

  static Future<SkeletonAnimation> createWithFiles(
      String atlasDataFile, String skeltonDataFile, String textureDataFile,
      [String pathPrefix = '']) async {
    if (atlasDataFile == null)
      throw new ArgumentError('atlasDataFile cannot be null.');
    if (skeltonDataFile == null)
      throw new ArgumentError('skeltonDataFile cannot be null.');
    if (textureDataFile == null)
      throw new ArgumentError('textureDataFile cannot be null.');
    if (pathPrefix == null)
      throw new ArgumentError('pathPrefix cannot be null.');

    final Map<String, dynamic> assets = <String, dynamic>{};
    final List<Future<MapEntry<String, dynamic>>> futures =
        <Future<MapEntry<String, dynamic>>>[
      AssetLoader.loadJson(pathPrefix + skeltonDataFile),
      AssetLoader.loadText(pathPrefix + atlasDataFile),
      AssetLoader.loadTexture(pathPrefix + textureDataFile),
    ];
    await Future.wait(futures).then(assets.addEntries);

    final core.TextureAtlas atlas = new core.TextureAtlas(
        assets[pathPrefix + atlasDataFile],
        (String path) => assets[pathPrefix + path]);
    final core.AtlasAttachmentLoader atlasLoader =
        new core.AtlasAttachmentLoader(atlas);
    final core.SkeletonJson skeletonJson = new core.SkeletonJson(atlasLoader);
    final core.SkeletonData skeletonData =
        skeletonJson.readSkeletonData(assets[pathPrefix + skeltonDataFile]);
    return new SkeletonAnimation(skeletonData);
  }
}
