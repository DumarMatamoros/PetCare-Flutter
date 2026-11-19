# PetCare Flutter — Módulo de Mascotas (Persona B)

## 1. Información general

- **Responsable:** Marcelo Matias Nieto Medina (Persona B)
- **Rama de trabajo:** `feature/persona-b-mascotas`, creada desde `main` cuando Dumar avise que el Paso 0 está listo
- **Módulo:** lista de mascotas con búsqueda, formulario de crear y editar, y foto en Supabase Storage

Este documento detalla tu parte del [plan técnico](plan-tecnico-implementacion.md). Lee primero el plan: aquí no se repiten el modelo de datos ni las reglas de arquitectura.

**Estado:** nada implementado todavía. Ve llenando la tabla de la sección 8 a medida que avances.

## 2. Qué te toca construir

- **`MascotaRepositoryImpl`:** leer, crear, actualizar y eliminar mascotas en Supabase, y subir la foto a Storage.
- **Mis mascotas** (`/mascotas`): lista con foto, nombre, especie y raza; buscador por nombre; orden según Ajustes; botón para registrar.
- **Formulario** (`/mascotas/nueva` y `/mascotas/:id/editar`): la misma pantalla para crear y editar.
- **`GuardarMascotaUseCase`:** las validaciones de la app nativa, fuera del ViewModel.
- **Pruebas** de `GuardarMascotaUseCase` y `MascotasViewModel`.

## 3. Archivos

Todos son tuyos y nuevos, salvo los dos últimos.

### Datos

- `lib/features/mascotas/data/mascota_service.dart`: el único archivo del módulo que importa `supabase_flutter`. Hace las consultas a la tabla `mascotas` y al bucket `fotos-mascotas`.
- `lib/features/mascotas/data/mascota_repository_impl.dart`: implementa `MascotaRepository`, convierte filas en `Mascota` y excepciones en `Fallo`.

### Dominio

- `lib/features/mascotas/domain/guardar_mascota_use_case.dart`

El contrato `mascota_repository.dart` y el modelo `mascota.dart` ya los dejó Dumar en esta carpeta.

### Presentación

- `lib/features/mascotas/presentation/mascotas_screen.dart`
- `lib/features/mascotas/presentation/mascotas_view_model.dart`
- `lib/features/mascotas/presentation/mascota_form_screen.dart`
- `lib/features/mascotas/presentation/mascota_form_view_model.dart`

### Pruebas

- `test/features/mascotas/guardar_mascota_use_case_test.dart`
- `test/features/mascotas/mascotas_view_model_test.dart`

### Archivos de Dumar que tocas

- `lib/app.dart`: registrar `MascotaService`, `MascotaRepositoryImpl` y `GuardarMascotaUseCase` en lugar del repositorio provisional.
- `lib/core/router/app_router.dart`: cambiar tus tres pantallas provisionales por las reales.

Avísale antes de editar cualquiera de los dos.

## 4. Contrato que implementas

```dart
abstract class MascotaRepository {
  Future<List<Mascota>> obtenerMascotas();
  Future<Mascota> obtenerMascota(int id);
  Future<Mascota> guardar(Mascota mascota, {XFile? fotoNueva}); // inserta si id es null
  Future<void> eliminar(int id);
  Future<String?> urlDeFoto(Mascota mascota); // URL firmada temporal
}
```

| Campo de `Mascota` | Tipo | Columna |
|---|---|---|
| `id` | `int?` | `id` |
| `nombre` | `String` | `nombre` |
| `especie` | `String` | `especie` |
| `raza` | `String` | `raza` |
| `fechaNacimiento` | `DateTime?` | `fecha_nacimiento` |
| `sexo` | `String` | `sexo` |
| `pesoKg` | `double?` | `peso_kg` |
| `fotoPath` | `String?` | `foto_path` |

Diferencias con la app nativa: el id es `int` (antes `Long`), la fecha es un `DateTime` (antes días desde 1970) y la foto es una ruta dentro del bucket (antes una URI del teléfono).

## 5. Puntos clave

### Repositorio

- No envíes `usuario_id` ni `id` al insertar: la base los rellena. Las reglas de acceso ya filtran por usuario, así que `obtenerMascotas()` no necesita un `where`.
- Atrapa `PostgrestException`, `StorageException` y los errores de red, y lanza `FalloServidor` o `FalloRed` con un mensaje en español. `AuthRepositoryImpl` sirve de ejemplo.
- `eliminar(id)` lo usa la pantalla de detalle de Yimmi. Los cuidados se borran solos en la base, pero el archivo de la foto no: bórralo del bucket en el mismo método.

### Foto

