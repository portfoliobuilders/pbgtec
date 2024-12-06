import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AssignmentPage extends StatefulWidget {
  final String courseId;
  final String moduleId;

  const AssignmentPage({
    Key? key,
    required this.courseId,
    required this.moduleId,
  }) : super(key: key);

  @override
  _AssignmentPageState createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _choiceController = TextEditingController();
  String? correctAnswer;
  int marks = 2;
  List<String> choices = [];
  String? editingAssignmentId;

  // Fetch assignments only for the specific module and course
  Stream<QuerySnapshot> _fetchAssignments() {
    return _firestore
        .collection('courses')
        .doc(widget.courseId)
        .collection('modules')
        .doc(widget.moduleId)
        .collection('assignments')
        .snapshots();
  }

  // Add or update an assignment
  Future<void> _saveAssignment() async {
    if (_questionController.text.trim().isEmpty) {
      _showError('Question cannot be empty');
      return;
    }

    if (choices.length < 2) {
      _showError('Add at least 2 choices');
      return;
    }

    if (correctAnswer == null) {
      _showError('Please select the correct answer');
      return;
    }

    try {
      final assignmentData = {
        'question': _questionController.text.trim(),
        'choices': choices,
        'correctAnswer': correctAnswer,
        'marks': marks,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (editingAssignmentId == null) {
        // Add new assignment
        await _firestore
            .collection('courses')
            .doc(widget.courseId)
            .collection('modules')
            .doc(widget.moduleId)
            .collection('assignments')
            .add(assignmentData);
        _showSuccess('Assignment added successfully');
      } else {
        // Update existing assignment
        await _firestore
            .collection('courses')
            .doc(widget.courseId)
            .collection('modules')
            .doc(widget.moduleId)
            .collection('assignments')
            .doc(editingAssignmentId)
            .update(assignmentData);
        _showSuccess('Assignment updated successfully');
      }

      _resetForm();
    } catch (e) {
      _showError('Error saving assignment: $e');
    }
  }

  // Edit an assignment
  void _editAssignment(DocumentSnapshot assignmentDoc) {
    final data = assignmentDoc.data() as Map<String, dynamic>;
    setState(() {
      editingAssignmentId = assignmentDoc.id;
      _questionController.text = data['question'] ?? '';
      choices = List<String>.from(data['choices'] ?? []);
      correctAnswer = data['correctAnswer'];
      marks = data['marks'] ?? 2;
    });
  }

  // Delete an assignment
  Future<void> _deleteAssignment(String assignmentId) async {
    try {
      await _firestore
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .doc(widget.moduleId)
          .collection('assignments')
          .doc(assignmentId)
          .delete();
      _showSuccess('Assignment deleted successfully');
    } catch (e) {
      _showError('Error deleting assignment: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _questionController.clear();
      _choiceController.clear();
      choices.clear();
      correctAnswer = null;
      marks = 2;
      editingAssignmentId = null;
    });
  }

  void _addChoice(String value) {
    if (value.trim().isEmpty) {
      _showError('Choice cannot be empty');
      return;
    }

    if (choices.contains(value.trim())) {
      _showError('This choice already exists');
      return;
    }

    setState(() {
      choices.add(value.trim());
      _choiceController.clear();
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Assignments', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.blue,
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Column(
          children: [
            // Stream to display assignments for the selected module
            StreamBuilder<QuerySnapshot>(
              stream: _fetchAssignments(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final assignments = snapshot.data?.docs ?? [];
                if (assignments.isEmpty) {
                  return const Center(child: Text('No assignments available.', style: TextStyle(fontSize: 16)));
                }

                return Column(
                  children: assignments.map((assignmentDoc) {
                    final assignmentData = assignmentDoc.data() as Map<String, dynamic>;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Question: ${assignmentData['question'] ?? 'No question'}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            Text('Marks: ${assignmentData['marks'] ?? 0}', style: TextStyle(fontSize: 14)),
                            const SizedBox(height: 8),
                            Text('Choices:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8.0,
                              children: (assignmentData['choices'] as List?)
                                      ?.map((choice) => Chip(
                                            label: Text(choice),
                                            backgroundColor: Colors.grey[200],
                                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                          ))
                                      .toList() ??
                                  [const Text('No choices')],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Correct Answer: ${assignmentData['correctAnswer'] ?? 'Not set'}',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editAssignment(assignmentDoc),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteAssignment(assignmentDoc.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            // Form to add or edit assignment
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      editingAssignmentId == null ? 'Add New Assignment' : 'Edit Assignment',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _questionController,
                      decoration: const InputDecoration(
                        labelText: 'Question',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      ),
                      maxLines: null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _choiceController,
                            decoration: const InputDecoration(
                              labelText: 'Add Choice',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            ),
                            onSubmitted: _addChoice,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: () => _addChoice(_choiceController.text),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8.0,
                      children: choices.map((choice) => Chip(
                        label: Text(choice),
                        onDeleted: () {
                          setState(() {
                            choices.remove(choice);
                            if (correctAnswer == choice) {
                              correctAnswer = null;
                            }
                          });
                        },
                      )).toList(),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Correct Answer',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      ),
                      value: correctAnswer,
                      items: choices.map((choice) => DropdownMenuItem(
                        value: choice,
                        child: Text(choice),
                      )).toList(),
                      onChanged: (value) => setState(() => correctAnswer = value),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Marks',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => setState(() {
                        marks = int.tryParse(value) ?? 2;
                      }),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _saveAssignment,
                      child: Text(
                        editingAssignmentId == null ? 'Add Assignment' : 'Update Assignment',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}