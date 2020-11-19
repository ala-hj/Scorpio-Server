import 'package:scorpio_server/model/payment_methods.dart';
import 'package:scorpio_server/scorpio_server.dart';

class PaymentMethodsController extends ManagedObjectController<PaymentMethods> {
  /// The [PaymentMethodsController] extends from ResourceController class as subclass where it handles all HTTP(s)
  /// A controller takes only get requests weather by id or speical paramters such as sortby / pageBy and the given detail
  /// the return reponse as encoded requests as plain text of JSON, so the app client / core api can decoded into JSON.

  PaymentMethodsController({this.context}) : super(context);
  final ManagedContext context;
}
