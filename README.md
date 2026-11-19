# PetCare Flutter

Aplicación Android para llevar el control de tus mascotas y sus cuidados, hecha con Flutter y Supabase. Cada usuario se registra, inicia sesión y ve solo sus mascotas.

## Equipo

| Persona | Integrante | Módulo |
|---|---|---|
| A | Josue Fernando Palma Zambrano | Sign up, Sign in, Inicio, diseño adaptable y accesibilidad |
| B | Marcelo Matias Nieto Medina | Mascotas: lista, búsqueda, formulario y foto |
| C | Yimmi Leonel Barberan Moreira | Tipos de cuidado, detalle de mascota y cuidados |
| D | Dumar Abdul Matamoros Pluas | Proyecto base, navegación, sesión, inyección con Provider y Ajustes |

## Documentación

- [Plan técnico](docs/plan-tecnico-implementacion.md): qué se construye, arquitectura, modelo de datos y reparto. Empieza por aquí.
- [Persona A — Sign up, Sign in, Inicio, diseño adaptable y accesibilidad](docs/PERSONA_A_AUTH_INICIO.md)
- [Persona B — Mascotas](docs/PERSONA_B_MASCOTAS.md)
- [Persona C — Tipos de cuidado, detalle de mascota y cuidados](docs/PERSONA_C_CUIDADOS.md)
- [Persona D — Proyecto base, navegación, sesión y Ajustes](docs/PERSONA_D_BASE_NAVEGACION_AJUSTES.md)

## Cómo ejecutar

Disponible cuando termine el Paso 0 del plan.

1. Copia `env.ejemplo.json` como `env.json` y pon la URL y la clave pública (`anon`) del proyecto Supabase. Se comparten por el grupo privado; `env.json` no se sube al repositorio.
2. Instala las dependencias: `flutter pub get`.
3. Ejecuta en un emulador o teléfono Android: `flutter run --dart-define-from-file=env.json`.

Antes de pedir revisión de un PR: `flutter analyze` sin errores y `flutter test` en verde.
