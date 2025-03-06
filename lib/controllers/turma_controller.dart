import 'package:projeto_viviera/models/turma.dart';
import 'package:projeto_viviera/repositories/turma_repository.dart';

class TurmaController {
  final TurmaRepository _repository = TurmaRepository();

  /// Salva uma nova turma no Firestore
  Future<void> saveTurma(Turma turma) async {
    // Validação simples: campos obrigatórios não podem estar vazios
    if (turma.nome.isEmpty || turma.descricao.isEmpty) {
      throw Exception('Campos obrigatórios não preenchidos');
    }
    await _repository.saveTurma(turma);
  }

  /// Atualiza os dados de uma turma existente
  Future<void> updateTurma(String turmaId, Turma turma) async {
  try {
    // Recupera a turma atual para preservar os estudantes
    var turmaData = await _repository.buscarTurma(turmaId);

    
    List<String> currentEstudantes = turmaData['estudantes'] is List
        ? List<String>.from(turmaData['estudantes'])
        : []; 

    // Atualiza a turma, preservando a lista de estudantes
    Turma updatedTurma = Turma(
      nome: turma.nome,
      descricao: turma.descricao,
      estudantes: currentEstudantes,
    );

    await _repository.updateTurma(turmaId, updatedTurma);
  } catch (e) {
    throw Exception('Erro ao atualizar turma: $e');
  }
}
}
