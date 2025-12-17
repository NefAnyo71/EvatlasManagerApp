import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class MessageDetailScreen extends StatefulWidget {
  final int otherUserId;
  final String otherUserName;

  MessageDetailScreen({
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  _MessageDetailScreenState createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  List<dynamic> _messages = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Mock user ID - gerçek uygulamada AuthService.currentUser?.id kullanılacak
      final currentUserId = 1;
      final result =
          await ApiService.getMessages(currentUserId, widget.otherUserId);

      setState(() {
        _messages = result['messages'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      setState(() {
        _isSending = true;
      });

      final currentUserId = 1;
      await ApiService.sendMessage(
        senderId: currentUserId,
        receiverId: widget.otherUserId,
        content: _messageController.text.trim(),
      );

      _messageController.clear();
      _loadMessages(); // Mesajları yeniden yükle
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mesaj gönderilemedi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _deleteConversation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konuşmayı Sil'),
        content: Text(
            '${widget.otherUserName} ile olan tüm konuşmayı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final currentUserId = 1;
        await ApiService.deleteConversation(currentUserId, widget.otherUserId);
        Navigator.pop(context); // Mesaj detay ekranından çık
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Konuşma silindi'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Konuşma silinemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteConversation,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
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
                              onPressed: _loadMessages,
                              child: Text('Tekrar Dene'),
                            ),
                          ],
                        ),
                      )
                    : _messages.isEmpty
                        ? Center(
                            child: Text(
                              'Henüz mesaj yok',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              return _buildMessageBubble(message);
                            },
                          ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(dynamic message) {
    final currentUserId = 1;
    final isMe = message['sender_id'] == currentUserId;
    final content = message['content'] ?? '';
    final messageType = message['message_type'] ?? 'text';
    final createdAt = message['createdAt'] != null
        ? DateTime.parse(message['createdAt'])
        : DateTime.now();
    final messageId = message['id'];
    final sender = message['sender'];
    final property = message['property'];

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mesaj ID ve kullanıcı bilgileri
                  Row(
                    children: [
                      Text(
                        'Msg #$messageId',
                        style: TextStyle(
                          color: isMe ? Colors.white70 : Colors.grey[600],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isMe && sender != null) ...[
                        SizedBox(width: 8),
                        Text(
                          '${sender['name']} (ID: ${sender['id']})',
                          style: TextStyle(
                            color: isMe ? Colors.white70 : Colors.grey[600],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (messageType == 'auto_reply')
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: EdgeInsets.only(bottom: 4, top: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Otomatik Yanıt',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  // İlan bilgisi
                  if (property != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.home, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'İlan #${property['id']}: ${property['title']}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    content,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _formatTime(createdAt),
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Mesajınızı yazın...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            onPressed: _isSending ? null : _sendMessage,
            icon: _isSending
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.send, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
