// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path/path.dart' as path;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Sinalização',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {



}

class MyHomePage extends StatefulWidget{
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context){
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = VerticalSinLancar();
        break;
      case 1: 
        page = MostrarDados();
        break;
      case 2:
        page = HorizontalSinLancar();
        break;
      case 3:
        page = HorizontalMostrarDados();
        break;
      default:
        throw UnimplementedError('sem tela pra isso');
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Column(
            children: [
              Expanded(
                child: Container(
                  color:Theme.of(context).colorScheme.primaryContainer,
                  child:page,
                ),
              ),
                SafeArea(child: NavigationBar(
                //extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationDestination(
                    icon: Icon(Icons.assignment_add),
                    //label: Text('Lançar Vertical'),
                    label: 'Novo Ver.'
                    ),
                  NavigationDestination(
                    icon: Icon(Icons.assignment),
                    //label: Text('Ver Lançamentos')
                    label:'Ver.'
                    ),
                  NavigationDestination(
                    icon: Icon(Icons.add_road),
                    //label: Text('Lançar Horizontal')
                    label:'Novo Hor.'
                  ),
                  NavigationDestination(
                    icon:Icon(Icons.edit_road_sharp),
                    //label:Text('Lançamentos Hor.')
                    label:"Hor."
                  )
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState((){
                      selectedIndex = value;
                    });
                  },
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  indicatorColor: Theme.of(context).colorScheme.secondaryFixedDim,
                )
              ),
            ],
          ),
        );
      }
    );
  }
}

//pagina pra lançar a sinalização vertical
class VerticalSinLancar extends StatefulWidget {
  @override
  _VerticalSinLancarState createState() => _VerticalSinLancarState();
}

class _VerticalSinLancarState extends State<VerticalSinLancar> {
  final Map<String, TextEditingController> controllers = {};
  final Map<String, TextEditingController> dadosCor1 = {};
  final Map<String, TextEditingController> dadosCor2 = {};
  final Map<String, TextEditingController> dadosCor3 = {};

  String? caminhoImagem;

  String? _coordenadas;

  Future<void> _getCoordenadas() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se o serviço de localização está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Caso não esteja habilitado, você pode solicitar ao usuário para habilitar
      print('Serviço de localização desativado.');
      return;
    }

    // Verifica o status da permissão de localização
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Permissão de localização negada.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Se a permissão foi negada permanentemente, o app não pode usar o serviço
      print('Permissão de localização permanentemente negada.');
      return;
    }

    // Se todas as permissões forem concedidas, obtém a posição atual
    Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.best));

    setState(() {
      _coordenadas = '${position.latitude}, ${position.longitude}';
    });
  }


  //parte da lista das rodovias (se der errado apaga essa merda)

  List<String> rodovias = ['MT-220', 'MT-320', 'PI-397', 'PI-262'];
  String? _rodoviaSelecionada;

  List<String> formatos = ['Circular','Retangular'];
  String? _formatoSelecionado;  

  List<String> cores = ['Verde','Amarelo','Azul','Vermelho','Preto','Branco'];
  String? _cor1;
  String? _cor2;
  String? _cor3;


