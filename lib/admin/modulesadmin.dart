import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gtech/admin/adcourseadmin.dart';
import 'package:gtech/admin/assignment.dart';
import 'package:gtech/admin/dashboard.dart';

class ModuleScreen extends StatefulWidget {
  final String courseId;

  const ModuleScreen({Key? key, required this.courseId, required Null Function() onBackPressed}) : super(key: key);

  @override
  _ModuleScreenState createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  String? selectedModuleId;
    String? selectedCourseId;
  String? selectedModuleName;

  @override
void initState() {
  super.initState();
  selectedCourseId = widget.courseId; // Initialize selectedCourseId with the courseId passed from the parent
}
  List<Map<String, dynamic>> lessons = [];

  // Fetch modules
// Fetch modules sorted by order
Future<List<Map<String, dynamic>>> _fetchModules() async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('courses')
      .doc(widget.courseId)
      .collection('modules')
      .orderBy('order') // Order modules by the 'order' field
      .get();

  return querySnapshot.docs
      .map((doc) => {
            'id': doc.id,
            'name': doc['name'],
            'order': doc['order'],
          })
      .toList();
}


  // Fetch lessons for a module
  Future<void> _fetchLessons(String moduleId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('modules')
        .doc(moduleId)
        .collection('lessons')
        .get();

    setState(() {
      lessons = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
                'url': doc['url'],
              })
          .toList();
    });
  }

  // Add a lesson
  Future<void> _addLesson(String moduleId, String name, String url) async {
    final lessonData = {'name': name, 'url': url};
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('modules')
        .doc(moduleId)
        .collection('lessons')
        .add(lessonData);

    // Fetch the updated list of lessons after adding a new lesson
    _fetchLessons(moduleId);
  }

  // Add a module
// Add a module with an order field
Future<void> _addModule(String name) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('courses')
      .doc(widget.courseId)
      .collection('modules')
      .orderBy('order', descending: true)
      .limit(1)
      .get();

  int newOrder = 1; // Default order if there are no modules
  if (querySnapshot.docs.isNotEmpty) {
    newOrder = querySnapshot.docs.first['order'] + 1; // Set new order to the last order + 1
  }

  final moduleData = {
    'name': name,
    'order': newOrder, // Set the order field
  };
  await FirebaseFirestore.instance
      .collection('courses')
      .doc(widget.courseId)
      .collection('modules')
      .add(moduleData);

  // Refresh the module list
  setState(() {});
}


  // Delete a course
Future<void> _deleteCourse() async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete Course'),
        content: const Text('Are you sure you want to delete this course?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Cancel and close dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true); // Confirm deletion and close dialog
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  if (shouldDelete == true) {
    // Delete the course from Firestore
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .delete();

    // Navigate to the DashboardScreen after deletion
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => DashboardScreen()),
    );
  }
}
// Delete a module
Future<void> _deleteModule(String moduleId) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete Module'),
        content: const Text('Are you sure you want to delete this module?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Cancel
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Confirm
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  if (shouldDelete == true) {
    // Delete the module from Firestore
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('modules')
        .doc(moduleId)
        .delete();

    // Refresh the module list
    setState(() {});
  }
}


  // Show dialog to add lesson
  void _showAddLessonDialog(BuildContext context, String moduleId) {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Lesson'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Lesson Name'),
              ),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: 'Lesson URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final String name = _nameController.text;
                final String url = _urlController.text;
                if (name.isNotEmpty && url.isNotEmpty) {
                  _addLesson(moduleId, name, url);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter both name and URL')),
                  );
                }
              },
              child: const Text('Add Lesson'),
            ),
          ],
        );
      },
    );
  }

void _navigateToAssignmentPage(BuildContext context, String courseId, String moduleId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AssignmentPage(
        courseId: courseId,  // Pass the courseId here
        moduleId: moduleId,  // Pass the moduleId here
      ),
    ),
  );
}


  // Show dialog to add module
  void _showAddModuleDialog(BuildContext context) {
    final TextEditingController _nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Module'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Module Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final String name = _nameController.text;
                if (name.isNotEmpty) {
                  _addModule(name);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a module name')),
                  );
                }
              },
              child: const Text('Add Module'),
            ),
          ],
        );
      },
    );
  }
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
  // Edit a module
