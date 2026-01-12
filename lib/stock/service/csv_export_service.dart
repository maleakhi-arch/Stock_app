import 'dart:io';
import 'package:csv/csv.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/item.dart';

class CsvExportService {
  Future<String> exportItemsToCSV(List<Item> items) async {
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();

    List<List<dynamic>> rows = [];

    rows.add(['Nama', 'Kode', 'Stok', 'Harga Beli', 'Harga Jual', 'Min Stok']);

    for (var item in items) {
      rows.add([
        item.name,
        item.code,
        item.stock,
        item.buyPrice,
        item.sellPrice,
        item.minStock,
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    String path = "/storage/emulated/0/Download/stock_export.csv";

    File file = File(path);
    await file.writeAsString(csv);

    return path;
  }
}
