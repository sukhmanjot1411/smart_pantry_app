import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<InventoryItem> inventoryItems = [];
  final dateFormat = DateFormat('dd/MM/yyyy');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<QuerySnapshot>? _inventorySubscription;

  @override
  void initState() {
    super.initState();
    _setupInventoryListener();
  }

  void _setupInventoryListener() {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      print('Fetching inventory for user: $userId');
      _inventorySubscription = _firestore
          .collection('users')
          .doc(userId)
          .collection('inventory')
          .snapshots()
          .listen((snapshot) {
        setState(() {
          inventoryItems = snapshot.docs.map((doc) {
            final data = doc.data();
            data['category'] = data['category'].toLowerCase();
            return InventoryItem.fromMap(data, doc.id);
          }).toList();
          // Sort inventory items by expiry date
          inventoryItems.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
          print('Fetched ${inventoryItems.length} items');
        });
        // Scroll to bottom when new items are added
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }, onError: (error) {
        print('Error fetching inventory: $error');
      });
    } else {
      print('User is not authenticated');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inventorySubscription?.cancel();
    super.dispose();
  }

  Future<void> _addItemToFirebase(InventoryItem item) async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('inventory')
            .add(item.toMap());
        print('Item added to Firebase');
      } catch (error) {
        print('Error adding item to Firebase: $error');
      }
    }
  }

  Future<void> _updateItemInFirebase(InventoryItem item) async {
    final userId = _auth.currentUser?.uid;
    if (userId != null && item.id != null) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('inventory')
            .doc(item.id)
            .update(item.toMap());
        print('Item updated in Firebase');
      } catch (error) {
        print('Error updating item in Firebase: $error');
      }
    }
  }

  Future<void> _deleteItemFromFirebase(String itemId) async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('inventory')
            .doc(itemId)
            .delete();
        print('Item deleted from Firebase');
      } catch (error) {
        print('Error deleting item from Firebase: $error');
      }
    }
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(
        onAdd: (item) {
          _addItemToFirebase(item);
        },
      ),
    );
  }

  void _editItem(InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(
        initialItem: item,
        onAdd: (updatedItem) {
          updatedItem.id = item.id;
          _updateItemInFirebase(updatedItem);
        },
      ),
    );
  }

  void _deleteItem(String itemId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final item =
            inventoryItems.firstWhere((element) => element.id == itemId);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Delete Item',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Are you sure you want to delete "${item.name}"?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        _deleteItemFromFirebase(itemId);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _scanBill() async {
    try {
      final ImagePicker imagePicker = ImagePicker();
      final XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (pickedFile == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected')),
        );
        return;
      }

      final inputImage = InputImage.fromFile(File(pickedFile.path));
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      List<String> products = [];
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          if (line.text.contains('ITEMS -')) {
            // Extract everything after "ITEMS -" and split by comma
            String itemsText = line.text.split('ITEMS -')[1].trim();
            if (itemsText.endsWith('.')) {
              itemsText = itemsText.substring(0, itemsText.length - 1);
            }
            products = itemsText
                .split(',')
                .map((item) => item.trim())
                .where((item) => item.isNotEmpty)
                .toList();
            break; // Stop after finding the items line
          }
        }
        if (products.isNotEmpty) break; // Stop searching if we found items
      }

      textRecognizer.close();

      if (products.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No products found in the bill')),
        );
        return;
      }

      // Show products selection dialog
      if (!mounted) return;
      final List<String>? selectedProducts = await showDialog<List<String>>(
        context: context,
        builder: (BuildContext context) {
          return _ProductSelectionDialog(products: products);
        },
      );

      if (selectedProducts == null || selectedProducts.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No products selected')),
        );
        return;
      }

      // Process selected products
      for (String product in selectedProducts) {
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (context) => AddItemDialog(
            initialItemName: product,
            onAdd: (item) {
              _addItemToFirebase(item);
            },
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning bill: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<InventoryItem>> itemsByCategory = {};
    for (var item in inventoryItems) {
      if (!itemsByCategory.containsKey(item.category)) {
        itemsByCategory[item.category] = [];
      }
      itemsByCategory[item.category]!.add(item);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: _scanBill,
          ),
        ],
      ),
      body: itemsByCategory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No items in inventory',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              itemCount: itemsByCategory.length,
              itemBuilder: (context, index) {
                String category = itemsByCategory.keys.elementAt(index);
                List<InventoryItem> items = itemsByCategory[category]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFF49619).withOpacity(0.8),
                            Color(0xFFF49619).withOpacity(0.6),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.category_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            category.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${items.length} items',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, itemIndex) {
                        final item = items[itemIndex];
                        final daysUntilExpiry =
                            item.expiryDate.difference(DateTime.now()).inDays;
                        final isExpiringSoon =
                            daysUntilExpiry <= 5 && daysUntilExpiry >= 0;
                        final isExpired = daysUntilExpiry < 0;
                        final isSafe = daysUntilExpiry > 5;

                        return Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isExpired
                                    ? Colors.red.withOpacity(0.1)
                                    : isExpiringSoon
                                        ? Colors.yellow.withOpacity(0.1)
                                        : isSafe
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFF49619)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.inventory_2_outlined,
                                            color: Color(0xFFF49619),
                                            size: 24,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFF49619)
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'Quantity: ${item.quantity} ${item.unit}',
                                                  style: TextStyle(
                                                    color: Color(0xFFF49619),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit,
                                                  color: Colors.blue),
                                              onPressed: () => _editItem(item),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete_outline,
                                                  color: Colors.red),
                                              onPressed: () {
                                                _deleteItem(item.id!);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          _buildDateRow(
                                            'Expiry Date',
                                            dateFormat.format(item.expiryDate),
                                            Icons.event,
                                            textColor: isExpired
                                                ? Colors.red
                                                : isExpiringSoon
                                                    ? Color.fromARGB(
                                                        171, 184, 157, 4)
                                                    : Colors.black87,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isExpired || isExpiringSoon)
                                      Container(
                                        margin: EdgeInsets.only(top: 12),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isExpired
                                              ? Colors.red.withOpacity(0.1)
                                              : Colors.yellow.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              isExpired
                                                  ? Icons.error_outline
                                                  : Icons.warning_amber_rounded,
                                              color: isExpired
                                                  ? Colors.red
                                                  : Color.fromARGB(
                                                      171, 184, 157, 4),
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              isExpired
                                                  ? 'Expired ${-daysUntilExpiry} days ago'
                                                  : 'Expires in $daysUntilExpiry days',
                                              style: TextStyle(
                                                color: isExpired
                                                    ? Colors.red
                                                    : Color.fromARGB(
                                                        171, 184, 157, 4),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(0xFFF49619),
        onPressed: _addItem,
        icon: Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: Text(
          'Add Item',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDateRow(String label, String value, IconData icon,
      {Color textColor = Colors.black87}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

class _ProductSelectionDialog extends StatefulWidget {
  final List<String> products;

  const _ProductSelectionDialog({Key? key, required this.products})
      : super(key: key);

  @override
  State<_ProductSelectionDialog> createState() =>
      _ProductSelectionDialogState();
}

class _ProductSelectionDialogState extends State<_ProductSelectionDialog> {
  final Set<String> _selectedProducts = {};

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF49619).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long,
                color: Color(0xFFF49619),
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Detected Products',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Select the products you want to add:',
              style: TextStyle(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: widget.products.map((product) {
                    return CheckboxListTile(
                      title: Text(product),
                      value: _selectedProducts.contains(product),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedProducts.add(product);
                          } else {
                            _selectedProducts.remove(product);
                          }
                        });
                      },
                      activeColor: const Color(0xFFF49619),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF49619),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, _selectedProducts.toList());
                  },
                  child: const Text(
                    'Add Selected',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddItemDialog extends StatefulWidget {
  final Function(InventoryItem) onAdd;
  final InventoryItem? initialItem;
  final String? initialItemName;

  const AddItemDialog(
      {super.key, required this.onAdd, this.initialItem, this.initialItemName});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  List<String> _units = ['Kg', 'L', 'Piece', 'Pack'];
  String? _selectedUnit;
  List<String> _categories = [
    'Fruits',
    'Vegetables',
    'Dairy',
    'Snacks',
    'Meat',
    'Grains',
    'Spices'
  ];
  String? _selectedCategory;
  DateTime? _expiryDate;
  final dateFormat = DateFormat('MMM dd, yyyy');
  final _quantityController = TextEditingController();

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _newCategoryController =
            TextEditingController();
        return AlertDialog(
          title: Text('Add New Category'),
          content: TextField(
            controller: _newCategoryController,
            decoration: InputDecoration(
              hintText: 'Enter new category',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                setState(() {
                  _categories.add(_newCategoryController.text);
                  _selectedCategory = _newCategoryController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddUnitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _newUnitController =
            TextEditingController();
        return AlertDialog(
          title: Text('Add New Unit'),
          content: TextField(
            controller: _newUnitController,
            decoration: InputDecoration(
              hintText: 'Enter new unit',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                setState(() {
                  _units.add(_newUnitController.text);
                  _selectedUnit = _newUnitController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFF49619),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialItem != null) {
      _nameController.text = widget.initialItem!.name;
      _selectedCategory = widget.initialItem!.category;
      _expiryDate = widget.initialItem!.expiryDate;
      _selectedUnit = widget.initialItem!.unit;
      _quantityController.text = widget.initialItem!.quantity.toString();
    } else if (widget.initialItemName != null) {
      _nameController.text = widget.initialItemName!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF49619).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: Color(0xFFF49619),
                    size: 32,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  widget.initialItem != null ? 'Edit Item' : 'Add New Item',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    hintText: 'Enter item name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFFF49619)),
                    ),
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter item name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList()
                    ..add(
                      DropdownMenuItem(
                        value: 'Add New Category',
                        child: Text('Add New Category'),
                      ),
                    ),
                  onChanged: (String? newValue) {
                    if (newValue == 'Add New Category') {
                      _showAddCategoryDialog();
                    } else {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFFF49619)),
                    ),
                    prefixIcon: Icon(Icons.category),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    hintText: 'Enter quantity',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFFF49619)),
                    ),
                    prefixIcon: Icon(Icons.numbers),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter quantity';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  items: _units.map((unit) {
                    return DropdownMenuItem(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList()
                    ..add(
                      DropdownMenuItem(
                        value: 'Add New Unit',
                        child: Text('Add New Unit'),
                      ),
                    ),
                  onChanged: (String? newValue) {
                    if (newValue == 'Add New Unit') {
                      _showAddUnitDialog();
                    } else {
                      setState(() {
                        _selectedUnit = newValue;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFFF49619)),
                    ),
                    prefixIcon: Icon(Icons.straighten),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a unit';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildDateSelector(
                  'Expiry Date',
                  _expiryDate,
                  () => _selectDate(context),
                  Icons.event,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _expiryDate != null &&
                        _selectedUnit != null &&
                        _selectedCategory != null) {
                      widget.onAdd(InventoryItem(
                        id: '',
                        name: _nameController.text,
                        category: _selectedCategory!,
                        quantity: int.parse(_quantityController.text),
                        unit: _selectedUnit!,
                        expiryDate: _expiryDate!,
                      ));
                      Navigator.of(context).pop();
                    } else if (_expiryDate == null ||
                        _selectedUnit == null ||
                        _selectedCategory == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Please select expiry date, unit, and category'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF49619),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      widget.initialItem != null ? 'Update Item' : 'Add Item',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(
    String label,
    DateTime? selectedDate,
    VoidCallback onTap,
    IconData icon,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[600]),
            SizedBox(width: 8),
            Text(
              '$label: ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              selectedDate != null
                  ? dateFormat.format(selectedDate)
                  : 'Select Date',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}

class InventoryItem {
  String id;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final DateTime expiryDate;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.expiryDate,
  });

  factory InventoryItem.fromMap(Map<String, dynamic> map, String id) {
    return InventoryItem(
      id: id,
      name: map['name'],
      category: map['category'] ?? 'Other',
      quantity: map['quantity'],
      unit: map['unit'] ?? 'kg',
      expiryDate: DateTime.parse(map['expiryDate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'expiryDate': expiryDate.toIso8601String(),
    };
  }
}
