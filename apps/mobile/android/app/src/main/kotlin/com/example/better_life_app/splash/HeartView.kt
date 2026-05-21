package com.example.better_life_app.splash

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Canvas
import android.graphics.LinearGradient
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.Path
import android.graphics.PathMeasure
import android.graphics.PorterDuff
import android.graphics.PorterDuffXfermode
import android.graphics.Shader
import android.os.SystemClock
import android.util.AttributeSet
import android.view.View
import android.view.animation.PathInterpolator
import androidx.core.content.ContextCompat
import com.example.better_life_app.R
import kotlin.math.cos
import kotlin.math.PI

/**
 * The animated heart logo + halos + check stroke + particle trail.
 *
 * Reproduces the SVG/CSS from splash-standalone.html:
 *   - 3 halos, scale 0.6 → 1.6 with alpha 0.5 → 0 over 4400ms (staggered 1100ms)
 *   - Heart entry: opacity 0 → 1, scale 0.6 → 1, translateY 20 → 0 over 1100ms
 *   - Check stroke draw: 0 → full length over 700ms, starting at 400ms
 *   - 7 particles: translate (+18, -22) px while scaling 1 → 0.4, opacity 0 → 1 → 0
 *     period 2400ms, staggered 600 + 80*i ms
 *
 * Drawn on a 200x200 virtual canvas (same viewBox as the SVG) and scaled
 * to the View's measured size.
 */
class HeartView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : View(context, attrs, defStyleAttr) {

