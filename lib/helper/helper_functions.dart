import 'package:scorpio_server/scorpio_server.dart';

/// A Helper function that helps to parse the given value from String value to the desired value from desc value.
/// Please refer yourself to the detail of the code since it is quite simple to understand.
dynamic parseValueForProperty(String value, ManagedPropertyDescription desc,
    {Response onError}) {
  // check if the value is empty in case , returns null value.
  if (value == "null") {
    return null;
  }

  /// the process goes through try keyword and throw if there is failure may occur.
  try {
    /// check the attribute of the data, go through case keywords.
    switch (desc.type.kind) {
      case ManagedPropertyType.string:
        return value;
      case ManagedPropertyType.bigInteger:
        return int.parse(value);
      case ManagedPropertyType.integer:
        return int.parse(value);
      case ManagedPropertyType.datetime:
        return DateTime.parse(value);
      case ManagedPropertyType.doublePrecision:
        return double.parse(value);
      case ManagedPropertyType.boolean:
        return value == "true";
      case ManagedPropertyType.list:
        return null;
      case ManagedPropertyType.map:
        return null;
      case ManagedPropertyType.document:
        return null;
    }
  } on FormatException {
    /// throw an error but if the error is empty then through as badRequest occures.
    throw onError ??
        Response.badRequest(body: {
          'error':
              'This error occured due to undefined expcetion but it has to do with property type of the request. Please report it to the Dev/Admin.'
        });
  }

  return null;
}
