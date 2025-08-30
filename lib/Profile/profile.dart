import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';

import 'package:staymitra/Profile/profileedit.dart';
import 'package:staymitra/services/auth_service.dart';
import 'package:staymitra/services/user_service.dart';
import 'package:staymitra/services/post_service.dart';
import 'package:staymitra/services/campaign_service.dart';
import 'package:staymitra/services/follow_service.dart';
import 'package:staymitra/services/follow_request_service.dart';
import 'package:staymitra/config/supabase_config.dart';

import 'package:staymitra/models/user_model.dart';
import 'package:staymitra/models/post_model.dart';
import 'package:staymitra/models/campaign_model.dart';
import 'package:staymitra/widgets/user_avatar.dart';

import 'package:staymitra/Posts/post_detail_page.dart';
import 'package:staymitra/Campaigns/campaign_detail_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final PostService _postService = PostService();
  final CampaignService _campaignService = CampaignService();
  final FollowService _followService = FollowService();
  final FollowRequestService _followRequestService = FollowRequestService();

  UserModel? _currentUser;
  bool _isLoading = true;

  List<PostModel> _userPosts = [];
  List<CampaignModel> _userCampaigns = [];
  int _followersCount = 0;
  int _followingCount = 0;

  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() => setState(() => _selectedTab = _tabController.index));
    _loadUserProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Public refresh
  Future<void> refreshProfile() async => _loadUserProfile();

  Future<void> _loadUserProfile() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final userProfile = await _userService.getUserById(currentUser.id);
      await _loadUserStats(currentUser.id);
      await _loadFollowerCounts(currentUser.id);

      if (!mounted) return;
      setState(() {
        _currentUser = userProfile;
        _isLoading = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error loading user profile: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserStats(String userId) async {
    try {
      final posts = await _postService.getUserPosts(userId);
      final campaigns = await _campaignService.getUserCampaigns(userId);

      // Additional safety filter to ensure only user's campaigns are shown
      final filteredCampaigns = campaigns
          .where((campaign) => campaign.userId == userId)
          .toList();

      if (mounted) {
        setState(() {
          _userPosts = posts;
          _userCampaigns = filteredCampaigns;
        });
      }

      _followersCount = await _followService.getFollowersCount(userId);
      _followingCount = await _followService.getFollowingCount(userId);
    } catch (e) {
      // ignore: avoid_print
      print('Error loading user stats: $e');
    }
  }

  Future<void> _loadFollowerCounts(String userId) async {
    try {
      final followersResponse = await supabase
          .from('follows')
          .select('id')
          .eq('following_id', userId);
      final followingResponse = await supabase
          .from('follows')
          .select('id')
          .eq('follower_id', userId);

      if (!mounted) return;
      setState(() {
        _followersCount = followersResponse.length;
        _followingCount = followingResponse.length;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error loading follower counts: $e');
    }
  }

  Future<void> _signOut() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      await _authService.signOut();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Error signing out: $e',
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

  String _getInitials() {
    final fullName = _currentUser?.fullName ?? '';
    final username = _currentUser?.username ?? '';
    if (fullName.isNotEmpty) return fullName[0].toUpperCase();
    if (username.isNotEmpty) return username[0].toUpperCase();
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (ctx, innerBoxIsScrolled) => [
            // Top bar + profile header combined in a collapsible SliverAppBar
            SliverAppBar(
              backgroundColor: const Color(0xFF007F8C),
              pinned: true,
              floating: false,
              snap: false,
              expandedHeight: screenH * 0.38, // collapses smoothly
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: _TopBar(
                username: _currentUser?.username ?? 'Profile',
                onEdit: () async {
                  final ok = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  );
                  if (ok == true) _loadUserProfile();
                },
                onLogout: _signOut,
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: _buildProfileHeader(screenW, screenH),
              ),
            ),
            // Pinned TabBar
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(_buildTabBar()),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildMixedGrid(),
              _buildPostsGrid(),
              _buildCampaignsGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(double screenWidth, double screenHeight) {
    final name = _currentUser?.fullName ?? _currentUser?.username ?? 'User';
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF007F8C), Color(0xFF005A6B)],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.015,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: screenHeight * 0.01),
            ProfileUserAvatar(
              user: _currentUser,
              size: screenWidth * 0.24, // diameter = radius * 2
            ),
            SizedBox(height: screenHeight * 0.008),
            Text(
              name,
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            Text(
              _currentUser?.email ?? 'No email',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            if ((_currentUser?.bio ?? '').isNotEmpty) ...[
              SizedBox(height: screenHeight * 0.01),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                child: Text(
                  _currentUser!.bio!,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.white70,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ),
            ],
            if ((_currentUser?.location ?? '').isNotEmpty) ...[
              SizedBox(height: screenHeight * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.white70,
                    size: screenWidth * 0.04,
                  ),
                  SizedBox(width: screenWidth * 0.01),
                  Flexible(
                    child: Text(
                      _currentUser!.location!,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: screenHeight * 0.015),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.008,
                  horizontal: screenWidth * 0.02,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _ProfileStat(
                        title: "Following",
                        count: "$_followingCount",
                      ),
                    ),
                    SizedBox(
                      height: 24,
                      child: VerticalDivider(
                        thickness: 1,
                        color: Colors.black12,
                      ),
                    ),
                    Expanded(
                      child: _ProfileStat(
                        title: "Posts",
                        count: "${_userPosts.length + _userCampaigns.length}",
                      ),
                    ),
                    SizedBox(
                      height: 24,
                      child: VerticalDivider(
                        thickness: 1,
                        color: Colors.black12,
                      ),
                    ),
                    Expanded(
                      child: _ProfileStat(
                        title: "Followers",
                        count: "$_followersCount",
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
          ],
        ),
      ),
    );
  }

  // Return a TabBar directly (PreferredSizeWidget) for the SliverPersistentHeader
  PreferredSizeWidget _buildTabBar() {
    final screenWidth = MediaQuery.of(context).size.width;
    return TabBar(
      controller: _tabController,
      indicatorColor: const Color(0xFF007F8C),
      labelColor: const Color(0xFF007F8C),
      unselectedLabelColor: Colors.grey,
      labelPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
      tabs: [
        Tab(
          icon: Icon(Icons.apps, size: screenWidth * 0.045),
          text: 'All',
        ),
        Tab(
          icon: Icon(Icons.grid_on, size: screenWidth * 0.045),
          text: 'Posts',
        ),
        Tab(
          icon: Icon(Icons.campaign, size: screenWidth * 0.045),
          text: 'Campaigns',
        ),
      ],
    );
  }

  Widget _buildPostsGrid() {
    if (_userPosts.isEmpty) {
      return const _EmptyState(
        icon: Icons.photo_library,
        title: 'No posts yet',
        subtitle: 'Tap the + button to create your first post',
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
      physics:
          const ClampingScrollPhysics(), // important inside NestedScrollView
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: MediaQuery.of(context).size.width * 0.005,
        mainAxisSpacing: MediaQuery.of(context).size.width * 0.005,
        childAspectRatio: 1.0,
      ),
      itemCount: _userPosts.length,
      itemBuilder: (_, i) => _buildGridItem(_userPosts[i], true),
    );
  }

  Widget _buildCampaignsGrid() {
    if (_userCampaigns.isEmpty) {
      return const _EmptyState(
        icon: Icons.campaign,
        title: 'No campaigns yet',
        subtitle: 'Create your first campaign to get started',
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
      physics: const ClampingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: MediaQuery.of(context).size.width * 0.005,
        mainAxisSpacing: MediaQuery.of(context).size.width * 0.005,
        childAspectRatio: 1.0,
      ),
      itemCount: _userCampaigns.length,
      itemBuilder: (_, i) => _buildGridItem(_userCampaigns[i], false),
    );
  }

  Widget _buildMixedGrid() {
    final all = <dynamic>[..._userPosts, ..._userCampaigns];
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (all.isEmpty) {
      return const _EmptyState(
        icon: Icons.apps,
        title: 'No content yet',
        subtitle: 'Start creating posts and campaigns',
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
      physics: const ClampingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: MediaQuery.of(context).size.width * 0.005,
        mainAxisSpacing: MediaQuery.of(context).size.width * 0.005,
        childAspectRatio: 1.0,
      ),
      itemCount: all.length,
      itemBuilder: (_, i) {
        final item = all[i];
        final isPost = item is PostModel;
        return _buildGridItem(item, isPost);
      },
    );
  }

  Widget _buildGridItem(dynamic item, bool isPost) {
    final List<String> imageUrls = item.imageUrls ?? const [];
    final List<String> videoUrls = item.videoUrls ?? const [];
    final hasMedia = imageUrls.isNotEmpty || videoUrls.isNotEmpty;

    return GestureDetector(
      onTap: () => _showContentDetail(item, isPost),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasMedia) ...[
              if (imageUrls.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: imageUrls.first,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (_, __, ___) =>
                      const Center(child: Icon(Icons.error)),
                )
              else
                Container(
                  color: Colors.black,
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_filled,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
            ] else
              Container(
                color: Colors.grey[300],
                child: Center(
                  child: Icon(
                    isPost ? Icons.text_fields : Icons.campaign,
                    color: Colors.grey[600],
                    size: 32,
                  ),
                ),
              ),
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  isPost ? Icons.photo : Icons.campaign,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 16,
                ),
                onSelected: (v) => _handleContentAction(v, item, isPost),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share, size: 16),
                        SizedBox(width: 8),
                        Text('Share'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContentDetail(dynamic item, bool isPost) {
    if (isPost) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PostDetailPage(post: item)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CampaignDetailPage(campaign: item)),
      );
    }
  }

  void _handleContentAction(String action, dynamic item, bool isPost) {
    switch (action) {
      case 'edit':
        _editContent(item, isPost);
        break;
      case 'delete':
        _deleteContent(item, isPost);
        break;
      case 'share':
        _shareContent(item, isPost);
        break;
    }
  }

  void _editContent(dynamic item, bool isPost) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit ${isPost ? 'post' : 'campaign'}: ${item.id}'),
      ),
    );
  }

  void _deleteContent(dynamic item, bool isPost) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete ${isPost ? 'Post' : 'Campaign'}'),
        content: Text(
          'Are you sure you want to delete this ${isPost ? 'post' : 'campaign'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performDelete(item, isPost);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(dynamic item, bool isPost) async {
    try {
      final userId = _currentUser?.id;
      if (userId == null) throw 'No current user';

      if (isPost) {
        await _postService.deletePost(item.id, userId);
        if (!mounted) return;
        setState(() => _userPosts.removeWhere((p) => p.id == item.id));
      } else {
        await _campaignService.deleteCampaign(item.id, userId);
        if (!mounted) return;
        setState(() => _userCampaigns.removeWhere((c) => c.id == item.id));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${isPost ? 'Post' : 'Campaign'} deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting ${isPost ? 'post' : 'campaign'}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareContent(dynamic item, bool isPost) async {
    try {
      final shareText = isPost
          ? 'Check out this post: ${item.content ?? ''}'
          : 'Join this campaign: ${item.title ?? ''} - ${item.description ?? ''}';
      final shareUrl =
          'https://staymitra.app/${isPost ? 'post' : 'campaign'}/${item.id}';
      await Share.share('$shareText\n\n$shareUrl');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
// hii
/// Small stat tile
class _ProfileStat extends StatelessWidget {
  final String title;
  final String count;
  const _ProfileStat({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            fontSize: screenWidth * 0.032,
            color: Colors.grey[600],
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// Pinned header for TabBar
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final PreferredSizeWidget tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}

/// Teal top row with edit & logout
class _TopBar extends StatelessWidget {
  final String username;
  final VoidCallback onEdit;
  final VoidCallback onLogout;
  const _TopBar({
    required this.username,
    required this.onEdit,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            username,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenW * 0.05,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, color: Colors.white),
              ),
              IconButton(
                onPressed: onLogout,
                icon: const Icon(Icons.logout, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
