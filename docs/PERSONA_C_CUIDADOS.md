# PetCare Flutter — Tipos de cuidado, detalle de mascota y cuidados (Persona C)

## 1. Información general

- **Responsable:** Yimmi Leonel Barberan Moreira (Persona C)
- **Rama de trabajo:** `feature/persona-c-cuidados`, creada desde `main` cuando Dumar avise que el Paso 0 está listo
- **Módulo:** catálogo de tipos de cuidado, detalle de mascota con su historial y formulario de registrar cuidado

Este documento detalla tu parte del [plan técnico](plan-tecnico-implementacion.md). Lee primero el plan: aquí no se repiten el modelo de datos ni las reglas de arquitectura.

**Estado:** nada implementado todavía. Ve llenando la tabla de la sección 8 a medida que avances.

## 2. Qué te toca construir

- **`TipoCuidadoRepositoryImpl` y `CuidadoRepositoryImpl`:** leer el catálogo, y leer, registrar y eliminar cuidados en Supabase.
- **Catálogo** (`/tipos-cuidado`): lista de solo lectura con los cuatro tipos. Se entra desde Inicio.
- **Detalle de mascota** (`/mascotas/:id`): datos y foto de la mascota, historial de cuidados, botones "Editar", "Eliminar mascota" (con confirmación) y "Registrar cuidado", y eliminar un cuidado del historial.
- **Registrar cuidado** (`/mascotas/:id/cuidados/nuevo`): tipo, fecha y notas.
- **Pruebas** de `DetalleMascotaViewModel` y `CuidadoFormViewModel`.

Un cuidado no se edita: se registra, se consulta y se elimina.

## 3. Archivos

Todos son tuyos y nuevos, salvo los dos últimos.

### Tipos de cuidado

- `lib/features/tipos_cuidado/data/tipo_cuidado_service.dart`
- `lib/features/tipos_cuidado/data/tipo_cuidado_repository_impl.dart`
- `lib/features/tipos_cuidado/presentation/tipos_cuidado_screen.dart`
- `lib/features/tipos_cuidado/presentation/tipos_cuidado_view_model.dart`

### Cuidados

- `lib/features/cuidados/data/cuidado_service.dart`
- `lib/features/cuidados/data/cuidado_repository_impl.dart`
- `lib/features/cuidados/presentation/detalle_mascota_screen.dart`
- `lib/features/cuidados/presentation/detalle_mascota_view_model.dart`
- `lib/features/cuidados/presentation/cuidado_form_screen.dart`
- `lib/features/cuidados/presentation/cuidado_form_view_model.dart`

Los `*_service.dart` son los únicos archivos del módulo que importan `supabase_flutter`. Los contratos y los modelos ya los dejó Dumar en las carpetas `domain/`.

### Pruebas

- `test/features/cuidados/detalle_mascota_view_model_test.dart`
- `test/features/cuidados/cuidado_form_view_model_test.dart`

### Archivos de Dumar que tocas

- `lib/app.dart`: registrar tus dos servicios y tus dos repositorios en lugar de los provisionales.
- `lib/core/router/app_router.dart`: cambiar tus tres pantallas provisionales por las reales.

Avísale antes de editar cualquiera de los dos.

## 4. Contratos

Los que implementas:

```dart
abstract class TipoCuidadoRepository {
  Future<List<TipoCuidado>> obtenerTipos();
}

abstract class CuidadoRepository {
  Future<List<Cuidado>> obtenerCuidadosDeMascota(int mascotaId);
  Future<Cuidado> registrar(Cuidado cuidado);
  Future<void> eliminar(int id);
}
```

| Campo de `Cuidado` | Tipo | Columna |
|---|---|---|
| `id` | `int?` | `id` |
| `mascotaId` | `int` | `mascota_id` |
| `tipoCuidadoId` | `int` | `tipo_cuidado_id` |
| `tipoNombre` | `String` | viene de `tipos_cuidado.nombre` |
| `fecha` | `DateTime` | `fecha` |
| `notas` | `String?` | `notas` |

Los que usas, de Marcelo: `MascotaRepository.obtenerMascota(id)`, `urlDeFoto(mascota)` y `eliminar(id)`.

## 5. Puntos clave

### Repositorios

- Trae el nombre del tipo en la misma consulta: `select('*, tipos_cuidado(nombre)')`. La respuesta trae el nombre anidado (`fila['tipos_cuidado']['nombre']`); el `fromMap` de `Cuidado` lo pasa a `tipoNombre`.
- Usa el mismo `select` después del `insert` en `registrar`, para devolver el cuidado ya con su `tipoNombre`.
- Al insertar no envíes `id`, `usuario_id` ni `tipoNombre`: los dos primeros los rellena la base y el tercero no es una columna.
- La tabla `tipos_cuidado` es de solo lectura para la app. No hay pantalla para crear tipos.
- Atrapa `PostgrestException` y los errores de red, y lanza `FalloServidor` o `FalloRed` con un mensaje en español. `AuthRepositoryImpl` sirve de ejemplo.

