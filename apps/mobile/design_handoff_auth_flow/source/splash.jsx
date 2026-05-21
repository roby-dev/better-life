// BetterLife splash screen — light + dark variants
// Animated logo entry, particle trail, loading indicator

const BL = {
  // palette from Adobe Color reference
  lav1: '#C6C6F0',
  lav2: '#A7A7CC',
  lav3: '#8686A3',
  lav4: '#64647A',
  lav5: '#434352',
  // derived
  bgLight: '#FAFAFB',
  bgLightWarm: '#F4F2F8',
  bgDark: '#16151F',
  bgDarkDeep: '#0E0D16',
  textDark: '#2D2D40',
  textLight: '#E6E5F2',
};

// ───────────────────────────────────────────────────────────
// Logo — re-traced as SVG so it animates crisply.
// (Original is a heart with checkmark and a particle trail.)
// ───────────────────────────────────────────────────────────
function Logo({ size = 160, dark = false, animate = true }) {
  // gradient stops shift slightly between modes
  const g1 = dark ? '#B8B8E8' : '#C6C6F0';
  const g2 = dark ? '#8B8BC0' : '#A7A7CC';
  const g3 = dark ? '#5A5A78' : '#64647A';
  const g4 = dark ? '#3A3A50' : '#434352';

  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 200 200"
      style={{
        overflow: 'visible',
        animation: animate ? 'logoIn 1100ms cubic-bezier(.2,.9,.25,1) both' : 'none',
      }}
    >
      <defs>
        <linearGradient id="heartGrad" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor={g1} />
          <stop offset="45%" stopColor={g2} />
          <stop offset="100%" stopColor={g4} />
        </linearGradient>
        <linearGradient id="heartShadow" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor={g2} stopOpacity="0" />
          <stop offset="100%" stopColor={g4} stopOpacity="0.6" />
        </linearGradient>
        <linearGradient id="bandLight" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="0%" stopColor="#fff" stopOpacity="0.0" />
          <stop offset="50%" stopColor="#fff" stopOpacity="0.85" />
          <stop offset="100%" stopColor="#fff" stopOpacity="0.0" />
        </linearGradient>
      </defs>

      {/* heart base */}
      <path
        d="M100 178
           C 70 158, 30 130, 22 92
           C 16 62, 38 36, 68 36
           C 84 36, 95 44, 100 56
           C 105 44, 116 36, 132 36
           C 162 36, 184 62, 178 92
           C 170 130, 130 158, 100 178 Z"
        fill="url(#heartGrad)"
      />
      {/* darker right lobe to mimic depth */}
      <path
        d="M100 56
           C 105 44, 116 36, 132 36
           C 162 36, 184 62, 178 92
           C 170 130, 130 158, 100 178 Z"
        fill="url(#heartShadow)"
        opacity="0.55"
      />
      {/* soft inner band highlight */}
      <path
        d="M30 96 C 70 88, 130 88, 172 96"
        stroke="url(#bandLight)"
        strokeWidth="6"
        fill="none"
        opacity="0.6"
      />

      {/* check mark */}
      <path
        d="M62 100 L 90 126 L 140 70"
        stroke="#FFFFFF"
        strokeWidth="14"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
        style={{
          strokeDasharray: 160,
          strokeDashoffset: animate ? 160 : 0,
          animation: animate ? 'checkDraw 700ms cubic-bezier(.2,.7,.2,1) 400ms forwards' : 'none',
        }}
      />

      {/* particle trail — drifts up-right */}
      {[
        { cx: 152, cy: 52, r: 6, d: 0 },
        { cx: 164, cy: 44, r: 4, d: 80 },
        { cx: 172, cy: 38, r: 3, d: 160 },
        { cx: 178, cy: 32, r: 2.2, d: 240 },
        { cx: 184, cy: 26, r: 1.6, d: 320 },
        { cx: 158, cy: 30, r: 2, d: 380 },
        { cx: 170, cy: 22, r: 1.4, d: 440 },
      ].map((p, i) => (
        <circle
          key={i}
          cx={p.cx}
          cy={p.cy}
          r={p.r}
          fill={g1}
          opacity="0.9"
          style={{
            transformOrigin: `${p.cx}px ${p.cy}px`,
            animation: animate
              ? `particleFloat 2400ms ease-in-out ${600 + p.d}ms infinite`
              : 'none',
          }}
        />
      ))}
    </svg>
  );
}

