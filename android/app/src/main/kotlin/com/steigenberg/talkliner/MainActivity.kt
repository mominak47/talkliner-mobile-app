package com.steigenberg.talkliner

import android.app.PictureInPictureParams
import android.os.Build
import android.util.Rational
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.steigenberg.talkliner/pip"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableAutoPip" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        try {
                            val builder = PictureInPictureParams.Builder()
                            builder.setAutoEnterEnabled(true)
                            builder.setAspectRatio(Rational(9, 16))
                            setPictureInPictureParams(builder.build())
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("PIP_ERROR", e.message, null)
                        }
                    } else {
                        result.success(null)
                    }
                }
                "disableAutoPip" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        try {
                            val builder = PictureInPictureParams.Builder()
                            builder.setAutoEnterEnabled(false)
                            setPictureInPictureParams(builder.build())
                            result.success(null)
                        } catch (e: Exception) {
                            result.success(null)
                        }
                    } else {
                        result.success(null)
                    }
                }
                "enterPip" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        try {
                            val builder = PictureInPictureParams.Builder()
                            builder.setAspectRatio(Rational(9, 16))
                            enterPictureInPictureMode(builder.build())
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("PIP_ERROR", e.message, null)
                        }
                    } else {
                        result.success(null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
} 