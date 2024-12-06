import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gtech/admin/adcourseadmin.dart';
import 'package:gtech/admin/adminpanel.dart';
import 'package:gtech/admin/coursehome.dart';
import 'package:gtech/admin/excel/test2.dart';
import 'package:gtech/admin/liveclassadmin.dart';
import 'package:gtech/admin/status.dart';
import 'package:gtech/admin/studentmanager.dart';
import 'package:gtech/login.dart';
import 'package:gtech/user/modules.dart';
import 'package:gtech/registration.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedContent = 'Dashboard';
  TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void updateContent(String newContent) {
    setState(() {
      selectedContent = newContent;
    });
  }

  void handleMenuSelection(String value) {
    if (value == 'Settings') {
      updateContent('Settings');
    } else if (value == 'Sign Out') {
      _logout();
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[200],
      appBar: isLargeScreen
          ? null
          : AppBar(
              title: Text('Dashboard'),
              leading: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              actions: [
                PopupMenuButton<String>(
                  onSelected: handleMenuSelection,
                  itemBuilder: (context) {
                    return {'Settings', 'Sign Out'}.map((choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
      drawer: isLargeScreen
          ? null
          : Drawer(
              child: Sidebar(
                isLargeScreen: isLargeScreen,
                onMenuItemSelected: updateContent,
                searchController: searchController,
              ),
            ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              if (isLargeScreen)
                Sidebar(
                  isLargeScreen: isLargeScreen,
                  onMenuItemSelected: updateContent,
                  searchController: searchController,
                ),
              Expanded(
                child: ContentArea(
                  isLargeScreen: isLargeScreen,
                  selectedContent: selectedContent,
                  searchController: searchController,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class Sidebar extends StatelessWidget {
  final Function(String) onMenuItemSelected;
  final TextEditingController searchController;
  final bool isLargeScreen;

  Sidebar({
    required this.onMenuItemSelected,
    required this.searchController,
    required this.isLargeScreen,
  });

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = isLargeScreen ? 300.0 : MediaQuery.of(context).size.width * 0.8;

    return Card(
      elevation: 4,
      child: Container(
        color: Colors.white,
        width: sidebarWidth,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserCard(userId: 'userId'),
                    const SizedBox(height: 20),
                    SearchField(searchController: searchController),
                    const SizedBox(height: 20),
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      child: MainMenu(
                        isLargeScreen: isLargeScreen,
                        onMenuItemSelected: onMenuItemSelected,
                      ),
                    ),
                    const SizedBox(height: 90),
                    Divider(),
                    Bottom(
                      onMenuItemSelected: onMenuItemSelected,
                      isLargeScreen: isLargeScreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class UserCard extends StatelessWidget {
  final String userId;

  UserCard({required this.userId});

  Future<Map<String, String>> _fetchUserData(String userId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        return {
          'name': data['name'] ?? 'Name',
          'email': data['email'] ?? 'Email',
          'role': data['role'] ?? 'admin',
        };
      } else {
        return {'name': 'Admin', 'email': 'admin@gmail.com', 'role': 'admin'};
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return {'name': 'Admin', 'email': 'admin@gmail.com', 'role': 'admin'};
    }
  }

@override
Widget build(BuildContext context) {
  return FutureBuilder<Map<String, String>>(
    future: _fetchUserData(userId),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error loading user data'));
      } else if (snapshot.hasData) {
        final userData = snapshot.data!;
        return Column(
          children: [
            Card(
              color: Colors.blue[100], // Change the background color to blue
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.black,
                      child: Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData['name']!,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          userData['email']!,
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue[50], // Keeping the container's color light blue
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: Text(
                            userData['role']!,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        );
      } else {
        return Center(child: Text('No data available'));
      }
    },
  );
}



}

class SearchField extends StatelessWidget {
  final TextEditingController searchController;

  SearchField({required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }
}




class MainMenu extends StatefulWidget {
  final Function(String) onMenuItemSelected;
  final bool isLargeScreen;  // Accepting isLargeScreen

  MainMenu({required this.onMenuItemSelected, required this.isLargeScreen});

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  String selectedMenu = '';

  void updateSelectedMenu(String newMenu) {
    setState(() {
      selectedMenu = newMenu;
    });
    widget.onMenuItemSelected(newMenu);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        color: const Color.fromARGB(255, 255, 255, 255),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 146, 218, 228).withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(2, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            SidebarButton(
              icon: Icons.home,
              text: 'Dashboard',
              isSelected: selectedMenu == 'Dashboard',
              onTap: () => updateSelectedMenu('Dashboard'),
            ),
              SidebarButton(
              icon: Icons.book,
              text: 'Course Management',
              isSelected: selectedMenu == 'Course Management',
              onTap: () => updateSelectedMenu('Course Management'),
            ),
                SidebarButton(
              icon: Icons.live_tv,
              text: 'live',
              isSelected: selectedMenu == 'live',
              onTap: () => updateSelectedMenu('live'),
            ),
            SidebarButton(
              icon: Icons.people_sharp,
              text: 'Students Manager',
              isSelected: selectedMenu == 'Students Manager',
              onTap: () => updateSelectedMenu('Students Manager'),
            ),
            SidebarButton(
              icon: Icons.person,
              text: 'Our Centers',
              isSelected: selectedMenu == 'Our Centers',
              onTap: () => updateSelectedMenu('Our Centers'),
            ),
             SidebarButton(
            icon: Icons.settings,
            text: 'Settings',
            isSelected: selectedMenu == 'Settings',
            onTap: () => updateSelectedMenu('Settings'),
          ),
           
          ],
        ),
      ),
    );
  }

  ExpansionTile _buildExpandableTile({
    required IconData icon,
    required String title,
    required bool isSelected,
    required List<String> children,
    required Function(String) onMenuItemSelected,
    required bool isLargeScreen,
  }) {
    return ExpansionTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.blueGrey),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.blue : const Color.fromARGB(136, 0, 0, 0),
        ),
      ),
      initiallyExpanded: isLargeScreen || isSelected,
      onExpansionChanged: (expanded) {
        if (expanded) onMenuItemSelected(title);
      },
      tilePadding: EdgeInsets.symmetric(horizontal: 16),
      children: children.map((item) {
        return SidebarButton(
          icon: Icons.arrow_right,
          text: item,
          isSelected: false,
          onTap: () => onMenuItemSelected(item),
        );
      }).toList(),
    );
  }
}


class SidebarButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool isSelected;

  SidebarButton({
    required this.icon,
    required this.text,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius:
              BorderRadius.circular(10), // Applies circular border to all sides
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.blueGrey,
          ),
          title: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.blueGrey,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
class ContentArea extends StatelessWidget {
  final String selectedContent;
  final TextEditingController searchController;
  final bool isLargeScreen;  // Accepting isLargeScreen

  const ContentArea({required this.selectedContent, required this.searchController, required this.isLargeScreen});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedContent,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          SizedBox(height: 20),
          Expanded(child: _buildContent(selectedContent)),
        ],
      ),
    );
  }

  Widget _buildContent(String selectedContent) {
    switch (selectedContent) {
      case 'Course Content':
        return DashboardScreennew();

         case 'Course Management':
        return AdminCourse();
      
      case 'Students Manager':
        return AdminRegisteredStudentsPage();
        case 'Our Centers':
        return StudentAnalytics();
      case 'live':
        return AdminLiveClassesPage();
      case 'Dashboard':
        return DashboardScreennew();
      default:
        return DashboardScreennew();
    }
  }
}


class Bottom extends StatefulWidget {
  final Function(String) onMenuItemSelected;
  final bool isLargeScreen;

  const Bottom({
    Key? key,
    required this.onMenuItemSelected,
    required this.isLargeScreen,
  }) : super(key: key);

  @override
  _BottomState createState() => _BottomState();
}

class _BottomState extends State<Bottom> {
  String selectedMenu = '';
  bool isLoading = false;

  void updateSelectedMenu(String newMenu) {
    setState(() {
      selectedMenu = newMenu;
    });
    widget.onMenuItemSelected(newMenu);
  }

  Future<void> _logout(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });
      
      await FirebaseAuth.instance.signOut();
      
      if (!mounted) return;
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
         
          SidebarButton(
            icon: Icons.logout,
            text: isLoading ? 'Logging out...' : 'Log out',
            isSelected: selectedMenu == 'Log out',
            onTap: () => _logout(context),  // Fixed: Properly calling _logout with context
          ),
        ],
      ),
    );
  }
}