// cria o formulario
  @override
  void initState() {
    super.initState();
    //controllers['Rodovia'] = TextEditingController();
    controllers['Km'] = TextEditingController();
    controllers['Posição'] = TextEditingController();
    controllers['Sentido'] = TextEditingController();
    controllers['Observação'] = TextEditingController();
    controllers['Mensagem'] = TextEditingController();
    controllers['Fabricação'] = TextEditingController();
    controllers['Fabricante'] = TextEditingController();
    controllers['Largura'] = TextEditingController();
    controllers['Altura'] = TextEditingController();
    controllers['Altura'] = TextEditingController();


    //dadosCor1['Cor1'] = TextEditingController();
    dadosCor1['Tipo-1'] = TextEditingController();
    dadosCor1['M1-1'] = TextEditingController();
    dadosCor1['M2-1'] = TextEditingController();
    dadosCor1['M3-1'] = TextEditingController();
    dadosCor1['M4-1'] = TextEditingController();
    dadosCor1['M5-1'] = TextEditingController();

    //dadosCor2['Cor2'] = TextEditingController();
    dadosCor2['Tipo-2'] = TextEditingController();
    dadosCor2['M1-2'] = TextEditingController();
    dadosCor2['M2-2'] = TextEditingController();
    dadosCor2['M3-2'] = TextEditingController();
    dadosCor2['M4-2'] = TextEditingController();
    dadosCor2['M5-2'] = TextEditingController();

    //dadosCor3['Cor3'] = TextEditingController();
    dadosCor3['Tipo-3'] = TextEditingController();
    dadosCor3['M1-3'] = TextEditingController();
    dadosCor3['M2-3'] = TextEditingController();
    dadosCor3['M3-3'] = TextEditingController();
    dadosCor3['M4-3'] = TextEditingController();
    dadosCor3['M5-3'] = TextEditingController();
  }

  Future<void> _tirarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 600);

    if (pickedFile != null) {
      setState(() {
        caminhoImagem = pickedFile.path;
      });

      // Salvar o caminho da imagem no arquivo
      await _salvarCaminhoImagem(caminhoImagem!);

      // Obter o diretório de armazenamento permanente
      final Directory appDir = await getApplicationDocumentsDirectory();
      
      // Criar um caminho único para a imagem no diretório de armazenamento
      final String fileName = path.basename(pickedFile.path);
      final String newPath = path.join(appDir.path, fileName);

      // Copiar a imagem para o novo local
      final File savedImage = await File(pickedFile.path).copy(newPath);

      // Salvar o novo caminho da imagem no arquivo (caso necessário)
      await _salvarCaminhoImagem(savedImage.path);
    }
  }

  Future<void> _salvarCaminhoImagem(String caminho) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/dados.txt');

    // Adiciona o caminho da imagem ao arquivo
    await file.writeAsString('Caminho da Imagem: $caminho\n', mode: FileMode.append);
    print('Caminho da imagem salvo em: ${file.path}');
  }


  Future<void> _salvarDados() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/dados.json'); // Altere para .json

    // Cria um mapa para armazenar os dados
    Map<String, dynamic> dados = {};

    controllers.forEach((key, controller) {
      dados[key] = controller.text; // Armazena cada campo no mapa
    });

    dadosCor1.forEach((key, controller) {
      dados[key] = controller.text;
    });

    dadosCor2.forEach((key, controller) {
      dados[key] = controller.text;
    });

    dadosCor3.forEach((key, controller) {
      dados[key] = controller.text;
    });    

    dados['coordenadas'] = _coordenadas ?? 'Coordenadas não disponíveis';
    dados['rodovia'] = _rodoviaSelecionada ?? 'Rodovia Não Selecionada';
    dados['formato'] = _formatoSelecionado ?? 'Formato não especificado';
    dados['cor1'] = _cor1 ?? 'Cor 1 Não Especificada';
    dados['cor2'] = _cor2 ?? 'Cor 2 Não Especificada';
    dados['cor3'] = _cor3 ?? 'Cor 3 Não Especificada';

    // Adiciona o nome da imagem ao mapa, se existir
    if (caminhoImagem != null) { // Verifique se a imagem foi capturada
      dados['imagem'] = caminhoImagem!.split('/').last; // Salva apenas o nome da imagem
    }

    // Converte o mapa em uma string JSON
    String jsonDados = jsonEncode(dados);

    // Adiciona os dados ao arquivo
    await file.writeAsString('$jsonDados\n', mode: FileMode.append);
    print('Dados salvos em: ${file.path}');

    // Limpa os campos do formulário
    controllers.forEach((key, controller) {
      controller.clear(); // Limpa o campo
    });

    // Limpa o caminho da imagem
    caminhoImagem = null;


    // Exibe uma confirmação na interface
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dados salvos com sucesso!')),
    );
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Titulo(nomePagina: 'Sin. Vertical',)
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
                value: _rodoviaSelecionada,
                decoration: InputDecoration(
                  labelText: 'Rodovia',
                ),
                items: rodovias.map((String rodovia) {
                  return DropdownMenuItem<String>(
                    value: rodovia,
                    child: Text(rodovia),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _rodoviaSelecionada = newValue; // Atualiza o valor selecionado
                  });
                },
              ),
            SizedBox(height: 20),
            TextFormField(
              controller: controllers['Km'],
              decoration: InputDecoration(
                labelText: 'Km',
              ),
              keyboardType: TextInputType.number, // Teclado numérico
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // Aceita números decimais
                ],
                ),
              ...controllers.keys.map((key) {
                  return Visibility(
                    visible: key != 'Km',
                    child: TextField(
                      controller: controllers[key],
                      decoration: InputDecoration(labelText: key),
                  ),
                );
              }).toList(),
            DropdownButtonFormField<String>(
              value: _formatoSelecionado,
              decoration: InputDecoration(
                labelText: 'Formato',
              ),
              items: formatos.map((String formato){
                return DropdownMenuItem<String> (
                  value: formato,
                  child: Text(formato),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _formatoSelecionado = newValue;
                });
              },
            ),
            SizedBox(height: 40,),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: TextEditingController(text: _coordenadas ?? ''),
                    decoration: InputDecoration(
                      labelText: 'Coordenadas',
                    ),
                    readOnly: true,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _getCoordenadas,
                  label: Text('Local'),
                  icon: Icon(Icons.gps_fixed_rounded)
                )
              ],
            ),
            SizedBox(height: 40,),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      DropdownButtonFormField(
                        value: _cor1,
                        decoration: InputDecoration(
                          labelText: 'Cor 1'
                        ),
                        items: cores.map((String cor) {
                          return DropdownMenuItem<String>(
                            value: cor,
                            child: Text(cor),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _cor1 = newValue;
                          });
                        }
                      ),
                      SizedBox(height: 10,),
                      ...dadosCor1.keys.map((key){
                          return Column(
                            children: [
                              TextField(
                              controller: dadosCor1[key],
                              decoration: InputDecoration(
                                labelText: key,
                              ),
                              keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter> [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                              ),
                              SizedBox(height: 10,),
                            ],
                          ); 
                      }).toList(),
                    ],
                  ),
                ),
                SizedBox(width: 20,),
                Expanded(
                  child: Column(
                    children: [
                      DropdownButtonFormField(
                        value: _cor2,
                        decoration: InputDecoration(
                          labelText: 'Cor 2'
                        ),
                        items: cores.map((String cor) {
                          return DropdownMenuItem<String>(
                            value: cor,
                            child: Text(cor),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _cor2 = newValue;
                          });
                        }
                      ),
                      SizedBox(height: 10,),
                      ...dadosCor2.keys.map((key){
                          return Column(
                            children: [
                              TextField(
                              controller: dadosCor2[key],
                              decoration: InputDecoration(labelText: key),
                              keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter> [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                              ),
                              SizedBox(height: 10,),
                            ],
                          ); 
                      }).toList()
                    ],
                  ),
                ),
                SizedBox(width: 20,),
                Expanded(
                  child: Column(
                    children: [
                      DropdownButtonFormField(
                        value: _cor3,
                        decoration: InputDecoration(
                          labelText: 'Cor 3'
                        ),
                        items: cores.map((String cor) {
                          return DropdownMenuItem<String>(
                            value: cor,
                            child: Text(cor),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _cor3 = newValue;
                          });
                        }
                      ),
                      SizedBox(height: 10,),
                      ...dadosCor3.keys.map((key){
                          return Column(
                            children: [
                              TextField(
                              controller: dadosCor3[key],
                              decoration: InputDecoration(labelText: key),
                              keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter> [
                                   FilteringTextInputFormatter.digitsOnly
                              ],
                              ),
                              SizedBox(height: 10,)
                            ],
                          );
                      }).toList(),
                      
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30,),
            ElevatedButton.icon(
              onPressed: _tirarFoto,
              label: Text('Tirar Foto'),
              icon: Icon(Icons.camera_alt)
            ),
            SizedBox(height: 20),
            if (caminhoImagem != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(
                  File(caminhoImagem!),
                  width: 300,
                  height: 300,
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _salvarDados,
              child: Text('Salvar Dados'),
            ),
          ],
        ),
      ),
    );
  }
}

