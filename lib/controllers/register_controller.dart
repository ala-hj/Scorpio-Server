import 'package:scorpio_server/model/user.dart';
import 'package:scorpio_server/scorpio_server.dart';

class RegisterController extends ResourceController {
  /// A Controller that only handles post request(s) to create new users , it requires 3 things: username, email, and password.
  RegisterController({this.authServer, this.context});

  final ManagedContext context;
  final AuthServer authServer;

  ///
  /// createUser function is used to regsiter the request user to DB and ignoring primary key [{'id': value_id}]
  ///
  /// body contains decoded body aka JSON body, the binding will translate it into a Model.
  ///

  @Operation.post()
  Future<Response> createUser(@Bind.body(ignore: ['id']) User user) async {
    if (user.username == null || user.password == null || user.email == null) {
      throw Response.badRequest(body: {
        'code': 2001,
        'message': 'One of the username / password is empty'
      });
    }

    /// It first gives random Base64 salt, like string.
    /// then run hashing function by using PBKDF2 algorthim. by getting the salt varliable + password and combined together
    user
      ..salt = AuthUtility.generateRandomSalt()
      ..hashedPassword = authServer.hashPassword(user.password, user.salt);
    await Query<User>(context, values: user)?.insert();
    return Response.ok({
      "code": 2000,
      "message": "Thanks , your attempt to register is successed !"
    });
  }
}
