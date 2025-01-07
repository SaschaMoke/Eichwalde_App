import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
void main() {
  runApp(const MyApp());
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
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        ),
        home: MyHomePage(),                 
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();                        
 var favorites = <WordPair>[];

  void GetNext() {                                        
    current = WordPair.random();
    notifyListeners();
  }

   void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

  Widget page;
  switch (selectedIndex) {
    case 0:
      page = GeneratorPage();
      break;
    case 1:
      page = FavoritesPage();
      break;
    /*  case 2;
      page = Placeholder();
      break;*/
    default:
      throw UnimplementedError('no widget for $selectedIndex');
  }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          
         // floatingActionButton: FloatingActionButton(
           // onPressed: () {
                //setState(() {
                  //page = Placeholder();
                //selectedIndex = 2;
            //  }); 
            //},
            //foregroundColor: customizations[index].$1,
            //backgroundColor: customizations[index].$2,
            //shape: customizations[index].$3,
            //child: const Icon(Icons.settings),
          //),

          bottomNavigationBar: NavigationBarTheme(
            data:  NavigationBarThemeData(
            labelTextStyle: WidgetStatePropertyAll(const TextStyle(
                  color: Colors.white,
            ),
            )),
            child: NavigationBar(
              //backgroundColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Color.fromRGBO(108, 181, 108, 1),
              onDestinationSelected: (int index) {
                setState(() {
                  selectedIndex = index;
            });
              },
            indicatorColor: Theme.of(context).colorScheme.primaryContainer,
            selectedIndex: selectedIndex,
            destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: 'Home', 
              
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.route),
              icon: Icon(Icons.route_outlined),
              label: 'Verkehr',
            ),
                 /*      NavigationDestination(
              icon: Badge(
                label: Text('2'),
                child: Icon(Icons.messenger_sharp),
              ),
              label:'Messages',
            ), */
                    ],
                    ),
          ),
        body:Container(
                  //color: Theme.of(context).colorScheme.primaryContainer,
                
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.5, 0.8),
                      end: Alignment(0.5, 1),
                      colors: <Color>[
                      Color.fromARGB(255, 230, 255, 230),
                      Color.fromARGB(255, 151, 209, 151),
                      ],
                    ),
                  ),
                  child: page,
          ),
        );
      }
    );
  }
}

class FavoritesPage extends StatelessWidget {
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

  return ListView(
  children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;                          //Zugriff nur auf current, da er nicht mehr braucht

   IconData LikeIcon;
    if (appState.favorites.contains(pair)) {
      LikeIcon = Icons.favorite;
    } else {
      LikeIcon = Icons.favorite_border;
    }

    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Text('A random idea:'),
            RandomBox(pair: pair),
            SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(onPressed: () {
                  appState.toggleFavorite();                             //Aktionen
                }, 
                icon: Icon(LikeIcon),
                label: Text('Like')),
                SizedBox(width: 10),
                
                
                ElevatedButton(onPressed: () {
                  appState.GetNext();                             //Aktionen
                }, 
                child: Text('Next')),
               
              ],
            )                              //Design
          ],
        ),
      );
  }
}

class RandomBox extends StatelessWidget {
  const RandomBox({
    super.key,
    required this.pair,
  });

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
        padding: const EdgeInsets.all(10.0),
        child: Text(pair.asLowerCase, style: style,),
      ),
    );
  }
}
