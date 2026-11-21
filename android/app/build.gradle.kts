import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
} else {
    // Release çıktısı debug anahtarıyla imzalanıp mağazaya gitmesin; debug derlemesi etkilenmez.
    val releaseIsteniyor =
        gradle.startParameter.taskNames.any {
            val gorev = it.substringAfterLast(':')
            gorev.endsWith("Release") &&
                (gorev.startsWith("assemble") || gorev.startsWith("bundle") ||
                    gorev.startsWith("install") || gorev.startsWith("package"))
        }
    if (releaseIsteniyor) {
        throw GradleException(
            "android/key.properties bulunamadı: release derlemesi için imzalama ayarlarını ekleyin.",
        )
    }
}

android {
    namespace = "com.muhammet.hasan.marasli.DogumGunu"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Required by flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.muhammet.hasan.marasli.DogumGunu"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Enables desugaring support for java.time APIs used by notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