//pagina pra mostar sinalização vertical
class MostrarDados extends StatefulWidget {
  @override
  _MostrarDadosState createState() => _MostrarDadosState();
}

class _MostrarDadosState extends State<MostrarDados> {
  String dados = '';
  String _conteudo = '';
  int _numeroDeLinhas = 0;
  String _kmUltimoLancamento = '';
  String _rodoviaUltimoLancamento = '';

  Future<void> _compartilharArquivo() async {
    File arquivo = await _zipPasta();
    //final directory = await getApplicationDocumentsDirectory();
    final result = await Share.shareXFiles([XFile(arquivo.path)], text: 'Levantamento de Sinalização Vertical');

    if (result.status == ShareResultStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dados compartilhados com sucesso')),
    );
    }
  }

  Future<File> _zipPasta() async {
    final dataDir = await getApplicationDocumentsDirectory();
    final zipDir = await getApplicationCacheDirectory();
    final zipFile = File("${zipDir.path}/DadosCampo.zip");
    ZipFile.createFromDirectory(
      sourceDir: dataDir,
      zipFile: zipFile,
      recurseSubDirs: false,
    );
    return zipFile;
  }

  @override
  void initState() {
    super.initState();
    _lerDados();
  }



  // Função para ler os dados do arquivo
  Future<void> _lerDados() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/dados.json');

    if (await file.exists()) {
      String jsonString = await file.readAsString();
      List<dynamic> listaDados = jsonString
          .split('\n')
          .where((linha) => linha.isNotEmpty)
          .map((linha) => jsonDecode(linha)) // Decodifica cada linha
          .toList();

      // Atualiza a quantidade de linhas e o valor de km do último lançamento
      setState(() {
        _numeroDeLinhas = listaDados.length;
        _conteudo = listaDados.map((dado) => jsonEncode(dado)).join('\n'); // Para visualização
        if (_numeroDeLinhas > 0) {
          var ultimoLancamento = listaDados.last;
          _kmUltimoLancamento = ultimoLancamento['Km']?.toString() ?? 'N/A'; // Pega o campo km
          _rodoviaUltimoLancamento = ultimoLancamento['rodovia']?.toString() ?? 'N/A';
        }
      });
      } else {
      setState(() {
        _conteudo = 'Nenhum dado encontrado.';
      });
    }
    }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );



    return Scaffold(
      appBar: AppBar(
        title: Titulo(nomePagina: 'Sin. Vertical'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ListView(
            children: [
              Text(
                _conteudo.isEmpty ? 'Carregando...' : 'Levantamentos',
                style: TextStyle(fontSize: 16),
              ),
              CartaoContagem(theme: theme, numeroDeLinhas: _numeroDeLinhas, style: style),
              SizedBox(height: 20,),
              Text('Ultimo Levantamento'),
              CartaoUltimoKm(kmUltimoLancamento: 'Km $_kmUltimoLancamento', style: style, theme: theme,),
              SizedBox(height: 20,),
              CartaoUltimoKm(style: style, theme: theme, kmUltimoLancamento: _rodoviaUltimoLancamento),
              SizedBox(height: 20,),
              ElevatedButton.icon(
                onPressed: _compartilharArquivo,
                label: Text('Enviar Dados'),
                icon: Icon(Icons.telegram)
              )
            ]
          ),
        ),
      ),
    );
  }
}

