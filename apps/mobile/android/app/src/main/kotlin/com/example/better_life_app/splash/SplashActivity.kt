package com.example.better_life_app.splash

import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.app.Activity
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.text.SpannableString
import android.text.Spanned
import android.text.style.ForegroundColorSpan
import android.text.style.StyleSpan
import android.graphics.Typeface
import android.view.View
import android.view.WindowManager
import android.view.animation.PathInterpolator
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.example.better_life_app.MainActivity
import com.example.better_life_app.R

/**
 * Native Android splash. Plays the full animated splash (heart, halos,
 * particles, dots, wordmark, tagline, loader) before launching the
 * FlutterActivity. Reproduces splash-standalone.html in Kotlin/native.
 *
 * Timing (mirrors the HTML):
 *   - Heart entry:    0 → 1100 ms     (HeartView)
 *   - Check stroke:   400 → 1100 ms   (HeartView)
 *   - Wordmark:       350 → 1250 ms   (here)
 *   - Tagline fade:   650 → 1350 ms   (here)
 *   - Loader fade-in: 900 → 1500 ms   (LoaderView)
 *   - Hold floor:     2500 ms total
 */
class SplashActivity : Activity() {

    private val handler = Handler(Looper.getMainLooper())
    private var launched = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Edge-to-edge so the radial gradient owns the whole screen.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(false)
        } else {
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility =
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
                    View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
        }
        window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)

        setContentView(R.layout.activity_splash)

        val wordmark = findViewById<TextView>(R.id.splash_wordmark)
        val tagline = findViewById<TextView>(R.id.splash_tagline)

        applyWordmarkSpans(wordmark)

        // Wordmark: opacity 0→1 + translateY 14dp → 0 + letter-spacing 0.02 → -0.02
        // (letter spacing animation is approximated by leaving it at the final
        // value; visually negligible at 350ms).
        val wmAlpha = ObjectAnimator.ofFloat(wordmark, View.ALPHA, 0f, 1f)
        val wmTranslate = ObjectAnimator.ofFloat(wordmark, View.TRANSLATION_Y, dp(14f), 0f)
        val wmSet = AnimatorSet().apply {
            playTogether(wmAlpha, wmTranslate)
            duration = 900L
            startDelay = 350L
            interpolator = PathInterpolator(0.2f, 0.9f, 0.25f, 1f)
        }

        // Tagline: opacity 0→1 + translateY 6dp → 0 (650ms delay, 700ms duration)
        val tagAlpha = ObjectAnimator.ofFloat(tagline, View.ALPHA, 0f, 1f)
        val tagTranslate = ObjectAnimator.ofFloat(tagline, View.TRANSLATION_Y, dp(6f), 0f)
        val tagSet = AnimatorSet().apply {
            playTogether(tagAlpha, tagTranslate)
            duration = 700L
            startDelay = 650L
        }

        wmSet.start()
        tagSet.start()

        // After the minimum hold, launch Flutter.
        handler.postDelayed({ launchMain() }, HOLD_MS)
    }

    /** Render "Better" in primary text color (bold) + "Life" in lav-200 (medium). */
    private fun applyWordmarkSpans(tv: TextView) {
        val full = "BetterLife"
        val span = SpannableString(full)
        val betterEnd = "Better".length
        // "Better" → bold + primary text
        span.setSpan(
            ForegroundColorSpan(ContextCompat.getColor(this, R.color.bl_text)),
            0, betterEnd, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE,
        )
        span.setSpan(StyleSpan(Typeface.BOLD), 0, betterEnd, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
        // "Life" → lavender 200, medium weight (approximated with normal)
        span.setSpan(
            ForegroundColorSpan(ContextCompat.getColor(this, R.color.bl_lav_200)),
            betterEnd, full.length, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE,
        )
        tv.text = span
    }

    private fun launchMain() {
        if (launched) return
        launched = true
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NO_ANIMATION
        }
        startActivity(intent)
        // No exit animation — let the new activity's window appear seamlessly.
        @Suppress("DEPRECATION")
        overridePendingTransition(0, 0)
        finish()
    }

    override fun onDestroy() {
        handler.removeCallbacksAndMessages(null)
        super.onDestroy()
    }

    private fun dp(value: Float): Float = value * resources.displayMetrics.density

    companion object {
        /** Minimum hold time before launching Flutter. Matches the HTML 2500ms floor. */
        private const val HOLD_MS = 2500L
    }
}
