import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_services.dart';
import 'dart:convert';

class AccountInfoPage extends StatefulWidget {
  @override
  _AccountInfoPageState createState() {
    debugPrint("AccountInfoPage: createState called");
    return _AccountInfoPageState();
  }
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint("AccountInfoPage: didChangeDependencies called");
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    debugPrint("Fetching user profile...");
    try {
      var profile = await ApiService.fetchProfile();
      setState(() {
        userDetails = profile;
        isEditing = false;
        _initializeControllers();
      });
      debugPrint("User profile fetched: $profile");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userDetails', jsonEncode(profile));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile refreshed!")),
      );
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch profile: $e")),
      );
    }
  }

  void _initializeControllers() {
    debugPrint("Initializing text controllers with user data...");
    if (userDetails != null) {
      firstNameController.text = userDetails!['result']['firstname'] ?? '';
      lastNameController.text = userDetails!['result']['lastname'] ?? '';
      usernameController.text = userDetails!['result']['username'] ?? '';
      emailController.text = userDetails!['result']['email'] ?? '';
      phoneController.text = userDetails!['result']['whatsappNumber'] ?? '';
      linkedinController.text = userDetails!['result']['linkedinId'] ?? '';
    }
  }

  Future<void> saveChanges() async {
    debugPrint("Save changes clicked.");
    if (userDetails != null) {
      if (firstNameController.text ==
              (userDetails!['result']['firstname'] ?? '') &&
          lastNameController.text ==
              (userDetails!['result']['lastname'] ?? '') &&
          usernameController.text ==
              (userDetails!['result']['username'] ?? '') &&
          emailController.text == (userDetails!['result']['email'] ?? '') &&
          phoneController.text ==
              (userDetails!['result']['whatsappNumber'] ?? '') &&
          linkedinController.text ==
              (userDetails!['result']['linkedinId'] ?? '')) {
        setState(() => isEditing = false);
        debugPrint("No changes detected — exiting edit mode.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No changes to update.")),
        );
        return;
      }
    }

    Map<String, dynamic> updatedData = {
      'firstname': firstNameController.text.trim(),
      'lastname': lastNameController.text.trim(),
      'username': usernameController.text.trim(),
      'email': emailController.text.trim(),
      'whatsappNumber': phoneController.text.trim(),
      'linkedinId': linkedinController.text.trim(),
    };

    try {
      debugPrint("Attempting to update profile: $updatedData");
      bool success = await ApiService.updateProfile(updatedData);
      if (success) {
        setState(() {
          userDetails!.addAll(updatedData);
          isEditing = false;
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userDetails', jsonEncode(userDetails));
        debugPrint("Profile updated successfully.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully!")),
        );
      } else {
        debugPrint("Profile update failed.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to update profile. Please try again.")),
        );
      }
    } catch (e) {
      debugPrint("Error during profile update: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error occurred: $e")),
      );
    }
  }

  Future<bool> _onWillPop() async {
    debugPrint("Back button pressed.");
    if (isEditing) {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Discard Changes?"),
              content: Text(
                  "You have unsaved changes. Do you want to save or discard them?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    setState(() => isEditing = false);
                  },
                  child: Text("Discard", style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () {
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
    debugPrint("Logging out...");
    await ApiService.logout(context);
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _deleteAccount() {
    debugPrint("Delete account clicked.");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Account"),
        content: Text("Are you sure you want to delete your account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              debugPrint("Account deleted.");
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
    debugPrint("Building tile for $title");
    debugPrint("current value: $value");
    debugPrint("current controller value: ${controller.text}");
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
    debugPrint("AccountInfoPage: build method called.");
    final String profilePic = userDetails?['result']['profilePicUrl'] ?? '';
    final String bgPicUrl = userDetails?['result']['bgPicUrl'] ?? '';

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
                  await saveChanges();
                } else {
                  setState(() => isEditing = true);
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
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: bgPicUrl.isNotEmpty
                              ? NetworkImage(bgPicUrl)
                              : AssetImage('assets/images/default_bg.png')
                                  as ImageProvider,
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
                                    userDetails?['firstname'] ?? '',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    userDetails?['email'] ?? '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildInfoTile(
                      icon: Icons.person,
                      title: "First Name",
                      value: userDetails?['result']['firstname'] ?? '',
                      controller: firstNameController,
                    ),
                    Divider(),
                    _buildInfoTile(
                      icon: Icons.person_outline,
                      title: "Last Name",
                      value: userDetails?['result']['lastname'] ?? '',
                      controller: lastNameController,
                    ),
                    Divider(),
                    _buildInfoTile(
                      icon: Icons.person_4,
                      title: "Username",
                      value:
                          userDetails?['result']['username'] ?? 'Not Provided',
                      controller: usernameController,
                    ),
                    Divider(),
                    _buildInfoTile(
                      icon: Icons.link,
                      title: "LinkedIn ID",
                      value: userDetails?['result']['linkedinId'] ??
                          'Not Provided',
                      controller: linkedinController,
                    ),
                    Divider(),
                    _buildInfoTile(
                      icon: Icons.mail,
                      title: "Email",
                      value: userDetails?['result']['email'] ?? 'Not Provided',
                      controller: emailController,
                    ),
                    Divider(),
                    _buildInfoTile(
                      icon: Icons.phone,
                      title: "Phone Number",
                      value: userDetails?['result']['whatsappNumber'] ??
                          'Not Provided',
                      controller: phoneController,
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text('Logout Account',
                          style: TextStyle(color: Colors.red)),
                      onTap: logout,
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Delete Account',
                          style: TextStyle(color: Colors.red)),
                      onTap: _deleteAccount,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
