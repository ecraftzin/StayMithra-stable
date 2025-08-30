import 'package:flutter/material.dart';
import 'package:staymitra/Campaigns/campaign_participants_page.dart';
import 'package:staymitra/Campaigns/campaign_analytics_page.dart';

class CampaignHostDashboard extends StatelessWidget {
  final String campaignId;
  final String campaignTitle;
  final int totalParticipants;

  const CampaignHostDashboard({
    super.key,
    required this.campaignId,
    required this.campaignTitle,
    required this.totalParticipants,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Campaign Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF007F8C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campaign Info Card
            Container(
              width: double.infinity,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaignTitle,
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
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
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people,
                              size: screenWidth * 0.035,
                              color: Colors.green,
                            ),
                            SizedBox(width: screenWidth * 0.01),
                            Text(
                              '$totalParticipants Participants',
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.green,
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
            ),

            SizedBox(height: screenHeight * 0.03),

            // Dashboard Options
            Text(
              'Manage Your Campaign',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            // Participants Button
            _buildDashboardCard(
              context: context,
              title: 'View Participants',
              subtitle: 'See who joined your campaign',
              icon: Icons.people,
              color: Colors.blue,
              participantCount: totalParticipants,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CampaignParticipantsPage(
                      campaignId: campaignId,
                      campaignTitle: campaignTitle,
                      totalParticipants: totalParticipants,
                    ),
                  ),
                );
              },
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),

            SizedBox(height: screenHeight * 0.02),

            // Analytics Button
            _buildDashboardCard(
              context: context,
              title: 'Campaign Analytics',
              subtitle: 'View detailed insights and statistics',
              icon: Icons.analytics,
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CampaignAnalyticsPage(
                      campaignId: campaignId,
                      campaignTitle: campaignTitle,
                    ),
                  ),
                );
              },
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),

            SizedBox(height: screenHeight * 0.02),

            // Additional Options
            _buildDashboardCard(
              context: context,
              title: 'Campaign Settings',
              subtitle: 'Edit campaign details and settings',
              icon: Icons.settings,
              color: Colors.orange,
              onTap: () {
                // Navigate to campaign edit page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Campaign settings coming soon!')),
                );
              },
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),

            SizedBox(height: screenHeight * 0.02),

            _buildDashboardCard(
              context: context,
              title: 'Share Campaign',
              subtitle: 'Invite more people to join',
              icon: Icons.share,
              color: Colors.green,
              onTap: () {
                // Share campaign functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share functionality coming soon!')),
                );
              },
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required double screenWidth,
    required double screenHeight,
    int? participantCount,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
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
            Container(
              padding: EdgeInsets.all(screenWidth * 0.03),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: screenWidth * 0.06,
              ),
            ),
            
            SizedBox(width: screenWidth * 0.04),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (participantCount != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$participantCount',
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: screenWidth * 0.032,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: screenWidth * 0.04,
            ),
          ],
        ),
      ),
    );
  }
}

// Example of how to navigate to the dashboard from a campaign detail page
class CampaignDetailPageExample extends StatelessWidget {
  const CampaignDetailPageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign Details'),
        actions: [
          // Add this button to campaign detail page for hosts
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CampaignHostDashboard(
                    campaignId: 'campaign_123',
                    campaignTitle: 'Clean Mumbai Beach Drive',
                    totalParticipants: 156,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.dashboard),
            tooltip: 'Campaign Dashboard',
          ),
        ],
      ),
      body: const Center(
        child: Text('Campaign details would be shown here...'),
      ),
    );
  }
}