// ───────────────────────────────────────────────────────────
// Wordmark
// ───────────────────────────────────────────────────────────
function Wordmark({ dark = false, size = 40 }) {
  const better = dark ? '#E8E7F5' : BL.lav5;
  const life = dark ? BL.lav2 : BL.lav2;
  return (
    <div
      style={{
        fontFamily: '"Plus Jakarta Sans", "Inter", system-ui, sans-serif',
        fontSize: size,
        fontWeight: 800,
        letterSpacing: '-0.02em',
        lineHeight: 1,
        animation: 'wordmarkIn 900ms cubic-bezier(.2,.9,.25,1) 350ms both',
      }}
    >
      <span style={{ color: better }}>Better</span>
      <span style={{ color: life, fontWeight: 500 }}>Life</span>
    </div>
  );
}

// ───────────────────────────────────────────────────────────
// Loading bar
// ───────────────────────────────────────────────────────────
function Loader({ dark = false }) {
  const track = dark ? 'rgba(198,198,240,0.12)' : 'rgba(67,67,82,0.08)';
  const fill = dark ? BL.lav1 : BL.lav3;
  return (
    <div
      style={{
        width: 120,
        height: 3,
        borderRadius: 100,
        background: track,
        overflow: 'hidden',
        position: 'relative',
        animation: 'fadeIn 600ms ease 900ms both',
      }}
    >
      <div
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          height: '100%',
          width: '40%',
          background: fill,
          borderRadius: 100,
          animation: 'loaderSlide 1600ms cubic-bezier(.4,0,.2,1) infinite',
        }}
      />
    </div>
  );
}

// ───────────────────────────────────────────────────────────
// Pulsing ring behind the logo (subtle ambient glow)
// ───────────────────────────────────────────────────────────
function Halo({ dark = false }) {
  const c = dark ? BL.lav2 : BL.lav1;
  return (
    <div
      style={{
        position: 'absolute',
        inset: 0,
        display: 'grid',
        placeItems: 'center',
        pointerEvents: 'none',
      }}
    >
      {[0, 1, 2].map(i => (
        <div
          key={i}
          style={{
            gridArea: '1 / 1',
            width: 220,
            height: 220,
            borderRadius: '50%',
            border: `1px solid ${c}`,
            opacity: 0,
            animation: `haloPulse 4400ms ease-out ${600 + i * 1100}ms infinite`,
          }}
        />
      ))}
    </div>
  );
}

// ───────────────────────────────────────────────────────────
// Splash content — shared between light/dark
// ───────────────────────────────────────────────────────────
function SplashContent({ dark }) {
  const bg = dark
    ? `radial-gradient(120% 80% at 50% 30%, ${BL.bgDark} 0%, ${BL.bgDarkDeep} 100%)`
    : `radial-gradient(120% 80% at 50% 30%, #FFFFFF 0%, ${BL.bgLightWarm} 100%)`;

  const tagline = dark ? 'rgba(232,231,245,0.55)' : 'rgba(67,67,82,0.55)';
  const footer = dark ? 'rgba(232,231,245,0.35)' : 'rgba(67,67,82,0.40)';

  return (
    <div
      data-screen-label={dark ? 'Splash · Dark' : 'Splash · Light'}
      style={{
        position: 'absolute',
        inset: 0,
        background: bg,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'space-between',
        padding: '180px 0 120px',
        overflow: 'hidden',
      }}
    >
      {/* subtle backdrop dots */}
      <BackdropDots dark={dark} />

      {/* center stack */}
      <div
        style={{
          flex: 1,
          width: '100%',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          gap: 28,
          position: 'relative',
          zIndex: 2,
        }}
      >
        <div style={{ position: 'relative', width: 220, height: 220, display: 'grid', placeItems: 'center' }}>
          <Halo dark={dark} />
          <Logo size={170} dark={dark} />
        </div>
        <Wordmark dark={dark} />
        <div
          style={{
            fontFamily: '"Plus Jakarta Sans", "Inter", system-ui, sans-serif',
            fontSize: 10,
            color: tagline,
            letterSpacing: '0.32em',
            textTransform: 'uppercase',
            fontWeight: 500,
            opacity: 0.7,
            animation: 'fadeIn 700ms ease 650ms both',
          }}
        >
          Hábitos · Bienestar · Tú
        </div>
      </div>

      {/* footer */}
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          gap: 18,
          zIndex: 2,
        }}
      >
        <Loader dark={dark} />
      </div>
    </div>
  );
}

