import 'package:aqueduct/managed_auth.dart';
import 'package:scorpio_server/model/blog.dart';
import 'package:scorpio_server/model/order.dart';
import 'package:scorpio_server/model/product.dart';
import 'package:scorpio_server/scorpio_server.dart';

class User extends ManagedObject<_User>
    implements _User, ManagedAuthResourceOwner<_User> {
  @Serialize(input: true, output: false)
  String password;
  String get fullName => "$firstName $lastName";
  set name(String fullName) {
    firstName = fullName.split(" ").first;
    lastName = fullName.split(" ").last;
  }

  @override
  void willUpdate() {
    updatedAt = DateTime.now().toUtc();
  }

  @override
  void willInsert() {
    createdAt = DateTime.now().toUtc();
  }
}

@Table(name: "Users")
class _User extends ResourceOwnerTableDefinition {
  // The sounds create thing is that Aqueduct framework helps to implenent the Columns and their data type and validation
  @Column(nullable: true, databaseType: ManagedPropertyType.string)
  String firstName;
  @Column(nullable: true, databaseType: ManagedPropertyType.string)
  String lastName;
  @Column(unique: true, databaseType: ManagedPropertyType.string)
  @Validate.length(greaterThan: 10)
  String email;
  @Column(databaseType: ManagedPropertyType.string)
  @Validate.oneOf(["admin", "buyer", "employee", "vendor"])
  String role;
  @Column(databaseType: ManagedPropertyType.boolean)
  bool enabled;
  @Column(nullable: true, databaseType: ManagedPropertyType.document)
  Document address;
  @Column(nullable: true, databaseType: ManagedPropertyType.document)
  Document billing;
  @Column(databaseType: ManagedPropertyType.string)
  String phoneNumber;
  @Column(databaseType: ManagedPropertyType.datetime, nullable: true)
  DateTime createdAt;
  @Column(databaseType: ManagedPropertyType.datetime, nullable: true)
  DateTime updatedAt;

  /// By declared [ManagedSet] we create one-to-many relationships
  ///
  ManagedSet<Products> productsByUser;

  ///
  ///
  ManagedSet<Orders> ordersByThisUser;

  ///
  ///
  ManagedSet<Blogs> blogsByThisUser;
}
