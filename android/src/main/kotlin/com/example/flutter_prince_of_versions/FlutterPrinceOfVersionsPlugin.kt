package com.example.flutter_prince_of_versions

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import androidx.fragment.app.FragmentActivity
import co.infinum.princeofversions.*
import co.infinum.queenofversions.QueenOfVersions
import co.infinum.queenofversions.QueenOfVersionsInAppUpdateInfo
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


class FlutterPrinceOfVersionsPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private lateinit var requirementsChannel: MethodChannel

    private lateinit var context: Context
    private lateinit var activity: Activity

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.context = flutterPluginBinding.applicationContext

        channel = MethodChannel(
                flutterPluginBinding.getFlutterEngine().dartExecutor,
                Constants.CHANNEL_NAME
        )
        requirementsChannel = MethodChannel(
                flutterPluginBinding.getFlutterEngine().dartExecutor,
                Constants.REQUIREMENTS_CHANNEL_NAME
        )

        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            Constants.CHECK_FOR_UPDATES_METHOD_NAME -> {
                val argsList = call.arguments as List<*>
                val url = argsList.first() as String
                val requirements = argsList.last() as List<String>
                checkForUpdates(url, requirements, result)
            }
            Constants.CHECK_UPDATES_FROM_PLAY_STORE_METHOD_NAME -> {
                checkForUpdatesFromPlayStore()
            }
        }
    }
    private fun checkForUpdatesFromPlayStore() {
        val queenOfVersions = QueenOfVersions.Builder()
                .build(this.activity as FragmentActivity)

        val loader = NetworkLoader("")

        val callback = QueenOfVersions.Callback.Builder()
                .withOnCanceled {
                    channel.invokeMethod(Constants.CANCELED, null)
                }
                .withOnMandatoryUpdateNotAvailable { _, inAppUpdateInfo, _, updateInfo ->
                    channel.invokeMethod(Constants.MANDATORY_UPDATE_NOT_AVAILABLE, listOf(inAppUpdateInfo.toMap(), updateInfo.toMap()))
                }
                .withOnDownloaded { _, info ->
                    channel.invokeMethod(Constants.DOWNLOADED, info.toMap())
                }
                .withOnDownloading { info, _, _ ->
                    channel.invokeMethod(Constants.DOWNLOADING, info.toMap())
                }
                .withOnError {
                    channel.invokeMethod(Constants.ERROR, it.localizedMessage)
                }
                .withOnInstalled {
                    channel.invokeMethod(Constants.INSTALLED, it.toMap())
                }
                .withOnInstalling {
                    channel.invokeMethod(Constants.INSTALLING, it.toMap())
                }
                .withOnUpdateAccepted { info, status, result ->
                    channel.invokeMethod(Constants.UPDATE_ACCEPTED, arrayOf(info.toMap(), status.toMap(), result?.toMap()))
                }
                .withOnUpdateDeclined { info, status, result ->
                    channel.invokeMethod(Constants.UPDATE_DECLINED, arrayOf(info.toMap(), status.toMap(), result?.toMap()))
                }
                .withOnNoUpdate { _, updateInfo ->
                    channel.invokeMethod(Constants.NO_UPDATE_CALLBACK, updateInfo?.toMap())
                }
                .withOnPending {
                    channel.invokeMethod(Constants.ON_PENDING, it.toMap())
                }
                .build()

        queenOfVersions.checkForUpdates(loader, callback);

    }

    private fun checkForUpdates(url: String, requirements: List<String>, @NonNull flutterResult: Result) {
        val updater = PrinceOfVersions.Builder()

        requirements.forEach {
            updater.addRequirementsChecker(it) {  value ->
            var requirementResult = false

            requirementsChannel.invokeMethod(Constants.REQUIREMENTS_METHOD_NAME, listOf(it, value), object: Result {
                override fun success(result: Any?) {
                    requirementResult = result as Boolean
                }

                override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {}
                override fun notImplemented() {}

            })
            requirementResult
            }
        }
        val loader: Loader = NetworkLoader(url)
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



fun QueenOfVersionsInAppUpdateInfo.toMap(): Map<String, Int?> {
    return mapOf(Constants.VERSION_CODE to versionCode(),
            Constants.UPDATE_PRIORITY to updatePriority(),
            Constants.CLIENT_VERSION_STALENESS_DAYS to clientVersionStalenessDays()
    )
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
            Constants.REQUIRED_VERSION to mapOf(Constants.MAJOR to requiredVersion)
    )
}


fun UpdateStatus.toMap(): String {
    return when(this) {
        UpdateStatus.NEW_UPDATE_AVAILABLE -> Constants.UPDATE_AVAILABLE
        UpdateStatus.NO_UPDATE_AVAILABLE -> Constants.NO_UPDATE
        UpdateStatus.REQUIRED_UPDATE_NEEDED -> Constants.REQUIRED_UPDATE
    }
}
