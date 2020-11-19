import 'package:scorpio_server/helper/helper_functions.dart';
import 'package:scorpio_server/model/blog.dart';

import 'package:scorpio_server/scorpio_server.dart';

class BlogsController extends ResourceController {
  /// The [BlogsController] extends from ResourceController class as subclass where it handles all HTTP(s)
  /// A controller takes only get requests weather by id or speical paramters such as sortby / pageBy and the given detail
  /// the return reponse as encoded requests as plain text of JSON, so the app client / core api can decoded into JSON.
  BlogsController(this.context) {
    {
      acceptedContentTypes = [ContentType.json, ContentType.binary];
    }
  }
  final ManagedContext context;

  @Operation.get('id')
  Future<Response> getBlogByEmail(@Bind.path('id') int id) async {
    final query = Query<Blogs>(context)
      ..where((data) => data.id).equalTo(id)
      ..join(object: (data) => data.author).returningProperties(
          (data) => [data.fullName, data.email, data.role]);
    final data = await query?.fetchOne();

    return data == null ? Response.noContent() : Response.ok(data)
      ..cachePolicy = const CachePolicy(
          requireConditionalRequest: true,
          expirationFromNow: Duration(days: 2));
  }

  @Operation.get()
  Future<Response> getBlogs({
    @Bind.query('title') String titleBlog,
    @Bind.query('email') String email,
    @Bind.query('idObject') int idObject,
    @Bind.query('count') int count = 0,
    @Bind.query("offset") int offset = 0,
    @Bind.query("pageBy") String pageBy,
    @Bind.query("pageAfter") String pageAfter,
    @Bind.query("pagePrior") String pagePrior,
  }) async {
    dynamic dataResponse;
    // here it is used for filtering
    if (pageBy != null) {
      QuerySortOrder direction;
      String pageValue;
      if (pageAfter != null) {
        direction = QuerySortOrder.ascending;
        pageValue = pageAfter;
      } else if (pagePrior != null) {
        direction = QuerySortOrder.descending;
        pageValue = pagePrior;
      } else {
        return Response.badRequest(body: {
          "error":
              "missing required parameter 'pageAfter' or 'pagePrior' when 'pageBy' is given"
        });
      }
      final pageByProperty = Query<Blogs>(context).entity.properties[pageBy];
      if (pageByProperty == null) {
        throw Response.badRequest(
            body: {"message": "cannot page by '$pageBy'"});
      }
      final parsed = parseValueForProperty(pageValue, pageByProperty);
      final query = Query<Blogs>(context)
        ..fetchLimit = count
        ..offset = offset
        ..pageBy((t) => t[pageBy], direction,
            boundingValue: parsed == "null" ? null : parsed);
      dataResponse = await query?.fetch();
    }
    // if the query is empty it will fetch all blogs
    if (titleBlog == null && idObject == null) {
      print("Fetch all blogs");
      final query = Query<Blogs>(context)
        ..fetchLimit = count
        ..offset = offset
        ..join(object: (data) => data.author).returningProperties(
            (data) => [data.fullName, data.email, data.role]);
      dataResponse = await query?.fetch();
    }

    // if the query is not empty , it will fetch the data by the given title
    if (titleBlog != null && idObject == null) {
      print("getting title request $titleBlog");
      final query = Query<Blogs>(context)
        ..where((v) => v.title).contains(titleBlog)
        ..fetchLimit = count
        ..offset = offset
        ..join(object: (data) => data.author).returningProperties(
            (data) => [data.fullName, data.email, data.role]);

      dataResponse = await query?.fetch();
    }
    // find titleBlog and the id
    if (titleBlog != null && idObject != null) {
      // print("number of ids are required to request ${idObject.length}");
      // print("getting title request $titleBlog and id ${idObject.iterator}");
      final query = Query<Blogs>(context)
        ..where((v) => v.title).contains(titleBlog)
        ..fetchLimit = count
        ..offset = offset
        ..where((data) => data.id).equalTo(idObject)
        ..join(object: (data) => data.author).returningProperties(
            (data) => [data.fullName, data.email, data.role]);

      dataResponse = await query?.fetch();
    }
    // find the blog by the of the user email if it is not null
    if (email != null) {
      print("getblogbyemail function executed = $email");
      final query = Query<Blogs>(context)
        ..where((data) => data.author.email).contains(email)
        ..fetchLimit = count
        ..offset = offset
        ..join(object: (data) => data.author).returningProperties(
            (data) => [data.fullName, data.email, data.role]);
      dataResponse = await query.fetch();
    }
    return dataResponse.length == 0
        ? Response.noContent()
        : Response.ok(dataResponse)
      ..cachePolicy = const CachePolicy(
          requireConditionalRequest: true,
          expirationFromNow: Duration(days: 2));
  }
}
