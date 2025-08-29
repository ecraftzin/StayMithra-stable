import 'package:flutter/material.dart';
import 'package:staymitra/models/user_model.dart';
import 'package:staymitra/models/post_model.dart';
import 'package:staymitra/models/campaign_model.dart';

/// Base class for profile pages to share common UI components
abstract class BaseProfilePage extends StatefulWidget {
  const BaseProfilePage({super.key});
}

abstract class BaseProfilePageState<T extends BaseProfilePage> extends State<T> 
    with TickerProviderStateMixin {
  
  late TabController tabController;
  List<PostModel> userPosts = [];
  List<CampaignModel> userCampaigns = [];
  int followersCount = 0;
  int followingCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  // Abstract methods that must be implemented by subclasses
  UserModel? get currentUser;
  List<Widget> get appBarActions;
  void loadUserData();

  // Shared UI components
  Widget buildTabBar() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabController,
        indicatorColor: const Color(0xFF007F8C),
        labelColor: const Color(0xFF007F8C),
        unselectedLabelColor: Colors.grey,
        isScrollable: false,
        labelPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
        labelStyle: TextStyle(
          fontSize: screenWidth * 0.032,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: screenWidth * 0.03,
          fontWeight: FontWeight.normal,
        ),
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
      ),
    );
  }

  Widget buildProfileStats() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Padding(
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
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ProfileStat(title: "Following", count: "$followingCount"),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.grey.withValues(alpha: 0.3),
              ),
              Expanded(
                child: ProfileStat(
                  title: "Posts",
                  count: "${userPosts.length + userCampaigns.length}",
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.grey.withValues(alpha: 0.3),
              ),
              Expanded(
                child: ProfileStat(title: "Followers", count: "$followersCount"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGridView(List<dynamic> items) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apps, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No content yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Start creating posts and campaigns', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: MediaQuery.of(context).size.width * 0.005,
        mainAxisSpacing: MediaQuery.of(context).size.width * 0.005,
        childAspectRatio: 1.0,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isPost = item is PostModel;
        return buildGridItem(item, isPost);
      },
    );
  }

  Widget buildGridItem(dynamic item, bool isPost) {
    // Implementation for grid item
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          isPost ? Icons.image : Icons.campaign,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}

/// Shared profile stat widget
class ProfileStat extends StatelessWidget {
  final String title;
  final String count;
  
  const ProfileStat({
    super.key,
    required this.title,
    required this.count,
  });

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
