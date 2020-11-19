import 'package:scorpio_server/model/blog.dart';

import 'package:scorpio_server/scorpio_server.dart';

class BlogsUserController extends ResourceController {
  /// The [BlogsUserController] extends from ResourceController class as subclass where it handles all HTTP(s)
  BlogsUserController(this.context) {
    {
      acceptedContentTypes = [ContentType.json];
    }
  }
  final ManagedContext context;
// This controller is only used for getting requests by the userName and the title of the objects
  @Operation.get('userName')
  Future<Response> getBlogByUser(
    @Bind.path('userName') String userName, {
    @Bind.query('title') String title,
    @Bind.query('count') int count = 0,
    @Bind.query("offset") int offset = 0,
  }) async {
    dynamic dataResponse;
    if (userName == null) {
      throw Response.forbidden();
    }
    if (userName != null && title != null) {
      print('name of the user $userName and title $title');
      final query = Query<Blogs>(context)
        ..where((v) => v.author.fullName).contains(userName)
        ..where((data) => data.title).contains(title)
        ..join(object: (data) => data.author).returningProperties(
            (data) => [data.fullName, data.email, data.role]);
      //  final moreQuery =   query.fetch().;
      dataResponse = await query?.fetch();
    }
    if (userName != null && title == null) {
      print('name of the user $userName');
      final query = Query<Blogs>(context)
        ..fetchLimit = count
        ..offset = offset
        ..where((data) => data.author.username).contains(userName)
        ..join(object: (data) => data.author).returningProperties(
            (data) => [data.fullName, data.email, data.role]);

      dataResponse = await query.fetch();
    }
    print("data response is ${dataResponse}");
    return Response.ok(dataResponse)
      ..cachePolicy = const CachePolicy(
          requireConditionalRequest: true,
          expirationFromNow: Duration(days: 2));
  }
}
