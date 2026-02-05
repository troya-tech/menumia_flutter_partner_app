import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// START: LOAD RELEASE KEYSTORE PROPERTIES
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()

if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { stream ->
        keystoreProperties.load(stream)
    }
}
// END: LOAD RELEASE KEYSTORE PROPERTIES


android {
    namespace = "com.menumia.partner"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.menumia.partner"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

        // START: SIGNING CONFIGS
    signingConfigs {
        // Debug signing for UAT (uses default debug keystore)
        getByName("debug") {
            storeFile = file(System.getProperty("user.home") + "/.android/debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
        
        // Release signing for Production (uses your release keystore)
        // Only create release config if keystore properties are available
        if (keystorePropertiesFile.exists() && 
            keystoreProperties["storeFile"] != null &&
            keystoreProperties["storePassword"] != null &&
            keystoreProperties["keyAlias"] != null &&
            keystoreProperties["keyPassword"] != null) {
            create("release") {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }
    // END: SIGNING CONFIGS

    // START: ADDED FOR UAT/PROD FLAVORS
    flavorDimensions += "environment"
    
    productFlavors {
        create("uat") {
            dimension = "environment"
            applicationIdSuffix = ".uat"
            versionNameSuffix = "-uat"
            resValue("string", "app_name", "MenuMia Partner UAT")
        }
        
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "MenuMia Partner")
        }
    }
    // END: ADDED FOR UAT/PROD FLAVORS


// START: BUILD TYPES WITH SIGNING
    buildTypes {
        debug {
            // UAT uses debug keystore
            signingConfig = signingConfigs.getByName("debug")
        }
        
        release {
            // Production uses release keystore (if available)
            if (signingConfigs.findByName("release") != null) {
                signingConfig = signingConfigs.getByName("release")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            ndk {
                debugSymbolLevel = "FULL"
            }
        }
    }
    // END: BUILD TYPES WITH SIGNING
}

flutter {
    source = "../.."
}