    // ── Paint pool ──────────────────────────────────────────────────────────
    private val heartPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.FILL }
    private val shadowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.FILL }
    private val bandPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        strokeWidth = 6f
    }
    private val checkPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        strokeWidth = 14f
        strokeCap = Paint.Cap.ROUND
        strokeJoin = Paint.Join.ROUND
    }
    private val haloPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        strokeWidth = 1f
    }
    private val particlePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.FILL }

    // ── Geometry (SVG viewBox 200x200) ──────────────────────────────────────
    private val heartPath = Path().apply {
        moveTo(100f, 178f)
        cubicTo(70f, 158f, 30f, 130f, 22f, 92f)
        cubicTo(16f, 62f, 38f, 36f, 68f, 36f)
        cubicTo(84f, 36f, 95f, 44f, 100f, 56f)
        cubicTo(105f, 44f, 116f, 36f, 132f, 36f)
        cubicTo(162f, 36f, 184f, 62f, 178f, 92f)
        cubicTo(170f, 130f, 130f, 158f, 100f, 178f)
        close()
    }
    private val rightLobePath = Path().apply {
        moveTo(100f, 56f)
        cubicTo(105f, 44f, 116f, 36f, 132f, 36f)
        cubicTo(162f, 36f, 184f, 62f, 178f, 92f)
        cubicTo(170f, 130f, 130f, 158f, 100f, 178f)
        close()
    }
    private val bandPath = Path().apply {
        moveTo(30f, 96f)
        cubicTo(70f, 88f, 130f, 88f, 172f, 96f)
    }
    private val checkPath = Path().apply {
        moveTo(62f, 100f)
        lineTo(90f, 126f)
        lineTo(140f, 70f)
    }
    private val checkLength = PathMeasure(checkPath, false).length
    private val checkSegment = Path()

    private data class Particle(val cx: Float, val cy: Float, val r: Float, val delayMs: Long)
    private val particles = listOf(
        Particle(152f, 52f, 6.0f, 600L),
        Particle(164f, 44f, 4.0f, 680L),
        Particle(172f, 38f, 3.0f, 760L),
        Particle(178f, 32f, 2.2f, 840L),
        Particle(184f, 26f, 1.6f, 920L),
        Particle(158f, 30f, 2.0f, 980L),
        Particle(170f, 22f, 1.4f, 1040L),
    )

    private val colorG1 = ContextCompat.getColor(context, R.color.bl_logo_g1)
    private val colorG2 = ContextCompat.getColor(context, R.color.bl_logo_g2)
    private val colorG3 = ContextCompat.getColor(context, R.color.bl_logo_g3)
    private val colorShadowStop = ContextCompat.getColor(context, R.color.bl_logo_shadow_stop)
    private val colorCheck = ContextCompat.getColor(context, R.color.bl_check)
    private val colorHalo = ContextCompat.getColor(context, R.color.bl_halo)

    // ── Animation drivers ───────────────────────────────────────────────────
    private val startUptime = SystemClock.uptimeMillis()
    private val ticker = ValueAnimator.ofFloat(0f, 1f).apply {
        duration = 1_000_000L
        repeatCount = ValueAnimator.INFINITE
        addUpdateListener { invalidate() }
    }

    // cubic-bezier(.2,.9,.25,1) — entry ease "soft pop"
    private val entryInterpolator = PathInterpolator(0.2f, 0.9f, 0.25f, 1f)
    // cubic-bezier(.2,.7,.2,1) — check stroke
    private val checkInterpolator = PathInterpolator(0.2f, 0.7f, 0.2f, 1f)
    // ease-out for halo
    private val haloInterpolator = PathInterpolator(0.0f, 0.0f, 0.2f, 1f)

    private var gradientReady = false

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        ticker.start()
    }

    override fun onDetachedFromWindow() {
        ticker.cancel()
        super.onDetachedFromWindow()
    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        rebuildShaders()
    }

    /** Build gradient shaders sized to the View bounds. */
    private fun rebuildShaders() {
        if (width == 0 || height == 0) return
        val w = width.toFloat()
        val h = height.toFloat()

        // SVG: linearGradient x1=0,y1=0 -> x2=100%,y2=100%
        heartPaint.shader = LinearGradient(
            0f, 0f, w, h,
            intArrayOf(colorG1, colorG2, colorG3),
            floatArrayOf(0f, 0.45f, 1f),
            Shader.TileMode.CLAMP,
        )
        shadowPaint.shader = LinearGradient(
            0f, 0f, w, h,
            intArrayOf((colorG2 and 0x00FFFFFF), colorShadowStop),
            floatArrayOf(0f, 1f),
            Shader.TileMode.CLAMP,
        )
        bandPaint.shader = LinearGradient(
            0f, 0f, w, 0f,
            intArrayOf(0x00FFFFFF, 0xD9FFFFFF.toInt(), 0x00FFFFFF),
            floatArrayOf(0f, 0.5f, 1f),
            Shader.TileMode.CLAMP,
        )
        gradientReady = true
        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        if (!gradientReady) return
        val elapsed = SystemClock.uptimeMillis() - startUptime

        // ── Halos (drawn BEHIND the heart) ───────────────────────────────
        drawHalos(canvas, elapsed)

        // ── Heart group with entry transform ────────────────────────────
        val entryRaw = ((elapsed.coerceAtLeast(0L)).toFloat() / 1100f).coerceIn(0f, 1f)
        val entry = entryInterpolator.getInterpolation(entryRaw)
        val heartAlpha = entry  // 0 → 1
        val heartScale = 0.6f + 0.4f * entry
        val heartTranslateY = 20f * (1f - entry) * (height / 200f)

        canvas.save()
        canvas.translate(0f, heartTranslateY)
        canvas.scale(heartScale, heartScale, width / 2f, height / 2f)

        // Map 200x200 viewBox to actual View size
        val sx = width / 200f
        val sy = height / 200f
        canvas.save()
        canvas.scale(sx, sy)

        // Heart base
        heartPaint.alpha = (heartAlpha * 255).toInt().coerceIn(0, 255)
        canvas.drawPath(heartPath, heartPaint)

        // Right-lobe shadow (55% opacity in spec, multiplied by entry alpha)
        shadowPaint.alpha = (heartAlpha * 0.55f * 255).toInt().coerceIn(0, 255)
        canvas.drawPath(rightLobePath, shadowPaint)

        // Inner band light
        bandPaint.alpha = (heartAlpha * 0.6f * 255).toInt().coerceIn(0, 255)
        canvas.drawPath(bandPath, bandPaint)

        // Check stroke draw (starts at 400ms, 700ms duration)
        val checkRaw = ((elapsed - 400L).coerceAtLeast(0L).toFloat() / 700f).coerceIn(0f, 1f)
        val checkProgress = checkInterpolator.getInterpolation(checkRaw)
        if (checkProgress > 0f) {
            checkSegment.reset()
            PathMeasure(checkPath, false).getSegment(
                0f,
                checkLength * checkProgress,
                checkSegment,
                true,
            )
            checkPaint.color = colorCheck
            checkPaint.alpha = (heartAlpha * 255).toInt().coerceIn(0, 255)
            canvas.drawPath(checkSegment, checkPaint)
        }

        // Particles (looping 2400ms, staggered)
        drawParticles(canvas, elapsed, heartAlpha)

        canvas.restore()
        canvas.restore()
    }

    private fun drawHalos(canvas: Canvas, elapsed: Long) {
        // Halos sized to ~110% of the heart container (220px in CSS over a 170px logo → 220/200 = 1.1)
        val period = 4400L
        for (i in 0 until 3) {
            val delay = i * 1100L
            val t = ((elapsed - delay).coerceAtLeast(0L)) % period
            val phase = t.toFloat() / period
            val k = haloInterpolator.getInterpolation(phase)
            val scale = 0.6f + 1.0f * k
            val alpha = (0.5f * (1f - k)).coerceIn(0f, 1f)

            haloPaint.color = colorHalo
            haloPaint.alpha = (alpha * 255).toInt().coerceIn(0, 255)
            val baseR = (minOf(width, height) / 2f) * 1.10f
            canvas.drawCircle(width / 2f, height / 2f, baseR * scale, haloPaint)
        }
    }

    private fun drawParticles(canvas: Canvas, elapsed: Long, baseAlpha: Float) {
        val period = 2400L
        for (p in particles) {
            val t = ((elapsed - p.delayMs).coerceAtLeast(0L)) % period
            val phase = t.toFloat() / period

            // Opacity curve: 0 -> 0%, 0.2 -> 100%, 0.6 -> 80%, 1.0 -> 0%
            val alpha = when {
                phase < 0.2f  -> (phase / 0.2f) * 1f
                phase < 0.6f  -> 1f - (phase - 0.2f) / 0.4f * 0.2f   // 100% -> 80%
                else          -> 0.8f * (1f - (phase - 0.6f) / 0.4f)  // 80% -> 0
            }
            val translate = phase  // 0 -> 1
            val scale = 1f - 0.6f * phase  // 1 -> 0.4
            val tx = 18f * translate
            val ty = -22f * translate

            particlePaint.color = colorG1
            particlePaint.alpha = (alpha * baseAlpha * 255).toInt().coerceIn(0, 255)
            canvas.drawCircle(p.cx + tx, p.cy + ty, p.r * scale, particlePaint)
        }
    }

    // Suppress unused-import warnings for symbols we may add later.
    @Suppress("unused") private fun _unused() {
        Matrix(); PorterDuffXfermode(PorterDuff.Mode.SRC_OVER); cos(0.0); PI
    }
}
