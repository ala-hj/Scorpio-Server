import 'package:scorpio_server/helper/helper_functions.dart';
import 'package:scorpio_server/model/order.dart';

import 'package:scorpio_server/scorpio_server.dart';

class OrdersAdminController extends ResourceController {
  /// The [OrdersAdminController] extends from ResourceController class as subclass where it handles all HTTP(s)
  ///
  /// This sort of controller is protected by the token and info inside of _authtoken, each requtes has a proper scope of the logged-in user, weather it is an admin or something else..
  /// The trick of the this is that it checks the scope of the requester in the header weatber it is an admin or not.
  ///
  /// this controller main designed to deliver all HTTP requests for orders in full controller for admins.
  OrdersAdminController({this.context});
  final ManagedContext context;

  @Scope(['admin'])
  @Operation.get('id')
  Future<Response> getOrder(@Bind.path('id') int id) async {
    if (id == null) {
      return Response.badRequest(body: {
        "message":
            "there is no ID for this object given , please make sure it is inserted"
      });
    }

    /// it checks the given value in scopes, header, and make sure it is matching admin otherwise requester can not reach any of the implmented functions / operation(S).€
    if (!request.authorization.isAuthorizedForScope('admin')) {
      return Response.forbidden();
    }

    final dataQuery = Query<Orders>(context)
      ..where((data) => data.id).equalTo(id)
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
    final _query = Query<Orders>(context);
    if (!request.authorization.isAuthorizedForScope('admin')) {
      return Response.forbidden();
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

    final results = await _query?.fetch();
    return results.isEmpty ? Response.noContent() : Response.ok(results);
  }

  @Scope(['admin'])
  @Operation.put('id')
  Future<Response> updatedUser(@Bind.path("id") int index,
      @Bind.body(ignore: ['id']) Orders orderValue) async {
    if (!request.authorization.isAuthorizedForScope('admin')) {
      return Response.forbidden();
    }
    final _query = Query<Orders>(context);
    _query
      ..where((x) => x.id).equalTo(index)
      ..values = orderValue;

    await _query?.updateOne();

    return Response.accepted();
  }

  @Scope(['admin'])
  @Operation.delete('id')
  Future<Response> deleteUser(@Bind.path("id") int index) async {
    if (!request.authorization.isAuthorizedForScope('admin')) {
      return Response.forbidden();
    }
    final _query = Query<Orders>(context);
    _query.where((x) => x.id).equalTo(index);
    await _query.delete();
    return Response.accepted();
  }

  @Scope(['admin'])
  @Operation.post()
  Future<Response> createNewUser(
      @Bind.body(ignore: ["id"]) Orders newOrder) async {
    if (!request.authorization.isAuthorizedForScope('admin')) {
      return Response.forbidden();
    }
    if (newOrder.productsOrder == null) {
      return Response.badRequest(body: {
        'message':
            'sorry looks you did not insert any product to create the deisred order'
      });
    }
    await Query<Orders>(context, values: newOrder)?.insert();
    return Response.ok(
        {"message": "Thanks , your attempt to updated that account !"});
  }
}
