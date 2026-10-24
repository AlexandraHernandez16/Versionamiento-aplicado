# gestor_cafeteria

Aplicación Flutter para gestionar los pedidos de una cafetería. Por ahora incluye el cliente HTTP (`ApiClient`) que consume la API de pedidos y traduce cada respuesta de error a un `Failure` tipado (red, no encontrado, conflicto, validación, servidor e inesperado).

## Requisitos

- **Flutter** estable con **Dart 3.13.2 o superior** (probado con Flutter 3.47.4 / Dart 3.13.3).
- **Node.js 22.13 o superior**, solo para levantar el servidor `mini_backend` (usa el módulo integrado `node:sqlite`).
- Chrome o un emulador de Android para ejecutar la app.

## Servidor (`mini_backend`)

La API vive en otro repositorio y **no se incluye en este proyecto**: <https://github.com/DMI-2026/mini_backend>.

Versión con la que se probó: commit `94d2533` (`feat: enable CORS for Flutter web clients`, rama `master`).

Para levantarlo (no requiere `npm install`):

```bash
git clone https://github.com/DMI-2026/mini_backend
cd mini_backend
git checkout 94d2533
node server.js        # escucha en http://localhost:8000
```

Variables opcionales: `PORT` (8000), `HOST` (0.0.0.0) y `DB_PATH` (app.db). El servidor ya permite CORS, por lo que en Chrome no hace falta desactivar la seguridad del navegador.

## Ejecutar la app

Con el servidor encendido, desde la carpeta de este proyecto:

```bash
flutter pub get
flutter run -d chrome
```

La URL de la API se define con `API_URL` mediante `--dart-define`. Si no se indica, el cliente usa `http://localhost:8000` en web y `http://10.0.2.2:8000` en el emulador de Android (la dirección con la que el emulador alcanza a la computadora anfitriona).

```bash
# otra dirección, por ejemplo un celular físico en la misma red
flutter run --dart-define=API_URL=http://192.168.1.50:8000
```

## Pruebas

```bash
flutter pub get
flutter analyze
flutter test
```

`flutter test` ejecuta 15 pruebas: 7 de la jerarquía de `Failure` y 8 del `ApiClient`. Estas últimas usan `MockClient`, así que no necesitan red ni el servidor encendido.

## Estructura

```
lib/
  core/
    failure.dart       jerarquía sellada de errores (Failure y sus subtipos)
    http_client.dart   ApiClient: GET, POST, PATCH, DELETE y mapeo de errores
  main.dart            pantalla de prueba que consulta /orders
test/
  core/
    failure_test.dart       pruebas de la jerarquía de Failure
    http_client_test.dart   pruebas del ApiClient con MockClient
```
