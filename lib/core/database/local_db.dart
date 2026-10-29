import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../objectbox.g.dart';

class LocalDb {
  late final Store store;

  LocalDb._create(this.store);

  static Future<LocalDb> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final storeDir = p.join(docsDir.path, "travel_logs_db");

    final store = await openStore(directory: storeDir);
    return LocalDb._create(store);
  }
}