plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.dim_institution"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Enable support for modern Java 8+ APIs required by flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.dim_institution"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Required for desugaring and multidex support
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // Signing with the debug keys for now so the release APK can be installed directly
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Android desugaring library supporting modern Java time APIs
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}