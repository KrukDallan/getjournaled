import 'dart:async';

import 'package:flutter/material.dart';

import 'package:getjournaled/db/abstraction/journal_service/journal_map_service.dart';
import 'package:getjournaled/journals/journal_object.dart';

import 'package:getjournaled/journals/journal_card.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/scheduler.dart';

class JournalSearchPage extends StatefulWidget {
  const JournalSearchPage({super.key});

  @override
  State<JournalSearchPage> createState() => _JournalSearchPage();
}

class _JournalSearchPage extends State<JournalSearchPage> {
  final JournalService _journalService = GetIt.I<JournalService>();

  Map<int, JournalObject> _journalMap = {};

  final Map<int, JournalObject> _searchMathces = {};

  StreamSubscription? _journalSub;

  final TextEditingController _titleTextEditingController =
      TextEditingController();

  final FocusNode _myFocusNode = FocusNode();

  @override
  void dispose() {
    _journalSub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _journalService.getAllJournals().then((value) => setState(() {
          _journalMap = value;
        }));
    _journalSub = _journalService.stream.listen(_onJournalsUpdate);

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
        backgroundColor: colorScheme.primary,
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
                          padding: const EdgeInsets.only(
                              top: 5.0, right: 4.0, left: 4.0, bottom: 5.0),
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
                reverse: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (var entry in _searchMathces.entries) ...[
                      GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 4.0, right: 6.0, left: 0.0),
                          child: DrawerCard(
                            title: entry.value.getTitle(),
                            body: entry.value.getBody(),
                            id: entry.value.getId(),
                            dateOfCreation: entry.value.getDateOfCreation(),
                            cardColor: entry.value.getCardColor(),
                            dayRating: entry.value.getDayRating(),
                            highlight: entry.value.getHighlight(),
                            lowlight: entry.value.getLowlight(),
                            noteWorthy: entry.value.getNoteWorthy(),
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
    if (text == "" || text == " ") {
      _searchMathces.clear();
      setState(() {});
      return;
    }

    final lcText = text.toLowerCase();
    _searchMathces.clear();
    for (var j in _journalMap.entries) {
      var tmp = j.value;
      if (tmp.getTitle().toLowerCase().contains(lcText) ||
          tmp.getBody().toString().toLowerCase().contains(lcText)) {
        _searchMathces.addAll({j.key: j.value});
      }
    }

    setState(() {});
  }

  void _onJournalsUpdate(Map<int, JournalObject> event) {
    /* setState(() {
      _journalMap = event;
    }); */
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
