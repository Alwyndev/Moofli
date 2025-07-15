import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moofli_app/auth_providers.dart';
import '../api/api_services.dart';
// import '../components/helper_functions.dart';

class AccountInfoPage extends ConsumerStatefulWidget {
  const AccountInfoPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends ConsumerState<AccountInfoPage> {
  final Map<String, TextEditingController> _controllers = {
    'firstname': TextEditingController(),
    'lastname': TextEditingController(),
    'username': TextEditingController(),
    'email': TextEditingController(),
    'whatsappNumber': TextEditingController(),
    'linkedinId': TextEditingController(),
  };
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _loadUserData() {
    final authState = ref.read(authProvider);
    final userData = authState.userDetails;
    if (userData != null) {
      _updateControllers(userData);
    }
  }

  void _updateControllers(Map<String, dynamic> userData) {
    _controllers['firstname']?.text = userData['firstname'] ?? '';
    _controllers['lastname']?.text = userData['lastname'] ?? '';
    _controllers['username']?.text = userData['username'] ?? '';
    _controllers['email']?.text = userData['email'] ?? '';
    _controllers['whatsappNumber']?.text = userData['whatsappNumber'] ?? '';
    _controllers['linkedinId']?.text = userData['linkedinId'] ?? '';
  }

  Future<void> _refreshProfile() async {
    setState(() => _isLoading = true);
    final token = ref.read(authProvider).token;
    final updatedProfile = await ApiService.fetchProfile(token);

    if (updatedProfile != null) {
      await ref.read(authProvider.notifier).updateUserDetails(updatedProfile);
      _updateControllers(updatedProfile);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveChanges() async {
    if (!_isEditing) {
      setState(() => _isEditing = true);
      return;
    }

    setState(() => _isLoading = true);
    final token = ref.read(authProvider).token;
    final updatedData = <String, dynamic>{};

    _controllers.forEach((key, controller) {
      if (controller.text.trim().isNotEmpty) {
        updatedData[key] = controller.text.trim();
      }
    });

    final success =
        await ApiService.updateMultipleProfileFields(token, updatedData);

    if (success == true) {
      await _refreshProfile();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }

    setState(() {
      _isEditing = false;
      _isLoading = false;
    });
  }

  Future<bool> _onWillPop() async {
    if (!_isEditing) return true;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard Changes?'),
            content: const Text(
                'You have unsaved changes. Do you want to save or discard them?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                  setState(() => _isEditing = false);
                },
                child:
                    const Text('Discard', style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () {
                  _saveChanges();
                  Navigator.pop(context, false);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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
      subtitle: _isEditing
          ? TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: title,
                border: InputBorder.none,
              ),
            )
          : Text(value.isEmpty ? 'Not provided' : value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userData = authState.userDetails;

    if (userData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final profilePic = userData['profilePicUrl'] ?? '';
    final bgPicUrl = userData['bgPicUrl'] ?? '';

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Account Info'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _refreshProfile,
            ),
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: _isLoading ? null : _saveChanges,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refreshProfile,
                child: ListView(
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: bgPicUrl.isNotEmpty
                              ? NetworkImage(bgPicUrl)
                              : const AssetImage('assets/images/default_bg.png')
                                  as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(0.4),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: profilePic.isNotEmpty
                                  ? NetworkImage(profilePic)
                                  : const AssetImage(
                                          'assets/images/default_profile_pic.png')
                                      as ImageProvider,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${userData['firstname'] ?? ''} ${userData['lastname'] ?? ''}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userData['email'] ?? '',
                                    style: const TextStyle(
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
                    const SizedBox(height: 20),
                    _buildInfoTile(
                      icon: Icons.person,
                      title: 'First Name',
                      value: userData['firstname'] ?? '',
                      controller: _controllers['firstname']!,
                    ),
                    const Divider(),
                    _buildInfoTile(
                      icon: Icons.person_outline,
                      title: 'Last Name',
                      value: userData['lastname'] ?? '',
                      controller: _controllers['lastname']!,
                    ),
                    const Divider(),
                    _buildInfoTile(
                      icon: Icons.person_4,
                      title: 'Username',
                      value: userData['username'] ?? '',
                      controller: _controllers['username']!,
                    ),
                    const Divider(),
                    _buildInfoTile(
                      icon: Icons.link,
                      title: 'LinkedIn ID',
                      value: userData['linkedinId'] ?? '',
                      controller: _controllers['linkedinId']!,
                    ),
                    const Divider(),
                    _buildInfoTile(
                      icon: Icons.mail,
                      title: 'Email',
                      value: userData['email'] ?? '',
                      controller: _controllers['email']!,
                    ),
                    const Divider(),
                    _buildInfoTile(
                      icon: Icons.phone,
                      title: 'Phone Number',
                      value: userData['whatsappNumber'] ?? '',
                      controller: _controllers['whatsappNumber']!,
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Logout Account',
                          style: TextStyle(color: Colors.red)),
                      onTap: _logout,
                    ),
                    const Divider(),
                  ],
                ),
              ),
      ),
    );
  }
}
