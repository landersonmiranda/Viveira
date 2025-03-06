import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projeto_viviera/providers/dark_mode_notifier.dart';
import 'package:projeto_viviera/screens/estudantes/adicionar.dart';
import 'package:projeto_viviera/screens/estudantes/visualizar.dart';
import 'package:projeto_viviera/screens/home_layout.dart';

class ListarEstudantePage extends ConsumerStatefulWidget {
  const ListarEstudantePage({super.key});

  @override
  ListarEstudantePageState createState() => ListarEstudantePageState();
}

class ListarEstudantePageState extends ConsumerState<ListarEstudantePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(darkModeProvider);

    return HomeLayout(
      title: 'Estudantes - Viveira',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar estudante pelo nome',
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
           
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdicionarEstudantePage()),
                  );

                  if (result != null) {
                   
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, 
                  minimumSize: const Size(150, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Adicionar Estudante",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
           
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('estudantes').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Nenhum estudante encontrado.'));
                  }

                  var estudantes = snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    data['id'] = doc.id;
                    return data;
                  }).toList();

               
                  var estudantesFiltrados = estudantes.where((estudante) {
                    String nome = (estudante['nome'] ?? '').toLowerCase();
                    return nome.contains(_searchText);
                  }).toList();

                  return ListView.builder(
                    itemCount: estudantesFiltrados.length,
                    itemBuilder: (context, index) {
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
                                  builder: (context) => VisualizarEstudantePage(
                                    estudanteId: estudantesFiltrados[index]['id'],
                                  ),
                                ),
                              );
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        estudantesFiltrados[index]['nome'] ?? 'Nome desconhecido',
                                        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black),
                                      ),
                                      Text(
                                        'Matrícula: ${estudantesFiltrados[index]['matricula'] ?? 'desconhecida'}',
                                        style: const TextStyle(fontSize: 14.0, color: Colors.black),
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
