import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import '../services/follow_request_service.dart';
import '../models/chat_model.dart';
import '../Profile/user_profile_page.dart';

class RealChatScreen extends StatefulWidget {
  final String peerId;
  final String peerName;
  final String? peerAvatar;

  const RealChatScreen({
    super.key,
    required this.peerId,
    required this.peerName,
    this.peerAvatar,
  });

  @override
  State<RealChatScreen> createState() => _RealChatScreenState();
}

class _RealChatScreenState extends State<RealChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final FollowRequestService _followRequestService = FollowRequestService();

  ChatModel? _currentChat;
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  RealtimeChannel? _subscription;

  // Follow status tracking
  String _followStatus =
      'not_following'; // 'not_following', 'requested', 'following', 'mutual'
  bool _isFollowLoading = false;
  DateTime? _lastFollowStatusCheck;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _checkFollowStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh follow status when returning to this chat screen
    // This ensures the button shows the correct state after navigation
    _checkFollowStatus();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _subscription?.unsubscribe();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    try {
      // Create or get existing chat
      final chat = await _chatService.createOrGetChat(
        currentUser.id,
        widget.peerId,
      );

      if (chat != null) {
        setState(() {
          _currentChat = chat;
        });

        // Load messages
        await _loadMessages();

        // Subscribe to new messages
        _subscribeToMessages();

        // Mark messages as read
        await _chatService.markMessagesAsRead(chat.id, currentUser.id);
      }
    } catch (e) {
      print('Error initializing chat: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMessages() async {
    if (_currentChat == null) return;

    try {
      final messages = await _chatService.getChatMessages(_currentChat!.id);
      setState(() {
        _messages = messages;
      });
      _scrollToBottom();
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  void _subscribeToMessages() {
    if (_currentChat == null) return;

    _subscription = _chatService.subscribeToChat(
      _currentChat!.id,
      (newMessage) {
        if (mounted) {
          // Check if message already exists to prevent duplicates
          final messageExists = _messages.any((msg) => msg.id == newMessage.id);
          if (!messageExists) {
            setState(() {
              _messages.add(newMessage);
            });
            _scrollToBottom();
          }

          // Mark as read if not from current user
          final currentUser = _authService.currentUser;
          if (currentUser != null && newMessage.senderId != currentUser.id) {
            _chatService.markMessagesAsRead(_currentChat!.id, currentUser.id);
          }
        }
      },
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _currentChat == null || _isSending) return;

    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    setState(() => _isSending = true);

    try {
      final message = await _chatService.sendMessage(
        chatId: _currentChat!.id,
        senderId: currentUser.id,
        content: text,
      );

      if (message != null) {
        _messageController.clear();
        // Add message immediately for better UX
        setState(() {
          _messages.add(message);
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _checkFollowStatus({bool forceRefresh = false}) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    // Cache follow status for 30 seconds to prevent excessive API calls
    final now = DateTime.now();
    if (!forceRefresh && _lastFollowStatusCheck != null &&
        now.difference(_lastFollowStatusCheck!).inSeconds < 30) {
      return; // Use cached status
    }

    try {
      final status = await _followRequestService.getFollowStatus(
        currentUser.id,
        widget.peerId,
      );

      if (mounted) {
        setState(() {
          _followStatus = status;
          _lastFollowStatusCheck = now;
        });
      }
    } catch (e) {
      print('Error checking follow status: $e');
    }
  }

  Future<void> _handleFollowAction() async {
    if (_isFollowLoading) return;

    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    // Prevent users from following themselves
    if (currentUser.id == widget.peerId) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You cannot follow yourself'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isFollowLoading = true);

    try {
      bool success = false;
      String message = '';
      String newStatus = _followStatus;

      switch (_followStatus) {
        case 'not_following':
          final result = await _followRequestService.sendFollowRequest(widget.peerId);
          success = result['success'] ?? false;
          message = result['message']?.isNotEmpty == true
              ? result['message']
              : (success ? 'Follow request sent!' : 'Failed to send follow request');

          if (success) {
            newStatus = result['status'] ?? 'requested';
          } else {
            // If the request failed because they're already following, update the status
            final returnedStatus = result['status'];
            if (returnedStatus == 'following') {
              newStatus = 'following';
              success = true; // Consider this a success since they're already following
              message = 'Already following this user';
            }
          }
          break;

        case 'requested':
          success = await _followRequestService.cancelFollowRequest(widget.peerId);
          message = success ? 'Follow request cancelled' : 'Failed to cancel follow request';
          if (success) {
            newStatus = 'not_following';
            // Force refresh to ensure accurate status
            _lastFollowStatusCheck = null;
          }
          break;

        case 'following':
          success = await _followRequestService.unfollowUser(widget.peerId);
          message = success ? 'Unfollowed user' : 'Failed to unfollow user';
          if (success) {
            // After unfollowing, force refresh to get accurate status
            await _checkFollowStatus(forceRefresh: true);
            return; // Exit early since _checkFollowStatus will update the state
          }
          break;

        case 'followed_by':
          final result = await _followRequestService.sendFollowRequest(widget.peerId);
          success = result['success'] ?? false;
          message = result['message']?.isNotEmpty == true
              ? result['message']
              : (success ? 'Now following each other!' : 'Failed to follow back');

          if (success) {
            newStatus = 'mutual'; // Now both follow each other
            message = 'Now following each other!';
          }
          break;

        case 'mutual':
          success = await _followRequestService.unfollowUser(widget.peerId);
          message = success ? 'Unfollowed user' : 'Failed to unfollow user';
          if (success) {
            // After unfollowing, force refresh to get accurate status
            await _checkFollowStatus(forceRefresh: true);
            return; // Exit early since _checkFollowStatus will update the state
          }
          break;
      }

      if (mounted) {
        setState(() {
          _isFollowLoading = false;
          _followStatus = newStatus;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFollowLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error in follow action: $e'); // Log for debugging
    }
  }

  String _getFollowButtonText() {
    switch (_followStatus) {
      case 'not_following':
        return 'Follow';
      case 'requested':
        return 'Requested';
      case 'following':
        return 'Following';
      case 'followed_by':
        return 'Follow Back';
      case 'mutual':
        return 'Following';
      default:
        return 'Follow';
    }
  }

  Color _getFollowButtonColor() {
    switch (_followStatus) {
      case 'not_following':
        return const Color(0xFF007F8C);
      case 'requested':
        return Colors.orange;
      case 'following':
        return Colors.green;
      case 'followed_by':
        return const Color(0xFF007F8C);
      case 'mutual':
        return Colors.green;
      default:
        return const Color(0xFF007F8C);
    }
  }

  bool _canSendMessages() {
    // Allow messaging if there's any follow relationship (one-way or mutual)
    return _followStatus == 'following' ||
           _followStatus == 'followed_by' ||
           _followStatus == 'mutual';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfilePage(
                  userId: widget.peerId,
                  userName: widget.peerName,
                ),
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: widget.peerAvatar != null
                    ? CachedNetworkImageProvider(widget.peerAvatar!)
                    : null,
                child: widget.peerAvatar == null
                    ? Text(
                        widget.peerName.isNotEmpty
                            ? widget.peerName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.peerName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Follow/Unfollow button (hide when chatting with yourself)
          if (_authService.currentUser?.id != widget.peerId)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: ElevatedButton(
                onPressed: _isFollowLoading ? null : _handleFollowAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getFollowButtonColor(),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: _isFollowLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _getFollowButtonText(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Messages list
                Expanded(
                  child: _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: screenWidth * 0.2,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Start a conversation with ${widget.peerName}',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final currentUser = _authService.currentUser;
                            final isMe = currentUser != null &&
                                message.senderId == currentUser.id;

                            return _buildMessageBubble(
                                message, isMe, screenWidth);
                          },
                        ),
                ),

                // Show follow prompt for non-following users
                if (_followStatus == 'not_following' || _followStatus == 'requested')
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      border: Border(
                        top: BorderSide(color: Colors.blue[200]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[600],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _followStatus == 'requested'
                                ? 'Follow request sent! You can chat once they accept.'
                                : 'Follow each other to start a conversation!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Message input - always show for any follow relationship
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: _canSendMessages()
                                  ? 'Type a message...'
                                  : 'Follow each other to send messages...',
                              border: InputBorder.none,
                            ),
                            maxLines: null,
                            enabled: _canSendMessages(),
                            onSubmitted: (_) => _canSendMessages() ? _sendMessage() : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: _canSendMessages()
                              ? const Color(0xFF007F8C)
                              : Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: (_isSending || !_canSendMessages()) ? null : _sendMessage,
                          icon: _isSending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMessageBubble(
      MessageModel message, bool isMe, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.peerAvatar != null
                  ? CachedNetworkImageProvider(widget.peerAvatar!)
                  : null,
              child: widget.peerAvatar == null
                  ? Text(
                      widget.peerName.isNotEmpty
                          ? widget.peerName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(fontSize: 12),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF007F8C) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeago.format(message.createdAt),
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            Icon(
              message.isRead ? Icons.done_all : Icons.done,
              size: 16,
              color: message.isRead ? Colors.blue : Colors.grey,
            ),
          ],
        ],
      ),
    );
  }
}
