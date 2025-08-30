// lib/Campaigns/campaigns_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // RealtimeChannel
import 'package:timeago/timeago.dart' as timeago;

import 'package:staymitra/services/campaign_service.dart';
import 'package:staymitra/models/campaign_model.dart';
import 'package:staymitra/Campaigns/create_campaign_page.dart';

class CampaignsPage extends StatefulWidget {
  const CampaignsPage({super.key});

  @override
  State<CampaignsPage> createState() => _CampaignsPageState();
}

class _CampaignsPageState extends State<CampaignsPage> {
  final CampaignService _campaignService = CampaignService();

  final List<CampaignModel> _campaigns = [];
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 0;
  final int _campaignsPerPage = 10;

  RealtimeChannel? _campaignsSubscription;

  // Filters
  String? _selectedLocation;
  String? _selectedCategory;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadCampaigns(refresh: true);
    _subscribeToNewCampaigns();
  }

  @override
  void dispose() {
    _campaignsSubscription?.unsubscribe();
    _searchController.dispose();
    super.dispose();
  }

  void _subscribeToNewCampaigns() {
    // Assumes your service exposes a method returning RealtimeChannel
    _campaignsSubscription =
        _campaignService.subscribeToNewCampaigns((CampaignModel newCampaign) {
      if (!mounted) return;
      setState(() {
        _campaigns.insert(0, newCampaign);
      });
    });
  }

  Future<void> _loadCampaigns({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _isLoadingMore = false;
        _currentPage = 0;
        _campaigns.clear();
      });
    }

    try {
      List<CampaignModel> page;

      final hasFilters = _selectedLocation != null ||
          _selectedCategory != null ||
          _selectedDateRange != null;

      if (hasFilters) {
        page = await _campaignService.getFilteredCampaigns(
          limit: _campaignsPerPage,
          offset: _currentPage * _campaignsPerPage,
          location: _selectedLocation,
          category: _selectedCategory,
          startDate: _selectedDateRange?.start,
          endDate: _selectedDateRange?.end,
        );
      } else {
        page = await _campaignService.getAllCampaigns(
          limit: _campaignsPerPage,
          offset: _currentPage * _campaignsPerPage,
        );
      }

      if (!mounted) return;
      setState(() {
        _campaigns.addAll(page);
        _currentPage++;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      // Optional: show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading campaigns: $e')),
      );
    }
  }

  Future<void> _loadMoreCampaigns() async {
    if (_isLoadingMore || _isLoading) return;
    setState(() => _isLoadingMore = true);
    await _loadCampaigns();
  }

  Future<void> _navigateToCreateCampaign() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateCampaignPage()),
    );
    if (result == true && mounted) {
      _loadCampaigns(refresh: true);
    }
  }

  void _showFilterDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        // local setState for the dialog
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: const Text('Filter Campaigns'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Location
                    DropdownButtonFormField<String?>(
                      value: _selectedLocation,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Locations'),
                        ),
                        DropdownMenuItem(value: 'Mumbai', child: Text('Mumbai')),
                        DropdownMenuItem(value: 'Delhi', child: Text('Delhi')),
                        DropdownMenuItem(value: 'Bangalore', child: Text('Bangalore')),
                        DropdownMenuItem(value: 'Chennai', child: Text('Chennai')),
                        DropdownMenuItem(value: 'Kolkata', child: Text('Kolkata')),
                        DropdownMenuItem(value: 'Hyderabad', child: Text('Hyderabad')),
                        DropdownMenuItem(value: 'Pune', child: Text('Pune')),
                      ],
                      onChanged: (v) => setLocal(() => _selectedLocation = v),
                    ),
                    const SizedBox(height: 16),

                    // Category
                    DropdownButtonFormField<String?>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Categories'),
                        ),
                        DropdownMenuItem(value: 'Social', child: Text('Social')),
                        DropdownMenuItem(value: 'Educational', child: Text('Educational')),
                        DropdownMenuItem(value: 'Environmental', child: Text('Environmental')),
                        DropdownMenuItem(value: 'Health', child: Text('Health')),
                        DropdownMenuItem(value: 'Sports', child: Text('Sports')),
                        DropdownMenuItem(value: 'Cultural', child: Text('Cultural')),
                        DropdownMenuItem(value: 'Technology', child: Text('Technology')),
                        DropdownMenuItem(value: 'Business', child: Text('Business')),
                      ],
                      onChanged: (v) => setLocal(() => _selectedCategory = v),
                    ),
                    const SizedBox(height: 16),

                    // Date range
                    ListTile(
                      title: Text(
                        _selectedDateRange == null
                            ? 'Select Date Range'
                            : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}'
                              ' - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}',
                      ),
                      trailing: const Icon(Icons.date_range),
                      onTap: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          initialDateRange: _selectedDateRange,
                        );
                        if (picked != null) {
                          setLocal(() => _selectedDateRange = picked);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setLocal(() {
                      _selectedLocation = null;
                      _selectedCategory = null;
                      _selectedDateRange = null;
                    });
                    Navigator.pop(context);
                    _loadCampaigns(refresh: true);
                  },
                  child: const Text('Clear'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _loadCampaigns(refresh: true);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Campaigns & Events',
          style: TextStyle(
            color: const Color(0xFF007F8C),
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list, color: Color(0xFF007F8C)),
          ),
          IconButton(
            onPressed: _navigateToCreateCampaign,
            icon: const Icon(Icons.add, color: Color(0xFF007F8C)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadCampaigns(refresh: true),
              child: _campaigns.isEmpty
                  ? _emptyState(screenWidth)
                  : ListView.builder(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      itemCount: _campaigns.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _campaigns.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final campaign = _campaigns[index];

                        // trigger load more a bit earlier
                        if (!_isLoadingMore &&
                            index >= _campaigns.length - 3) {
                          // schedule to avoid setState during build
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _loadMoreCampaigns();
                          });
                        }

                        return CampaignCard(
                          campaign: campaign,
                          screenWidth: screenWidth,
                          onTap: () {
                            // TODO: push campaign detail page
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Campaign: ${campaign.title}')),
                            );
                          },
                        );
                      },
                    ),
            ),
    );
  }

  Widget _emptyState(double screenWidth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event, size: screenWidth * 0.2, color: Colors.grey),
          SizedBox(height: screenWidth * 0.04),
          Text('No campaigns yet',
              style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey)),
          SizedBox(height: screenWidth * 0.02),
          ElevatedButton(
            onPressed: _navigateToCreateCampaign,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007F8C),
            ),
            child: const Text('Create your first campaign',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class CampaignCard extends StatelessWidget {
  final CampaignModel campaign;
  final double screenWidth;
  final VoidCallback onTap;

  const CampaignCard({
    super.key,
    required this.campaign,
    required this.screenWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = campaign.user;

    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: screenWidth * 0.05,
                    backgroundImage: user?.avatarUrl != null
                        ? NetworkImage(user!.avatarUrl!)
                        : null,
                    child: user?.avatarUrl == null
                        ? Text(
                            (user?.username ?? 'U')[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? user?.username ?? 'Unknown User',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          timeago.format(campaign.createdAt),
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (campaign.category != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                        vertical: screenWidth * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007F8C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      child: Text(
                        campaign.category!,
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: const Color(0xFF007F8C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Image (show first if present)
            if (campaign.imageUrls.isNotEmpty)
              SizedBox(
                height: screenWidth * 0.5,
                width: double.infinity,
                child: Image.network(
                  campaign.imageUrls.first,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loading) {
                    if (loading == null) return child;
                    return Container(
                      height: screenWidth * 0.5,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    height: screenWidth * 0.5,
                    color: Colors.grey[300],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.broken_image, size: 50),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load image',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Body
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaign.title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Text(
                    campaign.description,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenWidth * 0.02),

                  Row(
                    children: [
                      if (campaign.location != null) ...[
                        Icon(Icons.location_on,
                            size: screenWidth * 0.04, color: Colors.grey[600]),
                        SizedBox(width: screenWidth * 0.01),
                        Expanded(
                          child: Text(
                            campaign.location!,
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Icon(Icons.people,
                          size: screenWidth * 0.04, color: Colors.grey[600]),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        '${campaign.currentParticipants}'
                        '${campaign.maxParticipants != null ? '/${campaign.maxParticipants}' : ''}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  if (campaign.price != null || campaign.startDate != null)
                    SizedBox(height: screenWidth * 0.02),

                  Row(
                    children: [
                      if (campaign.price != null) ...[
                        const Icon(Icons.currency_rupee,
                            color: Color(0xFF007F8C)),
                        Text(
                          campaign.price!.toStringAsFixed(0),
                          style: const TextStyle(
                            color: Color(0xFF007F8C),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (campaign.startDate != null) ...[
                        Icon(Icons.schedule,
                            size: screenWidth * 0.04, color: Colors.grey[600]),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          '${campaign.startDate!.day}/'
                          '${campaign.startDate!.month}/'
                          '${campaign.startDate!.year}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
