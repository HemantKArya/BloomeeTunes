plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.io.FileInputStream
import java.util.Properties

val keystorePropertiesFile = rootProject.file("key.properties")


android {
    namespace = "ls.bloomee.musicplayer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "ls.bloomee.musicplayer"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    splits {
        abi {
            isEnable = true
            reset()
            include("armeabi-v7a", "arm64-v8a", "x86_64")
            isUniversalApk = true
        }
    }
    dependenciesInfo {
        includeInApk = false
        includeInBundle = false
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            println("   ✅ key.properties found - configuring release signing")
            val keystoreProperties = Properties()
            keystoreProperties.load(FileInputStream(keystorePropertiesFile))

            val keystorePath = keystoreProperties["bloomee.jks"] as String?
            val keyAliasValue = keystoreProperties["keyAlias"] as String?

            println("   Keystore file path: $keystorePath")
            println("   Key alias: $keyAliasValue")

            if (keystorePath != null) {
                val keystoreFile = file(keystorePath)
                println("   Keystore file exists: ${keystoreFile.exists()}")
                println("   Keystore file path: ${keystoreFile.absolutePath}")
            }

            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                storeFile = rootProject.file("bloomee.jks")
                storePassword = keystoreProperties["storePassword"] as String?
                println("   ✅ Release signing config created successfully")
            }
        } else {
            println("   ❌ key.properties not found - using debug signing")
        }
    }

    buildTypes {
        release {
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
                println("   📦 Release build: Using release signing config")
            }
            else{
                signingConfig = signingConfigs.getByName("debug")
                println("   📦 Release build: Using debug signing config (no keystore)")
            }
        }
    }

    // To reduce the size of the APK, since from AGP 8.0.0 the default value of useLegacyPackaging is false.
     packagingOptions {
        jniLibs {
            useLegacyPackaging = true
        }
    }
}

flutter {
    source = "../.."
}
