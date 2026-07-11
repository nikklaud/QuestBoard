# AGENTS.md

## Commands

- `flutter analyze` - Static analysis (linter)
- `flutter test` - Run tests
- `flutter run` - Run app (requires emulator/device)
- `dart format .` - Format code
- `flutter pub get` - Install dependencies

## Firebase

- Project: `dndquestboard`
- Configured via FlutterFire CLI
- Platforms: Android, iOS (web/macos/windows/linux unsupported)
- Re-run `flutterfire configure` if adding platforms

## Architecture

- **State**: flutter_bloc (AuthBloc, CampaignListCubit, ThemeCubit)
- **DI**: GetIt (registered in `lib/main.dart`)
- **Routing**: go_router (routes in `lib/router.dart`)
- **Logging**: talker_flutter

## Structure

- `lib/auth/` - Authentication (login, registration)
- `lib/campaign_list/` - Campaign CRUD (owner/player lists, create, join)
- `lib/settings/` - Theme settings
- `assets/logo/` - App icon assets