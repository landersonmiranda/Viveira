import 'package:flutter/material.dart';
import 'package:projeto_viviera/screens/turmas/editar.dart';
import 'package:projeto_viviera/repositories/visualizar_turma_repository.dart';

class VisualizarTurmaController {
  final VisualizarTurmaRepository _repository = VisualizarTurmaRepository();

  /// Busca os dados de uma turma pelo ID
  Future<Map<String, dynamic>> buscarTurma(String turmaId) {
    return _repository.buscarTurma(turmaId);
  }

  /// Exclui uma turma e exibe uma mensagem de sucesso ou erro
  Future<void> deletarTurma(String turmaId, BuildContext context) async {
    try {
      await _repository.deletarTurma(turmaId);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Turma excluída com sucesso')),
      );
      Navigator.pop(context); // Retorna para a tela anterior
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir turma')),
      );
    }
  }

  /// Navega para a tela de edição da turma
  void editarTurma(String turmaId, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarTurmaPage(
            turmaId: turmaId), // Certifique-se que essa tela está implementada
      ),
    );
  }
}
