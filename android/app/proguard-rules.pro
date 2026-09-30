# ProGuard / R8 rules for Shift Puzzle

# Flutter framework & plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Mobile Ads SDK
-keep public class com.google.android.gms.ads.** {
    public *;
}
-keep public class com.google.ads.** {
    public *;
}
-dontwarn com.google.android.gms.ads.**

# Suppress warnings for Flutter Play Store deferred component classes (not bundled)
-dontwarn com.google.android.play.core.**

# Prevent obfuscation of serializable / plugin model classes
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable

# AndroidX DataStore & Preferences (used by shared_preferences_android)
-keep class androidx.datastore.** { *; }
-keep class androidx.preference.** { *; }
-keep class androidx.work.** { *; }

# Keep native methods and JNI bindings
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep our application and activity classes
-keep class com.shiftpuzzle.shift_puzzle.** { *; }
-keep class com.shiftpuzzle.game.** { *; }

