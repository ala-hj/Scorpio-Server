// Developed & Documented by Ala Alhaj alla.hajj@gmail.com.
// if this project will be used for commercial use other than the developer , please write the credit.
// it is free use if it is for education purposes
import 'package:scorpio_server/helper/role_based_auth.dart';
import 'package:scorpio_server/config/scorpioConfig.dart';
import 'package:scorpio_server/controllers/admin_controllers/orders_admin_controller.dart';
import 'package:scorpio_server/controllers/admin_controllers/products_admin_controller.dart';
import 'package:scorpio_server/controllers/blogs_controllers/blogs_controller.dart';
import 'package:scorpio_server/controllers/blogs_controllers/blogs_user_controller.dart';

import 'package:scorpio_server/controllers/categories_controller.dart';
import 'package:scorpio_server/controllers/loggedin_user_controller.dart';
import 'package:scorpio_server/controllers/logout_controller.dart';

import 'package:scorpio_server/controllers/orders_controllers/orders_controller.dart';
import 'package:scorpio_server/controllers/paymentMethods_controller.dart';
import 'package:scorpio_server/controllers/products_controller.dart';
import 'package:scorpio_server/controllers/admin_controllers/users_controller.dart';
import 'package:scorpio_server/controllers/register_controller.dart';

import 'scorpio_server.dart';

/// This is the entery to the server where the server will behave base on two main methods
/// that should override: [entryPoint()] and [preapre()]
///
/// [prepare()]: it is a method used to initialize any service(s) to be used in controllers
/// and establish connection DB Server.
///
/// [entryPoint()]:
class ScorpioServerChannel extends ApplicationChannel {
  /// This is a delecared variable to give accesability to all database in under one scope
  ManagedContext context;

  /// it is used to controller any requried authentication that our server preforms from to client-side; app and website
  AuthServer authServer;

  /// To create the neccsery connection after you install the SQL at the host.
  ///
  /// Needs to create proper port, app name , user , grant the user permission to it:
  ///
  /// [CREATE DATABASE] app_name;
  /// [CREATE USER] username "WITH" PASSWORD ["any_given_passsowrd"];
  /// [GRANT ALL ON DATABASE] app_name "TO" username;
  ///
  /// After all you are good to pass them here manually or use config.yaml

  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    /// Confguire the connection to Scorpio Database
    /// for the sake of testing we enable stack trace to return 500 erros to client side
    ///
    /// Please if amend any changes on DB such as port , name or diffirent account you want server to connect to
    /// update the inform at [database.yaml].
    Controller.includeErrorDetailsInServerErrorResponses = true;
    final config = ScorpioConfig(options.configurationFilePath);

    /// Creates an instance of a [ManagedDataModel] from all subclasses of [ManagedObject] in all libraries visible to the calling library.
    /// This called method is basically check all subclasses under our model that inhirets from ManagedObject class
    final dataModel = ManagedDataModel.fromCurrentMirrorSystem();

    /// Here we pass all keys value to the construce to establish or let us say initiale the connection to DB
    final presistentStore = PostgreSQLPersistentStore.fromConnectionInfo(
        config.database.username,
        config.database.password,
        config.database.host,
        config.database.port,
        config.database.databaseName);
    // This is quite imporat when the user query sent from clien-side to server where it will be descrived by presistenStore
    context = ManagedContext(dataModel, presistentStore);
    /// Run aqueduct db generate to generate the tables configured under ManagedObject instance, all of those are declared under [Models] folder
    ///
    /// [ATTENTION]: Running that command not only to initial but also to update the table(s) if there is any change amend on the code base.
    ///

    /// PLEASE THOSE ARE THE CURRENT CLIENT APPLICATION:
    /// 
    /// In my case , I have setup them into those generic codes:
    /// 
    ///Client ID trc-319-69fa-ff52-3ef6eca51100
    ///Client Secret d440e833-3bbf-4393-ba890c79ee59d3ad6
    
    ///  aqueduct auth add-client \
    /// To create new Clients 2.0:
    /// aqueduct auth add-client \
    /// --id [Clinet ID] \
    /// --secret [Client secret] \
    /// --connect postgres://[username]:[password]@localhost:[port]/[database_name]
    ///
    /// Example: aqueduct db upgrade --connect postgres://[username]:[password]@localhost:[port]/[database_name]
    
    ///
    // final delgate = ManagedAuthDelegate<User>(context, tokenLimit: 2);
    final delgate = RoleBasedAuthDelegate(context, tokenLimit: 2);
    authServer = AuthServer(delgate);
  }

  /// This method will be executed after prepare method to get the requests.
  @override
  Controller get entryPoint {
    /// Happily to say that this is where the game starts !
    /// The router works to route the HTTP requests to the right path
    final router = Router();
    router.route('/auth/token').link(() => AuthController(authServer));

    /// delete the token row data at the database
    router.route('/logout').link(() => LogoutController(context: context));

    /// router.route("/auth/code").link(() => AuthRedirectController(authServer,delegate: authServer.delegate));
    /// Will be better design and approch that will divide the routers base on the need such as register , users and so on

    // ! Only authorized user can access by getting the owner of the token and then execute base on the ownerID
    router
        .route('/loggedInUser')
        .link(() => Authorizer.bearer(authServer))
        .link(() => LoggedInUserController(context: context));

    /// Admin controllers that only accept users who are in the same scope.
    router
        .route("/adminUsers[/:id]")
        .link(() => Authorizer.bearer(authServer, scopes: ['admin']))
        .link(() => UsersAdminController(context: context));

    router
        .route('/adminProducts[/:id]')
        .link(() => Authorizer.bearer(authServer, scopes: ['admin']))
        .link(() => ProductsAdminController(context: context));
    router
        .route('adminOrders[/:id]')
        .link(() => Authorizer.bearer(authServer, scopes: ['admin']))
        .link(() => OrdersAdminController(context: context));

    /// Public controllers that only contains get operation(s) or put/post/delete but all are limited.
    router
        .route("/products[/:id]")
        .link(() => ProdcutCotroller(context: context));

    /// This is a controller that registers USERs and each of them are not enabled.
    router.route('/register').link(
        () => RegisterController(context: context, authServer: authServer));

    /// to enable cache , use 'Cache-Control: no-cache' at headers
    router.route("/categories[/:id]").link(() => CategoriesController(context));

    /// Testing controller , not functional yet.
    // router
    //     .route("/paymentMethods")
    //     .link(() => PaymentMethodsController(context: context));

    /// each of those named blogs controller will handle specific path
    ///
    ///First controller is used for queries + post + delete + put
    router.route("/blogs[/:id]").link(() => BlogsController(context));

    /// Second controller of blogs used to find blogs by the user, this is a good example
    /// of best pracatice to have more specific use of controller if there is desired route.

    router
        .route("/blogs/userName/:userName")
        .link(() => BlogsUserController(context));
    router.route("/orders[/:id]").link(() => OrdersController(context));
    router.route("/files/*").link(() => FileController("public/")
      ..addCachePolicy(const CachePolicy(expirationFromNow: Duration(days: 2)),
          (path) => path.endsWith('.png') || path.endsWith('.jpg')));
    // ! hidden controller as it is still underworking to handle some sort of media/files requests.
    // router.route('/image').link(() => MediaUploadController());
    return router;
  }
}