Future<void> _editModule(String moduleId, String currentName) async {
    final TextEditingController nameController = TextEditingController(text: currentName);

    final String? newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Module'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Module Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != currentName) {
      try {
        await FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId)
            .collection('modules')
            .doc(moduleId)
            .update({
              'name': newName,
              'updatedAt': FieldValue.serverTimestamp(),
            });

        _showSuccessSnackBar('Module updated successfully');
        setState(() {
          if (selectedModuleId == moduleId) {
            selectedModuleName = newName;
          }
        });
      } catch (e) {
        _showErrorSnackBar('Error updating module');
        debugPrint('Error updating module: $e');
      }
    }
  }

  // Edit a lesson
  void _editLesson(BuildContext context, String moduleId, String lessonId, String currentName, String currentUrl) {
    final TextEditingController _nameController = TextEditingController(text: currentName);
    final TextEditingController _urlController = TextEditingController(text: currentUrl);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Lesson'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Lesson Name'),
              ),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: 'Lesson URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final String name = _nameController.text;
                final String url = _urlController.text;
                if (name.isNotEmpty && url.isNotEmpty) {
                  FirebaseFirestore.instance
                      .collection('courses')
                      .doc(widget.courseId)
                      .collection('modules')
                      .doc(moduleId)
                      .collection('lessons')
                      .doc(lessonId)
                      .update({'name': name, 'url': url});
                  setState(() {});
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter both name and URL')),
                  );
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  // Delete a lesson
 // Delete a lesson
Future<void> _deleteLesson(String moduleId, String lessonId) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete Lesson'),
        content: const Text('Are you sure you want to delete this lesson?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Cancel
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Confirm
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  if (shouldDelete == true) {
    // Delete the lesson from Firestore
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('modules')
        .doc(moduleId)
        .collection('lessons')
        .doc(lessonId)
        .delete();
    
    // Refresh the list of lessons
    _fetchLessons(moduleId);
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
        },
      ),
      title: const Text(
        'Course Management',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: 0.5,
        ),
      ),
      backgroundColor:  Colors.blue, // Custom teal shade
      elevation: 0,
      // shape: const RoundedRectangleBorder(
      //   borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      // ),
    ),
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color.fromARGB(255, 255, 255, 255),
            const Color.fromARGB(255, 255, 255, 255),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(
                  onPressed: () => _showAddModuleDialog(context),
                  icon: Icons.add_circle_outline,
                  label: 'Add Module',
                  color: const Color.fromARGB(255, 72, 173, 209),
                ),
                _buildActionButton(
                  onPressed: _deleteCourse,
                  icon: Icons.delete_outline,
                  label: 'Delete Course',
                  color: Colors.redAccent,
                ),
              ],
            ),
            const SizedBox(height: 24),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchModules(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00897B)),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState('No modules available');
                }

                final modules = snapshot.data!;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedModuleId,
                      hint: const Text(
                        'Select a Module',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF424242),
                        ),
                      ),
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                      items: modules.map((module) {
                        return DropdownMenuItem<String>(
                          value: module['id'],
                          child: Text(
                            module['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF424242),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedModuleId = value;
                          selectedModuleName = modules
                              .firstWhere((module) => module['id'] == value)['name'];
                        });
                        if (value != null) {
                          _fetchLessons(value);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
            if (selectedModuleId != null) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      onPressed: () => _showAddLessonDialog(context, selectedModuleId!),
                      icon: Icons.book_outlined,
                      label: 'Create Lesson',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      onPressed: () => _navigateToAssignmentPage(
                        context,
                        widget.courseId,
                        selectedModuleId!,
                      ),
                      icon: Icons.assignment_outlined,
                      label: 'Create Assignment',
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildTextButton(
                    onPressed: () => _editModule(selectedModuleId!, selectedModuleName!),
                    icon: Icons.edit_outlined,
                    label: 'Edit Module',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  _buildTextButton(
                    onPressed: () => _deleteModule(selectedModuleId!),
                    icon: Icons.delete_outline,
                    label: 'Delete Module',
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (lessons.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF00897B),
                          child: Icon(Icons.school, color: Colors.white),
                        ),
                        title: Text(
                          lesson['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF424242),
                          ),
                        ),
                        subtitle: Text(
                          lesson['url'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _editLesson(
                                context,
                                selectedModuleId!,
                                lesson['id'],
                                lesson['name'],
                                lesson['url'],
                              ),
                              icon: const Icon(Icons.edit_outlined),
                              color: Colors.blue,
                            ),
                            IconButton(
                              onPressed: () =>
                                  _deleteLesson(selectedModuleId!, lesson['id']),
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              else
                _buildEmptyState('No lessons available'),
            ],
          ],
        ),
      ),
    ),
  );
}

Widget _buildActionButton({
  required VoidCallback onPressed,
  required IconData icon,
  required String label,
  required Color color,
}) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 20),
    label: Text(label),
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
    ),
  );
}

Widget _buildTextButton({
  required VoidCallback onPressed,
  required IconData icon,
  required String label,
  required Color color,
}) {
  return TextButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 18, color: color),
    label: Text(
      label,
      style: TextStyle(color: color, fontSize: 14),
    ),
  );
}

Widget _buildEmptyState(String message) {
  return Container(
    padding: const EdgeInsets.all(32),
    alignment: Alignment.center,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.inbox_outlined,
          size: 48,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
}