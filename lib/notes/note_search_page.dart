import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:getjournaled/db/abstraction/note_service/note_map_service.dart';
import 'package:getjournaled/notes/note_object.dart';
import 'package:getjournaled/shared.dart';
import 'package:getjournaled/notes/note_card.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/scheduler.dart';

class NoteSearchPage extends StatefulWidget {
  const NoteSearchPage({super.key});

  @override
  State<NoteSearchPage> createState() => _NoteSearchPage();
}

class _NoteSearchPage extends State<NoteSearchPage> {
  final NoteService _noteService = GetIt.I<NoteService>();

  Map<int, NoteObject> _noteMap = {};

  final Map<int, NoteObject> _searchMathces = {};

  StreamSubscription? _noteSub;

  final TextEditingController _titleTextEditingController = TextEditingController();

  final FocusNode _myFocusNode = FocusNode();

  @override
  void dispose() {
    _noteSub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _noteService.getAllNotes().then((value) => setState(() {
          _noteMap = value;
        }));
    _noteSub = _noteService.stream.listen(_onNotesUpdate);

    //
    // Display the alert dialog
    //
    SchedulerBinding.instance.addPostFrameCallback((_) {
      //ifLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(padding: EdgeInsets.only(top: 24)),
              // ---------------------------------------------------------------------------
              // Title and search bar
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // ---------------------------------------------------------------------------
                  // Search bar
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 580),
                        curve: Curves.easeOutQuint,
                        child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: colorScheme.onPrimary),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            padding:
                                const EdgeInsets.only(top: 6.0, right: 4.0, left: 4.0),
                            child: EditableText(
                              autofocus: true,
                              showCursor: true,
                              controller: _titleTextEditingController,
                              focusNode: _myFocusNode,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 20,
                                color: colorScheme.onPrimary,
                              ),
                              cursorColor: colorScheme.onPrimary,
                              backgroundCursorColor: Colors.black,
                              onChanged: _onSearchBar,
                            ),
                          ),
                        
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    iconSize: 22.0,
                    icon: const Icon(
                      Icons.cancel_outlined,
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(bottom: 24)),
              // ---------------------------------------------------------------------------
              // Row where journals are shown
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (var entry in _searchMathces.entries) ...[
                      GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 4.0, right: 6.0, left: 0.0),
                          child: NoteCard(
                            title: entry.value.getTitle(),
                            body: entry.value.getBody(),
                            id: entry.value.getId(),
                            dateOfCreation: entry.value.getDateOfCreation(),
                            cardColor: entry.value.getCardColor(), 
                            dateOfLastEdit: entry.value.getDateOfLastEdit(),
                            
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onSearchBar(String text) {
    _searchMathces.clear();
    for (var j in _noteMap.entries) {
      var tmp = j.value;
      if (tmp.getTitle().toString().contains(text) ||
          tmp.getBody().toString().contains(text)) {
        _searchMathces.addAll({j.key: j.value});
      }
    }

    setState(() {});
  }

  void _onNotesUpdate(Map<int, NoteObject> event) {
    setState(() {
      _noteMap = event;
    });
  }
}

class DrawerPage extends StatelessWidget {
  const DrawerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: const Drawer(),
    ));
  }
}