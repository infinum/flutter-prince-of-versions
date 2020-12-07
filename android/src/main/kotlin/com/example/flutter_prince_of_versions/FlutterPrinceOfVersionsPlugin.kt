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


class FlutterPrinceOfVersionsPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var activity: Activity

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.context = flutterPluginBinding.applicationContext

        channel = MethodChannel(
                flutterPluginBinding.getFlutterEngine().dartExecutor,
                "flutter_prince_of_versions"
        )

        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "check_for_updates" ->  {
                val argsList = call.arguments as List<*>
                val url = argsList.first() as String
                val requirements = argsList.last() as Map<String, String>
                checkForUpdates(url, requirements, result)
            }
            "check_updates_from_play_store" -> checkForUpdatesFromPlayStore(result)
        }
    }
    private fun checkForUpdatesFromPlayStore(@NonNull resultt: Result) {
        val queenOfVersions = QueenOfVersions.Builder()
                .build(this.activity as FragmentActivity)

        val loader = NetworkLoader("http://pastebin.com/raw/QFGjJrLP")


        println("nessto")
        val callback = QueenOfVersions.Callback.Builder()
                .withOnCanceled {
                    println("on canceled")
                }
                .withOnMandatoryUpdateNotAvailable { requiredVersion, inAppUpdateInfo, metadata, updateInfo ->
                    println("jesam li ovde?")
                    println(requiredVersion)
                    // for example show a message that update is required for application to work, but isn't available yet.

                    // requiredVersion is version code of the update Prince of Versions claims is required
                    // inAppUpdateInfo contains information about the update from Google Play
                    // for metadata and updateInfo check Prince of Versions documentation
                }
                .withOnDownloaded { handler, info ->
                    println("on downloaded")
                }
                .withOnDownloading { info, bytes, total ->
                    println("on downloading")
                }
                .withOnError {
                    resultt.success("woooo")
                    println(it.localizedMessage)
                    println(it.stackTrace.toString())
                    println(it.message)
                    println("on error")

                }
                .withOnInstalled {
                    println("on installed")
                }
                .withOnInstalling {
                    println("on installing")
                }
                .withOnUpdateAccepted { info, status, result ->
                    println("on update accept")
                }
                .withOnUpdateDeclined { info, status, result ->
                    println("on update decline")
                }
                .withOnNoUpdate { metadata, updateInfo ->
                    println("on no update")
                }
                .withOnPending {
                    println("on pending")
                }
                .build()

        queenOfVersions.checkForUpdates(loader, callback);

    }

    private fun checkForUpdates(url: Any?, requirements: Map<String, String>, @NonNull flutterResult: Result) {
        val updater = PrinceOfVersions.Builder()
        requirements.forEach { updater.addRequirementsChecker(it.key) { value ->  it.value == value } }
        val loader: Loader = NetworkLoader(url as String)
        val callback: UpdaterCallback = object : UpdaterCallback {
            override fun onSuccess(result: UpdateResult) {
                flutterResult.success(result.toMap())
            }
            override fun onError(throwable: Throwable) {
                flutterResult.error("1", throwable.message, null)
            }
        }
        updater.build(context).checkForUpdates(loader, callback)
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
            Constants.UPDATE_INFO to info.toMap(),
            Constants.VERSION to mapOf(Constants.MAJOR to updateVersion),
            Constants.STATUS to status.toMap()
    )
}

fun UpdateInfo.toMap(): Map<String, Any> {
    return mapOf<String, Any>(Constants.LAST_VERSION_AVAILABLE to mapOf(Constants.MAJOR to lastVersionAvailable),
            Constants.INSTALLED_VERSION to mapOf(Constants.MAJOR to installedVersion),
            Constants.REQUIRED_VERSION to mapOf(Constants.MAJOR to requiredVersion))
}


fun UpdateStatus.toMap(): String {
    return when(this) {
        UpdateStatus.NEW_UPDATE_AVAILABLE -> Constants.UPDATE_AVAILABLE
        UpdateStatus.NO_UPDATE_AVAILABLE -> Constants.NO_UPDATE
        UpdateStatus.REQUIRED_UPDATE_NEEDED -> Constants.REQUIRED_UPDATE
    }

}
