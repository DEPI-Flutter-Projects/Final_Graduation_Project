# Supabase Configuration for Password Reset

For the "Forgot Password" and "Reset Password" features to work, you must configure the **Redirect URLs** in your Supabase Dashboard. This cannot be done via SQL.

## 1. URL Configuration
1.  Go to your **Supabase Dashboard**.
2.  Navigate to **Authentication** -> **URL Configuration**.
3.  **Site URL**: Set this to your app's deep link scheme, e.g., `io.supabase.elmoshwar://login-callback` (or just `io.supabase.elmoshwar://`).
4.  **Redirect URLs**: Add the following URL to the allow list:
    *   `io.supabase.elmoshwar://login-callback`
    *   `io.supabase.elmoshwar://reset-password` (if you want a specific one for resets, though the callback usually handles it)

## 2. Email Templates
1.  Navigate to **Authentication** -> **Email Templates**.
2.  Select **Reset Password**.
3.  Ensure the **Message Body** contains the link variable:
    ```html
    <a href="{{ .ConfirmationURL }}">Reset Password</a>
    ```
    *Note: The `{{ .ConfirmationURL }}` will automatically use the Redirect URL you configured.*

## 3. Deep Linking in App
Ensure your `android/app/src/main/AndroidManifest.xml` has the intent filter for your scheme (already checked in previous steps, but good to verify):
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="io.supabase.elmoshwar" android:host="login-callback" />
</intent-filter>
```
