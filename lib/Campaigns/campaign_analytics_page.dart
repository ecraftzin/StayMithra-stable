import 'package:flutter/material.dart';

class CampaignAnalyticsPage extends StatefulWidget {
  final String campaignId;
  final String campaignTitle;

  const CampaignAnalyticsPage({
    super.key,
    required this.campaignId,
    required this.campaignTitle,
  });

  @override
  State<CampaignAnalyticsPage> createState() => _CampaignAnalyticsPageState();
}

class _CampaignAnalyticsPageState extends State<CampaignAnalyticsPage> {
  bool _isLoading = true;

  // Mock analytics data - replace with actual service calls
  final Map<String, dynamic> _analyticsData = {
    'totalParticipants': 156,
    'newParticipantsToday': 12,
    'totalViews': 2340,
    'totalShares': 89,
    'totalLikes': 234,
    'engagementRate': 78.5,
    'topLocations': ['Mumbai', 'Delhi', 'Bangalore', 'Chennai', 'Kolkata'],
    'ageGroups': {
      '18-25': 45,
      '26-35': 38,
      '36-45': 12,
      '46+': 5,
    },
    'participationTrend': [10, 15, 23, 31, 45, 67, 89, 112, 134, 156],
  };

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
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
          'Campaign Analytics',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF007F8C),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Export or share analytics
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campaign Title
                  _buildCampaignTitle(screenWidth),
                  
                  SizedBox(height: screenHeight * 0.02),
                  
                  // Key Metrics Cards
                  _buildKeyMetrics(screenWidth, screenHeight),
                  
                  SizedBox(height: screenHeight * 0.03),
                  
                  // Engagement Overview
                  _buildEngagementOverview(screenWidth, screenHeight),
                  
                  SizedBox(height: screenHeight * 0.03),
                  
                  // Demographics
                  _buildDemographics(screenWidth, screenHeight),
                  
                  SizedBox(height: screenHeight * 0.03),
                  
                  // Top Locations
                  _buildTopLocations(screenWidth, screenHeight),
                  
                  SizedBox(height: screenHeight * 0.03),
                  
                  // Participation Trend
                  _buildParticipationTrend(screenWidth, screenHeight),
                ],
              ),
            ),
    );
  }

  Widget _buildCampaignTitle(double screenWidth) {
    return Container(
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
            widget.campaignTitle,
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: screenWidth * 0.02),
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
                      Icons.trending_up,
                      size: screenWidth * 0.035,
                      color: Colors.green,
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    Text(
                      'Active Campaign',
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
    );
  }

  Widget _buildKeyMetrics(double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: screenHeight * 0.015),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Participants',
                '${_analyticsData['totalParticipants']}',
                Icons.people,
                Colors.blue,
                '+${_analyticsData['newParticipantsToday']} today',
                screenWidth,
                screenHeight,
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: _buildMetricCard(
                'Total Views',
                '${_analyticsData['totalViews']}',
                Icons.visibility,
                Colors.purple,
                '+234 this week',
                screenWidth,
                screenHeight,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.015),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Shares',
                '${_analyticsData['totalShares']}',
                Icons.share,
                Colors.orange,
                '+12 today',
                screenWidth,
                screenHeight,
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: _buildMetricCard(
                'Likes',
                '${_analyticsData['totalLikes']}',
                Icons.favorite,
                Colors.red,
                '+45 today',
                screenWidth,
                screenHeight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: screenWidth * 0.05,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up,
                color: Colors.green,
                size: screenWidth * 0.04,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.032,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: screenHeight * 0.005),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: screenWidth * 0.025,
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementOverview(double screenWidth, double screenHeight) {
    return Container(
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
            'Engagement Overview',
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    width: screenWidth * 0.25,
                    height: screenWidth * 0.25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF007F8C).withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_analyticsData['engagementRate']}%',
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF007F8C),
                            ),
                          ),
                          Text(
                            'Engagement',
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildEngagementItem('Views', '2.3K', Icons.visibility, Colors.purple, screenWidth),
              _buildEngagementItem('Shares', '89', Icons.share, Colors.orange, screenWidth),
              _buildEngagementItem('Likes', '234', Icons.favorite, Colors.red, screenWidth),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementItem(String label, String value, IconData icon, Color color, double screenWidth) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(screenWidth * 0.025),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: screenWidth * 0.05,
          ),
        ),
        SizedBox(height: screenWidth * 0.01),
        Text(
          value,
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.03,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDemographics(double screenWidth, double screenHeight) {
    return Container(
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
            'Age Demographics',
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          ..._analyticsData['ageGroups'].entries.map<Widget>((entry) {
            final percentage = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.01),
              child: Row(
                children: [
                  SizedBox(
                    width: screenWidth * 0.15,
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: percentage / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF007F8C),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTopLocations(double screenWidth, double screenHeight) {
    return Container(
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
            'Top Locations',
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          ...(_analyticsData['topLocations'] as List<String>).asMap().entries.map((entry) {
            final index = entry.key;
            final location = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.01),
              child: Row(
                children: [
                  Container(
                    width: screenWidth * 0.06,
                    height: screenWidth * 0.06,
                    decoration: BoxDecoration(
                      color: const Color(0xFF007F8C),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Text(
                      location,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.location_on,
                    size: screenWidth * 0.04,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildParticipationTrend(double screenWidth, double screenHeight) {
    return Container(
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
            'Participation Trend',
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          SizedBox(
            height: screenHeight * 0.15,
            child: Center(
              child: Text(
                'Chart visualization would go here\n(Line chart showing participation growth over time)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
