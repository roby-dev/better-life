package com.example.better_life_app.splash

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import android.os.SystemClock
import android.util.AttributeSet
import android.view.View
import android.view.animation.PathInterpolator
import androidx.core.content.ContextCompat
import com.example.better_life_app.R

/**
 * Bottom loader bar: 120×3 dp pill, with a fill segment that slides
 * left → right on a 1600ms cubic-bezier(.4,0,.2,1) loop after a 900ms
 * fade-in delay. Mirrors `.loader` from splash-standalone.html.
 */
class LoaderView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : View(context, attrs, defStyleAttr) {

    private val trackPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = ContextCompat.getColor(context, R.color.bl_loader_track)
    }
    private val fillPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = ContextCompat.getColor(context, R.color.bl_loader_fill)
    }
    private val rect = RectF()
    private val density = resources.displayMetrics.density

    private val startUptime = SystemClock.uptimeMillis()
    private val slideInterpolator = PathInterpolator(0.4f, 0f, 0.2f, 1f)
    private val ticker = ValueAnimator.ofFloat(0f, 1f).apply {
        duration = 1_000_000L
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

        // Loader fade in starts at 900ms, takes 600ms
        val fadeRaw = ((elapsed - 900L).coerceAtLeast(0L).toFloat() / 600f).coerceIn(0f, 1f)
        val alpha = (fadeRaw * 255).toInt()

        // Track (full width pill)
        val radius = height / 2f
        rect.set(0f, 0f, width.toFloat(), height.toFloat())
        trackPaint.alpha = alpha
        canvas.drawRoundRect(rect, radius, radius, trackPaint)

        // Fill segment (40% width) slides from -110% to +310% over 1600ms.
        // Slide doesn't begin until the 900ms fade-in starts.
        if (elapsed >= 900L) {
            val period = 1600L
            val slideElapsed = elapsed - 900L
            val phase = (slideElapsed % period).toFloat() / period
            val eased = slideInterpolator.getInterpolation(phase)
            // Range: -110% to +310% (CSS spec)
            val translatePct = -1.10f + 4.20f * eased

            val fillW = width * 0.4f
            val startX = width * translatePct
            rect.set(startX, 0f, startX + fillW, height.toFloat())

            // Clip to the pill so the fill never overflows the track.
            canvas.save()
            val clip = RectF(0f, 0f, width.toFloat(), height.toFloat())
            canvas.clipRect(clip)
            fillPaint.alpha = alpha
            canvas.drawRoundRect(rect, radius, radius, fillPaint)
            canvas.restore()
        }
    }

    companion object {
        // Fixed CSS dimensions: 120×3 dp
        fun targetWidthDp(): Float = 120f
        fun targetHeightDp(): Float = 3f
    }
}
