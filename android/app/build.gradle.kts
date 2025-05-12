plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.kidsdo.kidsdo"
    compileSdk = flutter.compileSdkVersion
    //ndkVersion = flutter.ndkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        // Configura Java 8 para compatibilidad con desugaring
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        // Habilita el desugaring de bibliotecas principales
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        // Si cambiaste a Java 8 arriba, también puedes ajustar jvmTarget si es necesario,
        // aunque a menudo puede dejarse en 1.8 o incluso más alto si el Kotlin plugin lo maneja.
        // Por ahora, prueba dejándolo o ajústalo a "1.8".
        jvmTarget = JavaVersion.VERSION_1_8.toString() // O déjalo como VERSION_11 si no da problemas después del cambio de compileOptions
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.kidsdo.kidsdo"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
