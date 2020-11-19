import 'package:aqueduct/aqueduct.dart';
import 'package:aqueduct/managed_auth.dart';
import 'package:scorpio_server/model/user.dart';

/// Managed the return auth token(s) after login attempt with an given scopes base on the user role.
class RoleBasedAuthDelegate extends ManagedAuthDelegate<User> {
  RoleBasedAuthDelegate(ManagedContext context, {int tokenLimit = 40})
      : super(context, tokenLimit: tokenLimit);

  @override
  Future<User> getResourceOwner(AuthServer server, String username) {
    final query = Query<User>(context)
      ..where((u) => u.username).equalTo(username)
      ..returningProperties(
          (t) => [t.id, t.username, t.hashedPassword, t.salt, t.role]);

    return query.fetchOne();
  }

  /// Here we return the allowed scopes base on the user Role,
  ///
  /// Admins will get admin scope
  ///
  /// The reset can be applied later. For instance , we can apply cusomize scope like:
  ///
  /// Accounting role will be able to preview: orders (write/read), users (read only)
  @override
  List<AuthScope> getAllowedScopes(covariant User user) {
    var scopeStrings = [];
    if (user.role == 'admin') {
      scopeStrings = ["admin"];
    }

    return scopeStrings.map((str) => AuthScope(str.toString())).toList();
  }
}
