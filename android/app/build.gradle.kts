import java.util.Properties

plugins {
    id("com.android.application")
    // id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.cookedapp.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.cookedapp.app"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keyProps = Properties()
            val keyPropsFile = file("../key.properties")
            if (keyPropsFile.exists()) {
                keyProps.load(keyPropsFile.inputStream())
                storeFile = file(keyProps.getProperty("storeFile"))
                storePassword = keyProps.getProperty("storePassword")
                keyAlias = keyProps.getProperty("keyAlias")
                keyPassword = keyProps.getProperty("keyPassword")
            } else {
                // Fallback for CI/CD (GitHub Actions)
                val keystorePath = System.getenv("ANDROID_KEYSTORE_PATH")
                if (keystorePath != null) {
                    // Utiliser le chemin absolu du projet pour éviter les erreurs de chemin relatif
                    storeFile = rootProject.file("app/$keystorePath")
                    storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
                    keyAlias = System.getenv("ANDROID_KEY_ALIAS")
                    keyPassword = System.getenv("ANDROID_KEY_PASSWORD")
                    
                    if (storePassword == null || keyAlias == null || keyPassword == null) {
                        println("❌ ERREUR : Variables de signature manquantes dans l'environnement CI")
                    }
                }
            }
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("release")
        }
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
