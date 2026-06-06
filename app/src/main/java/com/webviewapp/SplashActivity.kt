package com.webviewapp

import android.annotation.SuppressLint
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.appcompat.app.AppCompatActivity

@SuppressLint("CustomSplashScreen")
class SplashActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        @Suppress("DEPRECATION")
        window.setFlags(
            android.view.WindowManager.LayoutParams.FLAG_FULLSCREEN or
            android.view.WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            android.view.WindowManager.LayoutParams.FLAG_FULLSCREEN or
            android.view.WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
        )

        setContentView(R.layout.activity_splash)

        Handler(Looper.getMainLooper()).postDelayed({
            val nextActivity = if (shouldShowDisclaimer()) {
                DisclaimerActivity::class.java
            } else {
                MainActivity::class.java
            }
            startActivity(Intent(this, nextActivity))
            finish()
        }, 800)
    }

    private fun shouldShowDisclaimer(): Boolean {
        if (!SHOW_DISCLAIMER.equals("true", ignoreCase = true)) return false
        return !getSharedPreferences("app_prefs", MODE_PRIVATE)
            .getBoolean("disc_agreed", false)
    }

    companion object {
        private const val SHOW_DISCLAIMER = "{{SHOW_DISCLAIMER}}"
    }
}
