import 'package:flutter/material.dart';

class CampaignParticipantsPage extends StatelessWidget {
  const CampaignParticipantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final participants = List.generate(
      12,
      (i) => {
        "name": "User $i",
        "username": "@user$i",
        "avatar": "https://i.pravatar.cc/150?img=${i + 10}",
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Campaign Participants"),
        backgroundColor: const Color(0xFF007F8C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // two per row
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: participants.length,
          itemBuilder: (context, index) {
            final user = participants[index];
            return _ParticipantCard(
              name: user["name"]!,
              username: user["username"]!,
              avatarUrl: user["avatar"]!,
            );
          },
        ),
      ),
    );
  }
}

class _ParticipantCard extends StatelessWidget {
  final String name;
  final String username;
  final String avatarUrl;

  const _ParticipantCard({
    required this.name,
    required this.username,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {}, // tap effect only
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                username,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
