# Plan técnico — PetCare en Flutter con Supabase

Este documento es el punto de partida del equipo para el trabajo autónomo "Desarrollo de una aplicación Android con Flutter y datos remotos". Explica qué vamos a construir, cómo se organiza el código, qué le toca a cada persona y en qué orden se integra. Cada persona tendrá además su propio documento `docs/PERSONA_X_*.md` con el detalle de su módulo.

## Equipo

| Persona | Integrante | Módulo |
|---|---|---|
| A | Josue Fernando Palma Zambrano | Sign up, Sign in, Inicio, diseño adaptable y accesibilidad |
| B | Marcelo Matias Nieto Medina | Mascotas: lista, búsqueda, formulario y foto |
| C | Yimmi Leonel Barberan Moreira | Tipos de cuidado, detalle de mascota y cuidados |
| D | Dumar Abdul Matamoros Pluas | Proyecto base, navegación, sesión, inyección con Provider y Ajustes |

Las letras no son las mismas de la app nativa: allá A era Marcelo y B era Josue.

## Qué construimos

PetCare es la misma app de la primera entrega (llevar el registro de cuidados de tus mascotas), pero ahora:

- Está hecha con Flutter y Dart, solo para Android.
- Tiene cuentas de usuario: cada quien se registra, inicia sesión y ve solo sus mascotas.
- Los datos viven en Supabase (un servicio en la nube con base de datos Postgres, autenticación y almacenamiento de archivos). No hay base de datos local: sin conexión la app avisa del fallo y ofrece reintentar.

### Qué cambia respecto a la app nativa

| Tema | App nativa (Kotlin) | App Flutter |
|---|---|---|
| Datos | Room, funcionaba sin conexión | Supabase; requiere conexión |
| Sesión | No había | Sign up, Sign in, cerrar sesión, restaurar sesión |
| Navegación | Navigation Compose | `go_router` con rutas protegidas |
| Estado | `StateFlow` + Hilt | `ChangeNotifier` + `provider` |
| Ajustes | DataStore | `shared_preferences` (solo tema y orden de listas) |
| Foto de mascota | Archivo en el teléfono | Archivo en Supabase Storage |
| Tipos de cuidado | Solo un desplegable | Además, una pantalla de catálogo |

### Fuera de alcance

- Base de datos local, caché en disco o sincronización diferida (el enunciado lo prohíbe).
- Editar un cuidado ya registrado: se registra, se consulta y se elimina.
- Que el usuario cree sus propios tipos de cuidado: el catálogo es fijo.
- iOS, web y escritorio.

## Cómo esto cubre la rúbrica

| Criterio | Puntos | Cómo se cubre |
|---|---|---|
| 1. Interfaz y navegación | 1.5 | Pantallas con widgets Material 3; `go_router` con parámetros (`/mascotas/:id`) y `redirect` que bloquea las rutas sin sesión |
| 2. Autenticación y sesión | 2.0 | Supabase Auth con correo y contraseña; cerrar sesión; la sesión se guarda en `flutter_secure_storage` |
| 3. Datos remotos y modelo | 2.5 | `mascotas` y `tipos_cuidado` (maestras), `cuidados` (transaccional, relacionada con ambas); todo se lee y escribe en Supabase |
| 4. Clean Architecture, MVVM, Repository | 2.0 | Carpetas por funcionalidad con `presentation`, `domain` y `data`; el ViewModel solo conoce el contrato del repositorio |
| 5. Estado, validación y errores | 1.0 | `EstadoCarga` con cargando, datos, vacío y error; botón "Reintentar"; validación en formularios |
| 6. Documento y demostración | 1.0 | Este plan, los documentos por persona y el guion de la demo |
| Extra: diseño adaptable | +0.4 | Barra lateral y dos columnas en horizontal o pantallas anchas |
| Extra: pruebas | +0.3 | Pruebas de ViewModels con `flutter_test` y `mocktail` |
| Extra: accesibilidad | +0.3 | Etiquetas, contraste y tamaños de toque revisados en las pantallas principales |

## Modelo de datos

```
auth.users (lo maneja Supabase)
    │ 1
    │ N
mascotas ──────────┐
    │ 1            │
    │ N            │
cuidados  N ── 1  tipos_cuidado
```

- `mascotas` (maestra): `id`, `usuario_id`, `nombre`, `especie`, `raza`, `fecha_nacimiento`, `sexo`, `peso_kg`, `foto_path`.
- `tipos_cuidado` (maestra): `id`, `nombre`. Cuatro filas fijas: Vacunación, Baño, Desparasitación, Visita veterinaria.
- `cuidados` (transaccional): `id`, `usuario_id`, `mascota_id`, `tipo_cuidado_id`, `fecha`, `notas`.

