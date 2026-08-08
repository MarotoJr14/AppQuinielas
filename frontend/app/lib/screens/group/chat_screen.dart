import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/mensaje.dart';
import '../../state/auth_provider.dart';
import '../../state/group_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/common.dart';
import '../../widgets/inicial_avatar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _mensajeCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<Mensaje> _mensajes = [];
  final Map<int, String> _nombres = {};
  bool _cargando = true;
  bool _enviando = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _cargar(mostrarLoading: true);
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _cargar(mostrarLoading: false));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mensajeCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar({required bool mostrarLoading}) async {
    if (mostrarLoading) setState(() => _cargando = true);
    try {
      final auth = context.read<AuthProvider>();
      final groupProvider = context.read<GroupProvider>();
      final mensajes = await auth.mensajeService.listar(groupProvider.grupoActual!.id, limit: 100);
      final idsUsuarios = mensajes.map((m) => m.usuarioId).toSet();
      await auth.usuariosCache.precargar(idsUsuarios);
      for (final id in idsUsuarios) {
        _nombres[id] = auth.usuariosCache.nombreCacheado(id);
      }
      if (mounted) {
        setState(() => _mensajes = mensajes);
      }
    } catch (_) {
      // Silencioso: el chat se refresca periódicamente, no interrumpimos con errores.
    } finally {
      if (mounted && mostrarLoading) setState(() => _cargando = false);
    }
  }

  Future<void> _enviar() async {
    final texto = _mensajeCtrl.text.trim();
    if (texto.isEmpty) return;
    setState(() => _enviando = true);
    try {
      final auth = context.read<AuthProvider>();
      final groupProvider = context.read<GroupProvider>();
      await auth.mensajeService.enviar(grupoId: groupProvider.grupoActual!.id, contenido: texto);
      _mensajeCtrl.clear();
      await _cargar(mostrarLoading: false);
    } catch (e) {
      if (mounted) mostrarErrorSnackbar(context, e);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final miId = context.watch<AuthProvider>().usuarioActual?.id;
    final fmtHora = DateFormat('HH:mm');

    return AppScaffold(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      body: Column(
        children: [
          Text('Chat del grupo', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Expanded(
            child: _cargando
                ? const CargandoWidget()
                : _mensajes.isEmpty
                    ? const EstadoVacio(icono: Icons.chat_bubble_outline, titulo: 'Todavía no hay mensajes')
                    : ListView.builder(
                        controller: _scrollCtrl,
                        reverse: true,
                        itemCount: _mensajes.length,
                        itemBuilder: (context, index) {
                          final mensaje = _mensajes[index];
                          final esMio = mensaje.usuarioId == miId;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: esMio ? MainAxisAlignment.end : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (!esMio) ...[
                                  InicialAvatar(inicial: (_nombres[mensaje.usuarioId] ?? '?')[0].toUpperCase(), radio: 14),
                                  const SizedBox(width: 8),
                                ],
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: esMio ? AppColors.acento : Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(14),
                                      border: esMio ? null : Border.all(color: Theme.of(context).dividerColor),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (!esMio)
                                          Text(
                                            _nombres[mensaje.usuarioId] ?? 'Usuario #${mensaje.usuarioId}',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                                          ),
                                        Text(
                                          mensaje.contenido,
                                          style: TextStyle(color: esMio ? Colors.white : null),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          fmtHora.format(mensaje.enviadoEn),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: esMio ? Colors.white70 : Theme.of(context).textTheme.bodySmall?.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 8),
          SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mensajeCtrl,
                    decoration: const InputDecoration(hintText: 'Escribe un mensaje...'),
                    onSubmitted: (_) => _enviar(),
                    textInputAction: TextInputAction.send,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _enviando ? null : _enviar,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
