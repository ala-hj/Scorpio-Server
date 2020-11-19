import 'package:scorpio_server/helper/helper_functions.dart';
import 'package:scorpio_server/model/product.dart';
import 'package:scorpio_server/scorpio_server.dart';

class ProdcutCotroller extends ResourceController {
  /// The [ProdcutCotroller] extends from ResourceController class as subclass where it handles all HTTP(s).
  /// A controller takes only get requests weather by id or speical paramters such as sortby / pageBy and the given detail
  /// the return reponse as encoded requests as plain text of JSON, so the app client / core api can decoded into JSON.

  ProdcutCotroller({this.context});
  final ManagedContext context;

  @Operation.get('id')
  Future<Response> getCategory(@Bind.path('id') int id) async {
    if (id == null) {
      return Response.badRequest(body: {
        "message":
            "there is no ID for this object given , please make sure it is inserted"
      });
    }

    final dataQuery = Query<Products>(context)
      ..where((data) => data.id).equalTo(id)
      ..where((data) => data.enabled).equalTo(true)
      ..join(object: (data) => data.category).returningProperties((data) => [
            data.name,
            data.description,
            data.image,
            data.menuOrder,
            data.parent
          ])
      ..join(object: (data) => data.ownerUser).returningProperties(
          (data) => [data.email, data.fullName, data.role]);
    final data = await dataQuery?.fetchOne();
    return data == null ? Response.noContent() : Response.ok(data)
      ..cachePolicy = const CachePolicy(
          requireConditionalRequest: true,
          expirationFromNow: Duration(days: 2));
  }

  @Operation.get()
  Future<Response> getProducts(
      {@Bind.query('count') int count = 0,
      @Bind.query("offset") int offset = 0,
      @Bind.query("pageBy") String pageBy,
      @Bind.query("pageAfter") String pageAfter,
      @Bind.query("pagePrior") String pagePrior,
      @Bind.query("sortBy") List<String> sortBy}) async {
    final _query = Query<Products>(context);
 _query..fetchLimit = count
        ..offset = offset;
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
      final pageByProperty = _query.entity.properties[pageBy];
      if (pageByProperty == null) {
        throw Response.badRequest(
            body: {"message": "cannot page by '$pageBy'"});
      }
      final parsed = parseValueForProperty(pageValue, pageByProperty);
      _query
       
        .pageBy((t) => t[pageBy], direction,
            boundingValue: parsed == "null" ? null : parsed);
    }
    if (sortBy != null) {
      print('start sorting');
      sortBy.forEach((sort) {
        
        final split = sort.split(",").map((str) => str.trim()).toList();
        if (split.length != 2) {
          throw Response.badRequest(body: {
            "error":
                "invalid 'sortyBy' format. syntax: 'name,asc' or 'name,desc'."
          });
        }
        if (_query.entity.properties[split.first] == null) {
          throw Response.badRequest(
              body: {"error": "cannot sort by '$sortBy'"});
        }
        if (split.last != "asc" && split.last != "desc") {
          throw Response.badRequest(body: {
            "error":
                "invalid 'sortBy' format. syntax: 'name,asc' or 'name,desc'."
          });
        }
        final sortOrder = split.last == "asc"
            ? QuerySortOrder.ascending
            : QuerySortOrder.descending;
        _query.sortBy((t) => t[split.first], sortOrder);
      });
    }

    _query
      ..join(object: (data) => data.category).returningProperties((data) => [
            data.name,
            data.id,
            data.image,
            data.name,
            data.description,
          ])
      ..join(object: (data) => data.ownerUser).returningProperties(
          (data) => [data.email, data.fullName, data.role]);
    final results = await _query?.fetch();
    return results.isEmpty ? Response.noContent() : Response.ok(results);
      
  }
}
