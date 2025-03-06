import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projeto_viviera/controllers/visualizar_controller.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_viviera/providers/dark_mode_notifier.dart';
import 'package:projeto_viviera/screens/home_layout.dart';

class VisualizarEstudantePage extends ConsumerWidget {
  final String estudanteId;

  const VisualizarEstudantePage({super.key, required this.estudanteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);
    return HomeLayout(
      title: 'Detalhes do Estudante',  
      child: StreamBuilder<Map<String, dynamic>>(
        stream: VisualizarController().observarEstudante(estudanteId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Estudante não encontrado.'));
          }

          var estudante = snapshot.data!;

        
          var dataNascimento = estudante['dataNascimento'] != null
              ? (estudante['dataNascimento'] as Timestamp).toDate()
              : null;

          String dataNascimentoFormatada = dataNascimento != null
              ? DateFormat('dd/MM/yyyy').format(dataNascimento)
              : 'Data não informada';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      child: Icon(Icons.person, size: 40),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Text(
                        estudante['nome'] ?? 'Nome desconhecido',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange, 
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await VisualizarController()
                            .deletarEstudante(estudanteId, context);
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        VisualizarController().editarEstudante(estudanteId, context);
                      },
                      child: Text('Editar'),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Text(
                  'Matrícula: ${estudante['matricula'] ?? 'Matrícula desconhecida'}',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black, // Texto preto
                  ),
                ),
                SizedBox(height: 24.0),
                Text(
                  'Informações Pessoais',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange, 
                  ),
                ),
                SizedBox(height: 8.0),
                Text('Data de nascimento: $dataNascimentoFormatada'),
                Text('CPF: ${estudante['cpf'] ?? 'Desconhecido'}'),
                Text('RG: ${estudante['rg'] ?? 'Desconhecido'}'),
                Text('Nº Certidão: ${estudante['certidao'] ?? 'Desconhecido'}'),
                SizedBox(height: 24.0),
                Text(
                  'Saúde',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange, 
                  ),
                ),
                SizedBox(height: 8.0),
                Text('Alergias: ${estudante['alergias'] ?? '-'}'),
                Text('Restrições Alimentares: ${estudante['restricoes'] ?? '-'}'),
                Text(
                  'Cuidados: ${estudante['cuidados'] ?? 'Nenhum cuidado especial.'}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0, 
                  ),
                  textAlign: TextAlign.justify, 
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
