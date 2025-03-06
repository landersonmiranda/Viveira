import 'package:projeto_viviera/models/estudante.dart';
import 'package:projeto_viviera/repositories/estudante_repository.dart';

class EstudanteController {
  final EstudanteRepository _repository = EstudanteRepository();

  Future<void> saveEstudante(Estudante estudante) async {
    if (estudante.nome.isEmpty || estudante.cpf.isEmpty) {
      throw Exception('Campos obrigatórios não preenchidos');
    }

    await _repository.saveEstudante(estudante);
  }
}