//função que monta o titulo das paginas
class Titulo extends StatelessWidget {
  const Titulo({
    super.key,
    required this.nomePagina,
  });

  final String nomePagina;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
            Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
              'assets/logo.png',
              height: 60,  
                          ),
            ],
          ),
          
            Expanded(
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(nomePagina),
                            ],
                          ),
            ),
      ],
    );
  }
}

//monta os cartões 
class CartaoUltimoKm extends StatelessWidget {
  const CartaoUltimoKm({
    super.key,
    required this.style,
    required this.theme,
    required String kmUltimoLancamento,
  }) : _kmUltimoLancamento = kmUltimoLancamento;

  final String _kmUltimoLancamento;
  final TextStyle style;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(child: Text(_kmUltimoLancamento, style: style,)),
      ),
    );
  }
}

class CartaoContagem extends StatelessWidget {
  const CartaoContagem({
    super.key,
    required this.theme,
    required int numeroDeLinhas,
    required this.style,
  }) : _numeroDeLinhas = numeroDeLinhas;

  final ThemeData theme;
  final int _numeroDeLinhas;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(child: Text(_numeroDeLinhas.toString(), style: style,))
      ),
    );
  }
}

//lança sinalização horizontal
class HorizontalSinLancar extends StatefulWidget {
  @override
  _HorizontalSinLancarState createState() => _HorizontalSinLancarState();
}

