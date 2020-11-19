/// This following table the order should have relationship wtih -> user , address ,product(s), category
import 'package:aqueduct/aqueduct.dart';
import 'package:scorpio_server/model/payment_methods.dart';
import 'package:scorpio_server/model/user.dart';

// Get user , product item , date time , address information , billing , transaction , payment method , status , payement status
// ip address

// enum OrderStatus {
//   newOrder,
//   acceptOrder,
//   rejectedOrder,
//   cancaledOrder,
//   deliveringOrder,
//   refundOrder
// }

class Orders extends ManagedObject<_Orders> implements _Orders {
  @override
  void willUpdate() {
    updatedAt = DateTime.now().toUtc();
  }

  @override
  void willInsert() {
    createdAt = DateTime.now().toUtc();
  }
}

/// The declared coulmns in [Prodcuts]: NAME , PRICE, DISCOUNT_PRICE , BRAND , SKU , IMAGE , VIDEO_URL, CREATED_TIME
///
@Table(name: "Orders")
class _Orders {
  // Setup a primary key at the table
  // You dont have to used [Column] key to create the column but the default will apply to it
  @primaryKey
  int id;

  @Column(
      nullable: false, unique: true, databaseType: ManagedPropertyType.string)
  String orderRefreance;
  @Column(nullable: false)
  String status;

  /// Use ISO format for the currency such as USD / SAR / PLN and so on.
  ///
  @Column(databaseType: ManagedPropertyType.datetime, nullable: true)
  DateTime createdAt;
  @Column(databaseType: ManagedPropertyType.string)
  String currency;
  @Column(databaseType: ManagedPropertyType.datetime, nullable: true)
  DateTime updatedAt;
  @Column(databaseType: ManagedPropertyType.doublePrecision)
  double discountTotal;
  @Column(databaseType: ManagedPropertyType.doublePrecision)
  double shippingTotal;
  @Column(databaseType: ManagedPropertyType.doublePrecision)
  double total;
  @Relate(#ordersByThisUser)
  User userOrders;

  Document productsOrder;
  @Column(nullable: true, databaseType: ManagedPropertyType.document)
  Document billing;
  @Column(nullable: true, databaseType: ManagedPropertyType.document)
  Document shipping;
  @Column(
      nullable: true, databaseType: ManagedPropertyType.string, unique: true)
  String transactionId;
  @Relate(#paymentmethodOrders)
  PaymentMethods paymentMethods;
  @Column(nullable: true, databaseType: ManagedPropertyType.datetime)
  DateTime datePaid;
  @Column(nullable: true, databaseType: ManagedPropertyType.datetime)
  DateTime dateCompleted;
  @Column(databaseType: ManagedPropertyType.string, nullable: true)
  String trackingNumber;
  @Column(nullable: true, databaseType: ManagedPropertyType.boolean)
  bool setPaid;
}
