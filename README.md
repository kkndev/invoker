# Hybrid Flutter Add-to-App

Пример приложения, где первые экраны нативные, затем запускается Flutter engine,
и дальнейший пользовательский путь идет во Flutter.

Структура:

- `flutter_module/` — Flutter-модуль с Dart UI.
- `android_host/` — нативное Android-приложение на Kotlin.
- `ios_host/` — нативное iOS-приложение на Swift/UIKit.
- `scripts/bootstrap_flutter_module.sh` — генерация скрытых Flutter wrapper-файлов
  для add-to-app интеграции.

## Как это работает

1. Пользователь открывает нативное приложение.
2. Android/iOS показывают несколько native экранов.
3. На последнем native шаге host-приложение прогревает `FlutterEngine`.
4. При нажатии кнопки открывается Flutter экран через уже запущенный engine.
5. Native и Flutter обмениваются данными через `MethodChannel`:
   `com.example.hybrid/native_bridge`.

## Требования

- Flutter SDK или FVM.
- Android Studio с Android SDK для Android host.
- Xcode и CocoaPods для iOS host.

Если в проекте используется FVM, выполните, например:

```bash
fvm use stable
```

Скрипт bootstrap автоматически использует `fvm flutter`, если `fvm` установлен.
Если нужно явно указать команду Flutter:

```bash
FLUTTER_CMD="fvm flutter" scripts/bootstrap_flutter_module.sh
```

## Первый запуск

Сгенерируйте platform wrapper-файлы Flutter-модуля:

```bash
scripts/bootstrap_flutter_module.sh
```

Эта команда создаст:

- `flutter_module/.android/`
- `flutter_module/.ios/`

Эти папки генерируемые и не коммитятся.

## Android

Откройте `android_host/` в Android Studio или соберите через Gradle:

```bash
cd android_host
./gradlew :app:assembleDebug
```

Android flow:

- `MainActivity` показывает native экран.
- `warmUpFlutterEngine()` создает `FlutterEngine`.
- Engine сохраняется в `FlutterEngineCache` под ключом `main_engine`.
- Flutter открывается через:

```kotlin
FlutterActivity.withCachedEngine("main_engine").build(this)
```

## iOS

После bootstrap выполните:

```bash
cd ios_host
pod install
open HybridIOSHost.xcworkspace
```

iOS flow:

- `NativeOnboardingViewController` показывает два native шага.
- На втором шаге вызывается `FlutterCoordinator.shared.warmUp()`.
- Flutter открывается через `FlutterViewController(engine:nibName:bundle:)`.

## Передача данных

Flutter вызывает native:

```dart
const MethodChannel('com.example.hybrid/native_bridge')
    .invokeMethod<String>('getInitialPayload');
```

Android и iOS возвращают demo payload. В реальном приложении здесь можно
передавать:

- access token;
- user id;
- язык и тему;
- стартовый route;
- feature flags;
- параметры экрана.

## Важные файлы

- Flutter UI: `flutter_module/lib/main.dart`
- Android native host: `android_host/app/src/main/java/com/example/hybrid/androidhost/MainActivity.kt`
- iOS native host:
  - `ios_host/HybridIOSHost/NativeOnboardingViewController.swift`
  - `ios_host/HybridIOSHost/FlutterCoordinator.swift`
