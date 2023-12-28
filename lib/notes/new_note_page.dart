import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:getjournaled/db/abstraction/note_map_service.dart';
import 'package:getjournaled/notes/note_object_class.dart';

class NewSingleNotePage extends StatefulWidget {
  late String title;
  late String body;
  late int id;
  late DateTime lDateOfCreation;

  NewSingleNotePage(
      {super.key,
      required this.title,
      required this.body,
      required this.id,
      required this.lDateOfCreation});

  @override
  State<StatefulWidget> createState() => _NewSingleNotePage();
}

class _NewSingleNotePage extends State<NewSingleNotePage> {
  String _title = 'Title';
  String _body = '';
  int _id = 0;
  DateTime _lDateOfCreation = DateTime(0);

  final NoteService _notesService = GetIt.I<NoteService>();

  Set<NoteObject> _notesSet = {};

  StreamSubscription? _notesSub;

  @override
  void dispose() {
    _notesSub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _id = widget.id;
    _lDateOfCreation = widget.lDateOfCreation;

    _notesService.getAllNotes().then((value) => setState(() {
          _notesSet = value;
        }));
    _notesSub = _notesService.stream.listen(_onNotesUpdate);
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    _title = widget.title;
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [
          Colors.amber.shade50,
          Colors.orange.shade50,
        ],
      )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back)),
              ),
              const Expanded(child: Text('')),
              Padding(
                padding: const EdgeInsets.only(top: 4.0, right: 10.0),
                child: OutlinedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith(
                        (states) => Colors.deepOrange.shade200),
                  ),
                  onPressed: () {
                    DateTime now = DateTime.now();
                    NoteObject noteObject = NoteObject(id: _id, title: _title, body: _body, dateOfCreation: _lDateOfCreation, dateOfLastEdit: _lDateOfCreation);
                    _notesSet.add(noteObject);
                    _notesService.add(noteObject);
                    _id = _notesService.getUniqueId();

                    //var mySnackBar = customSnackBar('Note saved!');
                    //ScaffoldMessenger.of(context).showSnackBar(mySnackBar);
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 480 * 0.5 * 0.09, top: 800 * 0.5 * 0.02),
            child: Material(
              type: MaterialType.transparency,
              child: EditableText(
                controller: TextEditingController(
                  text: widget.title,
                ),
                focusNode: FocusNode(),
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                cursorColor: Colors.black,
                backgroundCursorColor: Colors.black,
                onChanged: (String value) {
                  _title = value;
                  widget.title = value;
                },
              ),
            ),
          ),
          const Divider(
            thickness: 1.0,
            indent: 17,
            endIndent: 80,
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(left: 480 * 0.5 * 0.09, top: 10.0),
            child: EditableText(
              controller: TextEditingController(text: widget.body),
              focusNode: FocusNode(),
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                color: Colors.black,
              ),
              maxLines: null,
              cursorColor: Colors.black,
              backgroundCursorColor: const Color.fromARGB(255, 68, 67, 67),
              onChanged: (value) {
                _body = value;
                widget.body = value;
              },
            ),
          ))
        ],
      ),
    );
  }

  // business logic
  void _onNotesUpdate(Set<NoteObject> event) {
    setState(() {
      _notesSet= event;
    });
  }
}