Al eliminar una mascota se eliminan sus cuidados (`on delete cascade`), igual que en la app nativa.

### Esquema SQL

Dumar lo ejecuta una sola vez en el editor SQL de Supabase y lo guarda en `supabase/esquema.sql` para que quede versionado.

```sql
create table mascotas (
  id bigint generated always as identity primary key,
  usuario_id uuid not null default auth.uid() references auth.users on delete cascade,
  nombre text not null,
  especie text not null,
  raza text not null default '',
  fecha_nacimiento date,
  sexo text not null default '',
  peso_kg numeric,
  foto_path text
);

create table tipos_cuidado (
  id bigint generated always as identity primary key,
  nombre text not null unique
);

create table cuidados (
  id bigint generated always as identity primary key,
  usuario_id uuid not null default auth.uid() references auth.users on delete cascade,
  mascota_id bigint not null references mascotas on delete cascade,
  tipo_cuidado_id bigint not null references tipos_cuidado,
  fecha date not null,
  notas text
);

insert into tipos_cuidado (nombre) values
  ('Vacunación'), ('Baño'), ('Desparasitación'), ('Visita veterinaria');

-- Reglas de acceso: cada usuario solo toca lo suyo.
alter table mascotas enable row level security;
alter table tipos_cuidado enable row level security;
alter table cuidados enable row level security;

create policy "mascotas propias" on mascotas for all to authenticated
  using (usuario_id = auth.uid()) with check (usuario_id = auth.uid());

create policy "cuidados propios" on cuidados for all to authenticated
  using (usuario_id = auth.uid()) with check (usuario_id = auth.uid());

create policy "catalogo de solo lectura" on tipos_cuidado for select to authenticated
  using (true);

-- Fotos: bucket privado, una carpeta por usuario.
insert into storage.buckets (id, name, public) values ('fotos-mascotas', 'fotos-mascotas', false);

create policy "fotos propias" on storage.objects for all to authenticated
  using (bucket_id = 'fotos-mascotas' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'fotos-mascotas' and (storage.foldername(name))[1] = auth.uid()::text);
```

### Configuración del proyecto Supabase

- Auth → desactivar "Confirm email", para que el Sign up de la demo entre directo.
- La URL del proyecto y la clave pública (`anon`) se pasan al compilar con `--dart-define-from-file=env.json`. El archivo `env.json` está en `.gitignore`; en el repo solo va `env.ejemplo.json` con los valores vacíos.
- La clave `service_role` y las contraseñas de las cuentas de demostración nunca entran al repo; se comparten por el grupo privado.
- El plan gratuito pausa el proyecto tras varios días sin uso: hay que abrir el panel el día antes de la revisión.

## Arquitectura

Cada funcionalidad tiene tres capas, y las dependencias van en un solo sentido:

```
Pantalla (widget)  →  ViewModel (ChangeNotifier)  →  Repositorio (contrato)
                                                          ▲
                                          RepositorioImpl ┘ →  Servicio (SDK de Supabase)
```

Reglas del equipo:

1. La pantalla solo lee el estado del ViewModel y llama a sus métodos. No importa nada de `data/`.
2. El ViewModel recibe el repositorio por constructor (se lo entrega `provider`). No importa `supabase_flutter`.
3. El contrato del repositorio vive en `domain/` y habla solo de modelos propios (`Mascota`, `Cuidado`).
4. `supabase_flutter` solo se importa dentro de `data/` y en `core/`.
5. Nada de datos de negocio en `shared_preferences` ni en archivos locales.

### Estructura de carpetas

```
lib/
├── main.dart                         (D) inicializa Supabase y arranca la app
├── app.dart                          (D) árbol de Provider + MaterialApp.router
├── core/                             (D)
│   ├── config/entorno.dart               URL y clave leídas de --dart-define
│   ├── errores/fallo.dart                FalloRed, FalloSesion, FalloServidor
│   ├── estado/estado_carga.dart          Cargando, Datos, Vacio, ErrorCarga
│   ├── router/app_router.dart            go_router + redirect
│   ├── sesion/almacen_sesion_seguro.dart LocalStorage con flutter_secure_storage
│   ├── tema/                             colores y tipografía
│   └── widgets/                          vista de error con "Reintentar", vista vacía
└── features/
    ├── auth/
    │   ├── data/          (D) auth_service.dart, auth_repository_impl.dart
    │   ├── domain/        (D) auth_repository.dart, usuario.dart
    │   └── presentation/  (D) sesion_view_model.dart
    │                      (A) sign_in_screen/view_model, sign_up_screen/view_model
    ├── inicio/            (A) presentation/
    ├── mascotas/          (B) data/, domain/, presentation/ (lista y formulario)
    ├── tipos_cuidado/     (C) data/, domain/, presentation/
    ├── cuidados/          (C) data/, domain/, presentation/ (detalle de mascota y formulario)
    └── ajustes/           (D) data/, domain/, presentation/
```

