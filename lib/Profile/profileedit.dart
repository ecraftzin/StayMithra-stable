import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:staymitra/services/auth_service.dart';
import 'package:staymitra/services/user_service.dart';
import 'package:staymitra/services/storage_service.dart';
import 'package:staymitra/services/permission_service.dart';
import 'package:staymitra/services/first_time_permission_service.dart';
import 'package:staymitra/models/user_model.dart';
import 'package:staymitra/utils/responsive_utils.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _authService = AuthService();
  final _userService = UserService();
  final _storageService = StorageService();
  final _imagePicker = ImagePicker();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(); // (unused but kept)
  final _locationController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _websiteController = TextEditingController();

  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  String? _newAvatarUrl;
  bool _removeProfilePicture = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _fullNameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        final userProfile = await _userService.getUserById(currentUser.id);
        if (!mounted) return;
        if (userProfile != null) {
          setState(() {
            _currentUser = userProfile;
            // Populate all form fields with complete user data
            _usernameController.text = userProfile.username;
            _emailController.text = userProfile.email;
            _fullNameController.text = userProfile.fullName ?? '';
            _locationController.text = userProfile.location ?? '';
            _bioController.text = userProfile.bio ?? '';
            _websiteController.text = userProfile.website ?? '';

            // Reset photo states
            _removeProfilePicture = false;
            _newAvatarUrl = null;
            _isLoading = false;
          });
        } else {
          // If profile is null, populate with auth user data
          setState(() {
            _emailController.text = currentUser.email ?? '';
            _usernameController.text = currentUser.userMetadata?['username'] ?? '';
            _fullNameController.text = currentUser.userMetadata?['full_name'] ?? '';
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Error loading profile: $e',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      // Request storage permissions with first-time handling
      final firstTimePermissionService = FirstTimePermissionService();
      final hasPermissions = await firstTimePermissionService.requestStoragePermissionsFirstTime(context);

      if (!hasPermissions) {
        // Permission service already handles user feedback
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isUploadingPhoto = true);

      final avatarUrl = await _storageService.uploadImageFromXFile(
        image,
        'avatars',
        folder: 'users',
      );

      if (!mounted) return;

      if (avatarUrl != null) {
        setState(() {
          _newAvatarUrl = avatarUrl;
          _removeProfilePicture = false; // Reset remove flag when new photo is uploaded
          _isUploadingPhoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _isUploadingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload photo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removePhoto() async {
    try {
      setState(() {
        _newAvatarUrl = ''; // Set to empty string to remove
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo will be removed when you save'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  Future<void> _saveProfile() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        // Determine the avatar URL to save
        String? avatarUrlToSave;
        if (_removeProfilePicture) {
          avatarUrlToSave = null; // Remove the profile picture
        } else if (_newAvatarUrl != null) {
          avatarUrlToSave = _newAvatarUrl; // Use new uploaded picture
        } else {
          avatarUrlToSave = _currentUser?.avatarUrl; // Keep existing picture
        }

        await _userService.updateUserProfile(
          userId: currentUser.id,
          username: _usernameController.text.trim(),
          fullName: _fullNameController.text.trim(),
          bio: _bioController.text.trim(),
          location: _locationController.text.trim(),
          website: _websiteController.text.trim(),
          avatarUrl: avatarUrlToSave,
          updateAvatar: _removeProfilePicture || _newAvatarUrl != null,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Profile Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF007F8C)),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadPhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF007F8C)),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              if (_currentUser?.avatarUrl != null || _newAvatarUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _removeProfilePic();
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    try {
      // Request camera permission with first-time handling
      final firstTimePermissionService = FirstTimePermissionService();
      final hasPermission = await firstTimePermissionService.requestCameraPermissionsFirstTime(context);

      if (!hasPermission) {
        // Permission service already handles user feedback
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isUploadingPhoto = true);

      final avatarUrl = await _storageService.uploadImageFromXFile(
        image,
        'avatars',
        folder: 'users',
      );

      if (!mounted) return;

      if (avatarUrl != null) {
        setState(() {
          _newAvatarUrl = avatarUrl;
          _removeProfilePicture = false;
          _isUploadingPhoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo taken successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _isUploadingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload photo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error taking photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeProfilePic() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Profile Photo'),
        content: const Text('Are you sure you want to remove your profile photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _removeProfilePicture = true;
                _newAvatarUrl = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile photo will be removed when you save'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _getInitials() {
    if (_currentUser?.fullName != null && _currentUser!.fullName!.isNotEmpty) {
      final names = _currentUser!.fullName!.trim().split(RegExp(r'\s+'));
      if (names.length >= 2 && names[0].isNotEmpty && names[1].isNotEmpty) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      } else if (names.isNotEmpty && names[0].isNotEmpty) {
        return names[0][0].toUpperCase();
      }
    } else if (_currentUser?.username != null &&
        _currentUser!.username.isNotEmpty) {
      return _currentUser!.username[0].toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    final horizontalPadding = screenWidth * 0.05;
    final verticalPadding = screenHeight * 0.02;
    final textFieldHeight = screenHeight * 0.06;
    final iconSize = screenWidth * 0.06;
    final double avatarSize = screenWidth * 0.18;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top gradient
          Container(
            height: screenHeight * 0.35,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF007F99), Colors.white],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header Row
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: CircleAvatar(
                            radius: screenWidth * 0.05,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                              size: iconSize,
                            ),
                          ),
                        ),
                        // Title
                        Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        // Save button
                        InkWell(
                          onTap: _isSaving ? null : _saveProfile,
                          child: CircleAvatar(
                            radius: screenWidth * 0.05,
                            backgroundColor: _isSaving
                                ? Colors.grey
                                : Colors.white,
                            child: _isSaving
                                ? SizedBox(
                                    width: iconSize * 0.7,
                                    height: iconSize * 0.7,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF007F99),
                                    ),
                                  )
                                : Icon(
                                    Icons.check,
                                    color: Colors.black,
                                    size: iconSize,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: verticalPadding),


                  // Avatar + camera (drop this in place of your current Stack)
                  Center(
                    child: SizedBox(
                      width: avatarSize * 2, // diameter
                      height: avatarSize * 2,
                      child: Stack(
                        clipBehavior: Clip
                            .none, // allow the camera button to overflow a bit
                        children: [
                          // Avatar fills the box
                          Positioned.fill(
                            child: CircleAvatar(
                              backgroundColor: const Color(0xFF007F8C),
                              backgroundImage: _newAvatarUrl != null
                                  ? (_newAvatarUrl!.isEmpty
                                        ? null
                                        : NetworkImage(_newAvatarUrl!))
                                  : _currentUser?.avatarUrl != null
                                  ? NetworkImage(_currentUser!.avatarUrl!)
                                  : null,
                              child:
                                  ((_newAvatarUrl == null ||
                                          _newAvatarUrl!.isEmpty) &&
                                      _currentUser?.avatarUrl == null)
                                  ? Text(
                                      _getInitials(),
                                      style: TextStyle(
                                        fontSize: avatarSize * 0.4,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                          ),

                          // Camera button anchored to the avatar's bottom-right
                          Positioned(
                            right: -4, // small negative to hug the edge nicely
                            bottom: -4,
                            child: GestureDetector(
                              onTap: _isUploadingPhoto
                                  ? null
                                  : _showPhotoOptions,
                              child: Material(
                                color: const Color(0xFF007F8C),
                                shape: const CircleBorder(),
                                elevation: 3,
                                child: Container(
                                  padding: EdgeInsets.all(avatarSize * 0.12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: _isUploadingPhoto
                                      ? SizedBox(
                                          width: avatarSize * 0.22,
                                          height: avatarSize * 0.22,
                                          child:
                                              const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                        )
                                      : Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: avatarSize * 0.24,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),


                  SizedBox(height: verticalPadding),

                  // Change photo hint
                  Text(
                    'Change profile photo',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      color: const Color(0xFF007F99),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: verticalPadding),

                  // Fields
                  _buildTextField(
                    'Username',
                    screenWidth,
                    textFieldHeight,
                    _usernameController,
                  ),
                  _buildDivider(),

                  _buildTextField(
                    'Full Name',
                    screenWidth,
                    textFieldHeight,
                    _fullNameController,
                  ),
                  _buildDivider(),

                  _buildTextField(
                    'Email',
                    screenWidth,
                    textFieldHeight,
                    _emailController,
                    enabled: false,
                  ),
                  _buildDivider(),

                  _buildTextField(
                    'Location',
                    screenWidth,
                    textFieldHeight,
                    _locationController,
                  ),
                  _buildDivider(),

                  _buildTextField(
                    'Bio',
                    screenWidth,
                    textFieldHeight,
                    _bioController,
                    maxLines: 3,
                  ),
                  _buildDivider(),

                  _buildTextField(
                    'Website',
                    screenWidth,
                    textFieldHeight,
                    _websiteController,
                  ),
                  _buildDivider(),

                  SizedBox(height: verticalPadding * 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String hintText,
    double screenWidth,
    double textFieldHeight,
    TextEditingController controller, {
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenWidth * 0.03,
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: screenWidth * 0.04,
          color: enabled ? Colors.black : Colors.grey,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: textFieldHeight * 0.35,
          ),
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: screenWidth * 0.04,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() => const Divider(height: 1, color: Colors.grey);
}