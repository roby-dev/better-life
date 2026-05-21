package com.example.better_life_app.splash

import android.animation.ArgbEvaluator
import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.os.SystemClock
import android.util.AttributeSet
import android.view.View
import androidx.core.content.ContextCompat
import com.example.better_life_app.R
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.PI

/**
 * Background decorative dots. Each dot pulses (scale + color) on a 3000ms+
 * loop with a staggered start delay, faithfully reproducing the CSS
 * `.dot { animation: dotPulse 3000ms ease-in-out infinite }` pattern.
 */
class DotsView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : View(context, attrs, defStyleAttr) {

    private data class DotSpec(
        val xPct: Float,
        val yPct: Float,
        val baseRadiusDp: Float,
        val delayMs: Long,
        val periodMs: Long,
    )

    // x%, y%, base-radius (matches splash-standalone positions)
    private val specs = listOf(
        DotSpec(12f, 14f, 2.0f, 0L, 3000L),
        DotSpec(88f, 22f, 3.0f, 180L, 3250L),
        DotSpec(22f, 64f, 1.5f, 360L, 3500L),
        DotSpec(78f, 78f, 2.0f, 540L, 3750L),
        DotSpec(14f, 84f, 2.5f, 720L, 4000L),
        DotSpec(60f, 8f, 1.2f, 900L, 4250L),
        DotSpec(92f, 56f, 1.8f, 1080L, 4500L),
        DotSpec(8f, 38f, 1.4f, 1260L, 4750L),
        DotSpec(36f, 92f, 1.6f, 1440L, 5000L),
        DotSpec(70f, 90f, 1.2f, 1620L, 5250L),
    )

    private val paint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val argbEvaluator = ArgbEvaluator()
    private val colorBase = ContextCompat.getColor(context, R.color.bl_dot)
    private val colorPeak = ContextCompat.getColor(context, R.color.bl_dot_peak)
    private val density = resources.displayMetrics.density

    private val startUptime = SystemClock.uptimeMillis()
    private val ticker = ValueAnimator.ofFloat(0f, 1f).apply {
        duration = 1_000_000L  // long; we read elapsed time directly each frame
        repeatCount = ValueAnimator.INFINITE
        addUpdateListener { invalidate() }
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        ticker.start()
    }

    override fun onDetachedFromWindow() {
        ticker.cancel()
        super.onDetachedFromWindow()
    }

    override fun onDraw(canvas: Canvas) {
        val elapsed = SystemClock.uptimeMillis() - startUptime
        for (spec in specs) {
            val t = ((elapsed - spec.delayMs).coerceAtLeast(0L)) % spec.periodMs
            val phase = t.toFloat() / spec.periodMs            // 0..1
            // 0%/100% -> base, 50% -> peak. Use cosine so it eases in/out.
            val k = 0.5f - 0.5f * cos(phase * 2f * PI.toFloat())
            val scale = 1.0f + 0.6f * k
            val color = argbEvaluator.evaluate(k, colorBase, colorPeak) as Int

            paint.color = color
            val cx = spec.xPct / 100f * width
            val cy = spec.yPct / 100f * height
            val r = spec.baseRadiusDp * density * scale
            canvas.drawCircle(cx, cy, r, paint)
        }
    }

    // Suppress unused-import lint without removing math imports we may extend.
    @Suppress("unused") private fun _unused() = sin(0.0)
}
