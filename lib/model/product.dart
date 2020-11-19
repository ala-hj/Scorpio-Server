import 'package:scorpio_server/model/categories.dart';

import 'package:scorpio_server/model/user.dart';
import 'package:scorpio_server/scorpio_server.dart';

class Products extends ManagedObject<_Products> implements _Products {
  @override
  void willUpdate() {
    updatedAt = DateTime.now().toUtc();
  }

  //
  @override
  void willInsert() {
    createdAt = DateTime.now().toUtc();
  }
}

/// The declared coulmns in [Prodcuts]: NAME , PRICE, DISCOUNT_PRICE , BRAND , SKU , IMAGE , VIDEO_URL, CREATED_TIME
///
@Table(name: "Products")
class _Products {
  // Setup a primary key at the table
  // You dont have to used [Column] key to create the column but the default will apply to it
  @primaryKey
  int id;
  // @Column(
  //     nullable: true, omitByDefault: true, defaultValue: 'null_name_product')
  String name;
  @Column(databaseType: ManagedPropertyType.integer)
  int quantities;
  @Column(databaseType: ManagedPropertyType.doublePrecision)
  double price;
  @Column(databaseType: ManagedPropertyType.doublePrecision, nullable: false)
  double discountPrice;
  @Column(nullable: true, defaultValue: 'null')
  String brand;
  @Column(nullable: true, defaultValue: 'null')
  String sku;
  // image
  @Column(nullable: true, defaultValue: 'null')
  String videoUrl;
  @Column(nullable: true)
  // Possible to addup Document as JSON object
  Document productAttributes;
  @Column(nullable: true, databaseType: ManagedPropertyType.document)
  Document image;

  @Column(databaseType: ManagedPropertyType.boolean)
  bool enabled;
  @Column(databaseType: ManagedPropertyType.boolean)
  bool soldIndividual;
  @Column(databaseType: ManagedPropertyType.integer, nullable: true)
  int maxAmount;
  // @Column(databaseType: ManagedPropertyType.string, nullable: true)
  // String describation;
  // Here annotate the designates the given column as a goreign key
  // Same as well pros is delecared in User table ,one-to-many -> user has many products and product has one user
  // The reason to create this column
  @Column(databaseType: ManagedPropertyType.datetime, nullable: true)
  DateTime createdAt;
  @Column(databaseType: ManagedPropertyType.datetime, nullable: true)
  DateTime updatedAt;
  @Relate(#productsByUser)
  User ownerUser;
  // Categories that belong too as ORM

  @Relate(#productsCategory)
  Categories category;
}
