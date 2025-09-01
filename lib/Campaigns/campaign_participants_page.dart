import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:staymitra/services/campaign_service.dart';
import 'package:staymitra/models/user_model.dart';

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

  final CampaignService _campaignService = CampaignService();
  List<CampaignParticipant> _participants = [];
  List<CampaignParticipant> _filteredParticipants = [];

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final participants = await _campaignService.getCampaignParticipants(widget.campaignId);

      if (mounted) {
        setState(() {
          _participants = participants.map((participant) {
            final userData = participant['users'] as Map<String, dynamic>?;
            final joinedAt = DateTime.parse(participant['joined_at']);

            return CampaignParticipant(
              id: participant['id'],
              name: userData?['full_name'] ?? 'Unknown User',
              username: '@${userData?['username'] ?? 'unknown'}',
              avatarUrl: userData?['avatar_url'],
              joinedDate: joinedAt,
              isVerified: userData?['is_verified'] ?? false,
              participationLevel: _getParticipationLevel(joinedAt),
            );
          }).toList();
          _applyFilter();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading participants: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getParticipationLevel(DateTime joinedDate) {
    final daysSinceJoined = DateTime.now().difference(joinedDate).inDays;
    if (daysSinceJoined <= 1) {
      return 'High';
    } else if (daysSinceJoined <= 7) {
      return 'Active';
    } else {
      return 'Moderate';
    }
  }

  void _applyFilter() {
    switch (_selectedFilter) {
      case 'Recent':
        _filteredParticipants = _participants
            .where((p) => DateTime.now().difference(p.joinedDate).inDays <= 7)
            .toList();
        break;
      case 'Active':
        _filteredParticipants = _participants
            .where((p) => p.participationLevel == 'Active' || p.participationLevel == 'High')
            .toList();
        break;
      case 'Verified':
        _filteredParticipants = _participants
            .where((p) => p.isVerified)
            .toList();
        break;
      default:
        _filteredParticipants = List.from(_participants);
    }

    // Sort by joined date (most recent first)
    _filteredParticipants.sort((a, b) => b.joinedDate.compareTo(a.joinedDate));
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
                : RefreshIndicator(
                    onRefresh: _loadParticipants,
                    child: _buildParticipantsList(screenWidth),
                  ),
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
                      '${_participants.length} Participants',
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
                _applyFilter();
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
    if (_filteredParticipants.isEmpty) {
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
      itemCount: _filteredParticipants.length,
      itemBuilder: (context, index) {
        final participant = _filteredParticipants[index];
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
