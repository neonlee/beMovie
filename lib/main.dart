import 'package:flutter/material.dart';
import 'api.dart';
import 'bd.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeMovie',
      home: MyHomePage(title: 'BeMovie!'),
      theme: ThemeData.dark(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //variavel de controle do titulo do filme digitado
  final _title = TextEditingController();
  // variavel de controle de estado do icone de favorito
  var isFavorite = false;
  // referencia nossa classe single para gerenciar o banco de dados
  final dbHelper = DatabaseHelper.instance;
  //procura o filme e retorna no dio e adiciona em uma lista para ser exibido
  MyServices api = MyServices();
// métodos dos Buttons
  void _inserir(Map<String, dynamic> row) async {
    // linha para incluir
    await dbHelper.insert(row);
  }

  //consultar os filmes no banco
  Future _consultar() async {
    List movie = List();
    final todasLinhas = await dbHelper.queryAllRows();
    for (var movies in todasLinhas) {
      movies.containsKey("name");
      print(movies.containsKey("name"));
    }
    todasLinhas.forEach((row) => movie.add(row.values));
    return movie;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.movie),
                text: "Procure seu Filme",
              ),
              Tab(
                icon: Icon(Icons.favorite),
                text: "Seus filmes favoritos",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Container(
              padding: EdgeInsets.only(top: 10, left: 15, right: 15),
              child: ListView(
                children: <Widget>[
                  //forms para procurar o filme
                  TextFormField(
                    controller: _title,
                    decoration: InputDecoration(
                      labelText: "Procure seu Filme",
                      focusColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          setState(() {
                            //aqui eu seto o estado para o novo filme caso ele procure algum depois de digitar uma vez
                            api.search(_title.text);
                            isFavorite = false;
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    height: 450,
                    child: FutureBuilder(
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                children: <Widget>[
                                  Text(snapshot.data[index].title),
                                  Image.network(
                                    snapshot.data[index].poster,
                                    fit: BoxFit.fitWidth,
                                  ),
                                  Text(snapshot.data[index].plot),
                                  IconButton(
                                      icon: Icon(Icons.favorite),
                                      tooltip: "favoritar",
                                      color: isFavorite
                                          ? Colors.greenAccent
                                          : Colors.black,
                                      onPressed: () {
                                        setState(() {
                                          isFavorite = true;
                                        });
                                      }),
                                  Row(
                                    children: <Widget>[],
                                  ),
                                ],
                              );
                            },
                          );
                        }
                        return CircularProgressIndicator();
                      },
                      future: api.search(_title.text),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: FutureBuilder(
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data.hashCode,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: <Widget>[
                            Text(snapshot.data[index].toString()),
                          ],
                        );
                      },
                    );
                  }
                  return CircularProgressIndicator();
                },
                future: _consultar(),
              ),
            ),
          ],
        ),
      ),
      length: 2,
    );
  }
}