class _HorizontalSinLancarState extends State<HorizontalSinLancar>{
  final Map<String, TextEditingController> controllers = {};
  final Map<String, TextEditingController> dadosCor1 = {};
  final Map<String, TextEditingController> dadosCor2 = {};


  String? caminhoImagem;

  String? _coordenadas;

  Future<void> _getCoordenadas() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se o serviço de localização está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Caso não esteja habilitado, você pode solicitar ao usuário para habilitar
      print('Serviço de localização desativado.');
      return;
    }

    // Verifica o status da permissão de localização
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Permissão de localização negada.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Se a permissão foi negada permanentemente, o app não pode usar o serviço
      print('Permissão de localização permanentemente negada.');
      return;
    }

    // Se todas as permissões forem concedidas, obtém a posição atual
    Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.best));

    setState(() {
      _coordenadas = '${position.latitude}, ${position.longitude}';
    });
  }


  //parte da lista das rodovias (se der errado apaga essa merda)

  List<String> rodovias = ['MT-220', 'MT-320', 'PI-397', 'PI-262'];
  String? _rodoviaSelecionada;

    List<String> cores = ['branca','amarela'];
  String? _cor1;
  String? _cor2;



// cria o formulario
  @override
  void initState() {
    super.initState();
    //controllers['Rodovia'] = TextEditingController();
    controllers['Km'] = TextEditingController();
    controllers['Sentido'] = TextEditingController();
    controllers['Observação'] = TextEditingController();


    //dadosCor1['Cor1'] = TextEditingController();
    dadosCor1['M1-Eixo'] = TextEditingController();
    dadosCor1['M2-Eixo'] = TextEditingController();
    dadosCor1['M3-Eixo'] = TextEditingController();
    dadosCor1['M4-Eixo'] = TextEditingController();
    dadosCor1['M5-Eixo'] = TextEditingController();
    dadosCor1['M6-Eixo'] = TextEditingController();
    dadosCor1['M7-Eixo'] = TextEditingController();
    dadosCor1['M8-Eixo'] = TextEditingController();
    dadosCor1['M9-Eixo'] = TextEditingController();
    dadosCor1['M10-Eixo'] = TextEditingController();

    //dadosCor2['Cor2'] = TextEditingController();
    dadosCor2['M1-Bordo'] = TextEditingController();
    dadosCor2['M2-Bordo'] = TextEditingController();
    dadosCor2['M3-Bordo'] = TextEditingController();
    dadosCor2['M4-Bordo'] = TextEditingController();
    dadosCor2['M5-Bordo'] = TextEditingController();
    dadosCor2['M6-Bordo'] = TextEditingController();
    dadosCor2['M7-Bordo'] = TextEditingController();
    dadosCor2['M8-Bordo'] = TextEditingController();
    dadosCor2['M9-Bordo'] = TextEditingController();
    dadosCor2['M10-Bordo'] = TextEditingController();

  }

  Future<void> _tirarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 600);

    if (pickedFile != null) {
      setState(() {
        caminhoImagem = pickedFile.path;
      });

      // Salvar o caminho da imagem no arquivo
      await _salvarCaminhoImagem(caminhoImagem!);

      // Obter o diretório de armazenamento permanente
      final Directory appDir = await getApplicationDocumentsDirectory();
      
      // Criar um caminho único para a imagem no diretório de armazenamento
      final String fileName = path.basename(pickedFile.path);
      final String newPath = path.join(appDir.path, fileName);

      // Copiar a imagem para o novo local
      final File savedImage = await File(pickedFile.path).copy(newPath);

      // Salvar o novo caminho da imagem no arquivo (caso necessário)
      await _salvarCaminhoImagem(savedImage.path);
    }
  }

  Future<void> _salvarCaminhoImagem(String caminho) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/dados.txt');

    // Adiciona o caminho da imagem ao arquivo
    await file.writeAsString('Caminho da Imagem: $caminho\n', mode: FileMode.append);
    print('Caminho da imagem salvo em: ${file.path}');
  }

  Future<void> _salvarDados() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/HorizontalDados.json'); // Altere para .json

    // Cria um mapa para armazenar os dados
    Map<String, dynamic> dados = {};

    controllers.forEach((key, controller) {
      dados[key] = controller.text; // Armazena cada campo no mapa
    });

    dadosCor1.forEach((key, controller) {
      dados[key] = controller.text;
    });

    dadosCor2.forEach((key, controller) {
      dados[key] = controller.text;
    });


    dados['coordenadas'] = _coordenadas ?? 'Coordenadas não disponíveis';
    dados['rodovia'] = _rodoviaSelecionada ?? 'Rodovia Não Selecionada';
    dados['cor1'] = _cor1 ?? 'Cor 1 Não Especificada';
    dados['cor2'] = _cor2 ?? 'Cor 2 Não Especificada';


    // Adiciona o nome da imagem ao mapa, se existir
    if (caminhoImagem != null) { // Verifique se a imagem foi capturada
      dados['imagem'] = caminhoImagem!.split('/').last; // Salva apenas o nome da imagem
    }

    // Converte o mapa em uma string JSON
    String jsonDados = jsonEncode(dados);

    // Adiciona os dados ao arquivo
    await file.writeAsString('$jsonDados\n', mode: FileMode.append);
    print('Dados salvos em: ${file.path}');

    // Limpa os campos do formulário
    controllers.forEach((key, controller) {
      controller.clear(); // Limpa o campo
    });

    // Limpa o caminho da imagem
    caminhoImagem = null;


    // Exibe uma confirmação na interface
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dados salvos com sucesso!')),
    );
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Titulo(nomePagina: 'Sin. Horizontal')
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
                value: _rodoviaSelecionada,
                decoration: InputDecoration(
                  labelText: 'Rodovia',
                ),
                items: rodovias.map((String rodovia) {
                  return DropdownMenuItem<String>(
                    value: rodovia,
                    child: Text(rodovia),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _rodoviaSelecionada = newValue; // Atualiza o valor selecionado
                  });
                },
              ),
            SizedBox(height: 20),
            TextFormField(
              controller: controllers['Km'],
              decoration: InputDecoration(
                labelText: 'Km',
              ),
              keyboardType: TextInputType.number, // Teclado numérico
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // Aceita números decimais
                ],
                ),
              ...controllers.keys.map((key) {
                  return Visibility(
                    visible: key != 'Km',
                    child: TextField(
                      controller: controllers[key],
                      decoration: InputDecoration(labelText: key),
                  ),
                );
              }).toList(),
            SizedBox(height: 40,),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: TextEditingController(text: _coordenadas ?? ''),
                    decoration: InputDecoration(
                      labelText: 'Coordenadas',
                    ),
                    readOnly: true,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _getCoordenadas,
                  label: Text('Local'),
                  icon: Icon(Icons.gps_fixed_rounded)
                )
              ],
            ),
            SizedBox(height: 40,),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      DropdownButtonFormField(
                        value: _cor1,
                        decoration: InputDecoration(
                          labelText: 'Cor Eixo'
                        ),
                        items: cores.map((String cor) {
                          return DropdownMenuItem<String>(
                            value: cor,
                            child: Text(cor),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _cor1 = newValue;
                          });
                        }
                      ),
                      SizedBox(height: 10,),
                      ...dadosCor1.keys.map((key){
                          return Column(
                            children: [
                              TextField(
                              controller: dadosCor1[key],
                              decoration: InputDecoration(
                                labelText: key,
                              ),
                              keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter> [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                              ),
                              SizedBox(height: 10,),
                            ],
                          ); 
                      }).toList(),
                    ],
                  ),
                ),
                SizedBox(width: 20,),
                Expanded(
                  child: Column(
                    children: [
                      DropdownButtonFormField(
                        value: _cor2,
                        decoration: InputDecoration(
                          labelText: 'Cor Bordo'
                        ),
                        items: cores.map((String cor) {
                          return DropdownMenuItem<String>(
                            value: cor,
                            child: Text(cor),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _cor2 = newValue;
                          });
                        }
                      ),
                      SizedBox(height: 10,),
                      ...dadosCor2.keys.map((key){
                          return Column(
                            children: [
                              TextField(
                              controller: dadosCor2[key],
                              decoration: InputDecoration(labelText: key),
                              keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter> [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                              ),
                              SizedBox(height: 10,),
                            ],
                          ); 
                      }).toList()
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30,),
            ElevatedButton.icon(
              onPressed: _tirarFoto,
              label: Text('Tirar Foto'),
              icon: Icon(Icons.camera_alt)
            ),
            SizedBox(height: 20),
            if (caminhoImagem != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(
                  File(caminhoImagem!),
                  width: 300,
                  height: 300,
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _salvarDados,
              child: Text('Salvar Dados'),
            ),
          ],
        ),
      ),
    );
  }
}

