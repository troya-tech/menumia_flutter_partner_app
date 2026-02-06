# Dependency Graph: firebase_restaurant_repository.dart

Location: `lib/features/restaurant/infrastructure/repositories/firebase_restaurant_repository.dart`

```mermaid
graph TD
    firebase_restaurant_repository_dart["[Infrastructure] firebase_restaurant_repository.dart"]
    firebase_restaurant_repository_dart --> dart_convert["[Library] dart:convert"]
    firebase_restaurant_repository_dart --> firebase_database_firebase_database_dart["[Library] firebase_database/firebase_database.dart"]
    firebase_restaurant_repository_dart --> restaurant_dart["[Entity] restaurant.dart"]
    firebase_restaurant_repository_dart --> restaurant_repository_dart["[Domain] restaurant_repository.dart"]
    firebase_restaurant_repository_dart --> restaurant_dto_dart["[Infrastructure] restaurant_dto.dart"]
    firebase_restaurant_repository_dart --> app_logger_dart["[Theme] app_logger.dart"]
```
