package com.example.hybrid.androidhost

import android.app.Activity
import android.os.Bundle
import android.view.Gravity
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class MainActivity : Activity() {
    private var flutterEngine: FlutterEngine? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        warmUpFlutterEngine()
        setContentView(createNativeOnboardingView())
    }

    override fun onDestroy() {
        if (isFinishing) {
            FlutterEngineCache.getInstance().remove(ENGINE_ID)
            flutterEngine?.destroy()
            flutterEngine = null
        }
        super.onDestroy()
    }

    private fun warmUpFlutterEngine() {
        if (FlutterEngineCache.getInstance().contains(ENGINE_ID)) {
            flutterEngine = FlutterEngineCache.getInstance().get(ENGINE_ID)
            return
        }

        val engine = FlutterEngine(this)
        MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialPayload" -> result.success(
                        "Android native передал пользователя demo-user-42",
                    )
                    else -> result.notImplemented()
                }
            }

        engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())

        FlutterEngineCache.getInstance().put(ENGINE_ID, engine)
        flutterEngine = engine
    }

    private fun createNativeOnboardingView(): LinearLayout {
        return LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(48, 48, 48, 48)
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
            )

            addView(
                TextView(context).apply {
                    text = "Нативный Android экран"
                    textSize = 28f
                    gravity = Gravity.CENTER
                },
            )

            addView(
                TextView(context).apply {
                    text = "Здесь может быть onboarding, авторизация или любые первые native экраны."
                    textSize = 16f
                    gravity = Gravity.CENTER
                    setPadding(0, 24, 0, 24)
                },
            )

            addView(
                Button(context).apply {
                    text = "Продолжить во Flutter"
                    setOnClickListener { openFlutterFlow() }
                },
            )
        }
    }

    private fun openFlutterFlow() {
        startActivity(
            FlutterActivity
                .withCachedEngine(ENGINE_ID)
                .build(this),
        )
    }

    companion object {
        private const val ENGINE_ID = "main_engine"
        private const val CHANNEL_NAME = "com.example.hybrid/native_bridge"
    }
}
