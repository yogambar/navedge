plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // ✅ Firebase services
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin") // ✅ Must be last
}

android {
    namespace = "com.example.navedge"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.example.navedge"
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlinOptions {
        jvmTarget = "21"
    }

    kotlin {
        jvmToolchain(21)
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true

            signingConfig = signingConfigs.create("release") {
                val storeFilePath = System.getenv("RELEASE_STORE_FILE")
                    ?: project.findProperty("RELEASE_STORE_FILE") as String?
                val storePwd = System.getenv("RELEASE_STORE_PASSWORD")
                    ?: project.findProperty("RELEASE_STORE_PASSWORD") as String?
                val keyAliasVal = System.getenv("RELEASE_KEY_ALIAS")
                    ?: project.findProperty("RELEASE_KEY_ALIAS") as String?
                val keyPwd = System.getenv("RELEASE_KEY_PASSWORD")
                    ?: project.findProperty("RELEASE_KEY_PASSWORD") as String?

                if (storeFilePath != null && storePwd != null && keyAliasVal != null && keyPwd != null) {
                    storeFile = file(storeFilePath)
                    storePassword = storePwd
                    keyAlias = keyAliasVal
                    keyPassword = keyPwd
                } else {
                    throw GradleException("❌ Missing signing credentials. Provide via environment variables or gradle.properties.")
                }
            }

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
                "proguard-sentry.pro" // ✅ Add this file for missing keep rules
            )
        }

        getByName("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("androidx.window:window:1.2.0")

    // ✅ Sentry without Replay (avoid Compose dependency issues)
    implementation("io.sentry:sentry-android:6.35.0")
    // Comment out Replay if not needed:
    // implementation("io.sentry:sentry-android-replay:6.35.0")

    implementation(platform("com.google.firebase:firebase-bom:32.8.0"))
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.android.gms:play-services-auth:20.7.0")
}

