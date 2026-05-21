# BetterLife — Auth Flow Handoff (Splash · Sign Up · Login)

> Paquete de entrega para implementar las pantallas de autenticación de **BetterLife** en Flutter usando Claude Code (o cualquier agente/desarrollador).

---

## ⚠️ Importante: sobre los archivos de diseño

Los archivos en `source/` son **prototipos en HTML/React** — referencias visuales que muestran la apariencia y el comportamiento esperado, **NO código de producción para copiar directamente**.

La tarea es **recrear estos diseños en Flutter** (en el codebase existente del proyecto, siguiendo sus patrones y librerías ya establecidas). Si el proyecto está vacío, usa `flutter_lints`, Material 3 y `flutter_svg`.

---

## Overview

Flujo de entrada de la app **BetterLife** (app de hábitos y bienestar). Tres pantallas:

1. **Splash** — animación de entrada con logo, halo pulsante, partículas, wordmark y loader.
2. **Sign Up** — registro con nombre, email y contraseña (con medidor de fuerza).
3. **Login** — inicio de sesión con email y contraseña.

Cada pantalla soporta **modo claro y modo oscuro** nativamente, controlado por el `Brightness` del sistema.

---

## Fidelidad

**High-fidelity (hifi)**. Los colores, tipografía, espaciado, radios, animaciones e interacciones son finales y deben replicarse con precisión. Las copias en español son las definitivas (ajusta solo si el equipo de producto las cambia).

---

## Stack recomendado en Flutter

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_svg: ^2.0.0      # para el logo SVG
  google_fonts: ^6.0.0     # opcional, si no se empaqueta la fuente

flutter:
  uses-material-design: true
  fonts:
    - family: PlusJakartaSans
      fonts:
        - asset: assets/fonts/PlusJakartaSans-Regular.ttf
        - asset: assets/fonts/PlusJakartaSans-Medium.ttf
          weight: 500
        - asset: assets/fonts/PlusJakartaSans-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/PlusJakartaSans-Bold.ttf
          weight: 700
        - asset: assets/fonts/PlusJakartaSans-ExtraBold.ttf
          weight: 800
  assets:
    - assets/images/betterlife_logo.svg
```

> Descargar Plus Jakarta Sans desde Google Fonts (Apache 2.0). Si se usa `google_fonts`, no es necesario empaquetar los `.ttf`.

---

## Tokens de diseño

Dos formatos provistos en `tokens/`:

- **`tokens.json`** — fuente de verdad, multiplataforma.
- **`bl_tokens.dart`** — clases listas (`BLColors`, `BLType`, `BLSpacing`, `BLRadius`, `BLAnim`) para importar directamente.

### Paleta (de la referencia Adobe Color del cliente)

| Token            | Hex        | Uso                                     |
|------------------|------------|-----------------------------------------|
| `lavender-100`   | `#C6C6F0`  | Logo claro, halo dark, CTA dark         |
| `lavender-200`   | `#A7A7CC`  | Logo medio, "Life" en wordmark          |
| `lavender-300`   | `#8686A3`  | Logo oscuro                             |
| `lavender-400`   | `#64647A`  | Iconos focus light, border focus light  |
| `lavender-500`   | `#434352`  | Texto principal light, CTA light        |
| `danger`         | `#E26B7C`  | Errores de validación                   |
| `warning`        | `#D9A95B`  | Medidor de fuerza nivel 2               |

### Fondos

- **Light**: gradiente radial `#FFFFFF` (top) → `#F4F2F8` (bottom).
- **Dark**: gradiente radial `#1F1E2C` (top center) → `#0E0D16` (bottom).

### Tipografía

- **Fuente**: Plus Jakarta Sans (fallback: Inter, system-ui).
- Pesos usados: 400, 500, 600, 700, 800.
- Tracking negativo (-0.03em a -0.005em) para títulos y cuerpo. Tracking positivo amplio (0.14em a 0.32em) para labels en mayúsculas.

Ver `bl_tokens.dart › BLType` para los `TextStyle` exactos en Flutter.

### Radius / Spacing / Animación

Todo definido en `tokens/tokens.json` y `tokens/bl_tokens.dart`.

---

## Pantallas

### 1. Splash (`SplashScreen`)

**Propósito**: pantalla de carga con identidad de marca; dura ~2.5s o hasta que termine la inicialización (lo que tome más).

**Layout**:
- Stack a pantalla completa con gradiente radial de fondo.
- Centro vertical: logo (170×170) con halo de 3 anillos concéntricos pulsantes detrás, debajo el wordmark (40px), debajo la tagline.
- Footer: loader indeterminado (120×3, pill).
- 10 puntos decorativos esparcidos en posiciones porcentuales fijas, con pulse de opacidad escalonado.

