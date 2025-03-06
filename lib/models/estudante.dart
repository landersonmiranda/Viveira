import 'package:cloud_firestore/cloud_firestore.dart';

class Estudante {
  final String nome;
  final Timestamp dataNascimento;
  final String cpf;
  final String rg;
  final String certidao;
  final String? fotoUrl;
  final String alergias;
  final String restricoes;
  final String cuidados;
  final String matricula; 

  Estudante({
    required this.nome,
    required this.dataNascimento,
    required this.cpf,
    required this.rg,
    required this.certidao,
    this.fotoUrl,
    required this.alergias,
    required this.restricoes,
    required this.cuidados,
    required this.matricula,  
  });

  
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'dataNascimento': dataNascimento,
      'cpf': cpf,
      'rg': rg,
      'certidao': certidao,
      'fotoUrl': fotoUrl,
      'alergias': alergias,
      'restricoes': restricoes,
      'cuidados': cuidados,
      'matricula': matricula,  
    };
  }

  
  factory Estudante.fromMap(Map<String, dynamic> map) {
    return Estudante(
      nome: map['nome'],
      dataNascimento: map['dataNascimento'],
      cpf: map['cpf'],
      rg: map['rg'],
      certidao: map['certidao'],
      fotoUrl: map['fotoUrl'],
      alergias: map['alergias'],
      restricoes: map['restricoes'],
      cuidados: map['cuidados'],
      matricula: map['matricula'],  
    );
  }
}
