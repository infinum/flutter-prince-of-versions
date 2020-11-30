package com.example.flutter_prince_of_versions

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import androidx.fragment.app.FragmentActivity
import co.infinum.princeofversions.*
import co.infinum.queenofversions.QueenOfVersions
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.example.flutter_prince_of_versions.

class FlutterPrinceOfVersionsPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var activity: Activity

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.context = flutterPluginBinding.applicationContext

        channel = MethodChannel(
                flutterPluginBinding.getFlutterEngine().getDartExecutor(),
                "flutter_prince_of_versions"
        )

        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "check_for_updates" -> checkForUpdates((call.arguments as List<*>).first(), result)
            "check_updates_from_store" -> checkForUpdatesFromPlayStore(result)
        }
    }
    private fun checkForUpdatesFromPlayStore(@NonNull flutterResult: Result) {
    }

    private fun checkForUpdates(url: Any?, @NonNull flutterResult: Result) {
        val updater = PrinceOfVersions(context)
        val loader: Loader = NetworkLoader(url as String)
        val callback: UpdaterCallback = object : UpdaterCallback {
            override fun onSuccess(result: UpdateResult) {
                flutterResult.success(result.toMap())
            }
            override fun onError(throwable: Throwable) {
                flutterResult.error("1", "Invalid JSON", null)
            }
        }
        updater.checkForUpdates(loader, callback)
    }

    override fun onDetachedFromActivity() {
        // no-op
    }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.activity = binding.activity
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        // no-op
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

fun UpdateResult.toMap(): Map<String, Any> {
    return mapOf(
            "updateInfo" to info.toMap(),
            "version" to mapOf("major" to updateVersion),
            "status" to status.toMap()
    )
}

fun UpdateInfo.toMap(): Map<String, Any> {
    return mapOf<String, Any>("lastVersionAvailable" to mapOf("major" to lastVersionAvailable),
            "installedVersion" to mapOf("major" to installedVersion),
            "requiredVersion" to mapOf("major" to requiredVersion))
}


fun UpdateStatus.toMap(): String {
    return when(this) {
        UpdateStatus.NEW_UPDATE_AVAILABLE -> Constants.UPDATE-AVAILABLE
        UpdateStatus.NO_UPDATE_AVAILABLE -> "no-update"
        UpdateStatus.REQUIRED_UPDATE_NEEDED -> "required-update"
    }

}
