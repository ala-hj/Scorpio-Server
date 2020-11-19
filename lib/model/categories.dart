import 'package:scorpio_server/model/product.dart';
import 'package:scorpio_server/scorpio_server.dart';

class Categories extends ManagedObject<_Categories> implements _Categories {}

/// The declared coulmns in [Categories]: NAME , PRICE, DISCOUNT_PRICE , BRAND , SKU , IMAGE , VIDEO_URL, CREATED_TIME
///
@Table(name: "Categories")
class _Categories {
  // Setup a primary key at the table
  // You dont have to used [Column] key to create the column but the default will apply to it
  @primaryKey
  int id;
  // other needs colums for this table
  @Column(databaseType: ManagedPropertyType.string)
  String name;
  @Column(databaseType: ManagedPropertyType.integer, nullable: true)
  int parent;
  @Column(databaseType: ManagedPropertyType.string, nullable: true)
  String description;
  @Column(databaseType: ManagedPropertyType.document, nullable: true)
  Document image;
  @Column(databaseType: ManagedPropertyType.integer, nullable: true)
  int menuOrder;
  @Column(databaseType: ManagedPropertyType.integer, nullable: true)
  int count;
  // products property is inverse for the forgien key on products table
  ManagedSet<Products> productsCategory;
}
