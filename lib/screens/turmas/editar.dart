import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projeto_viviera/controllers/turma_controller.dart';
import 'package:projeto_viviera/controllers/visualizar_turma_controller.dart';
import 'package:projeto_viviera/models/turma.dart';
import 'package:projeto_viviera/providers/dark_mode_notifier.dart';
import 'package:projeto_viviera/screens/home_layout.dart';  

class EditarTurmaPage extends ConsumerStatefulWidget {
  final String turmaId;
  const EditarTurmaPage({super.key, required this.turmaId});

  @override
  ConsumerState<EditarTurmaPage> createState() => _EditarTurmaPageState();
}

class _EditarTurmaPageState extends ConsumerState<EditarTurmaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  bool _isLoading = false;

  final TurmaController turmaController = TurmaController();
  final VisualizarTurmaController visualizarTurmaController =
      VisualizarTurmaController();

  List<String> _estudantes = []; 

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
      final turmaData =
          await visualizarTurmaController.buscarTurma(widget.turmaId);
      _nomeController.text = turmaData['nome'] ?? '';
      _descricaoController.text = turmaData['descricao'] ?? '';
      _estudantes = List<String>.from(
          turmaData['estudantes'] ?? []); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e')),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(darkModeProvider);

    return HomeLayout(
      title: 'Editar Turma',  
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o nome';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descricaoController,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a descrição';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });

                          Turma turmaAtualizada = Turma(
                            nome: _nomeController.text,
                            descricao: _descricaoController.text,
                            estudantes: _estudantes,
                          );

                          try {
                            await turmaController.updateTurma(
                                widget.turmaId, turmaAtualizada);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Turma atualizada com sucesso'),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro: $e')),
                            );
                          }
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
