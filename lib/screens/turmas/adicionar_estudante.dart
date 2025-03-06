import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projeto_viviera/providers/dark_mode_notifier.dart';
import 'package:projeto_viviera/repositories/turma_repository.dart';
import 'package:projeto_viviera/screens/home_layout.dart';  

class AdicionarEstudanteTurmaPage extends ConsumerWidget {
  final String turmaId;

  const AdicionarEstudanteTurmaPage({Key? key, required this.turmaId})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);
    final turmaRepository = TurmaRepository();

    return HomeLayout( 
      title: 'Adicionar Estudante',  // Título reduzido
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
          
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar estudante',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('estudantes')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('Erro ao carregar estudantes.'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('Nenhum estudante encontrado.'));
                  }

                  final estudantes = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: estudantes.length,
                    itemBuilder: (context, index) {
                      final estudanteDoc = estudantes[index];
                      final estudante =
                          estudanteDoc.data() as Map<String, dynamic>;

                      final nome = estudante['nome'] != null
                          ? estudante['nome']
                          : 'Nome desconhecido';
                      final cpf = estudante['cpf'] != null
                          ? estudante['cpf']
                          : 'CPF desconhecido';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          color: Colors.orange.shade200, 
                          child: InkWell(
                            onTap: () async {
                              try {
                                await turmaRepository.adicionarEstudante(
                                    turmaId, estudanteDoc.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          '$nome adicionado à turma com sucesso!')),
                                );
                                Navigator.pop(context);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Erro ao adicionar estudante: $e')),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nome,
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        cpf,
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
