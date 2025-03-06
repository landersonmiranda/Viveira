import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_viviera/models/estudante.dart';

class EstudanteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveEstudante(Estudante estudante) async {
    try {
      await _firestore.collection('estudantes').add(estudante.toMap());
    } catch (e) {
      throw Exception('Erro ao salvar estudante: $e');
    }
  }
}
