import 'dart:async';

import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';
import 'package:getjournaled/db/abstraction/note_service/note_map_service.dart';
import 'package:getjournaled/db/abstraction/settings_service/settings_map_service.dart';
import 'package:getjournaled/notes/note_object.dart';
import 'package:getjournaled/settings/settings_object.dart';
import 'package:getjournaled/shared.dart';

// TODO: insert date below note title
//       plus, save the date of creation and the last edit

class SingleNotePage extends StatefulWidget {
  late String title;
  late dynamic body;
  late int id;
  late DateTime dateOfCreation;
  late DateTime dateOfLastEdit;
  late Color cardColor;

  SingleNotePage(
      {super.key,
      required this.title,
      required this.body,
      required this.id,
      required this.dateOfCreation,
      required this.dateOfLastEdit,
      required this.cardColor});

  @override
  State<StatefulWidget> createState() => _SingleNotePage();
}

class _SingleNotePage extends State<SingleNotePage> {
  // ignore: prefer_final_fields
  NoteService _notesService = GetIt.I<NoteService>();

  // ignore: prefer_final_fields
  SettingsService _settingsService = GetIt.I<SettingsService>();

  Map<int, NoteObject> _notesMap = {};

  StreamSubscription? _notesSub;

  StreamSubscription? _settingsSub;

  TextEditingController _bodyTextEditingController = TextEditingController();
  final MyTextInputFormatter _bodyTextInputFormatter = MyTextInputFormatter();
  final FocusNode _bodyFocusNode = FocusNode();

  //
  // Autosave data structures
  //
  bool _autoSave = false;

  List<String> _undoList = <String>[];
  ValueNotifier<Color> _undoColor = ValueNotifier(Colors.grey.shade800);
  List<String> _redoList = <String>[];
  ValueNotifier<Color> _redoColor = ValueNotifier(Colors.grey.shade800);
  late Color _activeUndoRedoColor;
  //
  // colored box
  //
  Color get boxColor => _boxColor;
  late Color _boxColor;
  set boxColor(Color value) {
    if (_boxColor != value) {
      setState(() {
        _boxColor = value;
      });
    }
  }

