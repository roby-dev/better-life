package com.example.better_life_app.splash

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RadialGradient
import android.graphics.Shader
import android.util.AttributeSet
import android.widget.FrameLayout
import androidx.core.content.ContextCompat
import com.example.better_life_app.R

/**
 * Root container for the splash. Paints the radial gradient background
 * (top->bottom) that mirrors `splash-standalone.html` and the in-app
 * SplashScreen gradient. All child views (dots, heart, wordmark, loader)
 * are stacked on top by the XML layout.
 */
class SplashStageView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : FrameLayout(context, attrs, defStyleAttr) {

    private val paint = Paint(Paint.ANTI_ALIAS_FLAG)

    private val colorTop = ContextCompat.getColor(context, R.color.bl_bg_top)
    private val colorBottom = ContextCompat.getColor(context, R.color.bl_bg_bottom)

    init {
        setWillNotDraw(false)
    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        if (w == 0 || h == 0) return
        // Center at (50%, 20%), radius ~120% of the larger axis — matches the
        // CSS `radial-gradient(120% 80% at 50% 20%, top, bottom)` closely
        // enough for the small visual budget of a splash.
        paint.shader = RadialGradient(
            w * 0.5f,
            h * 0.2f,
            maxOf(w, h) * 1.2f,
            colorTop,
            colorBottom,
            Shader.TileMode.CLAMP,
        )
    }

    override fun onDraw(canvas: Canvas) {
        canvas.drawRect(0f, 0f, width.toFloat(), height.toFloat(), paint)
        super.onDraw(canvas)
    }
}