//mostra os dados da sinalização horizontal
class HorizontalMostrarDados extends StatefulWidget {
  @override
  _HorizontalMostrarDadosState createState() => _HorizontalMostrarDadosState();
}

class _HorizontalMostrarDadosState extends State<HorizontalMostrarDados> {
  String dados = '';
  String _conteudo = '';
  int _numeroDeLinhas = 0;
  String _kmUltimoLancamento = '';
  String _rodoviaUltimoLancamento = '';

  Future<void> _compartilharArquivo() async {
    File arquivo = await _zipPasta();
    //final directory = await getApplicationDocumentsDirectory();
    final result = await Share.shareXFiles([XFile(arquivo.path)], text: 'Levantamento de Sinalização Vertical');

    if (result.status == ShareResultStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dados compartilhados com sucesso')),
    );
    }
  }

  Future<File> _zipPasta() async {
    final dataDir = await getApplicationDocumentsDirectory();
    final zipDir = await getApplicationCacheDirectory();
    final zipFile = File("${zipDir.path}/DadosCampo.zip");
    ZipFile.createFromDirectory(
      sourceDir: dataDir,
      zipFile: zipFile,
      recurseSubDirs: false,
    );
    return zipFile;
  }


  @override
  void initState() {
    super.initState();
    _lerDados();
  }

  // Função para ler os dados do arquivo
  Future<void> _lerDados() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/HorizontalDados.json');

    if (await file.exists()) {
      String jsonString = await file.readAsString();
      List<dynamic> listaDados = jsonString
          .split('\n')
          .where((linha) => linha.isNotEmpty)
          .map((linha) => jsonDecode(linha)) // Decodifica cada linha
          .toList();

      // Atualiza a quantidade de linhas e o valor de km do último lançamento
      setState(() {
        _numeroDeLinhas = listaDados.length;
        _conteudo = listaDados.map((dado) => jsonEncode(dado)).join('\n'); // Para visualização
        if (_numeroDeLinhas > 0) {
          var ultimoLancamento = listaDados.last;
          _kmUltimoLancamento = ultimoLancamento['Km']?.toString() ?? 'N/A'; // Pega o campo km
          _rodoviaUltimoLancamento = ultimoLancamento['rodovia']?.toString() ?? 'N/A';
        }
      });
      } else {
      setState(() {
        _conteudo = 'Nenhum dado encontrado.';
      });
    }
    }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );



    return Scaffold(
      appBar: AppBar(
        title: Titulo(nomePagina: 'Sin. Horizontal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ListView(
            children: [
              Text(
                _conteudo.isEmpty ? 'Carregando...' : 'Levantamentos',
                style: TextStyle(fontSize: 16),
              ),
              CartaoContagem(theme: theme, numeroDeLinhas: _numeroDeLinhas, style: style),
              SizedBox(height: 20,),
              Text('Ultimo Levantamento'),
              CartaoUltimoKm(kmUltimoLancamento: 'Km $_kmUltimoLancamento', style: style, theme: theme,),
              SizedBox(height: 20,),
              CartaoUltimoKm(style: style, theme: theme, kmUltimoLancamento: _rodoviaUltimoLancamento),
              SizedBox(height: 20,),
              ElevatedButton.icon(
                onPressed: _compartilharArquivo,
                label: Text('Enviar Dados'),
                icon: Icon(Icons.telegram)
              )
            ]
          ),
        ),
      ),
    );
  }
}

