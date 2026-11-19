# PetCare Flutter — Sign up, Sign in, Inicio, diseño adaptable y accesibilidad (Persona A)

## 1. Información general

- **Responsable:** Josue Fernando Palma Zambrano (Persona A)
- **Rama de trabajo:** `feature/persona-a-auth-inicio`, creada desde `main` cuando Dumar avise que el Paso 0 está listo
- **Módulo:** pantallas de registro e inicio de sesión, pantalla de Inicio, diseño adaptable y revisión de accesibilidad

Este documento detalla tu parte del [plan técnico](plan-tecnico-implementacion.md). Lee primero el plan: aquí no se repiten el modelo de datos ni las reglas de arquitectura.

**Estado:** nada implementado todavía. Ve llenando la tabla de la sección 8 a medida que avances.

## 2. Qué te toca construir

- **Iniciar sesión** (`/sign-in`): correo, contraseña, botón "Iniciar sesión" y enlace a registrarse.
- **Registrarse** (`/sign-up`): correo, contraseña, confirmación de contraseña, botón "Crear cuenta" y enlace para volver.
- **Inicio** (`/inicio`): cuántas mascotas tiene el usuario, accesos a "Mis mascotas" y "Registrar mascota", y un enlace al catálogo de tipos de cuidado.
- **Diseño adaptable** (extra, +0.4): en horizontal o en pantallas anchas, barra lateral en vez de barra inferior, y contenido en dos columnas donde tenga sentido.
- **Accesibilidad** (extra, +0.3): revisión de todas las pantallas al final, cuando las demás ramas estén fusionadas.
- **Pruebas** de `SignInViewModel`.

## 3. Archivos

Todos son tuyos y nuevos, salvo el último.

- `lib/features/auth/presentation/sign_in_screen.dart`
- `lib/features/auth/presentation/sign_in_view_model.dart`
- `lib/features/auth/presentation/sign_up_screen.dart`
- `lib/features/auth/presentation/sign_up_view_model.dart`
- `lib/features/inicio/presentation/inicio_screen.dart`
- `lib/features/inicio/presentation/inicio_view_model.dart`
- `test/features/auth/sign_in_view_model_test.dart`
- `lib/core/router/app_router.dart` (de Dumar): solo para cambiar tus tres pantallas provisionales por las reales y para la barra lateral. Avísale antes.

## 4. Contratos que usas

No escribes repositorios; usas los que ya existen.

| Contrato | Método | Para qué |
|---|---|---|
| `AuthRepository` | `iniciarSesion(correo, contrasena)` | Sign in |
| `AuthRepository` | `registrar(correo, contrasena)` | Sign up |
| `MascotaRepository` | `obtenerMascotas()` | Contar las mascotas en Inicio |

Los tres lanzan un `Fallo` con un mensaje en español cuando algo sale mal.

## 5. Puntos clave

### Sign in y Sign up

- Cada ViewModel guarda tres cosas: los errores de cada campo, si está enviando, y el mensaje de error general. La pantalla solo las lee.
- Validaciones, antes de llamar al repositorio:
  - correo no vacío y con forma de correo;
  - contraseña de 6 o más caracteres;
  - en Sign up, la confirmación debe ser igual a la contraseña.
- Mientras se envía, el botón se desactiva y muestra un indicador de progreso.
- Si el repositorio lanza un `Fallo`, se muestra `f.mensaje` y el usuario puede volver a intentar sin perder lo que escribió.
- **No navegues a `/inicio` después de iniciar sesión.** Cuando la sesión cambia, el router lleva solo a Inicio. Si navegas a mano, la pantalla se abre dos veces.
- El registro deja al usuario con la sesión iniciada (la confirmación por correo está desactivada), así que también entra directo.
- El campo de contraseña lleva un botón para mostrarla u ocultarla.

### Inicio

