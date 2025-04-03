import '../models/message_model.dart';
import '../models/project_model.dart';
import '../models/review_model.dart';
import '../models/professional_model.dart';

/// Classe utilitária para adaptar modelos para armazenamento local
class LocalModelsAdapter {
  
  /// Converte um objeto DateTime para String ISO8601
  static String dateTimeToString(DateTime dateTime) {
    return dateTime.toIso8601String();
  }
  
  /// Converte uma String ISO8601 para DateTime
  static DateTime stringToDateTime(String dateString) {
    return DateTime.parse(dateString);
  }
  
  /// Converte um Map para um formato compatível com armazenamento local
  static Map<String, dynamic> mapToLocalStorage(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    
    map.forEach((key, value) {
      if (value is DateTime) {
        result[key] = dateTimeToString(value);
      } else if (value is Map) {
        result[key] = mapToLocalStorage(Map<String, dynamic>.from(value));
      } else if (value is List) {
        result[key] = listToLocalStorage(value);
      } else {
        result[key] = value;
      }
    });
    
    return result;
  }
  
  /// Converte uma List para um formato compatível com armazenamento local
  static List listToLocalStorage(List list) {
    return list.map((item) {
      if (item is DateTime) {
        return dateTimeToString(item);
      } else if (item is Map) {
        return mapToLocalStorage(Map<String, dynamic>.from(item));
      } else if (item is List) {
        return listToLocalStorage(item);
      } else {
        return item;
      }
    }).toList();
  }
  
  /// Converte um Map do armazenamento local para um formato compatível com os modelos
  static Map<String, dynamic> localStorageToMap(Map<String, dynamic> map, List<String> dateTimeFields) {
    final result = <String, dynamic>{};
    
    map.forEach((key, value) {
      if (dateTimeFields.contains(key) && value is String) {
        result[key] = stringToDateTime(value);
      } else if (value is Map) {
        result[key] = localStorageToMap(Map<String, dynamic>.from(value), dateTimeFields);
      } else if (value is List) {
        result[key] = localStorageToList(value, dateTimeFields);
      } else {
        result[key] = value;
      }
    });
    
    return result;
  }
  
  /// Converte uma List do armazenamento local para um formato compatível com os modelos
  static List localStorageToList(List list, List<String> dateTimeFields) {
    return list.map((item) {
      if (item is String && dateTimeFields.contains(item)) {
        return stringToDateTime(item);
      } else if (item is Map) {
        return localStorageToMap(Map<String, dynamic>.from(item), dateTimeFields);
      } else if (item is List) {
        return localStorageToList(item, dateTimeFields);
      } else {
        return item;
      }
    }).toList();
  }
}