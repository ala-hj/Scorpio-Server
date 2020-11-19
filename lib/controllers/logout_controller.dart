import 'package:aqueduct/managed_auth.dart';
import 'package:scorpio_server/scorpio_server.dart';

class LogoutController extends ResourceController {
  /// A controller takes only delete request by the token given in the request.
  /// There is no given response only true if it went through or error message in encoded body.

  LogoutController({this.context});
  final ManagedContext context;

  @Operation.delete()
  Future<Response> logout(@Bind.query('token') String token) async {
    if (token == null) {
      return Response.badRequest(body: {'error': 'no token given'});
    }
    print('token access is $token');
    final query = Query<ManagedAuthToken>(context)
      ..where((o) => o.accessToken).equalTo(token);
    return await query?.delete() == 0
        ? Response.notFound(
            body: {'error': 'Could not find it , looks the token is deleted'})
        : Response.ok(true);
  }
}
