import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}

android {
    namespace = "com.shiftpuzzle.shift_puzzle"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.shiftpuzzle.game"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Production AdMob App ID can be supplied in key.properties, local.properties, or via ADMOB_APP_ID environment variable.
        // Defaults to Google's official sample App ID for testing and safety.
        val admobAppId = keystoreProperties.getProperty("admobAppId")
            ?: localProperties.getProperty("admobAppId")
            ?: System.getenv("ADMOB_APP_ID")
            ?: "ca-app-pub-3940256099942544~3347511713"
        manifestPlaceholders["admobAppId"] = admobAppId
    }

    val allowInsecureDebugSigning = project.hasProperty("allowInsecureDebugSigning") ||
        System.getenv("ALLOW_INSECURE_DEBUG_SIGNING") == "true" ||
        keystoreProperties.getProperty("allowInsecureDebugSigning") == "true"

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                val keyAliasVal = keystoreProperties.getProperty("keyAlias")
                val keyPassVal = keystoreProperties.getProperty("keyPassword")
                val storePassVal = keystoreProperties.getProperty("storePassword")
                val storeFilePath = keystoreProperties.getProperty("storeFile")

                if (keyAliasVal.isNullOrBlank() || keyPassVal.isNullOrBlank() || storePassVal.isNullOrBlank() || storeFilePath.isNullOrBlank()) {
                    throw GradleException(
                        "\n====================================================================================\n" +
                        "FAIL-CLOSED RELEASE SIGNING ERROR:\n" +
                        "Release signing configuration in 'android/key.properties' is incomplete.\n" +
                        "Required non-empty properties: keyAlias, keyPassword, storePassword, storeFile.\n" +
                        "====================================================================================\n"
                    )
                }

                val resolvedKeystore = when {
                    file(storeFilePath).exists() -> file(storeFilePath)
                    rootProject.file(storeFilePath).exists() -> rootProject.file(storeFilePath)
                    else -> rootProject.file(storeFilePath)
                }
                if (!resolvedKeystore.exists()) {
                    throw GradleException(
                        "\n====================================================================================\n" +
                        "FAIL-CLOSED RELEASE SIGNING ERROR:\n" +
                        "Release keystore file specified in 'android/key.properties' does not exist:\n" +
                        "${resolvedKeystore.absolutePath}\n" +
                        "====================================================================================\n"
                    )
                }

                keyAlias = keyAliasVal
                keyPassword = keyPassVal
                storeFile = resolvedKeystore
                storePassword = storePassVal
            }
        }
    }

    buildTypes {
        release {
            val storeFilePath = keystoreProperties.getProperty("storeFile")
            val resolvedKeystoreFile = if (storeFilePath != null) {
                when {
                    file(storeFilePath).exists() -> file(storeFilePath)
                    rootProject.file(storeFilePath).exists() -> rootProject.file(storeFilePath)
                    else -> null
                }
            } else null
            val hasCustomKeystore = keystorePropertiesFile.exists() && resolvedKeystoreFile != null

            if (hasCustomKeystore) {
                signingConfig = signingConfigs.getByName("release")
            } else if (allowInsecureDebugSigning) {
                println("[SECURITY WARNING] 'allowInsecureDebugSigning' is enabled. Signing release build with debug key (FOR LOCAL QA ONLY).")
                signingConfig = signingConfigs.getByName("debug")
            } else {
                val isReleaseTaskRequested = gradle.startParameter.taskNames.any {
                    it.contains("Release", ignoreCase = true) || it.contains("bundle", ignoreCase = true)
                }
                if (isReleaseTaskRequested) {
                    throw GradleException(
                        "\n====================================================================================\n" +
                        "FAIL-CLOSED RELEASE SIGNING ERROR:\n" +
                        "Production release build requested, but release signing is unconfigured!\n" +
                        "Google Play release builds (AAB/APK) must NOT be signed with the Android debug key.\n\n" +
                        "Missing prerequisite:\n" +
                        (if (!keystorePropertiesFile.exists()) "  - 'android/key.properties' was not found.\n" else "") +
                        (if (storeFilePath == null || !file(storeFilePath).exists()) "  - Upload keystore file was not found.\n" else "") +
                        "\nTo resolve for production Google Play release:\n" +
                        "1. Generate an upload keystore:\n" +
                        "   keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload\n" +
                        "2. Configure 'android/key.properties' using 'android/key.properties.example' as template.\n" +
                        "\nFor local dev/QA testing ONLY (never Google Play upload):\n" +
                        "   Pass -PallowInsecureDebugSigning=true\n" +
                        "====================================================================================\n"
                    )
                }
                signingConfig = signingConfigs.getByName("debug")
            }

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
