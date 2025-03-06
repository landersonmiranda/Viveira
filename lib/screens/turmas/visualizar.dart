import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projeto_viviera/controllers/visualizar_turma_controller.dart';
import 'package:projeto_viviera/providers/dark_mode_notifier.dart';
import 'package:projeto_viviera/repositories/turma_repository.dart';
import 'package:projeto_viviera/screens/turmas/editar.dart';
import 'package:projeto_viviera/screens/turmas/adicionar_estudante.dart';
import 'package:projeto_viviera/screens/home_layout.dart';  

class VisualizarTurmaPage extends ConsumerStatefulWidget {
  final String turmaId;
  const VisualizarTurmaPage({super.key, required this.turmaId});

  @override
  ConsumerState<VisualizarTurmaPage> createState() =>
      _VisualizarTurmaPageState();
}

class _VisualizarTurmaPageState extends ConsumerState<VisualizarTurmaPage> {
  final VisualizarTurmaController _controller = VisualizarTurmaController();
  Map<String, dynamic>? turmaData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTurma();
  }

  Future<void> _loadTurma() async {
    setState(() {
      _isLoading = true;
    });
    try {
      turmaData = await _controller.buscarTurma(widget.turmaId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar turma: $e')),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(darkModeProvider);

    return HomeLayout(
      title: turmaData?['nome'] ?? 'Turma',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : turmaData == null
              ? const Center(child: Text('Nenhuma turma encontrada'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Descrição',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditarTurmaPage(turmaId: widget.turmaId),
                                    ),
                                  ).then((_) => _loadTurma());
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await _controller.deletarTurma(widget.turmaId, context);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Text(turmaData?['descricao'] ?? ''),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                         
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdicionarEstudanteTurmaPage(
                                  turmaId: widget.turmaId),
                            ),
                          ).then((_) => _loadTurma());
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 36),
                        ),
                        child: const Text('Adicionar estudante'),
                      ),
                      const SizedBox(height: 16.0),
                      const Text(
                        'Estudantes',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16.0),
                      Expanded(
                        child: (turmaData?['estudantes'] as List<dynamic>?) == null ||
                                (turmaData?['estudantes'] as List<dynamic>).isEmpty
                            ? const Center(
                                child: Text('Nenhum estudante vinculado'))
                            : ListView.builder(
                                itemCount:
                                    (turmaData?['estudantes'] as List<dynamic>?)
                                       ?.length ,
                                itemBuilder: (context, index) {
                                  final estudanteId = (turmaData?['estudantes']
                                      as List<dynamic>)[index];
                                  return ListTile(
                                    leading: const CircleAvatar(
                                        child: Icon(Icons.person)),
                                    title: FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection('estudantes')
                                          .doc(estudanteId)
                                          .get(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Text('Carregando...');
                                        }
                                        if (!snapshot.hasData ||
                                            !snapshot.data!.exists) {
                                          return const Text(
                                              'Estudante desconhecido');
                                        }
                                        final estudanteData = snapshot.data!
                                            .data() as Map<String, dynamic>;
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              estudanteData['nome'] ?? 'Nome desconhecido',
                                              style: const TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'CPF: ${estudanteData['cpf'] ?? 'Desconhecido'}',
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.black
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        try {
                                          await TurmaRepository()
                                              .removerEstudante(widget.turmaId, estudanteId);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Estudante removido da turma com sucesso'),
                                            ),
                                          );
                                         
                                          _loadTurma();
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Erro ao remover estudante: $e'),
                                            ),
                                          );
                                        }
                                      },
                                    ),
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
