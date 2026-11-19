# PetCare Flutter — Proyecto base, navegación, sesión y Ajustes (Persona D)

## 1. Información general

- **Responsable:** Dumar Abdul Matamoros Pluas (Persona D)
- **Ramas:** el Paso 0 va directo a `main` (todavía no hay nadie más trabajando); Ajustes va en `feature/persona-d-ajustes`
- **Módulo:** todo `core/`, contratos y modelos de `domain/`, `features/auth` (datos y sesión), router, Provider y `features/ajustes`

Este documento detalla la parte de Persona D del [plan técnico](plan-tecnico-implementacion.md). Lo que no aparece aquí (modelo de datos, reglas de arquitectura, forma de trabajo) está en el plan y no se repite.

**Estado:** Paso 0 fusionado en `main`. Ajustes (Paso 1) en revisión en el [PR #1](https://github.com/DumarMatamoros/PetCare-Flutter/pull/1). Falta la prueba manual en el emulador (sección 8).

## 2. Qué hay que construir

### Paso 0 — Base compartida (bloquea a los demás)

- Dependencias en `pubspec.yaml`: `supabase_flutter`, `go_router`, `provider`, `flutter_secure_storage`, `shared_preferences`, `image_picker` y, para pruebas, `mocktail`.
- Proyecto Supabase: ejecutar el esquema SQL del plan, crear el bucket `fotos-mascotas`, desactivar "Confirm email" e invitar a los otros tres.
- `env.ejemplo.json` en el repo y `env.json` en `.gitignore`.
- Todo `core/`: configuración, fallos, `EstadoCarga`, router, almacén de sesión, tema y los widgets de error y vacío.
- Los cinco contratos de repositorio y los modelos `Usuario`, `Mascota`, `TipoCuidado`, `Cuidado` y `Preferencias`.
- `features/auth`: `AuthService`, `AuthRepositoryImpl` y `SesionViewModel`.
- `app_router.dart` con las diez rutas y una pantalla provisional en cada una.
- `app.dart` con el `MultiProvider`.
- Aviso al grupo cuando `main` compile y se pueda iniciar sesión contra Supabase.

### Paso 1 — Ajustes

- `PreferenciasRepositoryImpl` sobre `shared_preferences`.
- `AjustesViewModel` global y `AjustesScreen`: tema, orden de mascotas, orden del historial y botón "Cerrar sesión".
- Pruebas de `SesionViewModel` y del `redirect`.
- Apoyo a la integración de las otras tres ramas.

## 3. Archivos

### Raíz y configuración

- `lib/main.dart`: `Supabase.initialize(...)` con `AlmacenSesionSeguro` y `runApp`.
- `lib/app.dart`: `MultiProvider` + `MaterialApp.router`.
- `env.ejemplo.json`: `{"SUPABASE_URL": "", "SUPABASE_ANON_KEY": ""}`.
- `supabase/esquema.sql`: copia del SQL del plan.

### `lib/core/`

- `config/entorno.dart`: lee `SUPABASE_URL` y `SUPABASE_ANON_KEY` con `String.fromEnvironment`.
- `errores/fallo.dart`: `Fallo` con `mensaje`, y sus subclases `FalloRed`, `FalloSesion` y `FalloServidor`.
- `estado/estado_carga.dart`: `Cargando`, `Datos`, `Vacio`, `ErrorCarga`.
- `router/app_router.dart`: `GoRouter`, `redirect` y el `StatefulShellRoute` de las tres pestañas.
- `router/pantallas_provisionales.dart`: un `Scaffold` con el nombre de la ruta. Cada persona cambia la suya por la real; el archivo se borra cuando no quede ninguna.
- `sesion/almacen_sesion_seguro.dart`: implementa `LocalStorage` del SDK con `flutter_secure_storage`.
- `tema/`: colores y tipografía, claro y oscuro.
- `widgets/vista_error.dart` y `widgets/vista_vacia.dart`: mensaje + botón "Reintentar", y mensaje + acción opcional.

### `lib/features/`

- `auth/domain/`: `auth_repository.dart`, `usuario.dart`.
- `auth/data/`: `auth_service.dart`, `auth_repository_impl.dart`.
- `auth/presentation/sesion_view_model.dart`.
- `mascotas/domain/`: `mascota.dart`, `mascota_repository.dart`.
- `tipos_cuidado/domain/`: `tipo_cuidado.dart`, `tipo_cuidado_repository.dart`.
- `cuidados/domain/`: `cuidado.dart`, `cuidado_repository.dart`.
- `ajustes/domain/`: `preferencias.dart`, `preferencias_repository.dart`.
- `ajustes/data/preferencias_repository_impl.dart`.
- `ajustes/presentation/`: `ajustes_view_model.dart`, `ajustes_screen.dart`.

### Pruebas

- `test/features/auth/sesion_view_model_test.dart`
- `test/core/router/redirect_test.dart`

## 4. Modelos que usan todos

| Modelo | Campos |
|---|---|
| `Usuario` | `id: String`, `correo: String` |
| `Mascota` | `id: int?`, `nombre`, `especie`, `raza`, `fechaNacimiento: DateTime?`, `sexo`, `pesoKg: double?`, `fotoPath: String?` |
| `TipoCuidado` | `id: int`, `nombre: String` |
| `Cuidado` | `id: int?`, `mascotaId: int`, `tipoCuidadoId: int`, `tipoNombre: String`, `fecha: DateTime`, `notas: String?` |
| `Preferencias` | `tema: Tema`, `ordenMascotas: OrdenMascotas`, `ordenHistorial: OrdenHistorial` |

- `id` es `null` mientras el registro no se ha guardado; Supabase lo genera.
- `usuario_id` no aparece en los modelos: la base lo rellena sola con `auth.uid()`.
- Cada modelo lleva `fromMap` y `toMap` para convertir entre los nombres de Dart (`pesoKg`) y los de la tabla (`peso_kg`).
- Los enums son los de la app nativa: `Tema { claro, oscuro }`, `OrdenMascotas { nombre, masReciente }`, `OrdenHistorial { masReciente, masAntiguo }`.

## 5. Puntos clave

- **Sesión.** `SesionViewModel` se suscribe a `cambiosDeSesion` y llama a `notifyListeners()` en cada cambio. El router lo usa como `refreshListenable`, así que nadie navega a mano después de iniciar o cerrar sesión.
- **`redirect` en una función aparte.** Una función `String? redirigir({required bool haySesion, required String ruta})` se puede probar sin montar widgets.
- **Orden de las rutas.** `/mascotas/nueva` se declara antes que `/mascotas/:id`; si no, `nueva` se interpreta como un id.
- **Parámetros.** El router convierte `:id` a `int` y lo entrega al ViewModel al crearlo. Las pantallas no leen parámetros de la ruta.
- **Fallos.** `AuthRepositoryImpl` convierte `AuthException` en `FalloSesion` y los errores de red en `FalloRed`, con mensajes en español ("Correo o contraseña incorrectos", "Sin conexión a internet"). Sirve de ejemplo para los `RepositorioImpl` de B y C.
- **Ajustes.** `AjustesViewModel` es global porque `MaterialApp` lee el tema, y las listas de B y C leen el orden. Si un valor guardado no coincide con ninguna opción, se usa el valor por defecto.
- **Cerrar sesión** no borra las preferencias: tema y orden son del teléfono, no de la cuenta.

## 6. Integración con el equipo

- **Persona A (Josue):** usa `AuthRepository` para registrar e iniciar sesión. La barra lateral para pantallas anchas se hace en el widget de pestañas de `app_router.dart`; avisar antes de tocarlo.
- **Persona B (Marcelo):** implementa `MascotaRepository` y lo registra en `app.dart` en lugar del provisional. Lee `ordenMascotas` de `AjustesViewModel`.
- **Persona C (Yimmi):** implementa `TipoCuidadoRepository` y `CuidadoRepository`. Lee `ordenHistorial` de `AjustesViewModel`.
- Mientras B y C no fusionen sus implementaciones, `app.dart` registra repositorios provisionales que lanzan `FalloServidor('Pendiente')`, para que la app compile y arranque.

## 7. Pruebas

Con `mocktail`:

1. `SesionViewModel`: sin usuario, `haySesion` es falso; cuando el stream emite un usuario pasa a verdadero y notifica; cuando emite `null` vuelve a falso.
2. `redirigir`: sin sesión, `/mascotas` devuelve `/sign-in`; con sesión, `/sign-in` y `/sign-up` devuelven `/inicio`; con sesión, `/mascotas` devuelve `null`.

Manual, antes de avisar al grupo: registrar una cuenta desde una pantalla provisional o desde el panel de Supabase, iniciar sesión, cerrar la app y comprobar que al reabrirla sigue la sesión.

## 8. Estado de verificación

| Verificación | Estado |
|---|---|
| `flutter analyze` sin errores | Hecho |
| `flutter test` en verde | Hecho: 22 pruebas (`SesionViewModel`, `redirigir`, `AjustesViewModel`, `PreferenciasRepositoryImpl`) |
| Esquema SQL ejecutado y bucket creado | Hecho: las tres tablas responden y RLS oculta los datos sin sesión. Confirmar que se aplicó en Supabase la corrección de la política `cuidados propios` (ver `supabase/esquema.sql`) |
| Equipo invitado al proyecto Supabase y al repositorio | Repositorio: hecho (Josue, Marcelo y Yimmi son colaboradores). Supabase: por confirmar |
| La app arranca con `env.json` y conecta con Supabase | Parcial: el APK compila y Supabase responde con las claves de `env.json`; falta abrirla en el emulador |
| Las diez rutas abren su pantalla provisional | Pendiente (prueba manual) |
| Sin sesión, las rutas protegidas llevan a `/sign-in` | Parcial: cubierto por las pruebas de `redirigir`; falta comprobarlo en el emulador |
| La sesión se restaura al reabrir la app | Pendiente (prueba manual) |
| Ajustes: tema y órdenes se guardan y se aplican | Parcial: cubierto por las pruebas; falta comprobarlo en el emulador |
| Cerrar sesión vuelve a `/sign-in` | Pendiente (prueba manual) |
