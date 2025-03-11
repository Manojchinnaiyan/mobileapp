plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.go_flutter_demo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"  // Updated NDK version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.go_flutter_demo"
        minSdk = 26  // Updated minSdk to 26 for Nebula
        targetSdk = 30  // Lower targetSdk to avoid foreground service type requirement
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    
    // Add this for the AAR files in the libs directory
    repositories {
        flatDir {
            dirs("src/main/libs")
        }
    }

    // Disable lint check for target SDK
    lint {
        disable += "ExpiredTargetSdkVersion"
        checkReleaseBuilds = false
        abortOnError = false
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Add the Nebula AAR dependency
    implementation(fileTree(mapOf("dir" to "src/main/libs", "include" to listOf("*.aar"))))
}