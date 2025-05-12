package studio.creche.flutter_haptic

import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterHapticPlugin */
class FlutterHapticPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var vibrator: Vibrator

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_haptic")
    channel.setMethodCallHandler(this)

    vibrator = flutterPluginBinding.applicationContext.getSystemService(Vibrator::class.java)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "performSuccessFeedback" -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
          val effect = VibrationEffect.createPredefined(VibrationEffect.EFFECT_CLICK)
          vibrator.vibrate(effect)
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
          val effect = VibrationEffect.createWaveform(longArrayOf(7, 100), intArrayOf(
            VibrationEffect.DEFAULT_AMPLITUDE, 0), -1)
          vibrator.vibrate(effect)
        } else {
          val longArray = longArrayOf(7, 10)
          vibrator.vibrate(longArray, -1)
        }

        result.success(null)
      }
      "performFailureFeedback" -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
          val effect = VibrationEffect.createPredefined(VibrationEffect.EFFECT_DOUBLE_CLICK)
          vibrator.vibrate(effect)
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
          val effect = VibrationEffect.createWaveform(longArrayOf(9, 130, 11), intArrayOf(
            VibrationEffect.DEFAULT_AMPLITUDE, 0,
            VibrationEffect.DEFAULT_AMPLITUDE
          ), -1)
          vibrator.vibrate(effect)
        } else {
          val longArray = longArrayOf(90, 10, 110, 10)
          vibrator.vibrate(longArray, -1)
        }

        result.success(null)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