- Elige la imagen con `image_picker` pidiéndola ya reducida (`maxWidth: 1024`, `imageQuality: 70`). Así no hace falta otra librería para comprimir.
- La ruta del archivo debe empezar por el id del usuario: `<id-de-usuario>/<marca-de-tiempo>.jpg`. Las reglas del bucket rechazan cualquier otra carpeta.
- Orden al guardar con foto nueva: subir el archivo, guardar la fila con el `foto_path` nuevo y, si había una foto anterior, borrarla.
- El bucket es privado: para mostrar la foto se pide una URL firmada con `urlDeFoto`. Caduca, así que no la guardes; pídela al cargar la lista.
- Si la mascota no tiene foto o la URL falla, muestra un icono.

### Mis mascotas

- `MascotasViewModel` expone un `EstadoCarga<List<Mascota>>` y el texto de búsqueda.
- La búsqueda filtra en memoria la lista ya cargada, sin distinguir mayúsculas y quitando los espacios de los extremos. No hace una consulta por cada letra.
- Distingue "no tienes mascotas" (`Vacio`, con botón para registrar) de "ninguna coincide con la búsqueda" (lista vacía con otro mensaje).
- El orden sale de `AjustesViewModel` (`ordenMascotas`): por nombre o por más reciente (id descendente).
- **La lista no se actualiza sola.** En la app nativa Room avisaba de los cambios; aquí hay que volver a llamar a `cargar()` al regresar del formulario o del detalle:

```dart
await context.push('/mascotas/nueva');
if (context.mounted) context.read<MascotasViewModel>().cargar();
```

### Formulario

- `MascotaFormViewModel` recibe el id (o `null`) por constructor. Con id, carga la mascota y rellena los campos; mientras carga, muestra el indicador de progreso, y si falla, "Reintentar".
- Al guardar llama a `GuardarMascotaUseCase`, que valida y luego llama al repositorio:
  - nombre obligatorio;
  - especie obligatoria;
  - fecha de nacimiento no futura;
  - peso mayor que cero, si se escribió.
- El caso de uso devuelve los errores por campo para que la pantalla los pinte debajo de cada uno.
- Mientras guarda, el botón se desactiva. Si falla, se muestra el mensaje y no se pierde lo escrito. Si sale bien, `context.pop()`.

## 6. Integración con el equipo

- **Josue (A):** Inicio llama a `obtenerMascotas()` para contar. Al final revisará el diseño adaptable y la accesibilidad de tus pantallas.
- **Yimmi (C):** su pantalla de detalle usa `obtenerMascota`, `urlDeFoto` y `eliminar`, y tiene el botón "Editar" que abre tu formulario. Tu lista abre su pantalla con `context.push('/mascotas/$id')`. Fusiona tu repositorio pronto: su trabajo depende de él.
- **Dumar (D):** dueño de `app.dart`, del router y de `AjustesViewModel`.

## 7. Pruebas

`GuardarMascotaUseCase` con un `MascotaRepository` simulado con `mocktail`:

1. Nombre vacío, especie vacía, fecha futura y peso cero: cada uno devuelve su error y no llama al repositorio.
2. Datos válidos: llama a `guardar` una vez.

`MascotasViewModel`:

1. El repositorio devuelve una lista: el estado pasa de `Cargando` a `Datos`.
2. Devuelve una lista vacía: `Vacio`.
3. Lanza `FalloRed`: `ErrorCarga` con el mensaje; al llamar otra vez a `cargar()` y devolver datos, pasa a `Datos`.
4. La búsqueda filtra por nombre sin distinguir mayúsculas.

Manual, en el emulador:

1. Registrar una mascota con foto y verla en la lista y en el panel de Supabase (tabla y bucket).
2. Editarla, cambiar la foto y comprobar que el archivo anterior ya no está en el bucket.
3. Activar el modo avión, abrir la lista, ver el error; quitarlo y tocar "Reintentar".
4. Entrar con otra cuenta y comprobar que no ve las mascotas de la primera.

## 8. Estado de verificación

| Verificación | Estado |
|---|---|
| `flutter analyze` sin errores | Pendiente |
| `flutter test` en verde | Pendiente |
| Registrar una mascota y verla en la lista | Pendiente |
| Validaciones: nombre, especie, fecha futura, peso | Pendiente |
| Editar una mascota (carga los datos y los guarda) | Pendiente |
| Foto: se sube, se muestra y se reemplaza | Pendiente |
| Búsqueda por nombre | Pendiente |
| Orden según Ajustes | Pendiente (depende de D) |
| Estados cargando, vacío y error con "Reintentar" | Pendiente |
| Cada cuenta ve solo sus mascotas | Pendiente |
| Eliminar desde el detalle borra también la foto | Pendiente (depende de C) |
