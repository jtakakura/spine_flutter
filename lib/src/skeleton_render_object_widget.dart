// ******************************************************************************
// Copyright 2018 Junji Takakura
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

enum PlayState { Paused, Playing }

class SkeletonRenderObjectWidget extends LeafRenderObjectWidget {
  const SkeletonRenderObjectWidget(
      {this.skeleton,
      this.fit,
      this.alignment,
      this.playState,
      this.debugRendering = false,
      this.triangleRendering = false});

  final SkeletonAnimation skeleton;
  final BoxFit fit;
  final Alignment alignment;
  final PlayState playState;
  final bool debugRendering;
  final bool triangleRendering;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      SkeletonRenderObject()
        ..skeleton = skeleton
        ..fit = fit
        ..alignment = alignment
        ..playState = playState
        ..debugRendering = debugRendering
        ..triangleRendering = triangleRendering;

  @override
  void updateRenderObject(
      BuildContext context, covariant SkeletonRenderObject renderObject) {
    renderObject
      ..skeleton = skeleton
      ..fit = fit
      ..alignment = alignment
      ..playState = playState
      ..debugRendering = debugRendering
      ..triangleRendering = triangleRendering;
  }
}

class SkeletonRenderObject extends RenderBox {
  static const List<int> quadTriangles = <int>[0, 1, 2, 2, 3, 0];
  static const int vertexSize = 2 + 2 + 4;
  final core.Color _tempColor = core.Color();
  double globalAlpha = 1.0;

  SkeletonAnimation _skeleton;
  BoxFit _fit;
  Alignment _alignment;
  PlayState _playState;
  core.Bounds _bounds;
  bool _debugRendering;
  bool _triangleRendering;
  Float32List _vertices = Float32List(8 * 1024);
  double _lastFrameTime = 0.0;

  void beginFrame(Duration timeStamp) {
    final double t =
        timeStamp.inMicroseconds / Duration.microsecondsPerMillisecond / 1000.0;

    if (_lastFrameTime == 0 || _skeleton == null) {
      _lastFrameTime = t;
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
      return;
    }

    final double deltaTime = t - _lastFrameTime;
    _lastFrameTime = t;

    _skeleton
      ..updateState(deltaTime)
      ..applyState()
      ..updateWorldTransform();

    if (_playState == PlayState.Playing) {
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
    }

    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    if (_skeleton == null) {
      return;
    }

    final ui.Canvas canvas = context.canvas
      ..save()
      ..clipRect(offset & size);

    _resize(canvas, offset);

    if (_triangleRendering) {
      _drawTriangles(canvas, _skeleton);
    } else {
      _drawImages(canvas, _skeleton);
    }

    canvas.restore();
  }

  @override
  bool get sizedByParent => true;

  @override
  bool hitTestSelf(Offset screenOffset) => true;

  @override
  void performResize() {
    size = constraints.biggest;
  }

  SkeletonAnimation get skeleton => _skeleton;
  set skeleton(SkeletonAnimation value) {
    if (value == _skeleton) {
      return;
    }
    _skeleton = value;
    if (_skeleton != null) _bounds = _calculateBounds(_skeleton);
    markNeedsPaint();
  }

  AlignmentGeometry get alignment => _alignment;
  set alignment(AlignmentGeometry value) {
    if (value == _alignment) {
      return;
    }
    _alignment = value;
    markNeedsPaint();
  }

  BoxFit get fit => _fit;
  set fit(BoxFit value) {
    if (value == _fit) {
      return;
    }
    _fit = value;
    markNeedsPaint();
  }

  PlayState get playState => _playState;
  set playState(PlayState value) {
    if (value == _playState) {
      return;
    }
    _playState = value;
    if (_playState == PlayState.Playing) {
      SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
    }
  }

  bool get debugRendering => _debugRendering;
  set debugRendering(bool value) {
    if (_debugRendering == value) {
      return;
    }
    _debugRendering = value;
    markNeedsPaint();
  }

  bool get triangleRendering => _triangleRendering;
  set triangleRendering(bool value) {
    if (_triangleRendering == value) {
      return;
    }
    _triangleRendering = value;
    markNeedsPaint();
  }

  core.Bounds _calculateBounds(SkeletonAnimation skeleton) {
    skeleton
      ..setToSetupPose()
      ..updateWorldTransform();
    final core.Vector2 offset = core.Vector2();
    final core.Vector2 size = core.Vector2();
    skeleton.getBounds(offset, size, <double>[]);

    return core.Bounds(offset, size);
  }

