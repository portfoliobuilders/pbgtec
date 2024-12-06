import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gtech/user/attemptassignment.dart';
import 'package:gtech/user/videoplayer.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class UserAllocatedCoursesPage extends StatefulWidget {
  const UserAllocatedCoursesPage({Key? key}) : super(key: key);

  @override
  _UserAllocatedCoursesPageState createState() =>
      _UserAllocatedCoursesPageState();
}

class _UserAllocatedCoursesPageState extends State<UserAllocatedCoursesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, bool> expandedStates = {};

  Stream<QuerySnapshot> _getUserCourses(String userId) {
    return _firestore.collection('users').doc(userId).collection('courses').snapshots();
  }

  Future<String> _getCourseNameById(String courseId) async {
    try {
      DocumentSnapshot courseDoc = await _firestore.collection('courses').doc(courseId).get();
      return courseDoc.exists ? courseDoc['name'] ?? 'Unnamed Course' : 'Course Not Found';
    } catch (e) {
      print('Error fetching course name: $e');
      return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('User Allocated Courses'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('Please log in to see your courses'),
        ),
      );
    }

    String userId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Allocated Courses'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getUserCourses(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final userCourses = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: userCourses.length,
              itemBuilder: (context, index) {
                final userCourse = userCourses[index];
                final courseId = userCourse['courseId'];

                return FutureBuilder<String>(
                  future: _getCourseNameById(courseId),
                  builder: (context, courseSnapshot) {
                    if (courseSnapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(); // Empty space if waiting for course name
                    }
                    if (courseSnapshot.hasData) {
                      final courseName = courseSnapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                         Padding(
  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0), // Added horizontal padding for better alignment
  child: Container(
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue.shade300, Colors.blue.shade700],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16.0), // Slightly larger border radius for a softer look
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 12, // Increased blur for a more subtle shadow
          offset: Offset(0, 6), // Slightly offset to create more depth
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Better alignment of the icon and text
      children: [
        Icon(
          Icons.book_outlined,
          size: 36, // Larger icon for better visibility
          color: Colors.white,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            courseName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24, // Slightly larger font size for readability
              color: Colors.white,
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: Offset(1, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          color: Colors.white70,
          size: 20, // Increased size for better touch targets and visibility
        ),
      ],
    ),
  ),
),

                          // Fetching modules for the course
                        StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('courses')
      .doc(courseId)
      .collection('modules')
      .orderBy('order')
      .snapshots(),
  builder: (context, moduleSnapshot) {
    if (!moduleSnapshot.hasData) {
      return const SizedBox();
    }

    final modules = moduleSnapshot.data!.docs;

    return Column(
      children: modules.map((moduleDoc) {
        final moduleId = moduleDoc.id;
        final moduleName = moduleDoc['name'] ?? 'Unnamed Module';
        final moduleOrder = moduleDoc['order'] ?? 0;

        // Set the initial state for expandedStates when first accessed
        if (!expandedStates.containsKey(moduleId)) {
          expandedStates[moduleId] = false;
        }

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('unlockedModules')
              .doc(moduleId)
              .get(),
          builder: (context, unlockedSnapshot) {
            final isUnlocked = unlockedSnapshot.hasData && unlockedSnapshot.data!.exists;

            // Only display the first module or unlocked modules
            if (moduleOrder == 1 || isUnlocked) {
              return Column(
                children: [
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    elevation: 8.0, // Increased elevation for a more prominent shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      side: BorderSide(color: Colors.grey[300]!, width: 1.0), // Border for subtle definition
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('courses')
                                    .doc(courseId)
                                    .collection('modules')
                                    .doc(moduleId)
                                    .collection('lessons')
                                    .snapshots(),
                                builder: (context, lessonSnapshot) {
                                  if (!lessonSnapshot.hasData) {
                                    return CircleAvatar(
                                      radius: 24, // Slightly larger for better prominence
                                      backgroundColor: Colors.grey[300],
                                      child: Text(
                                        '0',
                                        style: TextStyle(color: Colors.black, fontSize: 14),
                                      ),
                                    );
                                  }
                                  final lessons = lessonSnapshot.data!.docs;
                                  return CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.green[100],
                                    foregroundColor: Colors.green[800],
                                    child: Text(
                                      '${lessons.length}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[800],
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  moduleName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('courses')
                                .doc(courseId)
                                .collection('modules')
                                .doc(moduleId)
                                .collection('lessons')
                                .snapshots(),
                            builder: (context, lessonCountSnapshot) {
                              if (!lessonCountSnapshot.hasData) {
                                return const SizedBox.shrink();
                              }
                              final lessonCount = lessonCountSnapshot.data!.docs.length;
                              return Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  '$lessonCount Recorded Videos',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      trailing: Icon(
                        expandedStates[moduleId]! ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        color: Colors.blue,
                        size: 28, // Slightly larger for better visual impact
                      ),
                      onTap: () {
                        setState(() {
                          expandedStates[moduleId] = !expandedStates[moduleId]!;
                        });
                      },
                    ),
                  ),

                  // Lessons Container (Show Under the Module)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Visibility(
                      visible: expandedStates[moduleId]!,
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('courses')
                              .doc(courseId)
                              .collection('modules')
                              .doc(moduleId)
                              .collection('lessons')
                              .snapshots(),
                          builder: (context, lessonSnapshot) {
                            if (!lessonSnapshot.hasData) {
                              return const SizedBox();
                            }

                            final lessons = lessonSnapshot.data!.docs;
                            return Column(
                              children: lessons.map((lessonDoc) {
                                final lessonName = lessonDoc['name'] ?? 'Unnamed Lesson';
                                final lessonUrl = lessonDoc['url'] ?? '';

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VideoPlayerScreen(url: lessonUrl),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), // Adjusted margins
                                    elevation: 4, // Subtle shadow effect
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0), // Rounded corners
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // Padding for better alignment
                                      title: Text(
                                        lessonName,
                                        style: TextStyle(
                                          fontSize: 18, // Increased font size for readability
                                          fontWeight: FontWeight.bold, // Bolder font for emphasis
                                          color: Colors.black87,
                                        ),
                                      ),
                                      trailing: Icon(
                                        Icons.play_arrow,
                                        color: Colors.blue.shade600, // A more vivid color for the play icon
                                        size: 28, // Larger size for better visibility
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Attempt Assignment Button
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: isUnlocked || moduleOrder == 1  // Check if the module is unlocked or the first module
                          ? () {
                              // Navigate to AttemptAssignmentPage for this module
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AttemptAssignmentPage(
                                    moduleId: moduleId,
                                    courseId: courseId,
                                  ),
                                ),
                              );
                            }
                          : null,  // Disable the button if not unlocked and not the first module
                      child: Text('Attempt Assignment'),
                    ),
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        );
      }).toList(),
    );
  },
),

                        ],
                      );
                    } else {
                      return const SizedBox(); // Empty space if course name fails
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}