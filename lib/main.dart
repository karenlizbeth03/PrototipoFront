import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';
import 'screens/talking_avatar_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Error cargando .env: $e");
  }
  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF931D21),
          titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      );

  ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF931D21),
          titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prototipo con IA',
      theme: isDarkMode ? darkTheme : lightTheme,
      home: MainDrawer(
        onToggleTheme: () {
          setState(() {
            isDarkMode = !isDarkMode;
          });
        },
      ),
    );
  }
}

class MainDrawer extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const MainDrawer({super.key, required this.onToggleTheme});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  int selectedIndex = 0;

  final List<Widget> _screens = [
    const ChatScreen(),
    TalkingAvatarScreen(),
  ];

  final List<String> _titles = [
    'Prototipo con IA Generativa',
    'Avatar conversacional',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF931D21)),
              child: Text(
                'Menú',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Prototipo con IA Generativa'),
              onTap: () {
                setState(() {
                  selectedIndex = 0;
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.face),
              title: const Text('Avatar conversacional'),
              onTap: () {
                setState(() {
                  selectedIndex = 1;
                  Navigator.pop(context);
                });
              },
            ),
          ],
        ),
      ),
      body: _screens[selectedIndex],
    );
  }
}
