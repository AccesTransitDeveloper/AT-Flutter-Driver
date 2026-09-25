import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val keystorePropertiesFile = rootProject.file("keystore.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val localPropertiesFile = rootProject.file("local.properties")
val localProperties = Properties()
if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}
val googleMapsApiKey =
    System.getenv("GOOGLE_MAPS_API_KEY")
        ?: localProperties.getProperty("GOOGLE_MAPS_API_KEY")
        ?: ""

android {
    namespace = "com.app.driver"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
        }
    }

    defaultConfig {
        applicationId = "com.accessible.provider"
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        resValue(
            type = "string",
            name = "MAPS_API_KEY",
            value = googleMapsApiKey,
        )
    }

    // Mapbox (common-ndk27) and flutter_pdfview (pdfium) each ship their own
    // libc++_shared.so; keep the first so the merge doesn't fail.
    packaging {
        jniLibs {
            pickFirsts += "**/libc++_shared.so"
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("release")
        }
        release {
            signingConfig = signingConfigs.getByName("release")
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

// The Navigation SDK ships its own copy of the Maps SDK classes
// (com.google.android.gms.maps.*) inside its AAR rather than depending on
// play-services-maps. google_maps_flutter pulls play-services-maps in, so both
// end up on the classpath and `checkDebugDuplicateClasses` fails on ~120
// duplicated classes. Google's guidance is to let the Navigation SDK provide
// them: drop the standalone Maps artifact wherever it is requested. The classes
// the plugin needs are all present in the Navigation AAR, at a newer version.
configurations.all {
    exclude(group = "com.google.android.gms", module = "play-services-maps")
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("com.google.android.gms:play-services-location:21.3.0")
    // In-app turn-by-turn — see InAppNavigationView.kt. Same version native pins.
    // Also supplies the Maps SDK classes for google_maps_flutter (see the
    // exclude above).
    implementation("com.google.android.libraries.navigation:navigation:7.3.0")
    implementation("androidx.core:core-ktx:1.15.0")
    implementation("io.socket:socket.io-client:2.1.0") {
        exclude(group = "org.json", module = "json")
    }
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
}
