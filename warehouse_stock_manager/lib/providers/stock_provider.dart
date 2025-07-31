import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/stock_item.dart';

class StockProvider extends ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  List<StockItem> _items = [];
  bool isLoading = false;

  List<StockItem> get items => _items;

  StockProvider() {
    _listenToStockItems();
  }

  void _listenToStockItems() {
    isLoading = true;
    notifyListeners();
    _dbRef.child('stock_items').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        _items = data.entries.map((e) {
          final value = e.value as Map<dynamic, dynamic>;
          return StockItem.fromMap(e.key, Map<String, dynamic>.from(value));
        }).toList();
      } else {
        _items = [];
      }
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addStockItem(StockItem item) async {
    final newRef = _dbRef.child('stock_items').push();
    item.id = newRef.key;
    await newRef.set(item.toMap());
  }

  Future<void> updateStockItem(StockItem item) async {
    if (item.id == null) return;
    await _dbRef.child('stock_items/${item.id}').update(item.toMap());
  }

  Future<void> deleteStockItem(String id) async {
    await _dbRef.child('stock_items/$id').remove();
  }
}
