import java.util.Properties
import java.io.FileInputStream

// ১. key.properties ফাইল লোড করার লজিক
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.rifat.book_verse"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    @Suppress("DEPRECATION")
    kotlinOptions {
        jvmTarget = "17"
    }

    // ২. রিলিজ সাইনিং কনফিগারেশন
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String? ?: "upload"
            keyPassword = keystoreProperties["keyPassword"] as String? ?: "123456"
            storePassword = keystoreProperties["storePassword"] as String? ?: "123456"
            
            val storeFilePath = keystoreProperties["storeFile"] as String? 
                ?: "C:\\Users\\Gazi_Rifat_Ahmed\\upload-keystore.jks"
            storeFile = file(storeFilePath)
        }
    }

    defaultConfig {
        applicationId = "com.rifat.book_verse"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            
            // প্লে স্টোরের জন্য কোড সিকিউর এবং সাইজ ছোট করার জন্য ট্রু করা হলো
            isMinifyEnabled = true
            isShrinkResources = true
            
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}