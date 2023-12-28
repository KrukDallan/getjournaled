import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:getjournaled/db/abstraction/note_map_service.dart';
import 'package:getjournaled/notes/note_object_class.dart';

// TODO: insert date below note title
//       plus, save the date of creation and the last edit

class SingleNotePage extends StatefulWidget {
  late String title;
  late String body;
  late int id;
  late DateTime dateOfCreation;

  SingleNotePage(
      {super.key, required this.title, required this.body, required this.id, required this.dateOfCreation});

  @override
  State<StatefulWidget> createState() => _SingleNotePage();
}

class _SingleNotePage extends State<SingleNotePage> {
  String _title = '';
  String _body = '';
  int _id = -1;
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
   if (_id == -1){
     _id = widget.id;
     _title = widget.title;
     _body = widget.body;
     _lDateOfCreation = widget.dateOfCreation;
   }

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
                padding:  const EdgeInsets.only(top: 4.0, left: 12.0),
                child: Container(
                  decoration:  BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: SizedBox(
                    width: 35,
                    height: 35,
                    child: IconButton(
                      iconSize: 15.0,
                      padding: const EdgeInsets.only(bottom: 1.0),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                          )
                          ),
                  ),
                ),
              ),
              const Expanded(child: Text('')),
              Padding(
                padding: const EdgeInsets.only(top: 4.0, right: 15.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: const BorderRadius.all(Radius.circular(10))
                  ),
                  child: SizedBox(
                    width: 35,
                    height: 35,
                    child: IconButton(
                      padding: const EdgeInsets.only(bottom: 0.0),
                      onPressed: () async{
                        DateTime now = DateTime.now();
                        NoteObject noteObject = NoteObject(id: _id, title: _title, body: _body, dateOfCreation: _lDateOfCreation, dateOfLastEdit: DateTime(now.year, now.month, now.day));
                        // res==true? -> object updated, else object added (it was not present, shouldn't happen)
                        bool res = await _notesService.update(noteObject);
                        // check if the note is already present in the map
                        if ((_notesSet.isNotEmpty) && (res)) {
                          _notesSet.remove(noteObject);
                          _notesSet.add(noteObject);
                        } else {
                          _notesSet.add(noteObject);
                        }
                        
                        //var mySnackBar = customSnackBar('Note saved!');
                        //ScaffoldMessenger.of(context).showSnackBar(mySnackBar);
                      },
                      icon: const Icon(
                        Icons.edit_document,
                        size: 18.0,
                        color: Colors.white,
                        ),
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
                  fontFamily: 'Roboto-Medium',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
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
      _notesSet = event;
    });
  }
}