  Float32List _computeRegionVertices(
      core.Slot slot, core.RegionAttachment region, bool pma) {
    final core.Skeleton skeleton = slot.bone.skeleton;
    final core.Color skeletonColor = skeleton.color;
    final core.Color slotColor = slot.color;
    final core.Color regionColor = region.color;
    final double alpha = skeletonColor.a * slotColor.a * regionColor.a;
    final double multiplier = pma ? alpha : 1.0;
    final core.Color color = _tempColor
      ..set(
          skeletonColor.r * slotColor.r * regionColor.r * multiplier,
          skeletonColor.g * slotColor.g * regionColor.g * multiplier,
          skeletonColor.b * slotColor.b * regionColor.b * multiplier,
          alpha);

    region.computeWorldVertices2(slot.bone, _vertices, 0, vertexSize);

    final Float32List vertices = _vertices;
    final Float32List uvs = region.uvs;

    vertices[core.RegionAttachment.c1r] = color.r;
    vertices[core.RegionAttachment.c1g] = color.g;
    vertices[core.RegionAttachment.c1b] = color.b;
    vertices[core.RegionAttachment.c1a] = color.a;
    vertices[core.RegionAttachment.u1] = uvs[0];
    vertices[core.RegionAttachment.v1] = uvs[1];

    vertices[core.RegionAttachment.c2r] = color.r;
    vertices[core.RegionAttachment.c2g] = color.g;
    vertices[core.RegionAttachment.c2b] = color.b;
    vertices[core.RegionAttachment.c2a] = color.a;
    vertices[core.RegionAttachment.u2] = uvs[2];
    vertices[core.RegionAttachment.v2] = uvs[3];

    vertices[core.RegionAttachment.c3r] = color.r;
    vertices[core.RegionAttachment.c3g] = color.g;
    vertices[core.RegionAttachment.c3b] = color.b;
    vertices[core.RegionAttachment.c3a] = color.a;
    vertices[core.RegionAttachment.u3] = uvs[4];
    vertices[core.RegionAttachment.v3] = uvs[5];

    vertices[core.RegionAttachment.c4r] = color.r;
    vertices[core.RegionAttachment.c4g] = color.g;
    vertices[core.RegionAttachment.c4b] = color.b;
    vertices[core.RegionAttachment.c4a] = color.a;
    vertices[core.RegionAttachment.u4] = uvs[6];
    vertices[core.RegionAttachment.v4] = uvs[7];

    return vertices;
  }

  Float32List _computeMeshVertices(
      core.Slot slot, core.MeshAttachment mesh, bool pma) {
    final core.Skeleton skeleton = slot.bone.skeleton;
    final core.Color skeletonColor = skeleton.color;
    final core.Color slotColor = slot.color;
    final core.Color regionColor = mesh.color;
    final double alpha = skeletonColor.a * slotColor.a * regionColor.a;
    final double multiplier = pma ? alpha : 1;
    final core.Color color = _tempColor
      ..set(
          skeletonColor.r * slotColor.r * regionColor.r * multiplier,
          skeletonColor.g * slotColor.g * regionColor.g * multiplier,
          skeletonColor.b * slotColor.b * regionColor.b * multiplier,
          alpha);

    final int numVertices = mesh.worldVerticesLength ~/ 2;
    if (_vertices.length < mesh.worldVerticesLength) {
      _vertices = Float32List(mesh.worldVerticesLength);
    }
    final Float32List vertices = _vertices;
    mesh.computeWorldVertices(
        slot, 0, mesh.worldVerticesLength, vertices, 0, vertexSize);

    final Float32List uvs = mesh.uvs;
    final int n = numVertices;
    for (int i = 0, u = 0, v = 2; i < n; i++) {
      vertices[v++] = color.r;
      vertices[v++] = color.g;
      vertices[v++] = color.b;
      vertices[v++] = color.a;
      vertices[v++] = uvs[u++];
      vertices[v++] = uvs[u++];
      v += 2;
    }

    return vertices;
  }

