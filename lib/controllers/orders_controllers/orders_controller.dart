import 'package:scorpio_server/helper/helper_functions.dart';
import 'package:scorpio_server/model/order.dart';
import 'package:scorpio_server/scorpio_server.dart';

class OrdersController extends ResourceController {
  /// The [OrdersController] extends from ResourceController class as subclass where it handles all HTTP(s).
  /// A controller takes only get requests weather by id or speical paramters such as sortby / pageBy and the given detail
  /// the return reponse as encoded requests as plain text of JSON, so the app client / core api can decoded into JSON.

  OrdersController(this.context) {
    {
      acceptedContentTypes = [ContentType.json, ContentType.binary];
    }
  }

  final ManagedContext context;

  @Operation.get('id')
  Future<Response> getCategory(@Bind.path('id') int id) async {
    if (id == null) {
      return Response.badRequest(body: {
        "message":
            "there is no ID for this object given , please make sure it is inserted"
      });
    }

    final dataQuery = Query<Orders>(context);

    dataQuery
      ..where((data) => data.id).equalTo(id)
      ..join(object: (data) => data.userOrders).returningProperties((data) =>
          [data.id, data.fullName, data.email, data.role, data.enabled])
      ..join(object: (data) => data.paymentMethods)
          .returningProperties((data) => [
                data.id,
                data.title,
                data.methodTitle,
                data.enabled,
                data.settings,
                data.methodDescription
              ]);

    final data = await dataQuery?.fetchOne();
    return data == null ? Response.noContent() : Response.ok(data)
      ..cachePolicy = const CachePolicy(
          requireConditionalRequest: true,
          expirationFromNow: Duration(days: 2));
  }

  @Operation.delete('id')
  Future<Response> deleteOneCategory(@Bind.path('id') int id) async {
    if (id == null) {
      return Response.badRequest(
          body: {"message": "the id for this object is not given / valid"});
    }
    final query = Query<Orders>(context)..where((data) => data.id).equalTo(id);

    return await query?.delete() == 0
        ? Response.notFound()
        : Response.ok({'message': 'item is deleted'});
  }

  @Operation.put("id")
  Future<Response> updateOneCategory(
      @Bind.path('id') int id, @Bind.body() Orders body) async {
    if (id == null) {
      return Response.notFound(
          body: {"message": "there is no given blog ID to update"});
    }
    if (body == null) {
      return Response.noContent();
    }
    print('id is $id');
    final query = Query<Orders>(context)
      ..where((data) => data.id).equalTo(id)
      ..values = body;
    return Response.ok(await query?.updateOne());
  }

  @Operation.get()
  Future<Response> getOrders(
      {@Bind.query("count") int count = 0,
      @Bind.query("offset") int offset = 0,
      @Bind.query("pageBy") String pageBy,
      @Bind.query("pageAfter") String pageAfter,
      @Bind.query("pagePrior") String pagePrior,
      @Bind.query("orderRefreance") String orderRefreance,
      @Bind.query("emailUserOrder") String emailUserOrder,
      @Bind.query("sortBy") List<String> sortBy}) async {
    final _query = Query<Orders>(context);
    _query.fetchLimit = count;
    _query.offset = offset;
    bool _singleFetch = false;
    if (orderRefreance != null) {
      if (emailUserOrder == null) {
        return Response.badRequest(body: {
          "error":
              "Not allowed till you provide 'email' where the order made from"
        });
      }
      _singleFetch = true;
      //
      _query
        ..where((data) => data.orderRefreance).equalTo(orderRefreance)
        ..where((data) => data.userOrders.email).equalTo(emailUserOrder);
    }
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

      _query.pageBy((t) => t[pageBy], direction,
          boundingValue: parsed == "null" ? null : parsed);
    }
    if (sortBy != null) {
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
    // if (pageBy == null) {}
    _query
      ..join(object: (data) => data?.userOrders).returningProperties((data) => [
            data.id,
            data.fullName,
            data.email,
            data.username,
            data.role,
            data.enabled
          ])
      ..join(object: (data) => data?.paymentMethods)
          .returningProperties((data) => [
                data.id,
                data.title,
                data.methodTitle,
                data.enabled,
                data.settings,
                data.methodDescription
              ]);

    final results =
        _singleFetch ? await _query?.fetchOne() : await _query?.fetch();

    return results == null ? Response.noContent() : Response.ok(results)
      ..cachePolicy = const CachePolicy(
          requireConditionalRequest: true,
          expirationFromNow: Duration(days: 2));
  }

  @Operation.post()
  Future<Response> addOrder(@Bind.body(ignore: ["id"]) Orders order) async {
    final query = Query<Orders>(context);
    query.values = order;

    return Response.ok(await query?.insert());
  }
}