**Animaciones** (ver `BLAnim`):
| Elemento       | Duración | Delay | Easing                            | Comportamiento                              |
|----------------|----------|-------|-----------------------------------|---------------------------------------------|
| Logo entry     | 1100 ms  | 0     | `Cubic(0.2, 0.9, 0.25, 1)`        | Scale 0.6→1, translateY 20→0, blur 8→0, opacity 0→1 |
| Check draw     | 700 ms   | 400ms | `Cubic(0.2, 0.7, 0.2, 1)`         | Stroke dashoffset 160→0 (`AnimatedDrawablePainter` o `flutter_svg` + animación) |
| Wordmark in    | 900 ms   | 350ms | `Cubic(0.2, 0.9, 0.25, 1)`        | TranslateY 14→0, opacity 0→1, tracking 0.02em→-0.02em |
| Tagline in     | 700 ms   | 650ms | `Curves.ease`                     | TranslateY 6→0, opacity 0→1                 |
| Particles      | 2400 ms  | 600ms (escalonado por 80ms) | `Curves.easeInOut` | Loop infinito: translate (0,0)→(18,-22), scale 1→0.4, fade |
| Halo (3 anillos) | 4400 ms | 600ms (escalonado por 1100ms) | `Curves.easeOut` | Loop: scale 0.6→1.6, opacity 0.5→0 |
| Loader bar     | 1600 ms  | 900ms (start) | `Cubic(0.4, 0, 0.2, 1)`     | Loop: translateX -110%→310% sobre el track  |

**Implementación Flutter**:
- Usa `flutter_svg` para renderizar `betterlife_logo.svg` y anima el `Stack` completo con `AnimationController`s.
- Alternativamente: convierte el logo a un `CustomPainter` (más control sobre el dibujado del check con `PathMetrics`).

### 2. Sign Up (`SignUpScreen`)

**Layout** (top → bottom, padding `28px` horizontal, `54px` top, `40px` bottom):
1. **Top row** — botón "atrás" 40×40 (border 12) + mini logo 32×32.
2. **Heading** — "Crea tu cuenta" (h1) + "Empieza tu camino hacia mejores hábitos." (body muted). Margen inferior 32.
3. **Form** — 3 campos con `gap: 18`:
   - Nombre — icono `user`, placeholder "Tu nombre".
   - Email — icono `mail`, placeholder "tucorreo@ejemplo.com", teclado `email`.
   - Contraseña — icono `lock`, trailing toggle ojo/ojo-tachado, placeholder "Mínimo 8 caracteres". Debajo: **medidor de fuerza** (4 barras + label) que aparece cuando hay texto.
4. **Términos** — caption centrado: "Al continuar, aceptas nuestros [Términos] y [Política de privacidad]." (links lavanda 600).
5. **CTA** — botón primario "Crear cuenta" (54px alto, full-width). Deshabilitado hasta validar el form.
6. **Footer** — "¿Ya tienes cuenta? [Inicia sesión]" centrado.

**Validación en vivo**:
| Campo      | Regla                                     | Mensaje de error      |
|------------|-------------------------------------------|-----------------------|
| Nombre     | `trim().length >= 2`                      | "Demasiado corto"     |
| Email      | `^[^\s@]+@[^\s@]+\.[^\s@]+$`              | "Correo no válido"    |
| Contraseña | score de fuerza ≥ 2                       | (sin mensaje, solo deshabilita) |

**Reglas del medidor de fuerza** (`strengthOf`):
- `length >= 8` → +1
- `[A-Z]` → +1
- `[0-9]` → +1
- `[^A-Za-z0-9]` → +1
- `length >= 12` → +1 (cap a 4)

Labels: `["", "Débil", "Aceptable", "Buena", "Excelente"]`.

**Estados del campo**:
- **Idle**: borde `border` (10% opacity), sin sombra.
- **Focus**: borde `border-focus` + `box-shadow: 0 0 0 4px focus-ring`. Transición 180ms.
- **Error**: borde `#E26B7C` siempre (incluso sin focus). Mensaje debajo en 12px.
- **Válido**: badge circular 20×20 (color `primary-bg`) con check blanco al final del row.

### 3. Login (`LoginScreen`)

Mismo layout que Sign Up pero con:
- Heading "Bienvenido de vuelta" / "Continuemos donde lo dejaste."
- Solo 2 campos: Email + Contraseña.
- Link "**¿Olvidaste tu contraseña?**" alineado a la derecha entre el form y el CTA.
- CTA "Iniciar sesión", deshabilitado hasta que `emailOk && password.length >= 6`.
- Footer "¿No tienes cuenta? [Regístrate]".

---

## Componentes reutilizables (sugerencia de arquitectura)