  void _drawImages(ui.Canvas canvas, SkeletonAnimation skeleton) {
    final Paint paint = Paint();
    final List<core.Slot> drawOrder = skeleton.drawOrder;

    // @TODO デバッグ表示実装
    // if (debugRendering) paint.color = const ui.Color.fromRGBO(0, 255, 0, 1.0);

    canvas.save();

    final int n = drawOrder.length;

    for (int i = 0; i < n; i++) {
      final core.Slot slot = drawOrder[i];
      final core.Attachment attachment = slot.getAttachment();
      core.RegionAttachment regionAttachment;
      core.TextureAtlasRegion region;
      ui.Image image;

      if (attachment is! core.RegionAttachment) {
        continue;
      }

      regionAttachment = attachment;
      region = regionAttachment.region as core.TextureAtlasRegion;
      image = region.texture.image;

      final core.Skeleton skeleton = slot.bone.skeleton;
      final core.Color skeletonColor = skeleton.color;
      final core.Color slotColor = slot.color;
      final core.Color regionColor = regionAttachment.color;
      final double alpha = skeletonColor.a * slotColor.a * regionColor.a;
      final core.Color color = _tempColor
        ..set(
            skeletonColor.r * slotColor.r * regionColor.r,
            skeletonColor.g * slotColor.g * regionColor.g,
            skeletonColor.b * slotColor.b * regionColor.b,
            alpha);

      final core.Bone bone = slot.bone;
      double w = region.width.toDouble();
      double h = region.height.toDouble();

      canvas
        ..save()
        ..transform(Float64List.fromList(<double>[
          bone.a,
          bone.c,
          0.0,
          0.0,
          bone.b,
          bone.d,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          bone.worldX,
          bone.worldY,
          0.0,
          1.0
        ]))
        ..translate(regionAttachment.offset[0], regionAttachment.offset[1])
        ..rotate(regionAttachment.rotation * math.pi / 180);

      final double atlasScale = regionAttachment.width / w;

      canvas
        ..scale(atlasScale * regionAttachment.scaleX,
            atlasScale * regionAttachment.scaleY)
        ..translate(w / 2, h / 2);
      if (regionAttachment.region.rotate) {
        final double t = w;
        w = h;
        h = t;
        canvas.rotate(-math.pi / 2);
      }
      canvas
        ..scale(1.0, -1.0)
        ..translate(-w / 2, -h / 2);
      if (color.r != 1 || color.g != 1 || color.b != 1 || color.a != 1) {
        final int alpha = (color.a * 255).toInt();
        paint.color = paint.color.withAlpha(alpha);
      }
      canvas.drawImageRect(
          image,
          Rect.fromLTWH(region.x.toDouble(), region.y.toDouble(), w, h),
          Rect.fromLTWH(0.0, 0.0, w, h),
          paint);
      if (_debugRendering)
        canvas.drawRect(Rect.fromLTWH(0.0, 0.0, w, h), paint);
      canvas.restore();
    }

    canvas.restore();
  }

  void _drawTriangles(ui.Canvas canvas, SkeletonAnimation skeleton) {
    core.BlendMode blendMode;

    final List<core.Slot> drawOrder = skeleton.drawOrder;
    Float32List vertices = _vertices;
    List<int> triangles;

    final int n = drawOrder.length;
    for (int i = 0; i < n; i++) {
      final core.Slot slot = drawOrder[i];
      final core.Attachment attachment = slot.getAttachment();
      ui.Image texture;
      core.TextureAtlasRegion region;
      core.Color attachmentColor;
      if (attachment is core.RegionAttachment) {
        final core.RegionAttachment regionAttachment = attachment;
        vertices = _computeRegionVertices(slot, regionAttachment, false);
        triangles = quadTriangles;
        region = regionAttachment.region;
        texture = region.texture.image;
        attachmentColor = regionAttachment.color;
      } else if (attachment is core.MeshAttachment) {
        final core.MeshAttachment mesh = attachment;
        vertices = _computeMeshVertices(slot, mesh, false);
        triangles = mesh.triangles;
        texture = mesh.region.renderObject.texture.image;
        attachmentColor = mesh.color;
      } else
        continue;

      if (texture != null) {
        final core.BlendMode slotBlendMode = slot.data.blendMode;
        if (slotBlendMode != blendMode) {
          blendMode = slotBlendMode;
        }

        final core.Skeleton skeleton = slot.bone.skeleton;
        final core.Color skeletonColor = skeleton.color;
        final core.Color slotColor = slot.color;
        final double alpha = skeletonColor.a * slotColor.a * attachmentColor.a;
        final core.Color color = _tempColor
          ..set(
              skeletonColor.r * slotColor.r * attachmentColor.r,
              skeletonColor.g * slotColor.g * attachmentColor.g,
              skeletonColor.b * slotColor.b * attachmentColor.b,
              alpha);

        globalAlpha = color.a;

        for (int j = 0; j < triangles.length; j += 3) {
          final int t1 = triangles[j] * 8,
              t2 = triangles[j + 1] * 8,
              t3 = triangles[j + 2] * 8;

          final double x0 = vertices[t1],
              y0 = vertices[t1 + 1],
              u0 = vertices[t1 + 6],
              v0 = vertices[t1 + 7];
          final double x1 = vertices[t2],
              y1 = vertices[t2 + 1],
              u1 = vertices[t2 + 6],
              v1 = vertices[t2 + 7];
          final double x2 = vertices[t3],
              y2 = vertices[t3 + 1],
              u2 = vertices[t3 + 6],
              v2 = vertices[t3 + 7];

          _drawTriangle(
              canvas, texture, x0, y0, u0, v0, x1, y1, u1, v1, x2, y2, u2, v2);

          if (_debugRendering) {
            final Path path = Path()
              ..moveTo(x0, y0)
              ..lineTo(x1, y1)
              ..lineTo(x2, y2)
              ..lineTo(x0, y0);
            canvas.drawPath(
              path,
              Paint()
                ..style = PaintingStyle.stroke
                ..color = Colors.green
                ..strokeWidth = 1,
            );
          }
        }
      }
    }
  }

