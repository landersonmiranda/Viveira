import 'package:flutter/material.dart';
import 'package:projeto_viviera/screens/estudantes/editar_estudante.dart';
import 'package:projeto_viviera/repositories/visualizar_repository.dart';

class VisualizarController {
  final VisualizarRepository _repository = VisualizarRepository();

  Stream<Map<String, dynamic>> observarEstudante(String estudanteId) {
    return _repository.observarEstudante(estudanteId);
  }
  
  Future<Map<String, dynamic>> buscarEstudante(String estudanteId) {
    return _repository.buscarEstudante(estudanteId);
  }

  Future<void> deletarEstudante(
      String estudanteId, BuildContext context) async {
    try {
      await _repository.deletarEstudante(estudanteId);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estudante excluído com sucesso')));
      Navigator.pop(context); // Retorna para a tela anterior após excluir
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao excluir estudante')));
    }
  }

  void editarEstudante(String estudanteId, BuildContext context) {
    // Navegar para a tela de edição
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarEstudantePage(
            estudanteId: estudanteId), // Certifique-se de que essa tela existe
      ),
    );
  }
}
