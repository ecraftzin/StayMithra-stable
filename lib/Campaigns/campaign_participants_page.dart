import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CampaignParticipantsPage extends StatefulWidget {
  final String campaignId;
  final String campaignTitle;
  final int totalParticipants;

  const CampaignParticipantsPage({
    super.key,
    required this.campaignId,
    required this.campaignTitle,
    required this.totalParticipants,
  });

  @override
  State<CampaignParticipantsPage> createState() => _CampaignParticipantsPageState();
}

class _CampaignParticipantsPageState extends State<CampaignParticipantsPage> {
  bool _isLoading = true;
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Recent', 'Active', 'Verified'];

  // Mock data - replace with actual service calls
  final List<CampaignParticipant> _participants = [
    CampaignParticipant(
      id: '1',
      name: 'John Doe',
      username: '@johndoe',
      avatarUrl: null,
      joinedDate: DateTime.now().subtract(const Duration(days: 2)),
      isVerified: true,
      participationLevel: 'Active',
    ),
    CampaignParticipant(
      id: '2',
      name: 'Sarah Wilson',
      username: '@sarahw',
      avatarUrl: null,
      joinedDate: DateTime.now().subtract(const Duration(days: 5)),
      isVerified: false,
      participationLevel: 'Moderate',
    ),
    CampaignParticipant(
      id: '3',
      name: 'Mike Johnson',
      username: '@mikej',
      avatarUrl: null,
      joinedDate: DateTime.now().subtract(const Duration(days: 1)),
      isVerified: true,
      participationLevel: 'High',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    // Simulate loading
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Campaign Participants',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF007F8C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Campaign Info Header
          _buildCampaignHeader(screenWidth, screenHeight),
          
          // Filter Tabs
          _buildFilterTabs(screenWidth),
          
          // Participants List
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _buildParticipantsList(screenWidth),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignHeader(double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: const BoxDecoration(
        color: Color(0xFF007F8C),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.campaignTitle,
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: screenHeight * 0.01),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.005,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.people,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    Text(
                      '${widget.totalParticipants} Participants',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.005,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    Text(
                      'Active',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(double screenWidth) {
    return Container(
      height: 50,
      margin: EdgeInsets.all(screenWidth * 0.04),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final option = _filterOptions[index];
          final isSelected = _selectedFilter == option;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = option;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: screenWidth * 0.03),
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF007F8C) : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? const Color(0xFF007F8C) : Colors.grey[300]!,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: const Color(0xFF007F8C).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Center(
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildParticipantsList(double screenWidth) {
    if (_participants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: screenWidth * 0.2,
              color: Colors.grey[400],
            ),
            SizedBox(height: screenWidth * 0.04),
            Text(
              'No participants yet',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              'Share your campaign to get more participants',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      itemCount: _participants.length,
      itemBuilder: (context, index) {
        final participant = _participants[index];
        return _buildParticipantCard(participant, screenWidth);
      },
    );
  }

  Widget _buildParticipantCard(CampaignParticipant participant, double screenWidth) {
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: screenWidth * 0.06,
            backgroundImage: participant.avatarUrl != null
                ? CachedNetworkImageProvider(participant.avatarUrl!)
                : null,
            backgroundColor: const Color(0xFF007F8C),
            child: participant.avatarUrl == null
                ? Text(
                    participant.name.isNotEmpty 
                        ? participant.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          
          SizedBox(width: screenWidth * 0.03),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        participant.name,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (participant.isVerified)
                      Icon(
                        Icons.verified,
                        size: screenWidth * 0.04,
                        color: Colors.blue,
                      ),
                  ],
                ),
                
                Text(
                  participant.username,
                  style: TextStyle(
                    fontSize: screenWidth * 0.032,
                    color: Colors.grey[600],
                  ),
                ),
                
                SizedBox(height: screenWidth * 0.01),
                
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getParticipationColor(participant.participationLevel).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        participant.participationLevel,
                        style: TextStyle(
                          fontSize: screenWidth * 0.025,
                          color: _getParticipationColor(participant.participationLevel),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    SizedBox(width: screenWidth * 0.02),
                    
                    Text(
                      'Joined ${_formatDate(participant.joinedDate)}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.025,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Action Button
          IconButton(
            onPressed: () {
              // Navigate to user profile or show options
            },
            icon: Icon(
              Icons.more_vert,
              color: Colors.grey[400],
              size: screenWidth * 0.05,
            ),
          ),
        ],
      ),
    );
  }

  Color _getParticipationColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return Colors.green;
      case 'active':
        return Colors.blue;
      case 'moderate':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'today';
    } else if (difference == 1) {
      return '1 day ago';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else {
      final months = (difference / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    }
  }
}

// Model class for campaign participants
class CampaignParticipant {
  final String id;
  final String name;
  final String username;
  final String? avatarUrl;
  final DateTime joinedDate;
  final bool isVerified;
  final String participationLevel;

  CampaignParticipant({
    required this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
    required this.joinedDate,
    required this.isVerified,
    required this.participationLevel,
  });
}
