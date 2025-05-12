// File: android/build.gradle.kts

buildscript {
    repositories {
        gradlePluginPortal() // ✅ Required for Kotlin DSL plugin resolution
        google()
        mavenCentral()
    }

    dependencies {
        // ✅ Android Gradle Plugin
        classpath("com.android.tools.build:gradle:8.6.0")

        // ✅ Kotlin Plugin (must match Kotlin version in app module)
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")

        // ✅ Google Services for Firebase
        classpath("com.google.gms:google-services:4.4.1")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 🏗️ Custom global build directory (optional, keeps root cleaner)
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    evaluationDependsOn(":app")

    val subprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(subprojectBuildDir)

    // ✅ Android library namespace auto-fix
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
            if (namespace.isNullOrBlank()) {
                namespace = "com.example.${project.name.replace("-", "_")}"
                println("✔️ Auto-added namespace to module '${project.name}'")
            }

            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_21
                targetCompatibility = JavaVersion.VERSION_21
            }
        }
    }

    // ✅ Kotlin plugin override enforcement (use consistent version)
    plugins.withId("org.jetbrains.kotlin.android") {
        project.buildscript.configurations["classpath"].resolutionStrategy.eachDependency {
            if (requested.group == "org.jetbrains.kotlin" && requested.name == "kotlin-gradle-plugin") {
                useVersion("2.1.0")
            }
        }
    }
}

// 🧹 Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

