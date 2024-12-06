import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gtech/admin/modulesadmin.dart';

class AdminCourse extends StatefulWidget {
  const AdminCourse({Key? key}) : super(key: key);

  @override
  State<AdminCourse> createState() => _AdminCourseState();
}

class _AdminCourseState extends State<AdminCourse> {
  int? selectedButton;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedCourseId; // Variable to track selected course for ModuleScreen

  // List of asset image paths
  final List<String> courseImages = [
    'assets/gol.png',
    'assets/gtech.png',
    'assets/gol.png',
    'assets/gtech.jpg',
  ];

  Future<void> _addCourse(String name, String description) async {
    try {
      final courseData = {'name': name, 'description': description};
      await _firestore.collection('courses').add(courseData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add course: $e')),
      );
    }
  }

  void _showAddCourseDialog() {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Course'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Course Name'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final String name = _nameController.text;
                final String description = _descriptionController.text;
                if (name.isNotEmpty && description.isNotEmpty) {
                  _addCourse(name, description);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                }
              },
              child: const Text('Add Course'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Display ModuleScreen if a course is selected, else display the course list
    return Scaffold(
    
      body: selectedCourseId == null
          ? _buildCourseList() // Course list view
          : ModuleScreen(
              courseId: selectedCourseId!,
              onBackPressed: () {
                setState(() {
                  selectedCourseId = null; // Go back to the course list
                });
              },
            ), // ModuleScreen view
    );
  }

  Widget _buildCourseList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Check screen width to determine if it's mobile, tablet, or desktop
          bool isDesktop = constraints.maxWidth >= 1024;
          bool isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Courses',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          'Manage your courses here.',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _showAddCourseDialog,
                      child: const Text('Create Course', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('courses').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final courses = snapshot.data!.docs;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: courses.asMap().entries.map((entry) {
                        final index = entry.key;
                        final courseDoc = entry.value;
                        final course = courseDoc.data() as Map<String, dynamic>;
                        final courseId = courseDoc.id;
                        final String courseName = course['name'] ?? 'No Name';
                        final String courseDescription = course['description'] ?? 'No Description';
                        final String imagePath = courseImages[index % courseImages.length];

                        return GestureDetector(
                          onTap: () => setState(() {
                            selectedCourseId = courseId; // Set the selected course
                          }),
                          child: Container(
                            width: 200,
                            child: Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                    ),
                                    child: Image.asset(
                                      imagePath,
                                      width: double.infinity,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          courseName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          courseDescription,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        print('Prev button pressed');
                      },
                      child: Text('Prev'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    ...List.generate(3, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedButton = index + 1;
                            });
                            print("Button ${index + 1} tapped");
                          },
                          highlightColor: Colors.blue,
                          splashColor: Colors.blue,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: selectedButton == index + 1
                                  ? Colors.blue
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: selectedButton == index + 1
                                    ? Colors.transparent
                                    : Colors.black,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: selectedButton == index + 1
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    TextButton(
                      onPressed: () {
                        print('Next button pressed');
                      },
                      child: Text('Next'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ],
                ),
                                Divider(),

                    Row(
                    // Adds spacing between elements
                    children: [
                      Flexible(
                        child: Text(
                          'Course Category',
                          style: TextStyle(fontSize: isDesktop ? 18 : 16),
                          overflow: TextOverflow
                              .ellipsis, // This ensures long text is truncated on smaller screens
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_document),
                        onPressed: () {},
                        tooltip: 'Edit Category',
                      ),
                      if (isDesktop)
                        Container(
                          width: 900, // Fixed width for desktop
                          height: 1,
                          color: Colors.grey,
                        ),
                      if (!isDesktop)
                        Flexible(
                          child: Container(
                            width: 900, // Stretches the line on smaller screens
                            height: 1, // Height adjusted for mobile
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(3, (index) {
                      return GestureDetector(
                        onTap: () {
                          print("Card tapped!");
                        },
                        child: Container(
                          width: isDesktop ? 200 : 160,
                          height: isDesktop ? 200 : 160,
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    height: isDesktop ? 160 : 120,
                                    color: Color.fromARGB(255, 0, 86, 156),
                                    child: Center(
                                      // child: Image.asset(
                                      //   'assets/sap.png',
                                      //   width: 100,
                                      //   height: 100,
                                      //   fit: BoxFit.contain,
                                      // ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'SAP Cloud',
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit_document,
                                            color: Colors.grey,
                                            size: 18,
                                          ),
                                          onPressed: () {},
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
                    }),
                  ),
                   Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        print('Prev button pressed');
                      },
                      child: Text('Prev'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    ...List.generate(3, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedButton = index + 1;
                            });
                            print("Button ${index + 1} tapped");
                          },
                          highlightColor: Colors.blue,
                          splashColor: Colors.blue,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: selectedButton == index + 1
                                  ? Colors.blue
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: selectedButton == index + 1
                                    ? Colors.transparent
                                    : Colors.black,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: selectedButton == index + 1
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    TextButton(
                      onPressed: () {
                        print('Next button pressed');
                      },
                      child: Text('Next'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ],
                ),
                
              ],
            ),
          );
        },
      ),
    );
  }
}
