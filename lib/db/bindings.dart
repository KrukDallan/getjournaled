
// bind to get_it the services
import 'package:get_it/get_it.dart';
import 'package:getjournaled/db/abstraction/journal_service/journal_map_service.dart';
import 'package:getjournaled/db/abstraction/journal_service/local_journal_map_service.dart';
import 'package:getjournaled/db/abstraction/note_service/local_note_map_service.dart';
import 'package:getjournaled/db/abstraction/note_service/note_map_service.dart';

Future<void> bindDependencies() async{
  // If you want to change the 'database', just change "LocalNoteMapService"
  // synchronous
  GetIt.I.registerSingleton<NoteService>(LocalNoteMapService());
  GetIt.I.registerSingleton<JournalService>(LocalJournalMapService());

/* // "transparent" activation
  GetIt.I.registerSingletonAsync(() async {
    var instance = LocalNoteMapService();
    await instance.open();
    return instance;
  });

  // initialize all singleton async
await GetIt.I.allReady(); */
}