package vn.edu.ntu.truongvu.skin_disease_app

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    init {
        try {
            System.loadLibrary("litert_flex_jni")
            println("✅ Loaded litert_flex_jni successfully!")
        } catch (e: UnsatisfiedLinkError) {
            println("⚠️ Could not load litert_flex_jni: $e")
        }
        try {
            System.loadLibrary("tensorflowlite_flex_jni")
            println("✅ Loaded tensorflowlite_flex_jni successfully!")
        } catch (e: UnsatisfiedLinkError) {
            println("⚠️ Could not load tensorflowlite_flex_jni: $e")
        }
    }
}

