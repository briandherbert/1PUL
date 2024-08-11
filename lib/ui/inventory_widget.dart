// ignore_for_file: unnecessary_const

import 'package:flutter/material.dart';
import 'package:flutter_camera/api/gemini.dart';
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
  List<InventoryItem> filteredDescriptions = [];
  String convo = "";

  void _onSendPressed(List<InventoryItem> items) {
    // Handle send button press
    print("Send button pressed with text: ${_textController.text}");
    askGeminiInventory(_textController.text, items);
    _textController.clear();
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
        "QUERY: $userQ. Answer the query from this list of item descriptions. Return a list of the most relevant descriptions verbatim, in the format ITEMS: \nDESCRIPTION_1\nDESCRIPTION_2\n\n If there are no relevant matches, say \"none\". If you need to say anything else, say it before listing items. Item decscriptions: \n${descriptions.toString()}";

    final response = await askGemini(prompt);

    String descList = "";

    if (response.contains("ITEMS:")) {
      final parts = response.split("ITEMS:");
      if (parts.length > 1) {
        convo = parts[0];
        descList = parts[1];
      } else {
        descList = parts[0];
      }

      for (final desc in descList.split("\n")) {
        final normDesc = desc.toLowerCase().replaceAll(' ', '');
        for (final item in items) {
          if (item.aiDesc.toLowerCase().replaceAll(' ', '') == normDesc) {
            filteredDescriptions.add(item);
          } else if (item.aiDesc.toLowerCase().replaceAll(' ', '') == normDesc) {
            filteredDescriptions.add(item);
          }
        }
      }

      setState(() {
      });
    }

    print("--Gemini response--\n $response \n--end---");
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
            var items = snapshot.data!;

            if (!filteredDescriptions.isEmpty) {
              items = filteredDescriptions;
            }

            return Column(
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
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          _onSendPressed(items);
                        },
                        child: const Text('Send'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                item.date,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                item.aiDesc,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                item.image,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Text(item.location),
                            Text(item.itemId),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.network(item.image),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        });
  }
}
