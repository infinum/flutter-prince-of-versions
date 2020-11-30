package com.example.flutter_prince_of_versions_example

import com.example.flutter_prince_of_versions.FlutterPrinceOfVersionsPlugin
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterFragmentActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        flutterEngine.plugins.add(FlutterPrinceOfVersionsPlugin())
    }

}
