# CoachApp release R8/ProGuard rules (P19/M4).
#
# Flutter's own keep rules are applied automatically by the Flutter Gradle
# plugin, and most plugins ship consumer rules inside their AARs. These are
# conservative safety nets for the reflection-sensitive libraries this app uses,
# plus -dontwarn entries so R8 doesn't fail on optional/desugared references.

# Flutter engine / embedding
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# flutter_secure_storage (AndroidX Security / Keystore)
-keep class androidx.security.crypto.** { *; }
-dontwarn androidx.security.crypto.**

# Firebase / FCM (linked but init is deferred)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Tink (used by AndroidX security-crypto)
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

# Core-library desugaring
-dontwarn java.lang.invoke.**
-dontwarn javax.annotation.**