```
lib/
  features/
    auth/
      presentation/
        screens/
          splash_screen.dart
          signup_screen.dart
          login_screen.dart
        widgets/
          bl_text_field.dart       // Field con icon, label, focus state, valid badge, error
          bl_primary_button.dart   // PrimaryBtn (54h, disabled state, hover lift en web)
          bl_mini_logo.dart        // logo 32px en headers
          bl_animated_logo.dart    // logo 170px con todas las animaciones de splash
          bl_strength_meter.dart   // 4 barras + label
          bl_loader_bar.dart       // 120×3 con indicador deslizante
          bl_back_button.dart      // 40×40 cuadrado redondeado
  core/
    theme/
      bl_tokens.dart               // (provisto)
      bl_theme.dart                // construye ThemeData light/dark a partir de tokens
```

---

## Interacciones & comportamiento

| Acción                       | Resultado                                                  |
|------------------------------|------------------------------------------------------------|
| Splash termina               | Navegar a Login (o Home si hay sesión activa)              |
| Tap "atrás" en Sign Up/Login | `Navigator.pop` o regresar a la pantalla anterior          |
| Tap ojito en contraseña      | Toggle `obscureText`                                       |
| Submit Sign Up exitoso       | Llamar API → navegar a Onboarding o Home                   |
| Submit Login exitoso         | Llamar API → navegar a Home                                |
| Tap "Términos"               | Abrir WebView o pantalla legal                             |
| Tap "Olvidaste tu contraseña"| Navegar a Reset Password (no incluido en este handoff)     |
| Tap "Regístrate" / "Inicia sesión" en footer | Navegar a la pantalla contraria          |

**Comportamiento del teclado**: la pantalla debe hacer scroll cuando el teclado aparece (`SingleChildScrollView` o `resizeToAvoidBottomInset: true`).

---

## State management

Cada pantalla maneja estado local de formulario. Para Flutter:

- Si el proyecto usa **Riverpod**: crea `signUpFormProvider` y `loginFormProvider` con `StateNotifier` que expongan `{name, email, password, showPassword, touched, isValid}`.
- Si usa **Bloc**: `SignUpFormBloc` / `LoginFormBloc` con eventos `NameChanged`, `EmailChanged`, etc.
- Si no hay state mgmt aún: `StatefulWidget` con `TextEditingController`s es suficiente.

Para llamadas a API (sign up / login): es responsabilidad del codebase. Mostrar `CircularProgressIndicator` en el CTA durante `isSubmitting` y deshabilitar el botón.

---

## Assets

| Archivo                                | Origen                              | Uso                       |
|----------------------------------------|-------------------------------------|---------------------------|
| `assets/betterlife_logo.svg`           | Logo trazado en SVG (limpio, sin raster) | Logo en splash + mini logo |
| `assets/betterlife_logo.png`           | Referencia original del cliente (1024×1536) | Referencia visual          |

> **Nota**: el SVG es una reconstrucción simplificada del logo del cliente. Si el cliente tiene un SVG oficial, sustitúyelo y descarta éste.

---

## Archivos en este paquete

```
design_handoff_auth_flow/
├── README.md                          ← este archivo
├── tokens/
│   ├── tokens.json                    ← tokens en JSON (fuente de verdad)
│   └── bl_tokens.dart                 ← tokens listos para importar en Flutter
├── assets/
│   ├── betterlife_logo.svg            ← logo vectorial limpio
│   └── betterlife_logo.png            ← referencia raster original
└── source/                            ← prototipos HTML (referencia, NO copiar)
    ├── BetterLife Splash.html         ← entrada — abre en navegador para ver el flujo completo
    ├── splash.jsx                     ← componente splash
    ├── signup.jsx                     ← componente sign up
    ├── login.jsx                      ← componente login
    └── components/
        ├── ios-frame.jsx              ← marco iPhone (solo demo, ignorar)
        └── design-canvas.jsx          ← canvas multi-pantalla (solo demo, ignorar)
```

Para previsualizar los diseños, abre `source/BetterLife Splash.html` en un navegador. Verás las 6 vistas (3 pantallas × 2 modos) en un canvas con zoom/pan; doble-click sobre cualquiera para verla en grande.

---

## Checklist de implementación

- [ ] Añadir `flutter_svg` y registrar la fuente Plus Jakarta Sans en `pubspec.yaml`.
- [ ] Copiar `tokens/bl_tokens.dart` a `lib/core/theme/`.
- [ ] Crear `BLTheme.light` y `BLTheme.dark` (`ThemeData`) usando los tokens.
- [ ] Implementar widgets reutilizables (`BLTextField`, `BLPrimaryButton`, `BLMiniLogo`, `BLAnimatedLogo`, `BLStrengthMeter`, `BLLoaderBar`).
- [ ] Implementar las 3 pantallas usando los widgets.
- [ ] Conectar con el servicio de autenticación del proyecto.
- [ ] Probar light + dark en iPhone SE, iPhone 14 Pro y Pixel 7 (verificar safe areas).
- [ ] Verificar comportamiento con teclado abierto.
- [ ] Validar accesibilidad: `Semantics` labels, contraste AA en ambos modos, hit targets ≥44px.
