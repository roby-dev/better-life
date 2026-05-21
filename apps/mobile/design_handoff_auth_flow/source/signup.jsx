// BetterLife — Sign Up screen
// Interactive form: focus states, show/hide password, strength meter, validation

// ───────────────────────────────────────────────────────────
// Tiny inline icons (no external lib)
// ───────────────────────────────────────────────────────────
const Icon = {
  user: (c) => (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
      <circle cx="12" cy="8" r="4" stroke={c} strokeWidth="1.6" />
      <path d="M4 20c1.5-3.5 4.5-5 8-5s6.5 1.5 8 5" stroke={c} strokeWidth="1.6" strokeLinecap="round" />
    </svg>
  ),
  mail: (c) => (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
      <rect x="3" y="5" width="18" height="14" rx="3" stroke={c} strokeWidth="1.6" />
      <path d="M4 7l8 6 8-6" stroke={c} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  ),
  lock: (c) => (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
      <rect x="4" y="10" width="16" height="10" rx="3" stroke={c} strokeWidth="1.6" />
      <path d="M8 10V7a4 4 0 018 0v3" stroke={c} strokeWidth="1.6" strokeLinecap="round" />
    </svg>
  ),
  eye: (c) => (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
      <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z" stroke={c} strokeWidth="1.6" />
      <circle cx="12" cy="12" r="3" stroke={c} strokeWidth="1.6" />
    </svg>
  ),
  eyeOff: (c) => (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
      <path d="M3 3l18 18" stroke={c} strokeWidth="1.6" strokeLinecap="round" />
      <path d="M10.5 6.2A10 10 0 0112 6c6.5 0 10 7 10 7a18 18 0 01-3.2 3.8M6.1 7.4A18 18 0 002 12s3.5 7 10 7c1.6 0 3-.3 4.3-.8" stroke={c} strokeWidth="1.6" strokeLinecap="round" />
      <path d="M9.9 9.9a3 3 0 004.2 4.2" stroke={c} strokeWidth="1.6" strokeLinecap="round" />
    </svg>
  ),
  back: (c) => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
      <path d="M15 5l-7 7 7 7" stroke={c} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  ),
  check: (c) => (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
      <path d="M5 12l5 5L20 7" stroke={c} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  ),
};

// ───────────────────────────────────────────────────────────
// Mini logo for header
// ───────────────────────────────────────────────────────────
function MiniLogo({ dark = false, size = 36 }) {
  const g1 = dark ? '#B8B8E8' : '#C6C6F0';
  const g2 = dark ? '#8B8BC0' : '#A7A7CC';
  const g4 = dark ? '#3A3A50' : '#434352';
  return (
    <svg width={size} height={size} viewBox="0 0 200 200">
      <defs>
        <linearGradient id={`mini-${dark ? 'd' : 'l'}`} x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor={g1} />
          <stop offset="55%" stopColor={g2} />
          <stop offset="100%" stopColor={g4} />
        </linearGradient>
      </defs>
      <path
        d="M100 178 C 70 158, 30 130, 22 92 C 16 62, 38 36, 68 36 C 84 36, 95 44, 100 56 C 105 44, 116 36, 132 36 C 162 36, 184 62, 178 92 C 170 130, 130 158, 100 178 Z"
        fill={`url(#mini-${dark ? 'd' : 'l'})`}
      />
      <path
        d="M62 100 L 90 126 L 140 70"
        stroke="#FFFFFF"
        strokeWidth="14"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  );
}

