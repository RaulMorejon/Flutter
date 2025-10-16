import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';



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
        title: 'Namer App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 230, 187, 45),
          ),
        ),
        home: MyHomePage(),
      ),
    );
  } 

}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  
  

  void getNext() {

    current = WordPair.random(); // obtenir nova paraula
   
    notifyListeners(); // notificar als listeners
  }

  var favorites = <WordPair>[]; // Llista de paraules de tipus WordPair


  //var historial = <WordPair>[]; // Llista de totes les paraules 

  var historial = <Historial>[];



  void InsertarAlHistorial() {
    
    var esFavorita = favorites.contains(current); // mira la llista de fav
    // Fa que inserti l'objecte de la paraula amb si es fav, al principi de la llista
    historial.insert(0, Historial(current, esFavorita)); 
    notifyListeners();
  }


  void toggleFavorite() {
    if (favorites.contains(current)) {
      // si esta a la llista el treu ja que estaria marcada d'avants
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

} 




class Historial {
  final WordPair paraula;
  final bool favorita;
  Historial(this.paraula, this.favorita);
}
  



 
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    Widget page;
    switch(selectedIndex){
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = GenerateFavoritesPage();
        break; 
      default:
        throw UnimplementedError("No hi ha widget per $selectedIndex");
    } 
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 700, 
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

@override
Widget build (BuildContext context){
  var appState = context.watch<MyAppState>();

  if(appState.favorites.isEmpty){ // si la llista esta buida
    return Center(
      child: Text("No hi han favorits"),
    );
  }

  return ListView(
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Llista de favorits:"), 
      ),
      for(var i in appState.favorites)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: 
            Text(i.asLowerCase),
        ),
    ],
  );

}
 
 

class GenerateFavoritesPage extends StatelessWidget{

  @override
  Widget build (BuildContext context){
    var appState = context.watch<MyAppState>();


    if(appState.favorites.isEmpty){
      return Center(
        child: Text("No hi han favorits"),
      );
    }

    return ListView(
     children: [
      Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          appState.favorites.length == 1 ? "Tens 1 paraula favorita"
                      : "Tens ${appState.favorites.length} paraules favorites",
        ),
      ),
      for (var pair in appState.favorites)
      ListTile(
        leading: Icon(Icons.favorite),
        title: Text(pair.asLowerCase), 
      ),]
    );
  }

}

 
class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    } 


    return Center(
      child: Column(
        children: [
        
        
          // historial




          Expanded(
            child: ListView(
              children: [
                if(!appState.historial.isEmpty)
                  for (var pair in appState.historial)
                      ListTile(
                        leading: Icon(pair.favorita ? Icons.favorite : Icons.favorite_border), // cambiem depenent si es o no fav
                        title: Text(pair.paraula.asLowerCase), 
                      ),
              ],
            ),
          ),
         




          // Carta 
          BigCard(pair: pair),
          SizedBox(height: 40), 
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon( 
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 30),
              ElevatedButton(
                onPressed: () {
                  appState.InsertarAlHistorial();   // Insertem al historial 
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}




class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.pair});

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(35.0),
        
        child: Text(pair.asSnakeCase, style: style),
      ),
    );
  }
}
