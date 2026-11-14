import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app/tema.dart';
import '../servicos/foto_usuario.dart';
import '../utils/mensagens.dart';

/// Avatar do usuário: a foto salva ou o ícone de pessoa.
class AvatarUsuario extends StatelessWidget {
  final double raio;
  final Color fundo;
  final Color corIcone;

  /// Mostra o botão de câmera e abre as opções de foto ao tocar.
  final bool editavel;

  const AvatarUsuario({
    super.key,
    this.raio = 25,
    this.fundo = Colors.white,
    this.corIcone = GaspoCores.azulCabecalho,
    this.editavel = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FotoUsuario.instancia,
      builder: (context, _) {
        final bytes = FotoUsuario.instancia.bytes;
        final avatar = CircleAvatar(
          radius: raio,
          backgroundColor: fundo,
          backgroundImage: bytes == null ? null : MemoryImage(bytes),
          child: bytes == null ? Icon(Icons.person, size: raio * 1.2, color: corIcone) : null,
        );
        if (!editavel) return avatar;

        return Semantics(
          button: true,
          label: 'Alterar foto do perfil',
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => mostrarOpcoesFoto(context),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                avatar,
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: GaspoCores.azul,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.photo_camera, size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Opções de foto: câmera, galeria e (se houver) remover.
Future<void> mostrarOpcoesFoto(BuildContext context, {ImagePicker? picker}) async {
  final origem = await showModalBottomSheet<Object>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.photo_camera_outlined, color: context.cores.destaque),
            title: const Text('Tirar foto'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: Icon(Icons.photo_library_outlined, color: context.cores.destaque),
            title: const Text('Escolher da galeria'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          if (FotoUsuario.instancia.temFoto)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Remover foto', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context, 'remover'),
            ),
        ],
      ),
    ),
  );
  if (origem == null || !context.mounted) return;

  if (origem == 'remover') {
    await FotoUsuario.instancia.remover();
    if (context.mounted) mostrarMensagem(context, 'Foto removida.');
    return;
  }

  try {
    final arquivo = await (picker ?? ImagePicker()).pickImage(
      source: origem as ImageSource,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (arquivo == null) return;
    await FotoUsuario.instancia.definir(await arquivo.readAsBytes());
    if (context.mounted) mostrarMensagem(context, 'Foto atualizada.');
  } catch (_) {
    if (context.mounted) {
      mostrarMensagem(context, 'Não foi possível abrir a ${origem == ImageSource.camera ? 'câmera' : 'galeria'}.');
    }
  }
}
