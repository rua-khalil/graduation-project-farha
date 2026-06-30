import 'package:flutter/material.dart';
import 'farha_shared.dart';
import 'UserNav.dart';

// ── Message Model ─────────────────────────────────────────────────────────────
class MessageModel {
  final String id;
  final String vendorName;
  final String lastMessage;
  final String time;
  final bool unread;

  const MessageModel({
    required this.id,
    required this.vendorName,
    required this.lastMessage,
    required this.time,
    required this.unread,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      vendorName: json['vendor_name'] ?? json['vendorName'] ?? '',
      lastMessage: json['last_message'] ?? json['lastMessage'] ?? '',
      time: json['time'] ?? '',
      unread: json['unread'] ?? false,
    );
  }
}

// ── Chat Message Model ────────────────────────────────────────────────────────
class ChatMessage {
  final String text;
  final bool isMe;
  final String time;

  const ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] ?? '',
      isMe: json['is_me'] ?? json['isMe'] ?? false,
      time: json['time'] ?? '',
    );
  }
}

// ── Messages Page ─────────────────────────────────────────────────────────────
class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  bool _loading = true;
  String? _error;
  List<MessageModel> _messages = [];
  String _search = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // TODO: Replace with your real API endpoint
      // final response = await http.get(Uri.parse('https://your-api.com/messages'));
      // final data = jsonDecode(response.body) as List;
      // _messages = data.map((e) => MessageModel.fromJson(e)).toList();

      await Future.delayed(const Duration(milliseconds: 800));
      _messages = [];
    } catch (e) {
      _error = 'Failed to load messages. Please try again.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<MessageModel> get _filtered {
    if (_search.isEmpty) return _messages;
    return _messages
        .where((m) => m.vendorName.toLowerCase().contains(_search.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: const UserNav(activeTab: 'Messages'),
      body: RefreshIndicator(
        color: kGold,
        onRefresh: _fetchMessages,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                'My Messages',
                style: TextStyle(
                  color: kNavy,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Chat directly with your event vendors and manage your inquiries.',
                style: TextStyle(color: kGray, fontSize: 14, height: 1.5),
              ),

              const SizedBox(height: 24),

              // ── Search Bar ────────────────────────
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kGold, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: kGold, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _search = v),
                        style: const TextStyle(color: kNavy, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Search vendor...',
                          hintStyle: TextStyle(color: kGray, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              if (_loading)
                _buildLoading()
              else if (_error != null)
                _buildError()
              else if (_filtered.isEmpty)
                  _buildEmpty()
                else
                  _buildList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(child: CircularProgressIndicator(color: kGold, strokeWidth: 2.5)),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_outlined, color: kGray, size: 36),
          const SizedBox(height: 10),
          Text(_error!, style: const TextStyle(color: kGray, fontSize: 13), textAlign: TextAlign.center),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: _fetchMessages,
            style: OutlinedButton.styleFrom(
              foregroundColor: kNavy,
              side: const BorderSide(color: kBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Padding(
      padding: EdgeInsets.only(top: 8),
      child: Text('No messages yet.', style: TextStyle(color: kGray, fontSize: 14)),
    );
  }

  Widget _buildList() {
    return Column(
      children: _filtered.map((msg) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ConversationCard(
            message: msg,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(
                  vendorName: msg.vendorName,
                  conversationId: msg.id,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Conversation Card ─────────────────────────────────────────────────────────
class _ConversationCard extends StatelessWidget {
  final MessageModel message;
  final VoidCallback onTap;

  const _ConversationCard({required this.message, required this.onTap});

  String get _initials {
    final parts = message.vendorName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return message.vendorName.isNotEmpty ? message.vendorName[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: message.unread ? kGold : kBorder,
            width: message.unread ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(color: kGold, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(
                _initials,
                style: const TextStyle(
                  color: kWhite,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.vendorName,
                    style: const TextStyle(
                      color: kNavy,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    message.lastMessage,
                    style: const TextStyle(color: kGray, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Time + dot
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (message.time.isNotEmpty)
                  Text(message.time, style: const TextStyle(color: kGray, fontSize: 11)),
                if (message.unread) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: kGold, shape: BoxShape.circle),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chat Page ─────────────────────────────────────────────────────────────────
class ChatPage extends StatefulWidget {
  final String vendorName;
  final String conversationId;

  const ChatPage({
    super.key,
    required this.vendorName,
    required this.conversationId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _loading = true;
  List<ChatMessage> _chatMessages = [];
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  String get _initials {
    final parts = widget.vendorName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return widget.vendorName.isNotEmpty ? widget.vendorName[0].toUpperCase() : '?';
  }

  @override
  void initState() {
    super.initState();
    _fetchChat();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchChat() async {
    setState(() => _loading = true);
    try {
      // TODO: Replace with your real API endpoint
      // final response = await http.get(Uri.parse('https://your-api.com/messages/${widget.conversationId}'));
      // final data = jsonDecode(response.body) as List;
      // _chatMessages = data.map((e) => ChatMessage.fromJson(e)).toList();

      await Future.delayed(const Duration(milliseconds: 600));
      _chatMessages = [];
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    // TODO: Send to API
    // await http.post(Uri.parse('https://your-api.com/messages/${widget.conversationId}'), body: {'text': text});

    setState(() {
      _chatMessages.add(ChatMessage(
        text: text,
        isMe: true,
        time: _nowTime(),
      ));
    });
    _inputController.clear();

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

  String _nowTime() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      // ── بدون UserNav هون ──────────────────────────
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(backgroundColor: kWhite, elevation: 0),
      ),
      body: Column(
        children: [

          // ── Vendor Header ──────────────────────
          Container(
            color: kWhite,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                // Back
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: kBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: kBorder),
                    ),
                    child: const Icon(Icons.arrow_back, color: kNavy, size: 16),
                  ),
                ),
                const SizedBox(width: 12),

                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: kGold, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(
                    _initials,
                    style: const TextStyle(
                      color: kWhite,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Name
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.vendorName,
                      style: const TextStyle(
                        color: kNavy,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const Text(
                      'Event Vendor',
                      style: TextStyle(color: kGray, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: kBorder),

          // ── Messages ───────────────────────────
          Expanded(
            child: _loading
                ? const Center(
              child: CircularProgressIndicator(color: kGold, strokeWidth: 2.5),
            )
                : _chatMessages.isEmpty
                ? const Center(
              child: Text(
                'No messages yet. Say hello!',
                style: TextStyle(color: kGray, fontSize: 14),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                return _ChatBubble(message: _chatMessages[index]);
              },
            ),
          ),

          // ── Input Bar ──────────────────────────
          Container(
            color: kWhite,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: kBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kBorder),
                    ),
                    child: TextField(
                      controller: _inputController,
                      style: const TextStyle(color: kNavy, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: kGray, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(color: kGold, shape: BoxShape.circle),
                    child: const Icon(Icons.send_rounded, color: kWhite, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chat Bubble ───────────────────────────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.68,
        ),
        decoration: BoxDecoration(
          color: message.isMe ? kGold : kWhite,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(message.isMe ? 14 : 4),
            bottomRight: Radius.circular(message.isMe ? 4 : 14),
          ),
          border: message.isMe ? null : Border.all(color: kBorder),
        ),
        child: Column(
          crossAxisAlignment:
          message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isMe ? kWhite : kNavy,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (message.time.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                message.time,
                style: TextStyle(
                  color: message.isMe ? kWhite.withOpacity(0.75) : kGray,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}