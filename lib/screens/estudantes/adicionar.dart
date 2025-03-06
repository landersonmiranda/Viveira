import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:projeto_viviera/models/estudante.dart';
import 'package:projeto_viviera/controllers/estudante_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_viviera/providers/dark_mode_notifier.dart'; 
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:projeto_viviera/screens/home_layout.dart'; 

class AdicionarEstudantePage extends ConsumerStatefulWidget {
  const AdicionarEstudantePage({super.key});

  @override
  AdicionarEstudantePageState createState() => AdicionarEstudantePageState();
}

class AdicionarEstudantePageState
    extends ConsumerState<AdicionarEstudantePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _cpfController = TextEditingController();
  final _rgController = TextEditingController();
  final _certidaoController = TextEditingController();
  final _alergiasController = TextEditingController();
  final _restricoesController = TextEditingController();
  final _cuidadosController = TextEditingController();
  final _matriculaController =
      TextEditingController(); 
  XFile? _image;

  final EstudanteController _controller = EstudanteController();
  final PageController _pageController = PageController();

  final _certidaoInputFormatter = MaskTextInputFormatter(
                      mask: '######.##.##.####.#.#####.###.#######-##', 
                      filter: { "#": RegExp(r'[0-9]') },
                      type: MaskAutoCompletionType.lazy,
                    );
  final _rgInputFormatter = MaskTextInputFormatter(
                      mask: '##.###.###-#', 
                      filter: { "#": RegExp(r'[0-9]') },
                      type: MaskAutoCompletionType.lazy
                    );
  final _cpfInputFormatter = MaskTextInputFormatter(
                      mask: '###.###.###-##', 
                      filter: { "#": RegExp(r'[0-9]') },
                      type: MaskAutoCompletionType.lazy
                    );

  
  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  
  DateTime? parseDate(String date) {
    try {
      final parts = date.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future<void> _saveEstudante() async {
    if (_formKey.currentState?.validate() ?? false) {
     
      if (_matriculaController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, insira a matrícula')),
        );
        return; 
      }

     
      DateTime? dataNascimento = parseDate(_dataNascimentoController.text);
      if (dataNascimento == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data de nascimento inválida, utilize o formato dd/MM/yyyy')),
        );
        return;
      }

    
      final estudante = Estudante(
        nome: _nomeController.text,
        dataNascimento:
            Timestamp.fromDate(dataNascimento), 
        cpf: _cpfController.text,
        rg: _rgController.text,
        certidao: _certidaoController.text,
        fotoUrl: _image != null ? File(_image!.path).path : null,
        alergias: _alergiasController.text.isNotEmpty
            ? _alergiasController.text
            : 'Nenhuma alergia',
        restricoes: _restricoesController.text.isNotEmpty
            ? _restricoesController.text
            : 'Nenhuma restrição alimentar',
        cuidados: _cuidadosController.text.isNotEmpty
            ? _cuidadosController.text
            : 'Nenhum cuidado em especial',
        matricula: _matriculaController
            .text, 
      );

      try {
        await _controller.saveEstudante(estudante);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estudante salvo com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar estudante')),
        );
      } finally {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(darkModeProvider);
    onTapFunction({required BuildContext context}) async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        lastDate: DateTime.now(),
        firstDate: DateTime(1900),
        initialDate: _dataNascimentoController.text.isEmpty ? DateTime.now() : DateFormat('dd/MM/yyyy').parse(_dataNascimentoController.text),
        locale: const Locale('pt', 'BR')
      );
      if (pickedDate != null) {
      _dataNascimentoController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
  }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Novo Estudante'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.nightlight : Icons.wb_sunny),
            onPressed: () =>
                ref.read(darkModeProvider.notifier).toggleDarkMode(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: PageView(
            controller: _pageController,
            children: [
              Column(
                children: <Widget>[
                  GestureDetector(
                      onTap: _pickImage,
                      child: _image == null
                          ? CircleAvatar(
                              radius: 50, child: Icon(Icons.add_a_photo))
                          : CircleAvatar(
                              radius: 50,
                              backgroundImage: FileImage(File(_image!.path)))),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _nomeController,
                    decoration: InputDecoration(labelText: 'Nome'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o nome';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _dataNascimentoController,
                    decoration:
                        InputDecoration(labelText: 'Data de Nascimento'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a data de nascimento';
                      }

                      
                      final dataNascimento = parseDate(value);
                      if (dataNascimento == null) {
                        return 'Data de nascimento inválida, utilize o formato dd/MM/yyyy';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUnfocus,
                    onTap: () => onTapFunction(context: context),
                  ),
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Documentos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _cpfController,
                    decoration: InputDecoration(labelText: 'CPF'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o CPF';
                      }
                      if(_cpfInputFormatter.getUnmaskedText().length < 11) {
                        return 'São necessários 11 dígitos para o CPF';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUnfocus,
                    inputFormatters: [_cpfInputFormatter],
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _rgController,
                    decoration: InputDecoration(labelText: 'RG'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o RG';
                      }
                      if(_rgInputFormatter.getUnmaskedText().length < 9) {
                        return 'São necessários 9 dígitos para o RG';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUnfocus,
                    inputFormatters: [_rgInputFormatter],

                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _certidaoController,
                    decoration: InputDecoration(labelText: 'Certidão'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a certidão';
                      }
                      if(_certidaoInputFormatter.getUnmaskedText().length < 32) {
                        return 'São necessários 32 dígitos para a certidão';
                      }
                      return null;
                    },
                    inputFormatters: [_certidaoInputFormatter],
                    autovalidateMode: AutovalidateMode.onUnfocus,
                  ),
                  SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _matriculaController,
                    decoration: InputDecoration(labelText: 'Matrícula'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a matrícula';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUnfocus,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text('Próximo'),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  TextFormField(
                    controller: _alergiasController,
                    decoration: InputDecoration(labelText: 'Alergias'),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _restricoesController,
                    maxLines: 2,
                    decoration:
                        InputDecoration(labelText: 'Restrições Alimentares'),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _cuidadosController,
                    decoration: InputDecoration(labelText: 'Cuidados'),
                    maxLines: 2,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text('Anterior'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveEstudante,
                    child: Text('Salvar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
