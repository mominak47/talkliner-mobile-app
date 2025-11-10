# Login Flow

This document summarizes the updated authentication flow implemented in `lib/app/controllers/auth_controller.dart`, `lib/app/services/auth_service.dart`, and related utilities.

## Sequence Overview
1. **Input validation**  
   `AuthController.login` trims the username, verifies both fields are present, and debounces repeated submissions (minimum 800 ms between attempts).

2. **Authentication request**  
   `AuthService.login` sends `POST https://api.talkliner.com/api/domains/login` with:
   ```json
   {
     "username": "<username>",
     "password": "<password>"
   }
   ```
   Responses are validated for a non-empty `token`; malformed payloads raise a `FormatException`.

3. **Token persistence**  
   `TokenManager.setToken` tries to store the token in `flutter_secure_storage` (mobile/desktop). If secure storage is unavailable, it falls back to `GetStorage`. Empty tokens trigger a full removal.

4. **Authenticated requests**  
   `ApiService` injects a request modifier that reads the latest token for each call, attaching `Authorization: Bearer <token>` when present.

5. **Session hydration**  
   `AuthService.getUser` retrieves `GET https://api.talkliner.com/api/domains/status`, expecting user data at `body.data.user`, and maps it into `UserModel`.

6. **Navigation lifecycle**  
   On success, the controller updates `user`, marks `isLoggedIn`, and routes via `Get.offAllNamed(Routes.home)` once user data finishes loading.

## Error Handling
- HTTP 401 responses surface as `AuthException` instances with message `Invalid credentials` and clear persisted tokens.
- Network timeouts raise `AuthException` with status code `408`.
- Unexpected failures (JSON shape, platform storage errors) propagate as `AuthException` with descriptive messages, populating `AuthController.error`.
- `loginWithToken` mirrors the same handling for externally supplied tokens.
- `_checkLoginStatus` refreshes the session on app start; failures purge the token and redirect to `Routes.login`.

## Logout
`AuthController.logout` removes the stored token (secure + fallback) and clears `GetStorage`, then routes back to `Routes.login`.

