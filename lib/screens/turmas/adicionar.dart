import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projeto_viviera/controllers/turma_controller.dart';
import 'package:projeto_viviera/models/turma.dart';
import 'package:projeto_viviera/providers/dark_mode_notifier.dart';
import 'package:projeto_viviera/screens/home_layout.dart';  

class AdicionarTurmaPage extends ConsumerStatefulWidget {
  const AdicionarTurmaPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AdicionarTurmaPage> createState() => _AdicionarTurmaPageState();
}

class _AdicionarTurmaPageState extends ConsumerState<AdicionarTurmaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  bool _isLoading = false;

  final TurmaController turmaController = TurmaController();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(darkModeProvider);

    return HomeLayout(  
      title: 'Nova Turma',  
      child: Padding(
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
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });

                          Turma novaTurma = Turma(
                            nome: _nomeController.text,
                            descricao: _descricaoController.text,
                            // Se necessário, defina fotoUrl após upload da imagem
                          );

                          try {
                            await turmaController.saveTurma(novaTurma);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Turma salva com sucesso'),
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