- `InicioViewModel` expone un `EstadoCarga<int>` con el número de mascotas.
  - `Cargando`: indicador de progreso.
  - `Datos`: el número y los accesos.
  - `Vacio` (cero mascotas): mensaje de bienvenida y botón "Registrar mi primera mascota".
  - `ErrorCarga`: `VistaError` con "Reintentar".
- Mientras Marcelo no fusione su repositorio, `obtenerMascotas()` falla y verás el estado de error. Es lo esperado; prueba los demás estados con un repositorio simulado en las pruebas.
- Al volver a Inicio desde otra pestaña el número puede estar desactualizado. Vuelve a cargar cuando la pantalla se muestre de nuevo.

### Diseño adaptable

- Decide según el ancho disponible, no según la orientación: 600 puntos o más cuenta como pantalla ancha. Un teléfono en horizontal ya supera ese ancho.
- En pantalla ancha: `NavigationRail` a la izquierda en lugar de `NavigationBar` abajo. Va en el widget de pestañas de `app_router.dart`.
- Formularios: limita el ancho (unos 480 puntos) y céntralos, para que no se estiren.
- Inicio y detalle de mascota son buenos candidatos para dos columnas.
- Todas las pantallas con formulario deben poder desplazarse: en horizontal, el teclado tapa casi todo.

### Accesibilidad

Revisa en cada pantalla:

- Los botones que son solo un icono tienen `tooltip`.
- Las fotos y los iconos con significado tienen `semanticLabel`.
- Nada que se pueda tocar mide menos de 48 × 48.
- Con el tamaño de letra del sistema al máximo, nada se corta ni se desborda.
- El texto contrasta con el fondo en tema claro y en oscuro.
- Los errores de formulario se muestran con texto, no solo con color.

Prueba con TalkBack activado en el emulador al menos el flujo de Sign in y registrar una mascota.

## 6. Integración con el equipo

- **Dumar (D):** dueño del router y de `SesionViewModel`. La barra lateral toca su archivo; coordinen para no editarlo a la vez.
- **Marcelo (B) y Yimmi (C):** la revisión de diseño adaptable y accesibilidad toca sus pantallas. Hazla después de que fusionen, en una rama aparte (`feature/persona-a-adaptable-accesibilidad`), y avísales qué archivos vas a cambiar.

## 7. Pruebas

`SignInViewModel` con un `AuthRepository` simulado con `mocktail`:

1. Correo vacío o con mala forma: muestra el error del campo y no llama al repositorio.
2. Contraseña de menos de 6 caracteres: muestra el error y no llama al repositorio.
3. Datos válidos: llama a `iniciarSesion` una vez con el correo y la contraseña.
4. El repositorio lanza `FalloSesion`: el mensaje queda en el estado y deja de estar enviando.

Manual, en el emulador:

1. Registrarse con un correo nuevo y entrar a Inicio.
2. Registrarse con un correo que ya existe y ver el mensaje de error.
3. Iniciar sesión con una contraseña incorrecta y ver el mensaje de error.
4. Activar el modo avión, intentar iniciar sesión y ver el error de conexión; quitarlo y volver a intentar.
5. Girar el teléfono en cada una de tus pantallas.

## 8. Estado de verificación

| Verificación | Estado |
|---|---|
| `flutter analyze` sin errores | Pendiente |
| `flutter test` en verde | Pendiente |
| Sign up con correo nuevo entra a Inicio | Pendiente |
| Sign in correcto entra a Inicio | Pendiente |
| Validaciones de correo, contraseña y confirmación | Pendiente |
| Mensajes de error con credenciales incorrectas y sin conexión | Pendiente |
| Inicio muestra el conteo real de mascotas | Pendiente (depende de B) |
| Inicio: estados cargando, vacío y error con "Reintentar" | Pendiente |
| Barra lateral en pantalla ancha | Pendiente |
| Ninguna pantalla se desborda al girar | Pendiente (depende de B y C) |
| Revisión de accesibilidad de toda la app | Pendiente (depende de B y C) |
