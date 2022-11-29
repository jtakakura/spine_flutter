part of spine_flutter_dart;

class Texture extends core.Texture {
  Texture(ui.Image image) : super(image);

  @override
  void setFilters(
      core.TextureFilter? minFilter, core.TextureFilter? magFilter) {}
  @override
  void setWraps(core.TextureWrap? uWrap, core.TextureWrap? vWrap) {}
  @override
  void dispose() {}
}
