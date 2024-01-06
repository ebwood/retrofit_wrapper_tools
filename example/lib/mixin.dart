part of custom;

mixin VideoMixin {
  @GET('/videos')
  Future<String?> getVideos();
}
