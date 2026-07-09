# invoker — Hybrid Flutter Add-to-App

A sample "add-to-app" project: native Android/iOS onboarding screens hand off to a
pre-warmed `FlutterEngine`, then the user continues inside Flutter. Native and Flutter
exchange data over a `MethodChannel` (`com.example.hybrid/native_bridge`).

Components:
- `flutter_module/` — shared Flutter/Dart UI module (`lib/main.dart`).
- `android_host/` — native Android host (Kotlin, Gradle).
- `ios_host/` — native iOS host (Swift/UIKit, CocoaPods).
- `scripts/bootstrap_flutter_module.sh` — regenerates the gitignored Flutter
  `.android/` / `.ios/` wrapper folders.

> Note: on the current `main` branch the app code lives only on the (unmerged)
> add-to-app PR branch. Commands below assume that code is present in the working tree.

## Cursor Cloud specific instructions

### Toolchain (already installed in the VM snapshot)
The dev toolchain is installed under `$HOME` and put on `PATH` via `~/.bashrc`
(login shells pick it up automatically — no need to re-export):
- Flutter (stable) → `~/flutter`  (`flutter`, `dart`)
- Android SDK → `~/android-sdk`  (`ANDROID_HOME`/`ANDROID_SDK_ROOT`; `adb`, `sdkmanager`;
  platform-tools, `platforms;android-37.0`/`37.1`, `build-tools;37.0.0`)
- Gradle → `~/gradle-9.6.1`  (the repo ships no Gradle wrapper, so a system Gradle is required)

### Platform reality on this VM
- **iOS host cannot be built here** — it needs macOS + Xcode + CocoaPods. Linux only.
- **No `/dev/kvm`**, so a hardware-accelerated Android emulator will not run. Validate the
  Flutter UI on **web/Chrome** instead of an emulator (see below).

### Lint / deps (the reliable checks here)
- Deps: `cd flutter_module && flutter pub get`
- Lint/analyze: `cd flutter_module && flutter analyze` (repo source is clean).
- The repo has **no committed tests**. `flutter create` regenerates a default
  `test/widget_test.dart` stub that references `MyApp` and will fail `flutter analyze`/
  `flutter test`; delete that stub (it is not part of the repo).

### Regenerating the Flutter wrappers (bootstrap gotcha)
`scripts/bootstrap_flutter_module.sh` calls `flutter create ... --platforms android,ios`,
but current Flutter **rejects `--platforms` for the `module` template**. To (re)generate
`flutter_module/.android` and `.ios`, run without `--platforms`:
```bash
flutter create --template module --org com.example.hybrid flutter_module
```
This preserves the existing `lib/main.dart` and `pubspec.yaml`.

### Running the Flutter UI (quick visual check on web)
The module is not web-configured and the `module` template rejects adding web. To render
`lib/main.dart` in a browser, copy it into a throwaway standard app and serve it:
```bash
flutter create --platforms web --org com.example.hybrid /tmp/hybrid_web_demo
cp flutter_module/lib/main.dart /tmp/hybrid_web_demo/lib/main.dart
cd /tmp/hybrid_web_demo && flutter run -d web-server --web-port 8099 --web-hostname 0.0.0.0
```
On web there is no native `MethodChannel` handler, so the "Payload от native" card stays at
"Ожидаем данные от native" — that is expected off-device, the UI itself renders fine.

### Android host build (known repo-config failure)
`cd android_host && gradle :app:assembleDebug` currently fails during configuration:
`settings.gradle` sets `RepositoriesMode.FAIL_ON_PROJECT_REPOS`, which conflicts with
`dev.flutter.flutter-gradle-plugin` adding a project `maven` repository. This is a
project configuration issue in the repo (not an environment/toolchain problem); the
Gradle + AGP + Android SDK toolchain itself resolves and runs up to that point.
`gradle` needs `android_host/local.properties` with `sdk.dir=$HOME/android-sdk`
(gitignored; create it if missing).
