/*
    developed by Ala Mohamed Alhaj - 2020 

    refer to alla.hajj@gmail.com
*/
import 'package:scorpio_server/scorpio_server.dart';


/// This is the first function Dart looks up as entry to execute the server from , so please pay attention by running [dart main.dart]
/// or  [aqudeuct serve]
/// ! ATTENTION PLEASE: If you would run the server without any database issue or conflict issues,
/// ! use Dart version 2.7.2 as the current packges aqudeuct is out-dated.


Future main() async {
  /// first variable declared which allows the listeners inside of this class to handle all HTTP requests
  ///
  /// options is instace that delcaring configuration options for the server such as configuration file or port
  final Application app = Application<ScorpioServerChannel>()
    ..options.configurationFilePath = "config.yaml"
    ..options.port = 8888;

  /// after delcaring app then the main future multhreading aka isolations comes here
  /// delcaring count by using platform instance that check the low-level of machine which is the CPU
  /// and then get average of threads that can be used , for instace in my machine 2 isolated memory
  ///
  /// ! more isolated does not mean it is better preformance as it is just consuming more sources of the machine
  final count = Platform.numberOfProcessors ~/ 2;

  print('number of prepreaed isolated memories : $count');

  /// if the system is not capable to run at more than one isolated memeory , then go with 1 in that case.
  await app.start(numberOfInstances: count > 0 ? count : 1);

  print("› started on port: ${app.options.port}.");
  print("Use Ctrl-C (SIGINT) to stop running the application.");
}
