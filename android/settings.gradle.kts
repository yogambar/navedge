// File: settings.gradle.kts

pluginManagement {
    // 📍 Load Flutter SDK path from local.properties
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    // 🎯 Include Flutter's Gradle plugin
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    // 🌍 Repositories for plugin resolution
    repositories {
        gradlePluginPortal() // ✅ Required for kotlin-dsl and modern plugin resolution
        google()
        mavenCentral()
    }
}

plugins {
    // 🧩 Flutter plugin loader (must come first)
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"

    // 📱 Android Gradle Plugin
    id("com.android.application") version "8.6.0" apply false

    // 🔥 Firebase / Google Services plugin
    id("com.google.gms.google-services") version "4.4.1" apply false

    // 💡 Kotlin plugin for Android
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

// 🧱 Include app module
include(":app")