// ───────────────────────────────────────────────────────────
// Text field
// ───────────────────────────────────────────────────────────
function Field({
  icon, label, value, onChange, type = 'text', placeholder,
  dark = false, error, valid, autoFocus, trailing,
}) {
  const [focus, setFocus] = React.useState(false);

  const labelColor = dark ? 'rgba(232,231,245,0.55)' : 'rgba(67,67,82,0.55)';
  const textColor = dark ? '#E8E7F5' : BL.lav5;
  const iconColor = focus
    ? (dark ? BL.lav1 : BL.lav4)
    : (dark ? 'rgba(232,231,245,0.45)' : 'rgba(100,100,122,0.55)');
  const bg = dark ? 'rgba(255,255,255,0.04)' : '#FFFFFF';
  const borderIdle = dark ? 'rgba(198,198,240,0.10)' : 'rgba(67,67,82,0.10)';
  const borderFocus = error
    ? '#E26B7C'
    : (dark ? BL.lav2 : BL.lav4);
  const borderColor = focus ? borderFocus : (error ? '#E26B7C' : borderIdle);

  return (
    <label style={{ display: 'block' }}>
      <div
        style={{
          fontSize: 11,
          fontWeight: 600,
          letterSpacing: '0.14em',
          textTransform: 'uppercase',
          color: labelColor,
          marginBottom: 8,
        }}
      >
        {label}
      </div>
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: 12,
          height: 52,
          padding: '0 14px',
          background: bg,
          border: `1.5px solid ${borderColor}`,
          borderRadius: 14,
          transition: 'border-color 180ms ease, box-shadow 180ms ease, background 180ms ease',
          boxShadow: focus
            ? (dark
                ? `0 0 0 4px rgba(167,167,204,0.10)`
                : `0 0 0 4px rgba(100,100,122,0.06)`)
            : 'none',
        }}
      >
        <div style={{ display: 'grid', placeItems: 'center', width: 20 }}>
          {icon(iconColor)}
        </div>
        <input
          type={type}
          value={value}
          onChange={(e) => onChange(e.target.value)}
          onFocus={() => setFocus(true)}
          onBlur={() => setFocus(false)}
          placeholder={placeholder}
          autoFocus={autoFocus}
          style={{
            flex: 1,
            border: 'none',
            outline: 'none',
            background: 'transparent',
            font: 'inherit',
            fontSize: 16,
            color: textColor,
            fontWeight: 500,
            letterSpacing: '-0.005em',
            padding: 0,
            minWidth: 0,
          }}
        />
        {trailing}
        {valid && !trailing && (
          <div
            style={{
              width: 20,
              height: 20,
              borderRadius: '50%',
              background: dark ? BL.lav1 : BL.lav4,
              display: 'grid',
              placeItems: 'center',
            }}
          >
            {Icon.check(dark ? BL.lav5 : '#fff')}
          </div>
        )}
      </div>
      {error && (
        <div
          style={{
            fontSize: 12,
            color: '#E26B7C',
            marginTop: 6,
            fontWeight: 500,
            letterSpacing: '-0.005em',
          }}
        >
          {error}
        </div>
      )}
    </label>
  );
}

// ───────────────────────────────────────────────────────────
// Password strength meter
// ───────────────────────────────────────────────────────────
function strengthOf(pw) {
  if (!pw) return { score: 0, label: '' };
  let s = 0;
  if (pw.length >= 8) s++;
  if (/[A-Z]/.test(pw)) s++;
  if (/[0-9]/.test(pw)) s++;
  if (/[^A-Za-z0-9]/.test(pw)) s++;
  if (pw.length >= 12) s = Math.min(4, s + 1);
  const labels = ['', 'Débil', 'Aceptable', 'Buena', 'Excelente'];
  return { score: s, label: labels[s] };
}

function StrengthMeter({ pw, dark }) {
  const { score, label } = strengthOf(pw);
  const colors = ['', '#E26B7C', '#D9A95B', BL.lav3, dark ? BL.lav1 : BL.lav4];
  const trackC = dark ? 'rgba(198,198,240,0.10)' : 'rgba(67,67,82,0.08)';
  const labelC = dark ? 'rgba(232,231,245,0.55)' : 'rgba(67,67,82,0.55)';

  return (
    <div
      style={{
        display: 'flex',
        alignItems: 'center',
        gap: 10,
        marginTop: 10,
        opacity: pw ? 1 : 0,
        transition: 'opacity 220ms ease',
        height: 18,
      }}
    >
      <div style={{ display: 'flex', gap: 4, flex: 1 }}>
        {[1, 2, 3, 4].map(n => (
          <div
            key={n}
            style={{
              flex: 1,
              height: 3,
              borderRadius: 100,
              background: n <= score ? colors[score] : trackC,
              transition: 'background 220ms ease',
            }}
          />
        ))}
      </div>
      <div
        style={{
          fontSize: 11,
          fontWeight: 600,
          color: score ? colors[score] : labelC,
          letterSpacing: '0.04em',
          minWidth: 64,
          textAlign: 'right',
        }}
      >
        {label}
      </div>
    </div>
  );
}