### Catálogo

- `TiposCuidadoViewModel` expone un `EstadoCarga<List<TipoCuidado>>`. Aunque el catálogo es fijo, la pantalla muestra los cuatro estados: sin conexión debe salir el error con "Reintentar".

### Detalle de mascota

- `DetalleMascotaViewModel` recibe el id de la mascota por constructor y carga la mascota y sus cuidados. Un solo `EstadoCarga` para la pantalla: si cualquiera de las dos consultas falla, error con "Reintentar".
- El historial vacío no es el estado `Vacio` de la pantalla: la mascota sí se muestra, y en el lugar del historial va el mensaje "Aún no hay cuidados registrados".
- El orden del historial sale de `AjustesViewModel` (`ordenHistorial`): más reciente o más antiguo primero.
- **Eliminar mascota:** diálogo de confirmación, luego `MascotaRepository.eliminar(id)` y `context.pop()` para volver a la lista. Los cuidados se borran solos en la base.
- **Eliminar cuidado:** confirmación y, si sale bien, volver a cargar el historial.
- Si una eliminación falla, muestra el mensaje en un `SnackBar` y deja la pantalla como estaba.
- **El historial no se actualiza solo.** Al regresar del formulario de cuidado o de editar la mascota, vuelve a cargar:

```dart
await context.push('/mascotas/$id/cuidados/nuevo');
if (context.mounted) context.read<DetalleMascotaViewModel>().cargar();
```

### Registrar cuidado

- `CuidadoFormViewModel` recibe el id de la mascota y carga los tipos para el desplegable. Si esa carga falla, error con "Reintentar" en lugar del formulario.
- Validaciones: tipo obligatorio y fecha obligatoria (por defecto, hoy). Las notas son opcionales.
- Mientras guarda, el botón se desactiva. Si falla, se muestra el mensaje y no se pierde lo escrito. Si sale bien, `context.pop()`.

## 6. Integración con el equipo

- **Marcelo (B):** dependes de su `MascotaRepositoryImpl` para el detalle. Hasta que lo fusione, en `main` hay un repositorio provisional que siempre falla: avanza con las pruebas simuladas y con el catálogo, que no depende de nadie. Tu botón "Editar" abre su formulario con `context.push('/mascotas/$id/editar')`.
- **Josue (A):** Inicio enlaza a tu catálogo. Al final revisará el diseño adaptable y la accesibilidad de tus pantallas; el detalle es candidato a dos columnas (datos a la izquierda, historial a la derecha).
- **Dumar (D):** dueño de `app.dart`, del router y de `AjustesViewModel`.

## 7. Pruebas

Con repositorios simulados con `mocktail`.

`DetalleMascotaViewModel`:

1. Mascota y cuidados cargan: el estado pasa de `Cargando` a `Datos`.
2. `obtenerMascota` lanza `FalloRed`: `ErrorCarga`; al llamar otra vez a `cargar()` y devolver datos, pasa a `Datos`.
3. Eliminar un cuidado llama a `CuidadoRepository.eliminar` y vuelve a cargar el historial.
4. Eliminar la mascota llama a `MascotaRepository.eliminar` con su id.

`CuidadoFormViewModel`:

1. Sin tipo elegido: muestra el error y no llama a `registrar`.
2. Datos válidos: llama a `registrar` una vez con el `mascotaId` y el `tipoCuidadoId` correctos.
3. `registrar` lanza un `Fallo`: el mensaje queda en el estado y deja de estar guardando.

Manual, en el emulador:

1. Abrir el catálogo y ver los cuatro tipos.
2. Registrar un cuidado y verlo en el historial y en el panel de Supabase.
3. Eliminar un cuidado.
4. Eliminar una mascota con cuidados y comprobar en el panel que sus cuidados ya no están.
5. Activar el modo avión en el detalle, ver el error; quitarlo y tocar "Reintentar".

## 8. Estado de verificación

| Verificación | Estado |
|---|---|
| `flutter analyze` sin errores | Pendiente |
| `flutter test` en verde | Pendiente |
| Catálogo muestra los cuatro tipos | Pendiente |
| Detalle muestra los datos y la foto de la mascota | Pendiente (depende de B) |
| Registrar un cuidado y verlo en el historial | Pendiente |
| Eliminar un cuidado | Pendiente |
| Eliminar mascota con confirmación y borrado en cascada | Pendiente (depende de B) |
| Orden del historial según Ajustes | Pendiente (depende de D) |
| Estados cargando, vacío y error con "Reintentar" | Pendiente |
| Cada cuenta ve solo sus cuidados | Pendiente |