### Piezas compartidas (las escribe Dumar en el Paso 0)

Estado de una pantalla que carga datos:

```dart
sealed class EstadoCarga<T> {
  const EstadoCarga();
}
class Cargando<T> extends EstadoCarga<T> { const Cargando(); }
class Datos<T> extends EstadoCarga<T> { const Datos(this.valor); final T valor; }
class Vacio<T> extends EstadoCarga<T> { const Vacio(); }
class ErrorCarga<T> extends EstadoCarga<T> { const ErrorCarga(this.mensaje); final String mensaje; }
```

Errores: cada `RepositorioImpl` atrapa las excepciones del SDK y de red y lanza un `Fallo` con un mensaje en español. Así el ViewModel hace `on Fallo catch (f)` sin saber nada de Supabase.

Contratos de los repositorios:

```dart
abstract class AuthRepository {
  Usuario? get usuarioActual;
  Stream<Usuario?> get cambiosDeSesion;
  Future<void> registrar({required String correo, required String contrasena});
  Future<void> iniciarSesion({required String correo, required String contrasena});
  Future<void> cerrarSesion();
}

abstract class MascotaRepository {
  Future<List<Mascota>> obtenerMascotas();
  Future<Mascota> obtenerMascota(int id);
  Future<Mascota> guardar(Mascota mascota, {XFile? fotoNueva}); // inserta si id es null
  Future<void> eliminar(int id);
  Future<String?> urlDeFoto(Mascota mascota); // URL firmada temporal
}

abstract class TipoCuidadoRepository {
  Future<List<TipoCuidado>> obtenerTipos();
}

abstract class CuidadoRepository {
  Future<List<Cuidado>> obtenerCuidadosDeMascota(int mascotaId);
  Future<Cuidado> registrar(Cuidado cuidado);
  Future<void> eliminar(int id);
}

abstract class PreferenciasRepository {
  Future<Preferencias> leer();
  Future<void> guardar(Preferencias preferencias); // tema, orden de mascotas, orden del historial
}
```

`Cuidado` incluye el nombre del tipo (`tipoNombre`) para pintar el historial sin otra consulta; `CuidadoRepositoryImpl` lo trae con `select('*, tipos_cuidado(nombre)')`.

### Sesión

- `main.dart` llama a `Supabase.initialize(...)` con `authOptions: FlutterAuthClientOptions(localStorage: AlmacenSesionSeguro())`. Por defecto el SDK guarda la sesión en `shared_preferences`, cosa que el enunciado prohíbe; con esto se guarda cifrada en `flutter_secure_storage`.
- `SesionViewModel` (un `ChangeNotifier` global) escucha `cambiosDeSesion` y expone `haySesion`.
- Al reabrir la app, el SDK restaura la sesión antes de pintar la primera pantalla.

### Navegación

| Ruta | Pantalla | Dueño | Sesión |
|---|---|---|---|
| `/sign-in` | Iniciar sesión | A | No |
| `/sign-up` | Registrarse | A | No |
| `/inicio` | Inicio (pestaña) | A | Sí |
| `/mascotas` | Mis mascotas (pestaña) | B | Sí |
| `/mascotas/nueva` | Registrar mascota | B | Sí |
| `/mascotas/:id` | Detalle con historial de cuidados | C | Sí |
| `/mascotas/:id/editar` | Editar mascota | B | Sí |
| `/mascotas/:id/cuidados/nuevo` | Registrar cuidado | C | Sí |
| `/tipos-cuidado` | Catálogo de tipos de cuidado | C | Sí |
| `/ajustes` | Ajustes y cerrar sesión (pestaña) | D | Sí |

- El `GoRouter` usa `refreshListenable: sesionViewModel` y un `redirect`: sin sesión, cualquier ruta protegida lleva a `/sign-in`; con sesión, `/sign-in` y `/sign-up` llevan a `/inicio`.
- Las tres pestañas van en un `StatefulShellRoute` con `NavigationBar`. En pantallas anchas se cambia por `NavigationRail` (lo hace Josue, coordinando con Dumar).
- Al catálogo de tipos de cuidado se entra desde Inicio.

### Entrega de dependencias con Provider

`app.dart` monta un `MultiProvider` en este orden: cliente de Supabase → servicios → repositorios (registrados por su contrato) → `SesionViewModel` y `AjustesViewModel` globales.

Los ViewModels de pantalla se crean en la ruta, nunca dentro de otro ViewModel ni en el widget de la pantalla:

```dart
GoRoute(
  path: '/mascotas',
  builder: (context, state) => ChangeNotifierProvider(
    create: (context) => MascotasViewModel(context.read<MascotaRepository>())..cargar(),
    child: const MascotasScreen(),
  ),
),
```

