## 7. Pruebas

### Automatizadas

Se utilizan repositorios simulados con `mocktail`.

Pruebas de `DetalleMascotaViewModel`:

1. La carga pasa de `Cargando` a `Datos` y devuelve la mascota y sus cuidados.
2. Un fallo de red produce `ErrorCarga`; al reintentar correctamente, pasa de `Cargando` a `Datos`.
3. Eliminar un cuidado llama al repositorio y actualiza el historial.
4. Eliminar la mascota utiliza su identificador.

Pruebas de `CuidadoFormViewModel`:

1. Sin tipo seleccionado, muestra el error y no registra.
2. Con datos válidos, registra una vez con los identificadores, fecha y notas correctos.
3. Si registrar falla, conserva el mensaje de error y termina el estado de guardado.

Resultado después de modificar la foto del detalle y completar la prueba de recuperación:

- `flutter analyze`: `No issues found!`.
- `flutter test`: 92 pruebas aprobadas.

Las 92 pruebas corresponden al conjunto del proyecto.

### Manuales realizadas en un teléfono Android

1. El catálogo muestra los cuatro tipos de cuidado.
2. Registrar un cuidado vuelve al detalle y actualiza el historial.
3. El historial respeta el orden por fecha seleccionado en Ajustes.
4. Cancelar la eliminación de un cuidado lo conserva.
5. Confirmar la eliminación retira el cuidado; al salir y volver a entrar, continúa eliminado y los demás permanecen.
6. Sin conexión, el detalle muestra un error; al recuperar internet y pulsar “Reintentar”, carga los datos.
7. Cancelar la eliminación de una mascota la conserva.
8. Confirmar la eliminación de una mascota con cuidados vuelve a la lista y la mascota desaparece.
9. Una segunda cuenta no muestra la mascota de la primera. Al regresar a la primera cuenta, su mascota y su cuidado siguen disponibles.
10. Una mascota sin cuidados muestra sus datos y el mensaje “Aún no hay cuidados registrados”.
11. La foto del detalle aparece circular. “Ver foto completa” permite verla sin recortes y cerrar la ventana.
12. Sin conexión, el catálogo muestra un error; al recuperar internet y reintentar, aparecen los cuatro tipos.
13. Si se abre el formulario de cuidado sin conexión, falla la carga de tipos. Al recuperar internet y reintentar, aparece el formulario con los tipos disponibles.

La separación entre cuentas se comprobó desde la app. No se realizaron pruebas directas de autorización mediante peticiones HTTP.

### Comprobaciones en Supabase pendientes de Dumar

Yimmi no dispone de acceso al panel administrativo del proyecto. Se solicita a Dumar:

- Comprobar en la tabla `cuidados` un registro creado desde la app.
- Confirmar que al eliminar una mascota se eliminan también sus cuidados mediante el borrado en cascada.

La desaparición de la mascota en la app está comprobada; la eliminación de sus registros asociados requiere la revisión directa en Supabase.

## 8. Estado de verificación

| Verificación | Estado |
|---|---|
| `flutter analyze` sin errores | Hecho: `No issues found!` |
| `flutter test` en verde | Hecho: 92 pruebas del proyecto aprobadas |
| Catálogo muestra los cuatro tipos | Hecho: comprobado en teléfono Android |
| Detalle muestra los datos y la foto de la mascota | Hecho |
| Foto circular y apertura de la imagen completa | Hecho: comprobado en el teléfono |
| Registrar un cuidado y verlo en el historial | Hecho: actualización al regresar comprobada |
| Ver el cuidado registrado en el panel de Supabase | Pendiente de Dumar: requiere acceso al panel |
| Eliminar un cuidado | Hecho: cancelación, confirmación y comprobación al volver a entrar |
| Eliminar mascota con confirmación | Hecho: cancelación, eliminación y regreso a la lista |
| Borrado en cascada de los cuidados de la mascota eliminada | Pendiente de Dumar: comprobar en Supabase |
| Orden del historial según Ajustes | Hecho: comprobado con fechas diferentes |
| Transición de carga a datos en el detalle | Hecho: cubierta por prueba automatizada |
| Historial vacío conserva los datos de la mascota | Hecho: muestra “Aún no hay cuidados registrados” |
| Error de red y reintento en el detalle | Hecho: comprobación manual y prueba automatizada de recuperación |
| Error de red y reintento en el catálogo | Hecho: comprobado en el teléfono |
| Error de red y reintento al cargar los tipos del formulario | Hecho: comprobado en el teléfono |
| Separación de datos entre cuentas desde la app | Hecho: comprobado con dos cuentas |
| Autorización mediante peticiones HTTP con y sin token | No realizada; pendiente de coordinación del equipo |