// ───────────────────────────────────────────────────────────
// Primary button
// ───────────────────────────────────────────────────────────
function PrimaryBtn({ children, onClick, disabled, dark }) {
  const [hover, setHover] = React.useState(false);
  const bg = disabled
    ? (dark ? 'rgba(198,198,240,0.18)' : 'rgba(67,67,82,0.18)')
    : (dark ? BL.lav1 : BL.lav5);
  const color = disabled
    ? (dark ? 'rgba(232,231,245,0.4)' : 'rgba(67,67,82,0.5)')
    : (dark ? BL.lav5 : '#FFFFFF');

  return (
    <button
      onClick={onClick}
      disabled={disabled}
      onMouseEnter={() => setHover(true)}
      onMouseLeave={() => setHover(false)}
      style={{
        width: '100%',
        height: 54,
        borderRadius: 14,
        border: 'none',
        background: bg,
        color: color,
        fontFamily: 'inherit',
        fontSize: 16,
        fontWeight: 700,
        letterSpacing: '-0.005em',
        cursor: disabled ? 'not-allowed' : 'pointer',
        transition: 'transform 140ms ease, box-shadow 200ms ease, background 200ms ease',
        transform: hover && !disabled ? 'translateY(-1px)' : 'translateY(0)',
        boxShadow: disabled
          ? 'none'
          : (hover
              ? (dark
                  ? '0 10px 28px rgba(198,198,240,0.30)'
                  : '0 10px 28px rgba(67,67,82,0.25)')
              : (dark
                  ? '0 4px 14px rgba(198,198,240,0.18)'
                  : '0 4px 14px rgba(67,67,82,0.12)')),
      }}
    >
      {children}
    </button>
  );
}

