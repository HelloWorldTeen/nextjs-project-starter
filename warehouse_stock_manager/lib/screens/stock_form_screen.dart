import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/stock_item.dart';
import '../providers/stock_provider.dart';

class StockFormScreen extends StatefulWidget {
  final StockItem? stockItem;

  const StockFormScreen({Key? key, this.stockItem}) : super(key: key);

  @override
  State<StockFormScreen> createState() => _StockFormScreenState();
}

class _StockFormScreenState extends State<StockFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late int _quantity;
  String? _description;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _name = widget.stockItem?.name ?? '';
    _quantity = widget.stockItem?.quantity ?? 0;
    _description = widget.stockItem?.description;
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isSubmitting = true;
    });

    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    final stockItem = StockItem(
      id: widget.stockItem?.id,
      name: _name,
      quantity: _quantity,
      description: _description,
    );

    try {
      if (widget.stockItem == null) {
        await stockProvider.addStockItem(stockItem);
      } else {
        await stockProvider.updateStockItem(stockItem);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Handle error, show snackbar or dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving stock item: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.stockItem != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Stock Item' : 'Add Stock Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isSubmitting
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _name,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the item name';
                        }
                        return null;
                      },
                      onSaved: (value) => _name = value!.trim(),
                    ),
                    TextFormField(
                      initialValue: _quantity.toString(),
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the quantity';
                        }
                        final n = int.tryParse(value);
                        if (n == null || n < 0) {
                          return 'Please enter a valid non-negative number';
                        }
                        return null;
                      },
                      onSaved: (value) => _quantity = int.parse(value!),
                    ),
                    TextFormField(
                      initialValue: _description,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      onSaved: (value) => _description = value?.trim(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(isEditing ? 'Update' : 'Add'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
