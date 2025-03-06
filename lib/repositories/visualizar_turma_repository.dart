import 'package:cloud_firestore/cloud_firestore.dart';

class VisualizarTurmaRepository {
  /// Busca os dados de uma turma pelo ID
  Future<Map<String, dynamic>> buscarTurma(String turmaId) async {
    var turmaDoc = await FirebaseFirestore.instance
        .collection('turmas')
        .doc(turmaId)
        .get();
    return turmaDoc.data() ?? {};
  }

  /// Exclui a turma da coleção 'turmas'
  Future<void> deletarTurma(String turmaId) async {
    await FirebaseFirestore.instance.collection('turmas').doc(turmaId).delete();
  }
}
