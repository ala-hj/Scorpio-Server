import 'package:scorpio_server/scorpio_server.dart';

class ScorpioConfig extends Configuration {
  /// Pass the path to the confgiration file: config.yaml so it will read all valus from the keys over there
  ScorpioConfig(String path)
      : assert(path.isNotEmpty),
        super.fromFile(File(path));

  DatabaseConfiguration database;
}
