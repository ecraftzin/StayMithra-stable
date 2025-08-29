import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:staymitra/models/user_model.dart';

class UserAvatar extends StatelessWidget {
  final UserModel? user;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double borderWidth;
  final bool showBorder;

  const UserAvatar({
    super.key,
    required this.user,
    this.size = 40,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderWidth = 2,
    this.showBorder = false,
  });

  String _getInitials() {
    if (user?.fullName != null && user!.fullName!.isNotEmpty) {
      final names = user!.fullName!.trim().split(RegExp(r'\s+'));
      if (names.length >= 2 && names[0].isNotEmpty && names[1].isNotEmpty) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      } else if (names.isNotEmpty && names[0].isNotEmpty) {
        return names[0][0].toUpperCase();
      }
    } else if (user?.username != null && user!.username.isNotEmpty) {
      return user!.username[0].toUpperCase();
    }
    return 'U';
  }

  Widget _buildInitialsAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? const Color(0xFF007F8C),
        border: showBorder
            ? Border.all(
                color: borderColor ?? const Color(0xFF007F8C),
                width: borderWidth,
              )
            : null,
      ),
      child: Center(
        child: Text(
          _getInitials(),
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user?.avatarUrl != null &&
        user!.avatarUrl!.isNotEmpty &&
        !user!.avatarUrl!.contains('blob:')) {
      // Show profile picture
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: showBorder
              ? Border.all(
                  color: borderColor ?? const Color(0xFF007F8C),
                  width: borderWidth,
                )
              : null,
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: user!.avatarUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildInitialsAvatar(),
            errorWidget: (context, url, error) => _buildInitialsAvatar(),
          ),
        ),
      );
    } else {
      // Show initials avatar
      return _buildInitialsAvatar();
    }
  }
}

// Specialized version for bottom navigation
class NavigationUserAvatar extends StatelessWidget {
  final UserModel? user;
  final bool isSelected;
  final double size;

  const NavigationUserAvatar({
    super.key,
    required this.user,
    required this.isSelected,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return UserAvatar(
      user: user,
      size: size,
      backgroundColor: isSelected 
          ? const Color(0xFF017E8D) 
          : Colors.grey[600],
      textColor: Colors.white,
      borderColor: isSelected 
          ? const Color(0xFF017E8D) 
          : Colors.grey[600],
      showBorder: true,
      borderWidth: 2,
    );
  }
}

// Specialized version for feed posts
class FeedUserAvatar extends StatelessWidget {
  final UserModel? user;
  final double size;

  const FeedUserAvatar({
    super.key,
    required this.user,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return UserAvatar(
      user: user,
      size: size,
      backgroundColor: const Color(0xFF007F8C),
      textColor: Colors.white,
      showBorder: false,
    );
  }
}

// Specialized version for profile pages
class ProfileUserAvatar extends StatelessWidget {
  final UserModel? user;
  final double size;

  const ProfileUserAvatar({
    super.key,
    required this.user,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return UserAvatar(
      user: user,
      size: size,
      backgroundColor: const Color(0xFF007F8C),
      textColor: Colors.white,
      showBorder: true,
      borderColor: const Color(0xFF007F8C),
      borderWidth: 3,
    );
  }
}
