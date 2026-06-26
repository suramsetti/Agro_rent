plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")         // use Kotlin DSL plugin id
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.f_pro"

    // If flutter.compileSdkVersion is defined and works, keep it; otherwise replace with a number like 34.
    compileSdk = flutter.compileSdkVersion
    
    // Disable NDK completely
    ndkVersion = ""
    
    defaultConfig {
        applicationId = "com.example.f_pro"

        // REQUIRED: Firebase Auth and some libs need minSdk >= 23
        minSdk = 23

        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        getByName("release") {
            // Use debug signing for quick testing. Replace with real signing config for publishing.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
