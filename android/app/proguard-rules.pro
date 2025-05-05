# ─────────────── FLUTTER CORE ───────────────
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.engine.plugins.** { *; }
-keep class io.flutter.view.** { *; }
-dontwarn io.flutter.embedding.**

# ─────────────── EMOJI SUPPORT ───────────────
# Flutter Emoji Picker
-keep class emoji_picker_flutter.** { *; }
-dontwarn emoji_picker_flutter.**

# AndroidX Emoji2
-keep class androidx.emoji2.** { *; }
-dontwarn androidx.emoji2.**

# ─────────────── FIREBASE ───────────────
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# ─────────────── GOOGLE PLAY SERVICES ───────────────
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# ─────────────── JAVASCRIPT INTERFACE ───────────────
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# ─────────────── REFLECTION & ANNOTATIONS ───────────────
-keepattributes Signature
-keepattributes *Annotation*

# ─────────────── ENUM SUPPORT ───────────────
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ─────────────── APP DATA CLASSES ───────────────
-keep class com.example.navedge.models.** { *; }

# ─────────────── JSON / GSON SERIALIZATION ───────────────
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# ─────────────── AUDIO / VIDEO PLUGIN SUPPORT ───────────────
-keep class xyz.luan.audioplayers.** { *; }
-dontwarn xyz.luan.audioplayers.**

# ─────────────── ENTRY POINT PROTECTION ───────────────
-keep class com.example.navedge.** { *; }
-dontwarn com.example.navedge.**

# ─────────────── WINDOW MANAGER SUPPORT ───────────────
-keep class androidx.window.layout.** { *; }
-dontwarn androidx.window.layout.**

-keep class androidx.window.sidecar.** { *; }
-dontwarn androidx.window.sidecar.**

-keep class androidx.window.extensions.** { *; }
-dontwarn androidx.window.extensions.**

# ─────────────── SENTRY (Without Replay) ───────────────
# Keep Sentry core classes
-keep class io.sentry.** { *; }
-dontwarn io.sentry.**

# Optional: Prevent Compose errors if Replay is disabled
-dontwarn androidx.compose.**

# Optional: If you ever enable Replay in future
#-keep class io.sentry.replay.** { *; }
#-dontwarn io.sentry.replay.**

