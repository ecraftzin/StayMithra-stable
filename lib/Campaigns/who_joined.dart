import 'package:flutter/material.dart';
import 'package:staymitra/services/campaign_service.dart';
import 'package:staymitra/Profile/user_profile_page.dart';

class CampaignParticipantsPage extends StatefulWidget {
  final String campaignId;
  final String? campaignTitle;

  const CampaignParticipantsPage({
    super.key,
    required this.campaignId,
    this.campaignTitle,
  });

  @override
  State<CampaignParticipantsPage> createState() => _CampaignParticipantsPageState();
}

class _CampaignParticipantsPageState extends State<CampaignParticipantsPage> {
  final CampaignService _campaignService = CampaignService();
  List<Map<String, dynamic>> _participants = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final participants = await _campaignService.getCampaignParticipants(widget.campaignId);

      if (mounted) {
        setState(() {
          _participants = participants;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.campaignTitle != null
            ? "${widget.campaignTitle} - Participants"
            : "Campaign Participants"),
        backgroundColor: const Color(0xFF007F8C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007F8C)),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading participants',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadParticipants,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007F8C),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_participants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No participants yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share your campaign to get more participants',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadParticipants,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // two per row
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: _participants.length,
          itemBuilder: (context, index) {
            final participant = _participants[index];
            final userData = participant['users'] as Map<String, dynamic>?;

            return _ParticipantCard(
              userId: userData?['id'] ?? participant['user_id'],
              name: userData?['full_name'] ?? 'Unknown User',
              username: '@${userData?['username'] ?? 'unknown'}',
              avatarUrl: userData?['avatar_url'],
              isVerified: userData?['is_verified'] ?? false,
              joinedDate: DateTime.parse(participant['joined_at']),
            );
          },
        ),
      ),
    );
  }
}

class _ParticipantCard extends StatelessWidget {
  final String userId;
  final String name;
  final String username;
  final String? avatarUrl;
  final bool isVerified;
  final DateTime joinedDate;

  const _ParticipantCard({
    required this.userId,
    required this.name,
    required this.username,
    this.avatarUrl,
    this.isVerified = false,
    required this.joinedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfilePage(
                userId: userId,
                userName: name,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl!)
                        : null,
                    backgroundColor: Colors.grey[300],
                    child: avatarUrl == null
                        ? Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey[600],
                          )
                        : null,
                  ),
                  if (isVerified)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified,
                          color: Color(0xFF007F8C),
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                username,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatJoinDate(joinedDate),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF007F8C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'View Profile',
                  style: TextStyle(
                    fontSize: 10,
                    color: const Color(0xFF007F8C),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatJoinDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Joined today';
    } else if (difference.inDays == 1) {
      return 'Joined yesterday';
    } else if (difference.inDays < 7) {
      return 'Joined ${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? 'Joined 1 week ago' : 'Joined $weeks weeks ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'Joined 1 month ago' : 'Joined $months months ago';
    }
  }
}
