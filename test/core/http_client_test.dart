import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_cafeteria/core/failure.dart';
import 'package:gestor_cafeteria/core/http_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ApiClient', () {
    test('GET exitoso devuelve el JSON decodificado', () async {
      final mock = MockClient((request) async {
        return http.Response('[{"id": 1}]', 200);
      });
      final api = ApiClient(client: mock, baseUrl: 'http://prueba');

      final resultado = await api.get('/orders');

      expect(resultado, isA<List>());
      expect(resultado, [
        {'id': 1},
      ]);
    });

    test('404 lanza NotFoundFailure con el mensaje de detail', () async {
      final mock = MockClient((request) async {
        return http.Response('{"detail": "Order 9 not found"}', 404);
      });
      final api = ApiClient(client: mock, baseUrl: 'http://prueba');

      expect(
        api.get('/orders/9'),
        throwsA(
          isA<NotFoundFailure>().having(
            (f) => f.message,
            'message',
            'Order 9 not found',
          ),
        ),
      );
    });

    test('409 lanza ConflictFailure con el mensaje de detail', () async {
      final mock = MockClient((request) async {
        return http.Response(
          '{"detail": "Cannot change status from pending to delivered"}',
          409,
        );
      });
      final api = ApiClient(client: mock, baseUrl: 'http://prueba');

      expect(
        api.patch('/orders/1', {'status': 'delivered'}),
        throwsA(
          isA<ConflictFailure>().having(
            (f) => f.message,
            'message',
            'Cannot change status from pending to delivered',
          ),
        ),
      );
    });

    test('422 lanza ValidationFailure con el mapa de campos', () async {
      final mock = MockClient((request) async {
        return http.Response(
          '{"detail": [{"loc": ["body", "customer"], '
          '"msg": "Must be 1-50 characters"}]}',
          422,
        );
      });
      final api = ApiClient(client: mock, baseUrl: 'http://prueba');

      expect(
        api.post('/orders', {'customer': '', 'drink': 'latte', 'size': 'M'}),
        throwsA(
          isA<ValidationFailure>().having((f) => f.fields, 'fields', {
            'customer': 'Must be 1-50 characters',
          }),
        ),
      );
    });

    test('503 lanza ServerFailure con statusCode 503', () async {
      final mock = MockClient((request) async {
        return http.Response('{"detail": "Simulated failure"}', 503);
      });
      final api = ApiClient(client: mock, baseUrl: 'http://prueba');

      expect(
        api.get('/orders'),
        throwsA(
          isA<ServerFailure>().having((f) => f.statusCode, 'statusCode', 503),
        ),
      );
    });

    test('ClientException del cliente lanza NetworkFailure', () async {
      final mock = MockClient((request) async {
        throw http.ClientException('sin red');
      });
      final api = ApiClient(client: mock, baseUrl: 'http://prueba');

      expect(api.get('/orders'), throwsA(isA<NetworkFailure>()));
    });

    test('tiempo agotado lanza NetworkFailure', () async {
      final mock = MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        return http.Response('[]', 200);
      });
      final api = ApiClient(
        client: mock,
        baseUrl: 'http://prueba',
        timeout: const Duration(milliseconds: 50),
      );

      expect(api.get('/orders'), throwsA(isA<NetworkFailure>()));
    });

    test('300 no es éxito: lanza UnexpectedFailure con statusCode 300', () async {
      final mock = MockClient((request) async {
        return http.Response('', 300);
      });
      final api = ApiClient(client: mock, baseUrl: 'http://prueba');

      expect(
        api.get('/orders'),
        throwsA(
          isA<UnexpectedFailure>().having((f) => f.statusCode, 'statusCode', 300),
        ),
      );
    });
  });
}
