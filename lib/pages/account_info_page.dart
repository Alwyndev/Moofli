import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_services.dart';
import 'dart:convert';

class AccountInfoPage extends StatefulWidget {
  @override
  _AccountInfoPageState createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  Map<String, dynamic>? userDetails;
  bool isEditing = false;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController linkedinController = TextEditingController();
  // final TextEditingController cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userDetailsString = prefs.getString('userDetails');

      if (userDetailsString != null) {
        setState(() {
          userDetails = jsonDecode(userDetailsString);
          _initializeControllers();
        });
        print("User profile loaded from SharedPreferences");
      } else {
        var profile = await ApiService.fetchProfile();
        setState(() {
          userDetails = profile;
          _initializeControllers();
        });
        print("User profile loaded from API");
      }
    } catch (e) {
      print("Error loading profile: $e");
    }
  }

  void _initializeControllers() {
    if (userDetails != null) {
      firstNameController.text = userDetails!['firstname'] ?? '';
      lastNameController.text = userDetails!['lastname'] ?? '';
      emailController.text = userDetails!['email'] ?? '';
      usernameController.text = userDetails!['username'] ?? '';
      phoneController.text = userDetails!['whatsappNumber'] ?? '';
      linkedinController.text = userDetails!['linkedinId'] ?? '';
      print("Controllers initialized with: "
          "firstname=${firstNameController.text}, "
          "lastname=${lastNameController.text}, "
          "email=${emailController.text}");
    }
  }

  Future<void> saveChanges() async {
    // Check if any field has changed
    if (userDetails != null &&
        firstNameController.text == (userDetails!['firstname'] ?? '') &&
        lastNameController.text == (userDetails!['lastname'] ?? '') &&
        usernameController.text == (userDetails!['username'] ?? '') &&
        emailController.text == (userDetails!['email'] ?? '') &&
        phoneController.text == (userDetails!['whatsappNumber'] ?? '') &&
        linkedinController.text == (userDetails!['linkedinId'] ?? '')) {
      print("No changes detected; skipping API update.");
      setState(() {
        isEditing = false; // Exit editing mode
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No changes to update.")),
      );
      return;
    }

    // Create an updated data map from the controllers
    Map<String, dynamic> updatedData = {
      'firstname': firstNameController.text,
      'lastname': lastNameController.text,
      'username': usernameController.text,
      'email': emailController.text,
      'whatsappNumber': phoneController.text,
      'linkedinId': linkedinController.text,
    };
    print("Attempting to save changes: $updatedData");

    try {
      bool success = await ApiService.updateProfile(updatedData);
      if (success) {
        setState(() {
          userDetails!['firstname'] = firstNameController.text;
          userDetails!['lastname'] = lastNameController.text;
          userDetails!['username'] = usernameController.text;
          userDetails!['email'] = emailController.text;
          userDetails!['whatsappNumber'] = phoneController.text;
          userDetails!['linkedinId'] = linkedinController.text;
          isEditing = false; // Exit editing mode on success
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userDetails', jsonEncode(userDetails));
        print("Account info updated successfully on server.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully!")),
        );
      } else {
        print("API call to update profile failed.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to update profile. Please try again.")),
        );
      }
    } catch (e) {
      print("Error while saving changes: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (isEditing) {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Discard Changes?"),
              content: Text(
                  "You have unsaved changes. Do you want to save or discard them?"),
              actions: [
                TextButton(
                  onPressed: () {
                    print("User chose to cancel leaving page.");
                    Navigator.of(context).pop(false);
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    print("User chose to discard changes.");
                    Navigator.of(context).pop(true);
                    setState(() => isEditing = false);
                  },
                  child: Text("Discard", style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () {
                    print("User chose to save changes before leaving.");
                    saveChanges();
                    Navigator.of(context).pop(false);
                  },
                  child: Text("Save"),
                ),
              ],
            ),
          ) ??
          false;
    }
    return true;
  }

  Future<void> logout() async {
    await ApiService.logout();
    print("User logged out.");
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Account"),
        content: Text("Are you sure you want to delete your account?"),
        actions: [
          TextButton(
            onPressed: () {
              print("User canceled account deletion.");
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Add your delete account API call here.
              print("Account deletion triggered.");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Account deleted.")),
              );
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required TextEditingController controller,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: isEditing
          ? TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: title,
                border: InputBorder.none,
              ),
            )
          : Text(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String bgImage =
        userDetails?['bgPicUrl'] ?? 'https://via.placeholder.com/300';
    final String profilePic = userDetails?['profilePicUrl'] ?? '';
    final String firstName = userDetails?['firstname'] ?? '';
    final String email = userDetails?['email'] ?? '';
    // final String lastName = userDetails?['lastname'] ?? '';
    // final String city = userDetails?['city'] ?? '';
    final String username = userDetails?['username'] ?? 'Not Provided';
    final String phoneNumber = userDetails?['whatsappNumber'] ?? 'Not Provided';
    final String linkedinId = userDetails?['linkedinId'] ?? 'Not Provided';

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Account Info"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(isEditing ? Icons.save : Icons.edit),
              onPressed: () async {
                if (isEditing) {
                  // Attempt to save and let saveChanges handle the state update.
                  await saveChanges();
                } else {
                  // If not editing, just toggle to editing mode.
                  setState(() {
                    isEditing = true;
                  });
                }
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: fetchUserProfile,
          child: userDetails == null
              ? Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    // Header styled like the drawer header.
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(bgImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(0.4),
                        padding: EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: profilePic.isNotEmpty
                                  ? NetworkImage(profilePic)
                                  : AssetImage(
                                          'assets/images/default_profile_pic.png')
                                      as ImageProvider,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    firstName,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    email,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Display user information as ListTiles.
                    _buildInfoTile(
                      icon: Icons.person,
                      title: "First Name",
                      value: firstNameController.text,
                      controller: firstNameController,
                    ),
                    Divider(),
                    _buildInfoTile(
                      icon: Icons.person_outline,
                      title: "Last Name",
                      value: lastNameController.text,
                      controller: lastNameController,
                    ),
                    Divider(),
                    _buildInfoTile(
                      icon: Icons.person_4,
                      title: "Username",
                      value: username,
                      controller: usernameController,
                    ),
                    Divider(),
                    _buildInfoTile(
                      icon: Icons.link,
                      title: "LinkedIn ID",
                      value: linkedinId,
                      controller: linkedinController,
                    ),
                    Divider(),
                    _buildInfoTile(
                      icon: Icons.mail,
                      title: "Email",
                      value: email,
                      controller: emailController,
                    ),

                    Divider(),
                    _buildInfoTile(
                      icon: Icons.phone,
                      title: "Phone Number",
                      value: phoneNumber,
                      controller: phoneController,
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        'Logout Account',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: logout,
                    ),

                    Divider(),
                    ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text(
                        'Delete Account',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: _deleteAccount,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
