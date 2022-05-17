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
import kotlinx.coroutines.runBlocking
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

class FlutterPrinceOfVersionsPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private lateinit var requirementsChannel: MethodChannel

    private lateinit var context: Context
    private lateinit var activity: Activity

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.context = flutterPluginBinding.applicationContext

        channel = MethodChannel(
                flutterPluginBinding.binaryMessenger,
                Constants.CHANNEL_NAME
        )
        requirementsChannel = MethodChannel(
                flutterPluginBinding.binaryMessenger,
                Constants.REQUIREMENTS_CHANNEL_NAME
        )

        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            Constants.CHECK_FOR_UPDATES_METHOD_NAME -> {
                val args = call.arguments as List<*>
                val url = args[0] as String
                // arg1 and arg2 are not used on Android
                @Suppress("UNCHECKED_CAST")
                val requirementChecks = args[3] as List<String>
                checkForUpdates(url, requirementChecks, result)
            }
            Constants.CHECK_FOR_UPDATES_FROM_GOOGLE_PLAY_METHOD_NAME -> {
                val argsList = call.arguments as List<*>
                val url = argsList[0] as String
                checkForUpdatesFromGooglePlay(url)
            }
        }
    }

    private fun checkForUpdatesFromGooglePlay(url: String) {
        val queenOfVersions = QueenOfVersions.Builder()
                .build(this.activity as FragmentActivity)

        val loader = NetworkLoader(url)

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
                    channel.invokeMethod(Constants.UPDATE_ACCEPTED, listOf(info.toMap(), status.toMap(), result?.toMap()))
                }
                .withOnUpdateDeclined { info, status, result ->
                    channel.invokeMethod(Constants.UPDATE_DECLINED, listOf(info.toMap(), status.toMap(), result?.toMap()))
                }
                .withOnNoUpdate { _, updateInfo ->
                    channel.invokeMethod(Constants.NO_UPDATE_CALLBACK, updateInfo?.toMap())
                }
                .withOnPending {
                    channel.invokeMethod(Constants.ON_PENDING, it.toMap())
                }
                .build()

        queenOfVersions.checkForUpdates(loader, callback)
    }

    private fun checkForUpdates(url: String, requirementChecks: List<String>, @NonNull flutterResult: Result) {
        val updater = PrinceOfVersions.Builder()

        requirementChecks.forEach { requirementKey ->
            updater.addRequirementsChecker(requirementKey) { requirementValue ->
                runBlocking<Boolean> {
                    suspendCoroutine<Boolean> { cont ->
                        activity.runOnUiThread {
                            requirementsChannel.invokeMethod(
                                    Constants.CHECK_REQUIREMENT_METHOD_NAME,
                                    listOf(requirementKey, requirementValue), object : Result {
                                override fun success(result: Any?) {
                                    cont.resume(result as Boolean)
                                }
                                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                                    cont.resume(false)
                                }
                                override fun notImplemented() {
                                    cont.resume(false)
                                }
                            })
                        }
                    }
                }
            }
        }

        val loader: Loader = NetworkLoader(url)

        updater.build(context).checkForUpdates(loader, object : UpdaterCallback {
            override fun onSuccess(result: UpdateResult) {
                flutterResult.success(result.toMap())
            }
            override fun onError(error: Throwable) {
                flutterResult.error("", error.localizedMessage, null)
            }
        })
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
    return mapOf(
            Constants.VERSION_CODE to versionCode(),
            Constants.UPDATE_PRIORITY to updatePriority(),
            Constants.CLIENT_VERSION_STALENESS_DAYS to clientVersionStalenessDays()
    )
}

fun UpdateResult.toMap(): Map<String, Any?> {
    return mapOf(
            Constants.STATUS to status.toMap(),
            Constants.VERSION to mapVersion(updateVersion),
            Constants.UPDATE_INFO to info.toMap(),
            Constants.METADATA to metadata
    )
}

fun UpdateInfo.toMap(): Map<String, Any?> {
    return mapOf(
            Constants.LAST_VERSION_AVAILABLE to mapVersion(lastVersionAvailable),
            Constants.INSTALLED_VERSION to mapVersion(installedVersion),
            Constants.REQUIRED_VERSION to mapVersion(requiredVersion)
    )
}

fun UpdateStatus.toMap(): String {
    return when(this) {
        UpdateStatus.NEW_UPDATE_AVAILABLE -> Constants.NEW_UPDATE_AVAILABLE
        UpdateStatus.NO_UPDATE_AVAILABLE -> Constants.NO_UPDATE_AVAILABLE
        UpdateStatus.REQUIRED_UPDATE_NEEDED -> Constants.REQUIRED_UPDATE_NEEDED
    }
}

fun mapVersion(version: Int?): Map<String, Int>?{
    return if (version == null){
        null
    } else {
        mapOf(Constants.MAJOR to version)
    }
}
