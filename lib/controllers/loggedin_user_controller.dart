import 'package:scorpio_server/model/user.dart';
import 'package:scorpio_server/scorpio_server.dart';

class LoggedInUserController extends ResourceController {
  /// The [LoggedInUserController] extends from ResourceController class as subclass where it handles all HTTP(s)
  /// A controller takes that handles only authorized requests from the owner of this object.
  /// it first gets the token, from the header, and then translated by checking from _authtoken table that checks up the existing of this token, expiration of token, and then find the owner of this token.
  ///
  ///     final userId = request.authorization.ownerID;
  ///
  ///     final query = Query<SomeModel>(context)..where((v)=> v.id).identifiedBy(userId);
  ///     final value = await query?.fetchOne();
  ///
  ///     return value == null ??  Response.noContent(): response.ok(value);
  LoggedInUserController({this.context});
  final ManagedContext context;

  @Operation.get()
  Future<Response> getLoggedInUser() async {
    final userId = request.authorization.ownerID;
    print('the owner is $userId');
    final query = Query<User>(context)
      ..where((x) => x.id).identifiedBy(userId)
      ..join(set: (data) => data.ordersByThisUser)
          .returningProperties((data) => [
                data.id,
                data.total,
                data.billing,
                data.dateCompleted,
                data.transactionId,
                data.orderRefreance,
                data.shipping,
                data.status,
                data.paymentMethods,
                data.productsOrder
              ])
      ..join(set: (data) => data.blogsByThisUser)
          .returningProperties((data) => [
                data.id,
                data.image,
                data.title,
                data.contents,
                data.createdAt,
                data.updatedAt,
              ])
      ..join(set: (data) => data.productsByUser).returningProperties((data) => [
            data.name,
            data.id,
            data.price,
            data.productAttributes,
            data.sku,
            data.enabled,
            data.createdAt,
            data.soldIndividual,
            data.videoUrl,
            data.category
          ]);

    return Response.ok(await query?.fetchOne());
  }

  /// Fetch the requester ID from authoentication , if it is not there then it will throw 403 error
  @Operation.put()
  Future<Response> updateUser(@Bind.body(ignore: ['id']) User newValue) async {
    final userId = request.authorization.ownerID;
    print(
        'the owner is $userId ... preforms update .. the new data is \n $newValue');
    final _query = Query<User>(context)
      ..where((x) => x.id).identifiedBy(userId)
      ..values = newValue;
    await _query?.updateOne();

    return Response.accepted();
  }

  /// Fetch the requester ID from authoentication , if it is not there then it will throw 403 error
  @Operation.delete()
  Future<Response> deleteUserOrInfo() async {
    final userId = request.authorization.ownerID;

    final _query = Query<User>(context)
      ..canModifyAllInstances = false
      ..where((x) => x.id).identifiedBy(userId);
    await _query?.delete();
    return Response.accepted();
  }
}