// ───────────────────────────────────────────────────────────
// Sign-up content
// ───────────────────────────────────────────────────────────
function SignUpContent({ dark }) {
  const [name, setName] = React.useState('');
  const [email, setEmail] = React.useState('');
  const [pw, setPw] = React.useState('');
  const [showPw, setShowPw] = React.useState(false);
  const [touched, setTouched] = React.useState({ name: false, email: false, pw: false });

  const emailOk = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  const nameOk = name.trim().length >= 2;
  const pwOk = strengthOf(pw).score >= 2;
  const formOk = nameOk && emailOk && pwOk;

  const bg = dark
    ? `radial-gradient(120% 80% at 50% 0%, #1F1E2C 0%, ${BL.bgDarkDeep} 60%)`
    : `radial-gradient(120% 80% at 50% 0%, #FFFFFF 0%, ${BL.bgLightWarm} 100%)`;

  const heading = dark ? '#F0EFFA' : BL.lav5;
  const sub = dark ? 'rgba(232,231,245,0.55)' : 'rgba(67,67,82,0.6)';
  const link = dark ? BL.lav1 : BL.lav4;
  const divider = dark ? 'rgba(198,198,240,0.08)' : 'rgba(67,67,82,0.08)';
  const ghostText = dark ? 'rgba(232,231,245,0.7)' : BL.lav5;

  const eyeColor = dark ? 'rgba(232,231,245,0.55)' : 'rgba(100,100,122,0.65)';

  return (
    <div
      data-screen-label={dark ? 'SignUp · Dark' : 'SignUp · Light'}
      style={{
        position: 'absolute',
        inset: 0,
        background: bg,
        display: 'flex',
        flexDirection: 'column',
        padding: '54px 28px 40px',
        overflow: 'auto',
        fontFamily: '"Plus Jakarta Sans", system-ui, sans-serif',
      }}
    >
      {/* top row: back + mini logo */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 28 }}>
        <button
          style={{
            width: 40, height: 40, borderRadius: 12,
            background: dark ? 'rgba(255,255,255,0.05)' : 'rgba(67,67,82,0.05)',
            border: `1px solid ${divider}`,
            display: 'grid', placeItems: 'center',
            cursor: 'pointer',
          }}
        >
          {Icon.back(dark ? BL.lav2 : BL.lav4)}
        </button>
        <MiniLogo dark={dark} size={32} />
      </div>

      {/* heading */}
      <div style={{ marginBottom: 32 }}>
        <h1
          style={{
            fontSize: 30,
            fontWeight: 800,
            color: heading,
            letterSpacing: '-0.03em',
            lineHeight: 1.1,
            margin: 0,
            marginBottom: 10,
          }}
        >
          Crea tu cuenta
        </h1>
        <p
          style={{
            margin: 0,
            fontSize: 15,
            lineHeight: 1.5,
            color: sub,
            letterSpacing: '-0.005em',
          }}
        >
          Empieza tu camino hacia mejores hábitos.
        </p>
      </div>

      {/* fields */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 18 }}>
        <Field
          icon={Icon.user}
          label="Nombre"
          placeholder="Tu nombre"
          value={name}
          onChange={(v) => { setName(v); setTouched(t => ({ ...t, name: true })); }}
          valid={nameOk}
          error={touched.name && name && !nameOk ? 'Demasiado corto' : null}
          dark={dark}
        />
        <Field
          icon={Icon.mail}
          label="Email"
          placeholder="tucorreo@ejemplo.com"
          type="email"
          value={email}
          onChange={(v) => { setEmail(v); setTouched(t => ({ ...t, email: true })); }}
          valid={emailOk}
          error={touched.email && email && !emailOk ? 'Correo no válido' : null}
          dark={dark}
        />
        <div>
          <Field
            icon={Icon.lock}
            label="Contraseña"
            placeholder="Mínimo 8 caracteres"
            type={showPw ? 'text' : 'password'}
            value={pw}
            onChange={(v) => { setPw(v); setTouched(t => ({ ...t, pw: true })); }}
            dark={dark}
            trailing={(
              <button
                onClick={(e) => { e.preventDefault(); setShowPw(s => !s); }}
                style={{
                  width: 32, height: 32, borderRadius: 8,
                  border: 'none', background: 'transparent',
                  display: 'grid', placeItems: 'center', cursor: 'pointer',
                }}
                tabIndex={-1}
                type="button"
              >
                {showPw ? Icon.eyeOff(eyeColor) : Icon.eye(eyeColor)}
              </button>
            )}
          />
          <StrengthMeter pw={pw} dark={dark} />
        </div>
      </div>

      {/* terms */}
      <p
        style={{
          marginTop: 24,
          marginBottom: 20,
          fontSize: 12,
          lineHeight: 1.5,
          color: sub,
          letterSpacing: '-0.003em',
          textAlign: 'center',
        }}
      >
        Al continuar, aceptas nuestros{' '}
        <span style={{ color: link, fontWeight: 600 }}>Términos</span> y{' '}
        <span style={{ color: link, fontWeight: 600 }}>Política de privacidad</span>.
      </p>

      {/* CTA */}
      <PrimaryBtn dark={dark} disabled={!formOk}>
        Crear cuenta
      </PrimaryBtn>

      {/* spacer / footer */}
      <div style={{ flex: 1, minHeight: 24 }} />
      <div
        style={{
          textAlign: 'center',
          fontSize: 14,
          color: sub,
          letterSpacing: '-0.005em',
        }}
      >
        ¿Ya tienes cuenta?{' '}
        <span style={{ color: link, fontWeight: 700, cursor: 'pointer' }}>
          Inicia sesión
        </span>
      </div>
    </div>
  );
}

// ───────────────────────────────────────────────────────────
// Signup artboard wrapper
// ───────────────────────────────────────────────────────────
function SignUpFrame({ dark }) {
  return (
    <IOSDevice width={390} height={844} dark={dark}>
      <SignUpContent dark={dark} />
    </IOSDevice>
  );
}

// Expose globally so splash.jsx App() can reach it
window.SignUpFrame = SignUpFrame;
