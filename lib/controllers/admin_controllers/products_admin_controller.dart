import 'package:scorpio_server/helper/helper_functions.dart';
import 'package:scorpio_server/model/product.dart';

import 'package:scorpio_server/scorpio_server.dart';

class ProductsAdminController extends ResourceController {
  /// The [ProductsAdminController] extends from ResourceController class as subclass where it handles all HTTP(s).
  /// please refer yourself to orders_admin.dart , it has similar idea and full documentation for scope and secruity.
  ProductsAdminController({this.context});
  final ManagedContext context;

  @Scope(['admin'])
  @Operation.get('id')
  Future<Response> getProduct(@Bind.path('id') int id) async {
    if (id == null) {
      return Response.badRequest(body: {
        "message":
            "there is no ID for this object given , please make sure it is inserted"
      });
    }
    if (!request.authorization.isAuthorizedForScope('admin')) {
      return Response.forbidden();
    }

    final dataQuery = Query<Products>(context)
      ..where((data) => data.id).equalTo(id)
      ..join(object: (data) => data.category).returningProperties((data) => [
            data.name,
            data.id,
            data.image,
            data.name,
            data.description,
          ])
      ..join(object: (data) => data.ownerUser).returningProperties(
          (data) => [data.email, data.fullName, data.role]);

    final data = await dataQuery?.fetchOne();
    return data == null ? Response.noContent() : Response.ok(data);
  }

  @Scope(['admin'])
  @Operation.get()
  Future<Response> getUsers(
      {@Bind.query('count') int count = 0,
      @Bind.query("offset") int offset = 0,
      @Bind.query("pageBy") String pageBy,
      @Bind.query("pageAfter") String pageAfter,
      @Bind.query("pagePrior") String pagePrior,
      @Bind.query("sortBy") List<String> sortBy}) async {
    final _query = Query<Products>(context);
    if (!request.authorization.isAuthorizedForScope('admin')) {
      return Response.forbidden();
    }
    print("The scope is accepted amd the user");
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
        ..fetchLimit = count
        ..offset = offset
        ..pageBy((t) => t[pageBy], direction,
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
    _query
      ..fetchLimit = count
      ..offset = offset
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
    return results.isEmpty ? Response.noContent() : Response.ok(results)
      ..cachePolicy = const CachePolicy(
          requireConditionalRequest: true,
          expirationFromNow: Duration(days: 2));
  }

  @Scope(['admin'])
  @Operation.put('id')
  Future<Response> updatedUser(
      @Bind.path("id")
          int index,
      @Bind.body(ignore: ['id', 'productsCategory'])
          Products productValue) async {
    if (!request.authorization.isAuthorizedForScope('admin')) {
      return Response.forbidden();
    }
    final _query = Query<Products>(context);
    _query
      ..where((x) => x.id).equalTo(index)
      ..values = productValue;

    await _query?.updateOne();

    return Response.accepted();
  }

  @Scope(['admin'])
  @Operation.delete('id')
  Future<Response> deleteProduct(@Bind.path("id") int index) async {
    if (!request.authorization.isAuthorizedForScope('admin')) {
      return Response.forbidden();
    }
    final _query = Query<Products>(context);
    _query.where((x) => x.id).equalTo(index);
    await _query.delete();
    return Response.accepted();
  }

  @Scope(['admin'])
  @Operation.post()
  Future<Response> createNewProduct(
      @Bind.body(ignore: ["id"]) Products newpRoudct) async {
    if (!request.authorization.isAuthorizedForScope('admin')) {
      return Response.forbidden();
    }

    await Query<Products>(context, values: newpRoudct)?.insert();
    return Response.ok(
        {"message": "Thanks , your attempt to updated that account !"});
  }
}
