import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pw_crudapp/services/firestore.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Firestore
  final FirestoreService firestoreService = FirestoreService();

  // Text Controller
  final TextEditingController textController = TextEditingController();

  // Dialog Box Note
  void openNoteBox({String? docId}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
              ),
              actions: [
                // Save note button
                ElevatedButton(
                    onPressed: () {
                      // Add note to db
                      if (docId == null) {
                        firestoreService.addNote(textController.text);
                      }

                      // Update note to db
                      else {
                        firestoreService.updateNote(docId, textController.text);
                      }

                      //clear text after add
                      textController.clear();

                      //close dialog
                      Navigator.pop(context);
                    },
                    child: Text("Add"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "のっと",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.deepPurple[200],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: openNoteBox, child: const Icon(Icons.add)),
        body: StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getNotesStream(),
          builder: (context, snapshot) {
            // Check if there is data
            if (snapshot.hasData) {
              // Get data and put in a List
              List notesList = snapshot.data!.docs;

              // Display data as a listview
              return ListView.builder(
                  itemCount: notesList.length,
                  itemBuilder: (context, index) {
                    // Get Individual doc
                    DocumentSnapshot document = notesList[index];
                    String docId = document.id;

                    // Get note from each doc
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;

                    String noteText = data['note'];

                    DateTime date = (data['timestamp'] as Timestamp).toDate();
                    String noteDate = DateFormat.yMMMd().add_jm().format(date);

                    // Display as a tile
                    return Padding(
                      padding:
                          const EdgeInsets.only(top: 10, left: 5, right: 5),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          // Title
                          title: Text(
                            noteText,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),

                          // Date
                          subtitle: Text(noteDate),
                          tileColor: Colors.deepPurple[100],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Update Button
                              IconButton(
                                onPressed: () => openNoteBox(docId: docId),
                                icon: const Icon(Icons.settings),
                              ),

                              // Delete Button
                              IconButton(
                                onPressed: () =>
                                    firestoreService.deleteNote(docId),
                                icon: const Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            }

            // If no data return no notes
            else {
              return const Text("のっとがいません...");
            }
          },
        ));
  }
}
