import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quinielas_app/models/partido.dart';
import 'package:quinielas_app/widgets/partido_details_sheet.dart';

void main() {
  Widget buildSubject(Partido partido) {
    return MaterialApp(
      home: Scaffold(
        body: PartidoDetailsSheet(
          partido: partido,
          equipoLocal: 'Celta',
          equipoVisitante: 'Valencia',
          competicion: 'LaLiga EA Sports',
        ),
      ),
    );
  }

  Partido createMatch({
    String estado = 'pendiente',
    String? canal = 'DAZN LaLiga',
    int? golesLocal,
    int? golesVisitante,
  }) {
    return Partido(
      id: 1,
      jornadaId: 1,
      orden: 1,
      estado: estado,
      fechaHora: DateTime(2026, 9, 12, 21),
      canal: canal,
      golesLocal: golesLocal,
      golesVisitante: golesVisitante,
    );
  }

  testWidgets('shows scheduled match details and channel fallback', (tester) async {
    await tester.pumpWidget(buildSubject(createMatch(canal: null)));

    expect(find.text('Celta - Valencia'), findsOneWidget);
    expect(find.text('LaLiga EA Sports'), findsOneWidget);
    expect(find.text('12/09/2026 21:00'), findsOneWidget);
    expect(find.text('No televisado'), findsOneWidget);
  });

  testWidgets('includes the score for a live match', (tester) async {
    await tester.pumpWidget(
      buildSubject(createMatch(estado: 'en_juego', golesLocal: 1, golesVisitante: 0)),
    );

    expect(find.text('Celta 1-0 Valencia'), findsOneWidget);
  });
}