function BackdropDots({ dark }) {
  // sparse decorative dots, scattered with deterministic positions
  const dots = [
    { x: 12, y: 14, s: 2 },
    { x: 88, y: 22, s: 3 },
    { x: 22, y: 64, s: 1.5 },
    { x: 78, y: 78, s: 2 },
    { x: 14, y: 84, s: 2.5 },
    { x: 60, y: 8, s: 1.2 },
    { x: 92, y: 56, s: 1.8 },
    { x: 8, y: 38, s: 1.4 },
    { x: 36, y: 92, s: 1.6 },
    { x: 70, y: 90, s: 1.2 },
  ];
  const c = dark ? BL.lav2 : BL.lav3;
  return (
    <div style={{ position: 'absolute', inset: 0, zIndex: 1 }}>
      {dots.map((d, i) => (
        <div
          key={i}
          style={{
            position: 'absolute',
            left: `${d.x}%`,
            top: `${d.y}%`,
            width: d.s * 2,
            height: d.s * 2,
            borderRadius: '50%',
            background: c,
            opacity: dark ? 0.16 : 0.18,
            animation: `dotPulse ${3000 + i * 250}ms ease-in-out ${i * 180}ms infinite`,
          }}
        />
      ))}
    </div>
  );
}

// ───────────────────────────────────────────────────────────
// Replay button (resets the animation for review)
// ───────────────────────────────────────────────────────────
function ReplayButton({ onClick }) {
  return (
    <button
      onClick={onClick}
      style={{
        position: 'absolute',
        top: 12,
        right: 12,
        zIndex: 100,
        background: 'rgba(255,255,255,0.9)',
        backdropFilter: 'blur(8px)',
        border: '1px solid rgba(67,67,82,0.12)',
        borderRadius: 999,
        padding: '6px 12px',
        fontSize: 11,
        fontFamily: '"Plus Jakarta Sans", system-ui, sans-serif',
        fontWeight: 600,
        letterSpacing: '0.08em',
        textTransform: 'uppercase',
        color: BL.lav5,
        cursor: 'pointer',
        boxShadow: '0 4px 12px rgba(67,67,82,0.08)',
      }}
    >
      ↻ Replay
    </button>
  );
}

// ───────────────────────────────────────────────────────────
// One splash artboard (frame + content + replay)
// ───────────────────────────────────────────────────────────
function SplashFrame({ dark }) {
  const [key, setKey] = React.useState(0);
  return (
    <div style={{ position: 'relative' }}>
      <IOSDevice width={390} height={844} dark={dark}>
        <div key={key} style={{ position: 'absolute', inset: 0 }}>
          <SplashContent dark={dark} />
        </div>
      </IOSDevice>
      <ReplayButton onClick={() => setKey(k => k + 1)} />
    </div>
  );
}

// ───────────────────────────────────────────────────────────
// App — design canvas with both artboards
// ───────────────────────────────────────────────────────────
function App() {
  return (
    <DesignCanvas
      title="BetterLife — App Screens"
      subtitle="Light & Dark · iPhone 14 Pro · 390×844"
    >
      <DCSection id="splash" title="Splash">
        <DCArtboard id="light" label="Light mode" width={390} height={844}>
          <SplashFrame dark={false} />
        </DCArtboard>
        <DCArtboard id="dark" label="Dark mode" width={390} height={844}>
          <SplashFrame dark={true} />
        </DCArtboard>
      </DCSection>
      <DCSection id="signup" title="Sign up">
        <DCArtboard id="signup-light" label="Light mode" width={390} height={844}>
          <SignUpFrame dark={false} />
        </DCArtboard>
        <DCArtboard id="signup-dark" label="Dark mode" width={390} height={844}>
          <SignUpFrame dark={true} />
        </DCArtboard>
      </DCSection>
      <DCSection id="login" title="Login">
        <DCArtboard id="login-light" label="Light mode" width={390} height={844}>
          <LoginFrame dark={false} />
        </DCArtboard>
        <DCArtboard id="login-dark" label="Dark mode" width={390} height={844}>
          <LoginFrame dark={true} />
        </DCArtboard>
      </DCSection>
    </DesignCanvas>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
