// ignore_for_file: unnecessary_const

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_camera/api/gemini.dart';
import 'package:flutter_camera/globals.dart';
import 'package:flutter_camera/model/inventory_item.dart';
import 'package:flutter_camera/providers/inventory_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InventoryWidget extends ConsumerStatefulWidget {
  const InventoryWidget({super.key});

  @override
  InventoryWidgetState createState() => InventoryWidgetState();
}

class InventoryWidgetState extends ConsumerState<InventoryWidget> {
  final TextEditingController _textController = TextEditingController();
  SplayTreeSet<InventoryItem> uniqueFilteredItems = SplayTreeSet<InventoryItem>(
    (b, a) => a.itemId.compareTo(b.itemId),
  );

  bool isLoading = false;

  String convo = "";

  void _onSendPressed(List<InventoryItem> items) {
    setState(() {
      isLoading = true;
    });
    // Handle send button press
    print("Send button pressed with text: ${_textController.text}");
    askGeminiInventory(_textController.text, items);
    //_textController.clear();
  }

  void askGeminiInventory(String userQ, List<InventoryItem> items) async {
    List<String> descriptions = [];
    for (final item in items) {
      if (item.aiDesc.isNotEmpty && item.aiDesc.toLowerCase() != 'none') {
        descriptions.add(item.aiDesc);
      }

      if (item.aiDesc.isNotEmpty && item.aiDesc.toLowerCase() != 'none') {
        descriptions.add(item.aiDesc);
      }
    }

    String prompt =
        "QUERY: $userQ. $PROMPT_INVENTORY_SEARCH${descriptions.toString()}";

    final response = await askGemini(prompt, modelName: GEMINI_MODEL_FLASH);
    print('gemini response $response');

    if (normalizeDescription(response) == 'none' ||
        normalizeDescription(response.replaceFirst('ITEMS:', '')) == 'none') {
      setState(() {
        convo = "No results";
        isLoading = false;
      });
    }

    String descList = "";

    if (response.contains("ITEMS:")) {
      final parts = response.split("ITEMS:");
      print('items split len ${parts.length} first part ${parts[0]}');
      if (parts.length > 1) {
        convo = parts[0];
        descList = parts[1];
      } else {
        descList = parts[0];
      }

      print('desc list $descList');
      List<InventoryItem> filteredItems = [];

      for (final desc in descList.split("\n")) {
        final normDesc = desc.toLowerCase().trim().replaceAll(' ', '');
        print('norm desc $normDesc');
        for (final item in items) {
          if (item.aiDesc.isNotEmpty &&
              normalizeDescription(item.aiDesc) == normDesc) {
            print('matched ai desc');
            filteredItems.add(item);
          } else if (item.humanDesc.isNotEmpty &&
              normalizeDescription(item.humanDesc) == normDesc) {
            print('matched human desc');

            filteredItems.add(item);
          }
        }

        uniqueFilteredItems.clear();
        uniqueFilteredItems.addAll(filteredItems);
      }

      setState(() {
        isLoading = false;
      });
    }

    print("--Gemini response--\n $response \n--end---");
  }

  String normalizeDescription(String desc) {
    return desc.toLowerCase().trim().replaceAll(' ', '');
  }

  @override
  Widget build(BuildContext context) {
    //final items = ref.watch(inventoryItemsProvider.future);

    return FutureBuilder(
        future: ref.watch(inventoryItemsProvider.future),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: const CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data'));
          } else {
            var allItems = snapshot.data!;
            var items = allItems;

            if (!uniqueFilteredItems.isEmpty) {
              print('filtered items size ${uniqueFilteredItems.length}');
              items = uniqueFilteredItems.toList();
            }

            return Center(
              child: isLoading
                  ? Text(
                      "Searching...",
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                  : SizedBox(
                      width: 500,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _textController,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter text',
                                    ),
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    _onSendPressed(allItems);
                                  },
                                  child: const Text('Search'),
                                ),
                              ],
                            ),
                          ),
                          Text(convo),
                          Expanded(
                            child: ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          item.date,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          item.location,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),                                      
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.network(item.image),
                                      ),
                                      //Text(item.image),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          item.aiDesc,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          }
        });
  }
}