  // Adapted from http://extremelysatisfactorytotalitarianism.com/blog/?p=2120
  // Apache 2 licensed
  void _drawTriangle(
      ui.Canvas canvas,
      ui.Image img,
      double x0,
      double y0,
      double u0,
      double v0,
      double x1,
      double y1,
      double u1,
      double v1,
      double x2,
      double y2,
      double u2,
      double v2) {
    u0 *= img.width;
    v0 *= img.height;
    u1 *= img.width;
    v1 *= img.height;
    u2 *= img.width;
    v2 *= img.height;

    final Path _path = Path()
      ..moveTo(x0, y0)
      ..lineTo(x1, y1)
      ..lineTo(x2, y2)
      ..close();

    x1 -= x0;
    y1 -= y0;
    x2 -= x0;
    y2 -= y0;

    u1 -= u0;
    v1 -= v0;
    u2 -= u0;
    v2 -= v0;

    final double det = 1 / (u1 * v2 - u2 * v1),
        // linear transformation
        a = (v2 * x1 - v1 * x2) * det,
        b = (v2 * y1 - v1 * y2) * det,
        c = (u1 * x2 - u2 * x1) * det,
        d = (u1 * y2 - u2 * y1) * det,
        // translation
        e = x0 - a * u0 - c * v0,
        f = y0 - b * u0 - d * v0;

    canvas
      ..save()
      ..clipPath(_path)

      /*
        https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/transform
        http://www.opengl-tutorial.org/cn/beginners-tutorials/tutorial-3-matrices/
        a c 0 e
        b d 0 f
        0 0 1 0
        0 0 0 1
      */
      ..transform(Float64List.fromList(<double>[
        a,
        b,
        0.0,
        0.0,
        c,
        d,
        0.0,
        0.0,
        0.0,
        0.0,
        1.0,
        0.0,
        e,
        f,
        0.0,
        1.0,
      ]));

    final Paint p = Paint()..isAntiAlias = true;
    p.color = p.color.withOpacity(globalAlpha);
    canvas
      ..drawImage(img, const Offset(0.0, 0.0), p)
      ..restore();
  }

  void _resize(Canvas canvas, ui.Offset offset) {
    if (_bounds == null) {
      return;
    }

    final double contentHeight = _bounds.size.y;
    final double contentWidth = _bounds.size.x;
    final double x = -_bounds.offset.x -
        contentWidth / 2.0 -
        (_alignment.x * contentWidth / 2.0);
    final double y = -_bounds.offset.y -
        contentHeight / 2.0 +
        (_alignment.y * contentHeight / 2.0);
    double scaleX = 1.0, scaleY = 1.0;

    switch (_fit) {
      case BoxFit.fill:
        scaleX = size.width / contentWidth;
        scaleY = size.height / contentHeight;
        break;
      case BoxFit.contain:
        final double minScale =
            math.min(size.width / contentWidth, size.height / contentHeight);
        scaleX = scaleY = minScale;
        break;
      case BoxFit.cover:
        final double maxScale =
            math.max(size.width / contentWidth, size.height / contentHeight);
        scaleX = scaleY = maxScale;
        break;
      case BoxFit.fitHeight:
        final double minScale = size.height / contentHeight;
        scaleX = scaleY = minScale;
        break;
      case BoxFit.fitWidth:
        final double minScale = size.width / contentWidth;
        scaleX = scaleY = minScale;
        break;
      case BoxFit.none:
        scaleX = scaleY = 1.0;
        break;
      case BoxFit.scaleDown:
        final double minScale =
            math.min(size.width / contentWidth, size.height / contentHeight);
        scaleX = scaleY = minScale < 1.0 ? minScale : 1.0;
        break;
    }

    canvas
      ..translate(
          offset.dx + size.width / 2.0 + (_alignment.x * size.width / 2.0),
          offset.dy + size.height / 2.0 + (_alignment.y * size.height / 2.0))
      ..scale(scaleX, -scaleY)
      ..translate(x, y);
  }
}
