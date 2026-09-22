import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_board/auth/bloc/auth_bloc.dart';
import 'package:quest_board/auth/data/model/app_user.dart';
import 'package:quest_board/settings/cubit/theme_cubit.dart';
import 'package:quest_board/settings/data/repo/abstract_settings_repo.dart';
import 'package:quest_board/settings/view/settings_page.dart';

class FakeSettingsRepo implements AbstractSettingsRepo {
  bool _dark = false;

  @override
  bool isDarkThemeSelected() => _dark;

  @override
  Future<void> setDarkThemeSelected(bool selected) async {
    _dark = selected;
  }
}

class FakeAuthBloc extends Bloc<AuthBlocEvent, AuthBlocState>
    implements AuthBloc {
  FakeAuthBloc(super.initialState) {
    on<DeleteAccountRequest>((event, emit) {
      deletedNickname = event.nickname;
    });
  }

  String? deletedNickname;
}

void main() {
  late FakeSettingsRepo fakeSettingsRepo;
  late ThemeCubit themeCubit;
  late FakeAuthBloc fakeAuthBloc;

  final testUser = AppUser(
    id: 'user_123',
    email: 'test@example.com',
    nickname: 'TestHero',
    myCampaignIds: [],
    joinedCampaignIds: [],
  );

  setUp(() {
    fakeSettingsRepo = FakeSettingsRepo();
    themeCubit = ThemeCubit(settingsRepo: fakeSettingsRepo);
    fakeAuthBloc = FakeAuthBloc(AuthAuthenticated(testUser));
  });

  tearDown(() {
    themeCubit.close();
    fakeAuthBloc.close();
  });

  Widget buildTestWidget() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>.value(value: themeCubit),
        BlocProvider<AuthBloc>.value(value: fakeAuthBloc),
      ],
      child: const MaterialApp(home: SettingsPage()),
    );
  }

  testWidgets('renders SettingsPage with Delete account button', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Delete account'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets(
    'clicking Delete account opens dialog and Cancel dismisses it cleanly without crash',
    (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Verify dialog is open
      expect(find.text('Delete account?'), findsOneWidget);
      expect(find.text('Type "TestHero" to confirm.'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.text('Delete account?'), findsNothing);
      expect(fakeAuthBloc.deletedNickname, isNull);
    },
  );

  testWidgets('clicking barrier dismisses dialog cleanly without crash', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap delete button
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Delete account?'), findsOneWidget);

    // Tap outside dialog (e.g. top-left corner of screen)
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    // Verify dialog is closed
    expect(find.text('Delete account?'), findsNothing);
    expect(fakeAuthBloc.deletedNickname, isNull);
  });

  testWidgets(
    'entering wrong nickname shows validation error and does not delete',
    (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Enter wrong nickname
      await tester.enterText(find.byType(TextField), 'WrongName');
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Nickname does not match'), findsOneWidget);
      expect(fakeAuthBloc.deletedNickname, isNull);
    },
  );

  testWidgets(
    'entering correct nickname and clicking Delete sends DeleteAccountRequest',
    (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Enter correct nickname
      await tester.enterText(find.byType(TextField), 'TestHero');
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete account?'), findsNothing);
      expect(fakeAuthBloc.deletedNickname, equals('TestHero'));
    },
  );
}
