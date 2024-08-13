import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Note>> fetchNotes(String userId) async {
  final response = await http.get(Uri.parse('http://localhost:3000/notes/$userId'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((note) => Note.fromJson(note)).toList();
  } else {
    throw Exception('Failed to load notes');
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
Future<void> createNote(String title, String content, String userId) async {
  final response = await http.post(
    Uri.parse('http://localhost:3000/notes'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'title': title,
      'content': content,
      'userId': userId,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to create note');
  }
}

Future<void> deleteNote(int id) async {
  final response = await http.delete(
    Uri.parse('http://localhost:3000/notes/$id'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete note');
  }
}
