plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.silentvoice"
    compileSdk = 36
    
    //  معدل: تم تثبيت نسخة الـ NDK اللي طلبتها مكتبة speech_to_text عشان الإيرور التحذيري يختفي
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.silentvoice"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        
        minSdk = flutter.minSdkVersion //  معدل: تم التثبيت يدوياً على 21 لتوافق الكاميرا وموديل الـ TFLite والـ ML Kit
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        multiDexEnabled = true //  معدل: للتأكيد على تفعيلها لحماية التطبيق من كراش حجم الداتا الكبير
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

// معدل: الكود السحري لحل مشكلة tflite_v2 والـ Namespace أوتوماتيكياً
subprojects {
    afterEvaluate { project ->
        if (project.hasProperty("android")) {
            if (project.android.namespace == null) {
                project.android.namespace = project.android.defaultConfig.applicationId
            }
        }
    }
}