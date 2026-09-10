import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/partido.dart';

Future<void> mostrarDetallesPartido(
  BuildContext context, {
  required Partido partido,
  required String equipoLocal,
  required String equipoVisitante,
  required String competicion,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => PartidoDetailsSheet(
      partido: partido,
      equipoLocal: equipoLocal,
      equipoVisitante: equipoVisitante,
      competicion: competicion,
    ),
  );
}

class PartidoDetailsSheet extends StatelessWidget {
  final Partido partido;
  final String equipoLocal;
  final String equipoVisitante;
  final String competicion;

  const PartidoDetailsSheet({
    super.key,
    required this.partido,
    required this.equipoLocal,
    required this.equipoVisitante,
    required this.competicion,
  });

  @override
  Widget build(BuildContext context) {
    final estaEnJuego = partido.estado == 'en_juego' && partido.tieneResultado;
    final equipos = estaEnJuego
        ? '$equipoLocal ${partido.golesLocal}-${partido.golesVisitante} $equipoVisitante'
        : '$equipoLocal - $equipoVisitante';
    final canal = partido.canal?.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalles del partido',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            equipos,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 20),
          _DetallePartido(etiqueta: 'Competicion', valor: competicion),
          _DetallePartido(
            etiqueta: 'Fecha y hora',
            valor: partido.fechaHora == null
                ? 'Sin fecha programada'
                : DateFormat('dd/MM/yyyy HH:mm').format(partido.fechaHora!),
          ),
          _DetallePartido(
            etiqueta: 'Canal',
            valor: canal == null || canal.isEmpty ? 'No televisado' : canal,
          ),
        ],
      ),
    );
  }
}

class _DetallePartido extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _DetallePartido({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 3),
          Text(valor, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
