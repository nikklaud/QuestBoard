# Quest Board Architecture Rules

## Architecture

**Feature First architecture** structure:

```
feature/
├── cubit or bloc
├── data/
│   ├── model/
│   └── repo/
└── view/
```

### Dependency Flow (strict one-way)

```
UI
↓
Cubit/Bloc
↓
Repository
↓
External Services
```

**Presentation layer must never communicate directly with Firebase, SharedPreferences or other external services.**

## State Management

### Cubit vs Bloc

- **Use Cubit by default** - for simple state management
- **Use Bloc only for complex event-driven flows** - when multiple event types affect state

### State Classes

- Must be immutable
- Use `Equatable` for value equality
- Avoid unnecessary rebuilds (keep state granular)
- Global state objects provided at app level in `main.dart`
- Feature-specific state remains local to pages/widgets

## Repositories

### Structure Rules

- Every repository **must have an abstract interface** (AbstractXRepo)
- Implementations **separated** from abstractions
- UI and Cubits depend **only on abstractions**
- Repositories registered through **GetIt**
- Business logic must **not exist inside widgets**

### Registration Pattern (main.dart)

```dart
GetIt.I.registerLazySingleton<AbstractAuthRepo>(
  () => AuthRepo(firebaseAuth: FirebaseAuth.instance, ...),
);
```

## Models

### Rules

- Models are **immutable** (const constructors where possible)
- Support `fromMap()` and `toMap()` for serialization
- Use `Equatable` for value equality
- Avoid embedding **UI-specific logic** inside models
- Handle null safety gracefully with default values

## Widgets

### Rules

- **Pages** coordinate state and orchestrate features
- **Reusable UI** extracted into widgets
- Widgets should remain **dumb and declarative**
- Avoid performing **asynchronous work inside build()**
- Prefer `const` constructors whenever possible
- Handle both loading and error states gracefully

## Logging

### Rules

- Use **Talker** for all errors and important actions
- Never silently catch exceptions
- Convert external exceptions into **domain-specific exceptions**

```dart
GetIt.I<Talker>().error('Error message: $e');
```

## Navigation

### Rules

- Use **go_router** exclusively
- Future routes should support **authentication guards**
- Navigation logic should **not be scattered** across widgets - centralize in `router.dart`

## Firebase

### Rules

- Firebase access **allowed only inside repositories**
- Widgets must **never call Firestore directly**
- Prefer **streams** when real-time synchronization is needed
- Handle all Firebase exceptions and rethrow as domain exceptions

## Testing

### Rules

- Every Cubit should have **unit tests**
- Repositories should be **testable** (mockable interfaces)
- Widget tests should cover **important screens**
- Remove all **placeholder tests**

## Development Process

Before implementing any feature:

1. **Analyze existing architecture**
2. **Reuse existing patterns** whenever possible
3. **Minimize code duplication**
4. **Prefer consistency** over introducing new patterns
5. **Avoid unnecessary abstractions** and overengineering
6. Modify only components **required by the task**
7. **Explain any architectural deviation** before applying it

## Current State

- **AuthBloc**: Global (provided at app root)
- **ThemeCubit**: Global (provided at app root)
- **CampaignListCubit**: Local to CampaignListPage (consider moving to DI for consistency)

## Known Issues (Do Not Fix Unless Required)

- Theme syntax error in `theme.dart` (lines 6-11)
- No authentication route guards
- Direct Firestore access in `campaign_list_page.dart` (lines 64-89)
- Placeholder test in `widget_test.dart`
- Missing campaign creation/edit pages