## Reparto de tareas

### Paso 0 — Base compartida (Dumar, antes que todos)

1. Dependencias: `supabase_flutter`, `go_router`, `provider`, `flutter_secure_storage`, `shared_preferences`, `image_picker`; para pruebas, `mocktail`.
2. Proyecto Supabase: esquema SQL, bucket, configuración de Auth, invitar al equipo.
3. Todo `core/`, los cinco contratos de `domain/`, los modelos y `features/auth` (datos y `SesionViewModel`).
4. `app_router.dart` con las diez rutas apuntando a pantallas provisionales, para que cada quien reemplace la suya sin tocar el router.
5. Aviso al grupo cuando `main` esté listo.

### Paso 1 — Trabajo en paralelo

| Persona | Entrega | Pruebas con `mocktail` |
|---|---|---|
| A — Josue | `SignInScreen` y `SignUpScreen` con sus ViewModels (validan correo, contraseña de 6 o más caracteres y confirmación); `InicioScreen` con el conteo de mascotas, accesos y enlace al catálogo; diseño adaptable y revisión de accesibilidad de toda la app al final | `SignInViewModel` |
| B — Marcelo | `MascotaRepositoryImpl` (incluida la subida de foto comprimida a Storage); `MascotasScreen` con búsqueda y orden según Ajustes; formulario de crear y editar con las validaciones de la app nativa (nombre y especie obligatorios, fecha no futura, peso mayor que cero) en un `GuardarMascotaUseCase` | `GuardarMascotaUseCase`, `MascotasViewModel` |
| C — Yimmi | `TipoCuidadoRepositoryImpl` y `CuidadoRepositoryImpl`; pantalla de catálogo; `DetalleMascotaScreen` con el historial, eliminar mascota (con confirmación) y eliminar cuidado; formulario de registrar cuidado | `DetalleMascotaViewModel`, `CuidadoFormViewModel` |
| D — Dumar | `AjustesScreen` (tema, orden de listas, cerrar sesión) con `PreferenciasRepositoryImpl` sobre `shared_preferences`; apoyo a la integración | `SesionViewModel`, `redirect` del router |

Toda pantalla que carga datos debe mostrar los cuatro estados (cargando, datos, vacío, error con "Reintentar") usando los widgets de `core/widgets/`.

### Paso 2 — Integración y verificación

1. Cada persona abre un PR de su rama contra `main`. Se fusiona con "Create a merge commit", nunca con "Squash and merge" (borra la autoría).
2. Antes de pedir revisión: `flutter analyze` sin errores y `flutter test` en verde.
3. Prueba manual del flujo completo en el emulador:
   - Sign up con un correo nuevo → entra a Inicio.
   - Cerrar la app y reabrirla → sigue con sesión. Cerrar sesión → vuelve a Sign in y `/mascotas` ya no es accesible.
   - Registrar una mascota con foto → aparece en la lista y en el panel de Supabase.
   - Abrir el catálogo de tipos de cuidado.
   - Detalle → registrar un cuidado → aparece en el historial al volver a consultar.
   - Modo avión → la lista muestra el error → quitar modo avión → "Reintentar" carga los datos.
   - Entrar con una segunda cuenta → no ve las mascotas de la primera.
   - Girar el teléfono → nada se desborda.

## Forma de trabajo

- Repositorio: `https://github.com/DumarMatamoros/PetCare-Flutter`. Dumar añade a los otros tres como colaboradores.
- Ramas: `feature/persona-x-descripcion`, creadas desde `main` después del Paso 0.
- Commits: Conventional Commits en español (`feat(mascotas): ...`, `fix(auth): ...`, `test(cuidados): ...`).
- Cada integrante debe hacer commits con un correo vinculado a su cuenta de GitHub. Quien no registre participación en el repositorio pierde toda la nota grupal.
- Si necesitas cambiar un contrato de `domain/`, `core/` o el router, avisa primero en el grupo: son archivos que usan todos.

## Presentación de cierre (5 minutos)

- **1 min — problema y solución:** qué es PetCare, para quién y el flujo principal.
- **2 min — demo en vivo:** Sign in, lista de mascotas, catálogo de tipos de cuidado, registrar un cuidado y verlo al volver a consultar, modo avión con "Reintentar".
- **2 min — arquitectura:** `app_router.dart` (rutas y `redirect`), un ViewModel con `ChangeNotifier`, contrato e implementación de un repositorio, el servicio con el SDK, `AlmacenSesionSeguro`, y por qué no hay datos de negocio guardados en el teléfono.

Los cuatro deben poder responder preguntas de cualquier capa, no solo de su módulo. El emulador y el proyecto deben estar abiertos antes del turno.
