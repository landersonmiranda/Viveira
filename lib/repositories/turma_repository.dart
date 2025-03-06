import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_viviera/models/turma.dart';

class TurmaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Salva uma nova turma na coleção 'turmas'
  Future<void> saveTurma(Turma turma) async {
    try {
      await _firestore.collection('turmas').add(turma.toMap());
    } catch (e) {
      throw Exception('Erro ao salvar turma: $e');
    }
  }

  /// Atualiza os dados de uma turma já existente
  Future<void> updateTurma(String turmaId, Turma turma) async {
    try {
      await _firestore.collection('turmas').doc(turmaId).update(turma.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar turma: $e');
    }
  }

  /// Adiciona o ID de um estudante à lista de estudantes da turma
  Future<void> adicionarEstudante(String turmaId, String estudanteId) async {
    try {
      await _firestore.collection('turmas').doc(turmaId).update({
        'estudantes': FieldValue.arrayUnion([estudanteId]),
      });
    } catch (e) {
      throw Exception('Erro ao adicionar estudante à turma: $e');
    }
  }

  /// Remove o ID de um estudante da lista de estudantes da turma
  Future<void> removerEstudante(String turmaId, String estudanteId) async {
    try {
      await _firestore.collection('turmas').doc(turmaId).update({
        'estudantes': FieldValue.arrayRemove([estudanteId]),
      });
    } catch (e) {
      throw Exception('Erro ao remover estudante da turma: $e');
    }
  }
  Future<Map<String, dynamic>> buscarTurma(String turmaId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('turmas').doc(turmaId).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        throw Exception('Turma não encontrada');
      }
    } catch (e) {
      throw Exception('Erro ao buscar turma: $e');
    }
  }
}

