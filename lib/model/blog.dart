import 'package:scorpio_server/model/user.dart';
import 'package:scorpio_server/scorpio_server.dart';

class Blogs extends ManagedObject<_Blogs> implements _Blogs {
  @override
  void willUpdate() {
    updatedAt = DateTime.now().toUtc();
  }

  @override
  void willInsert() {
    createdAt = DateTime.now().toUtc();
  }
}

@Table(name: "Blogs")
class _Blogs {
  @primaryKey
  int id;
  @Column(databaseType: ManagedPropertyType.string)
  String title;
  @Column(databaseType: ManagedPropertyType.string)
  String contents;
  @Column(databaseType: ManagedPropertyType.string)
  String contentOnList;
  @Column(nullable: true)
  String image;
  @Column(databaseType: ManagedPropertyType.datetime, nullable: true)
  DateTime createdAt;
  @Column(databaseType: ManagedPropertyType.datetime, nullable: true)
  DateTime updatedAt;

  /// By d
  @Relate(#blogsByThisUser)
  User author;
}
