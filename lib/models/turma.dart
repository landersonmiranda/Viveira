class Turma {
  final String nome;
  final String descricao;
  final String? fotoUrl;
  final List<String> estudantes; // IDs dos estudantes vinculados

  Turma({
    required this.nome,
    required this.descricao,
    this.fotoUrl,
    this.estudantes = const [],
  });

  // Converte o objeto Turma em um mapa para enviar ao Firestore
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'fotoUrl': fotoUrl,
      'estudantes': estudantes,
    };
  }

  // Converte um mapa (de um documento Firestore) em um objeto Turma
  factory Turma.fromMap(Map<String, dynamic> map) {
    return Turma(
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      fotoUrl: map['fotoUrl'],
      estudantes: List<String>.from(map['estudantes'] ?? []),
    );
  }
}
