import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projeto_viviera/providers/dark_mode_notifier.dart';
import 'package:projeto_viviera/screens/turmas/adicionar.dart';
import 'package:projeto_viviera/screens/turmas/visualizar.dart';
import 'package:projeto_viviera/screens/home_layout.dart'; 

class ListarTurmaPage extends ConsumerStatefulWidget {
  const ListarTurmaPage({super.key});

  @override
  ListarTurmaPageState createState() => ListarTurmaPageState();
}

class ListarTurmaPageState extends ConsumerState<ListarTurmaPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(darkModeProvider);
    final turmasCollection = FirebaseFirestore.instance.collection('turmas');

    return HomeLayout(  
      title: 'Turmas', 
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
           
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar turma pelo nome',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 16.0),
            // Botão Adicionar Turma
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdicionarTurmaPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, 
                  minimumSize: const Size(200, 50),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Adicionar Turma", 
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: turmasCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Erro ao carregar turmas'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final turmas = snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    data['id'] = doc.id;
                    return data;
                  }).toList();

                  // Filtrando as turmas pelo nome
                  var turmasFiltradas = turmas.where((turma) {
                    String nome = (turma['nome'] ?? '').toLowerCase();
                    return nome.contains(_searchText);
                  }).toList();

                  if (turmasFiltradas.isEmpty) {
                    return const Center(child: Text('Nenhuma turma encontrada'));
                  }

                  return ListView.builder(
                    itemCount: turmasFiltradas.length,
                    itemBuilder: (context, index) {
                      final turma = turmasFiltradas[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          color: Colors.orange.shade200, 
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      VisualizarTurmaPage(turmaId: turma['id']),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                
                                  turma['fotoUrl'] != null
                                      ? Image.network(
                                          turma['fotoUrl'],
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        )
                                      : const Placeholder(
                                          fallbackWidth: 80,
                                          fallbackHeight: 80,
                                        ),
                                  const SizedBox(width: 16.0),
                                  Text(
                                    turma['nome'] ?? 'Sem nome',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
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
