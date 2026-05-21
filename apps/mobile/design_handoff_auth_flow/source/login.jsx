// BetterLife — Login screen
// Email + password only. Same field components as signup for consistency.

function LoginContent({ dark }) {
  const [email, setEmail] = React.useState('');
  const [pw, setPw] = React.useState('');
  const [showPw, setShowPw] = React.useState(false);
  const [touched, setTouched] = React.useState({ email: false, pw: false });

  const emailOk = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  const pwOk = pw.length >= 6;
  const formOk = emailOk && pwOk;

  const bg = dark
    ? `radial-gradient(120% 80% at 50% 0%, #1F1E2C 0%, ${BL.bgDarkDeep} 60%)`
    : `radial-gradient(120% 80% at 50% 0%, #FFFFFF 0%, ${BL.bgLightWarm} 100%)`;

  const heading = dark ? '#F0EFFA' : BL.lav5;
  const sub = dark ? 'rgba(232,231,245,0.55)' : 'rgba(67,67,82,0.6)';
  const link = dark ? BL.lav1 : BL.lav4;
  const divider = dark ? 'rgba(198,198,240,0.08)' : 'rgba(67,67,82,0.08)';
  const eyeColor = dark ? 'rgba(232,231,245,0.55)' : 'rgba(100,100,122,0.65)';

  return (
    <div
      data-screen-label={dark ? 'Login · Dark' : 'Login · Light'}
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
      <div style={{ marginBottom: 36 }}>
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
          Bienvenido de vuelta
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
          Continuemos donde lo dejaste.
        </p>
      </div>

      {/* fields */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 18 }}>
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
        <Field
          icon={Icon.lock}
          label="Contraseña"
          placeholder="Tu contraseña"
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
      </div>

      {/* forgot password */}
      <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: 14, marginBottom: 28 }}>
        <span
          style={{
            fontSize: 13,
            color: link,
            fontWeight: 600,
            cursor: 'pointer',
            letterSpacing: '-0.005em',
          }}
        >
          ¿Olvidaste tu contraseña?
        </span>
      </div>

      {/* CTA */}
      <PrimaryBtn dark={dark} disabled={!formOk}>
        Iniciar sesión
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
        ¿No tienes cuenta?{' '}
        <span style={{ color: link, fontWeight: 700, cursor: 'pointer' }}>
          Regístrate
        </span>
      </div>
    </div>
  );
}

function LoginFrame({ dark }) {
  return (
    <IOSDevice width={390} height={844} dark={dark}>
      <LoginContent dark={dark} />
    </IOSDevice>
  );
}

window.LoginFrame = LoginFrame;
