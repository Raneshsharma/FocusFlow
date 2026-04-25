import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/note.dart';

class NoteRepository {
  static const String boxName = 'notes';
  final Box<String> _box;

  NoteRepository(this._box);

  static Future<NoteRepository> create() async {
    final box = await Hive.openBox<String>(boxName);
    return NoteRepository(box);
  }

  List<Note> getAll() {
    return _box.values.map((json) => Note.fromJson(jsonDecode(json))).toList();
  }

  Stream<BoxEvent> watchAll() {
    return _box.watch();
  }

  List<Note> getByTag(String tag) {
    return getAll().where((n) => n.hasTag(tag)).toList();
  }

  List<Note> getBySession(String sessionId) {
    return getAll().where((n) => n.sessionId == sessionId).toList();
  }

  List<Note> getVoiceNotes() {
    return getAll().where((n) => n.isVoiceNote).toList();
  }

  Note? getById(String id) {
    final json = _box.get(id);
    if (json == null) return null;
    return Note.fromJson(jsonDecode(json));
  }

  Future<void> save(Note note) async {
    await _box.put(note.id, jsonEncode(note.toJson()));
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteAll() async {
    await _box.clear();
  }

  int count() {
    return _box.length;
  }
}
