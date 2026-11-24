import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:petcare_flutter/core/errores/fallo.dart';
import 'package:petcare_flutter/features/cuidados/domain/cuidado.dart';
import 'package:petcare_flutter/features/cuidados/domain/cuidado_repository.dart';
import 'package:petcare_flutter/features/cuidados/presentation/cuidado_form_view_model.dart';
import 'package:petcare_flutter/features/tipos_cuidado/domain/tipo_cuidado_repository.dart';

class TiposRepositorioFalso extends Mock implements TipoCuidadoRepository {}

class CuidadosRepositorioFalso extends Mock implements CuidadoRepository {}

class CuidadoFalso extends Fake implements Cuidado {}

void main() {
  setUpAll(() {
    registerFallbackValue(CuidadoFalso());
  });

  late TiposRepositorioFalso tiposRepositorio;
  late CuidadosRepositorioFalso cuidadosRepositorio;
  late CuidadoFormViewModel viewModel;

  setUp(() {
    tiposRepositorio = TiposRepositorioFalso();
    cuidadosRepositorio = CuidadosRepositorioFalso();

    viewModel = CuidadoFormViewModel(1, tiposRepositorio, cuidadosRepositorio);
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('sin tipo seleccionado muestra error y no registra', () async {
    final resultado = await viewModel.guardar('Notas');

    expect(resultado, isFalse);
    expect(viewModel.mensajeError, 'Selecciona un tipo de cuidado.');
    verifyNever(() => cuidadosRepositorio.registrar(any()));
  });

  test('con datos válidos registra el cuidado de la mascota', () async {
    final fecha = DateTime(2026, 11, 20);
    viewModel.seleccionarTipo(3);
    viewModel.seleccionarFecha(fecha);

    when(() => cuidadosRepositorio.registrar(any()))
        .thenAnswer((invocation) async {
          return invocation.positionalArguments.first as Cuidado;
        });

    final resultado = await viewModel.guardar('  Control anual  ');

    expect(resultado, isTrue);
    expect(viewModel.mensajeError, isNull);

    final cuidado =
        verify(() => cuidadosRepositorio.registrar(captureAny()))
                .captured
                .single
            as Cuidado;

    expect(cuidado.mascotaId, 1);
    expect(cuidado.tipoCuidadoId, 3);
    expect(cuidado.fecha, fecha);
    expect(cuidado.notas, 'Control anual');
  });

  test('si registrar falla muestra el mensaje y termina de guardar', () async {
    viewModel.seleccionarTipo(3);

    when(() => cuidadosRepositorio.registrar(any()))
        .thenThrow(const FalloServidor('No se pudo registrar el cuidado.'));

    final resultado = await viewModel.guardar('');

    expect(resultado, isFalse);
    expect(viewModel.mensajeError, 'No se pudo registrar el cuidado.');
    expect(viewModel.guardando, isFalse);
  });
}
