import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/stock_provider.dart';
import '../models/stock_item.dart';
import 'stock_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final stockProvider = Provider.of<StockProvider>(context);

    final isAdmin = authProvider.role == 'admin';

    List<StockItem> filteredItems = stockProvider.items.where((item) {
      return item.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouse Stock Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
            },
            tooltip: 'Logout',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search stock items...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: stockProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredItems.isEmpty
              ? const Center(child: Text('No stock items found.'))
              : ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return StockItemTile(
                      item: item,
                      isAdmin: isAdmin,
                      onEdit: () {
                        if (isAdmin) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StockFormScreen(stockItem: item),
                            ),
                          );
                        }
                      },
                      onDelete: () async {
                        if (isAdmin && item.id != null) {
                          await stockProvider.deleteStockItem(item.id!);
                        }
                      },
                    );
                  },
                ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StockFormScreen()),
                );
              },
              child: const Icon(Icons.add),
              tooltip: 'Add Stock Item',
            )
          : null,
    );
  }
}

class StockItemTile extends StatelessWidget {
  final StockItem item;
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const StockItemTile({
    Key? key,
    required this.item,
    required this.isAdmin,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: item.description != null && item.description!.isNotEmpty
            ? Text(item.description!)
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: item.quantity <= 5 ? Colors.redAccent : Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.quantity.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            if (isAdmin) ...[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
                tooltip: 'Delete',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
