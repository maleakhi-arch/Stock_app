class StockHistory {
  int? id;
  int itemId;
  int change;
  String note;
  int resultingStock;
  String timestamp;

  StockHistory({
    this.id,
    required this.itemId,
    required this.change,
    required this.note,
    required this.resultingStock,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'itemId': itemId,
      'change': change,
      'note': note,
      'resultingStock': resultingStock,
      'timestamp': timestamp,
    };

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  factory StockHistory.fromMap(Map<String, dynamic> map) {
    return StockHistory(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
      itemId: map['itemId'] ?? 0,
      change: map['change'] ?? 0,
      note: map['note'] ?? '',
      resultingStock: map['resultingStock'] ?? 0,
      timestamp: map['timestamp'] ?? '',
    );
  }

  @override
  String toString() {
    return 'StockHistory('
        'id: $id, '
        'itemId: $itemId, '
        'change: $change, '
        'note: $note, '
        'resultingStock: $resultingStock, '
        'timestamp: $timestamp'
        ')';
  }

  String get formattedTime {
    try {
      final date = DateTime.parse(timestamp);
      final formattedDate =
          '${date.day}-${date.month}-${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      return formattedDate;
    } catch (e) {
      return timestamp;
    }
  }
}
