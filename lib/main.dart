import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navigation App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amberAccent),
        useMaterial3: true,
      ),
      home: const BottomNavigationBarExample(),
    );
  }
}

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({super.key});

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const DataPage(),
    const ContactPage(),
  ];

  final List<Color> _navbarColors = [
    Color(0xFFD9CBBD), // Home tab color
    Color(0xFFCFCFCF), // Data tab color
    Color(0xFFB5813C),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flutter Navigation App',
          style: TextStyle(
              fontFamily: 'SixtyfourConvergence', // Use the custom font
              fontSize: 16),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.data_usage),
            label: 'Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail),
            label: 'Contact',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        backgroundColor: _navbarColors[_selectedIndex],
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/whales.png'), // Replace with your asset path
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: Color(0xFFD9CBBD),
            alignment: Alignment.center,
            child: Transform.rotate(
              angle: 0.1,
              child: Text(
                'Sunny',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontFamily: 'SixtyfourConvergence', // Use the custom font
                  fontSize: 48,
                      color: Colors.white,
                      
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  late Future<List<DataModel>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = fetchData();
  }

  Future<List<DataModel>> fetchData() async {
    final response =
        await http.get(Uri.parse('https://randomuser.me/api/?results=20'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['results'] as List;
      return data.map((item) => DataModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DataModel>>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final user = snapshot.data![index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.picture),
                ),
                title: Text(user.name),
                subtitle: Text(user.email),
              );
            },
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }
}

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? name;
  String? email;
  String? message;

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              'Contact Us',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.person),
                hintText: 'Enter your name',
                labelText: 'Name',
              ),
              autofocus: true,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  value!.isEmpty ? 'Please enter your name' : null,
              onSaved: (value) => name = value,
            ),
            TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.email),
                hintText: 'Enter your email',
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  value!.isEmpty ? 'Please enter your email' : null,
              onSaved: (value) => email = value,
            ),
            TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.message),
                hintText: 'Enter your message',
                labelText: 'Message',
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a message' : null,
              onSaved: (value) => message = value,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveForm,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class DataModel {
  final String name;
  final String email;
  final String picture;

  DataModel({required this.name, required this.email, required this.picture});

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      name: '${json['name']['first']} ${json['name']['last']}',
      email: json['email'],
      picture: json['picture']['thumbnail'],
    );
  }
}
