import 'package:scorpio_server/model/order.dart';
import 'package:scorpio_server/scorpio_server.dart';

class PaymentMethods extends ManagedObject<_PaymentMethods>
    implements _PaymentMethods {}

@Table(name: "paymentMethods")
class _PaymentMethods {
  @primaryKey
  int id;
  @Column(databaseType: ManagedPropertyType.string)
  String title;
  // @Column(indexed: true, databaseType: ManagedPropertyType.integer)
  // int orderSort;
  @Column(databaseType: ManagedPropertyType.boolean)
  bool enabled;
  @Column(databaseType: ManagedPropertyType.string)
  String methodTitle;

  // id, label,descr,type, value, default, tip, placeholder.
  @Column(databaseType: ManagedPropertyType.string)
  String methodDescription;
  @Column(nullable: true)
  Document methodSupports;
  @Column(nullable: true, databaseType: ManagedPropertyType.document)
  Document settings;
  Orders paymentmethodOrders;
  /*
  id, label, description, type , value, default,
  tip, placeholder
  */

}
