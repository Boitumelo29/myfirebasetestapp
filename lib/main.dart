import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:myfirebasetestapp/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthState(),
    );
  }
}

class AuthState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasData) {
          return NotesScreen();
        }
        return LoginScreen();
      },
    );
  }
}

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Handle successful signup here
      print("Signed up: ${userCredential.user?.email}");
    } on FirebaseAuthException catch (e) {
      // Handle signup errors here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Signup failed"),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _signup,
                child: Text('Sign Up'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Handle successful login here
      print("Logged in: ${userCredential.user?.email}");
    } on FirebaseAuthException catch (e) {
      // Handle login errors here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Login failed"),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: Text('Login'),
                    ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  );
                },
                child: Text('Don\'t have an account? Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: user != null ? Text(user.email ?? 'No email') : Text('No user'),
      ),
    );
  }
}





class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      try {
        final response = await http.get(Uri.parse('http://localhost:3000/notes/${user.uid}'));

        if (response.statusCode == 200) {
          List jsonResponse = json.decode(response.body);
          setState(() {
            _notes = jsonResponse.map((note) => Note.fromJson(note)).toList();
          });
        } else {
          throw Exception('Failed to load notes');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Center(
        child: user != null ? Text(user.email ?? 'No email') : Text('No user'),),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddNoteScreen(onNoteAdded: _fetchNotes)),
              );
            },
          ),
        ],
      ),
      body: _notes.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_notes[index].title),
            subtitle: Text(_notes[index].content),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await _deleteNote(_notes[index].id);
                _fetchNotes();
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteNote(int id) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/notes/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete note');
    }
  }
}

class Note {
  final int id;
  final String title;
  final String content;

  Note({
    required this.id,
    required this.title,
    required this.content,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
    );
  }
}

class AddNoteScreen extends StatefulWidget {
  final VoidCallback onNoteAdded;

  AddNoteScreen({required this.onNoteAdded});

  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addNote,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addNote() async {
    final title = _titleController.text;
    final content = _contentController.text;
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/notes'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'title': title,
            'content': content,
            'userId': user.uid,
          }),
        );

        if (response.statusCode == 200) {
          widget.onNoteAdded();
          Navigator.pop(context);
        } else {
          throw Exception('Failed to create note');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}