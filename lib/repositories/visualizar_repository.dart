import 'package:cloud_firestore/cloud_firestore.dart';

class VisualizarRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<Map<String, dynamic>> buscarEstudante(String estudanteId) async {
    var estudanteDoc = await FirebaseFirestore.instance.collection('estudantes').doc(estudanteId).get();
    return estudanteDoc.data() ?? {};
  }

  Future<void> deletarEstudante(String estudanteId) async {
    await FirebaseFirestore.instance.collection('estudantes').doc(estudanteId).delete();
  }
  

  Stream<Map<String, dynamic>> observarEstudante(String estudanteId) {
    return _firestore
        .collection('estudantes')
        .doc(estudanteId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return {};
          var data = snapshot.data()!;
          data['id'] = snapshot.id;
          return data;
        });
  }


}
