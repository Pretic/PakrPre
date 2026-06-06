package com.webviewapp

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

class DisclaimerActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_disclaimer)

        findViewById<TextView>(R.id.tvDisclaimerBody).text = buildString {
            appendLine("本应用仅供学习、研究和个人合法用途。")
            appendLine()
            appendLine("禁止用于：")
            appendLine()
            appendLine("× 制作仿冒、钓鱼或诈骗类应用")
            appendLine("× 封装违法、赌博等违规网站")
            appendLine("× 侵犯他人知识产权")
            appendLine("× 任何违反法律法规的行为")
            appendLine()
            append("使用本应用产生的一切法律责任由使用者自行承担。")
        }

        findViewById<Button>(R.id.btnDecline).setOnClickListener { finishAffinity() }
        findViewById<Button>(R.id.btnAccept).setOnClickListener { proceed() }
    }

    private fun proceed() {
        getSharedPreferences("app_prefs", MODE_PRIVATE)
            .edit()
            .putBoolean("disc_agreed", true)
            .apply()
        startActivity(Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        })
        finish()
    }
}