  late String _oldTitle;
  late String _oldBody;

  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'Menu Button');
  final MenuController _menuController = MenuController();

  @override
  void dispose() {
    _notesSub?.cancel();
    _settingsSub?.cancel();
    _buttonFocusNode.dispose();
    _bodyFocusNode.dispose();
    //_bodyTextEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _boxColor = widget.cardColor;

    _notesService.getAllNotes().then((value) => setState(() {
          _notesMap = value;
        }));
    _settingsService.get(0).then((value) => setState(() {}));
    _notesSub = _notesService.stream.listen(_onNotesUpdate);
    _settingsSub = _settingsService.stream.listen(_onSettingsUpdate);
    _settingsService.get(0).then((value) => _autoSave = value!.getAutoSave());

    _bodyTextEditingController.addListener(() {});

    _oldTitle = widget.title;
    _oldBody = widget.body;
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    _activeUndoRedoColor = colorScheme.onPrimary;
    _bodyTextEditingController = TextEditingController(text: widget.body);
    setState(() {
      final String text = _bodyTextEditingController.text;
      _bodyTextEditingController.value =
          _bodyTextEditingController.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.collapsed(text.length),
      );
    });
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.primary,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: (colorScheme.primary == Colors.black)
                          ? Colors.grey.shade800
                          : Colors.lightBlue.shade100,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: SizedBox(
                      width: 35,
                      height: 35,
                      child: IconButton(
                          iconSize: 15.0,
                          padding: const EdgeInsets.only(bottom: 1.0),
                          onPressed: () {
                            if (_autoSave == false) {
                              if ((widget.title != _oldTitle) ||
                                  (widget.body != _oldBody)) {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Exit?'),
                                        content: const Text(
                                            'You have unsaved changes, if you leave now they will be lost.'),
                                        actions: [
                                          TextButton(
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: colorScheme.onPrimary,
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context, 'Cancel');
                                            },
                                          ),
                                          TextButton(
                                              child: Text(
                                                'Leave',
                                                style: TextStyle(
                                                  color: colorScheme.onPrimary,
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context, 'Leave');
                                                Navigator.pop(context);
                                              }),
                                        ],
                                      );
                                    });
                              } else {
                                Navigator.pop(context);
                              }
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: colorScheme.onPrimary,
                          )),
                    ),
                  ),
                ),
                const Expanded(child: Text('')),
                if (_autoSave) ...{
                  //
                  // Undo & Redo
                  //
                  Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: ValueListenableBuilder(
                        valueListenable: _undoColor,
                        builder:
                            (BuildContext context, Color color, Widget? child) {
                          return IconButton(
                            onPressed: () {
                              if (_undoList.isNotEmpty) {
                                if (_redoList.isEmpty) {
                                  _redoColor.value = colorScheme.onPrimary;
                                }
                                _redoList.add(_bodyTextEditingController.text);
                                _bodyTextEditingController.text =
                                    _undoList.removeLast();
                                widget.body = _bodyTextEditingController.text;
                                if (_undoList.isEmpty) {
                                  _undoColor.value =
                                      (colorScheme.primary == Colors.black)
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade400;
                                }
                                setState(() {});
                              }
                            },
                            icon: Icon(
                              Icons.undo_rounded,
                              color: color, // make color dynamic
                            ),
                          );
                        },
                      )),
                  Padding(
                      padding: const EdgeInsets.only(right: 4.0, left: 4.0),
                      child: ValueListenableBuilder(
                          valueListenable: _redoColor,
                          builder: (BuildContext context, Color color,
                              Widget? child) {
                            return IconButton(
                              onPressed: () {
                                if (_redoList.isNotEmpty) {
                                  if (_undoList.isEmpty) {
                                    _undoColor.value = colorScheme.onPrimary;
                                  }
                                  _undoList
                                      .add(_bodyTextEditingController.text);
                                  _bodyTextEditingController.text =
                                      _redoList.removeLast();
                                  widget.body = _bodyTextEditingController.text;
                                  if (_redoList.isEmpty) {
                                    _redoColor.value =
                                        (colorScheme.primary == Colors.black)
                                            ? Colors.grey.shade800
                                            : Colors.grey.shade400;
                                  }
                                  setState(() {});
                                }
                              },
                              icon: Icon(
                                Icons.redo_rounded,
                                color: color,
                              ),
                            );
                          })),
                },
                if (_autoSave == false) ...{
                  //
                  // Save button
                  //
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, right: 15.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: (colorScheme.primary == Colors.black)
                              ? Colors.grey.shade800
                              : Colors.lightBlue.shade100,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: SizedBox(
                        width: 60,
                        height: 35,
                        child: IconButton(
                            padding: const EdgeInsets.only(bottom: 0.0),
                            highlightColor: Colors.teal.shade200,
                            onPressed: () {
                              while (true) {
                                if (widget.body.toString().endsWith('\n')) {
                                  widget.body = widget.body
                                      .toString()
                                      .replaceRange(
                                          widget.body.toString().length - 1,
                                          widget.body.toString().length,
                                          '');
                                } else {
                                  break;
                                }
                              }
                              DateTime now = DateTime.now();
                              NoteObject noteObject = NoteObject(
                                  id: widget.id,
                                  title: widget.title,
                                  body: widget.body,
                                  dateOfCreation: widget.dateOfCreation,
                                  dateOfLastEdit:
                                      DateTime(now.year, now.month, now.day),
                                  cardColor: widget.cardColor);
                              _notesService.update(noteObject);
                              // check if the note is already present in the map
                              _notesMap.addAll({widget.id: noteObject});
                              _oldBody = widget.body;
                              _oldTitle = widget.title;
                              setState(() {
                                widget.dateOfLastEdit =
                                    DateTime(now.year, now.month, now.day);
                                _undoList.clear();
                                _redoList.clear();
                              });
                            },
                            icon: Text(
                              'Save',
                              style: TextStyle(
                                  color: (colorScheme.primary == Colors.black)
                                      ? Colors.white
                                      : Colors.black),
                            )),
                      ),
                    ),
                  ),
                },
              ],
            ),
            //
            // Title
            //
            Padding(
              padding: const EdgeInsets.only(
                  left: 480 * 0.5 * 0.09, top: 800 * 0.5 * 0.02),
              child: Material(
                type: MaterialType.transparency,
                child: EditableText(
                  showCursor: true,
                  controller: TextEditingController(
                    text: widget.title,
                  ),
                  focusNode: FocusNode(),
                  style: TextStyle(
                    fontFamily: 'Roboto-Medium',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onPrimary,
                  ),
                  cursorColor: colorScheme.onPrimary,
                  backgroundCursorColor: Colors.black,
                  onChanged: _onTitleChanged,
                ),
              ),
            ),
            //
            // Color box
            //
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTapDown: (pos) {
                    _menuController.open(position: pos.localPosition);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 22.0),
                    child: Container(
                      color: Colors.white,
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: Center(
                          child: SizedBox(
                            width: 15,
                            height: 15,
                            child: Container(
                              color: boxColor,
                              child: MenuAnchor(
                                controller: _menuController,
                                anchorTapClosesMenu: true,
                                menuChildren: <Widget>[
                                  MenuItemButton(
                                    onPressed: () =>
                                        _activate(MenuEntry.colorGreen),
                                    child: Text(MenuEntry.colorGreen.label),
                                  ),
                                  MenuItemButton(
                                    onPressed: () =>
                                        _activate(MenuEntry.colorLightBlue),
                                    child: Text(MenuEntry.colorLightBlue.label),
                                  ),
                                  MenuItemButton(
                                    onPressed: () =>
                                        _activate(MenuEntry.colorOrange),
                                    child: Text(MenuEntry.colorOrange.label),
                                  ),
                                  MenuItemButton(
                                    onPressed: () =>
                                        _activate(MenuEntry.colorPurple),
                                    child: Text(MenuEntry.colorPurple.label),
                                  ),
                                  MenuItemButton(
                                    onPressed: () =>
                                        _activate(MenuEntry.colorTeal),
                                    child: Text(MenuEntry.colorTeal.label),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            //
            // Dates
            //
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 22.0),
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    child: Text(
                        'Created: ${widget.dateOfCreation.toString().replaceAll('00:00:00.000', '')}'),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 4.0, top: 8.0),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    child: Text(
                      '-',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    child: Text(
                      'Last edit: ${widget.dateOfLastEdit.toString().replaceAll('00:00:00.000', '')}',
                    ),
                  ),
                )
              ],
            ),
            //
            // Body
            //
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(left: 480 * 0.5 * 0.1, top: 10.0),
              child: EditableText(
                controller: _bodyTextEditingController,
                inputFormatters: [_bodyTextInputFormatter],
                focusNode: _bodyFocusNode,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  color: colorScheme.onPrimary,
                ),
                maxLines: null,
                showSelectionHandles: true,
                cursorColor: Colors.white,
                backgroundCursorColor: const Color.fromARGB(255, 68, 67, 67),
                onChanged: _onBodyChanged,
                readOnly: false,
                selectionColor: Colors.lightBlue.shade300,
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _onBodyChanged(String text) {
    if (text != widget.body) {
      _undoList.add(widget.body);
      _bodyTextEditingController.text = text;
      widget.body = _bodyTextEditingController.text;

      _bodyTextEditingController.selection = TextSelection.fromPosition(
          TextPosition(offset: _bodyTextInputFormatter.getCursorOffset()));

      if (_autoSave) {
        _undoColor.value = _activeUndoRedoColor;
        DateTime now = DateTime.now();
        NoteObject noteObject = NoteObject(
            id: widget.id,
            title: widget.title,
            body: widget.body,
            dateOfCreation: widget.dateOfCreation,
            dateOfLastEdit: DateTime(now.year, now.month, now.day),
            cardColor: widget.cardColor);
        _notesService.update(noteObject);
        // check if the note is already present in the map
        _notesMap.addAll({widget.id: noteObject});
        widget.dateOfLastEdit = DateTime(now.year, now.month, now.day);
      }
    }
  }

  void _onTitleChanged(String text) {
    if (text != widget.title) {
      widget.title = text;

      if (_autoSave) {
        _undoColor.value = _activeUndoRedoColor;
        DateTime now = DateTime.now();
        NoteObject noteObject = NoteObject(
            id: widget.id,
            title: widget.title,
            body: widget.body,
            dateOfCreation: widget.dateOfCreation,
            dateOfLastEdit: DateTime(now.year, now.month, now.day),
            cardColor: widget.cardColor);
        _notesService.update(noteObject);
        // check if the note is already present in the map
        _notesMap.addAll({widget.id: noteObject});
        widget.dateOfLastEdit = DateTime(now.year, now.month, now.day);
      }
    }
  }

  void _activate(MenuEntry selection) {
    Color tmp = widget.cardColor;

    switch (selection) {
      case MenuEntry.colorMenu:
        break;
      case MenuEntry.colorOrange:
        tmp = Colors.deepOrange.shade200;
      case MenuEntry.colorGreen:
        tmp = Colors.green.shade200;
      case MenuEntry.colorLightBlue:
        tmp = Colors.lightBlue.shade100;
      case MenuEntry.colorTeal:
        tmp = Colors.teal.shade100;
      case MenuEntry.colorPurple:
        tmp = Colors.deepPurple.shade100;
    }
    setState(() {
      widget.cardColor = tmp;
      boxColor = tmp;
      NoteObject noteObject = NoteObject(
          id: widget.id,
          title: widget.title,
          body: widget.body,
          dateOfCreation: widget.dateOfCreation,
          dateOfLastEdit: widget.dateOfLastEdit,
          cardColor: widget.cardColor);
      _notesService.update(noteObject);
    });
  }

  // business logic
  void _onNotesUpdate(Map<int, NoteObject> event) {
    /* setState(() {
      _notesMap = event;
    }); */
  }

  void _onSettingsUpdate(Map<int, SettingsObject> event) {
    setState(() {});
  }
}

enum MenuEntry {
  colorMenu('Color Menu'),
  colorOrange(
    'Orange Card',
  ),
  colorGreen(
    'Green Card',
  ),
  colorLightBlue(
    'Lightblue Card',
  ),
  colorTeal(
    'Teal Card',
  ),
  colorPurple(
    'Purple Card',
  );

  const MenuEntry(this.label, [this.shortcut]);
  final String label;
  final MenuSerializableShortcut? shortcut;
}
