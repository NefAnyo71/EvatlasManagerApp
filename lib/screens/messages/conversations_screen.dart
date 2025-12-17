import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'message_detail_screen.dart';

class ConversationsScreen extends StatefulWidget {
  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  List<dynamic> _conversations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Mock user ID - gerçek uygulamada AuthService.currentUser?.id kullanılacak
      final userId = 1;
      final result = await ApiService.getConversations(userId);

      setState(() {
        _conversations = result['conversations'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mesajlaşma'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadConversations,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Hata: $_error'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadConversations,
                        child: Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : _conversations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.message, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Henüz mesajlaşma bulunmuyor',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = _conversations[index];
                        return _buildConversationCard(conversation);
                      },
                    ),
    );
  }

  Widget _buildConversationCard(dynamic conversation) {
    final unreadCount = conversation['unreadCount'] ?? 0;
    final lastMessage = conversation['lastMessage'] ?? '';
    final otherUserId = conversation['otherUserId'];
    final otherUserName =
        conversation['otherUserName'] ?? 'Bilinmeyen Kullanıcı';
    final lastMessageAt = conversation['lastMessageAt'] != null
        ? DateTime.parse(conversation['lastMessageAt'])
        : DateTime.now();
    final lastMessageId = conversation['lastMessageId'];

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              otherUserName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lastMessage.length > 50
                  ? '${lastMessage.substring(0, 50)}...'
                  : lastMessage,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'ID: $otherUserId',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                if (lastMessageId != null) ...[
                  SizedBox(width: 8),
                  Text(
                    'Msg #$lastMessageId',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ],
            ),
            SizedBox(height: 4),
            Text(
              _formatDateTime(lastMessageAt),
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (unreadCount > 0)
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MessageDetailScreen(
                otherUserId: otherUserId,
                otherUserName: otherUserName,
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }
}
