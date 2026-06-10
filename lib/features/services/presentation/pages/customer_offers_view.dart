import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/service_request.dart';
import '../bloc/service_bloc.dart';
import '../bloc/service_event.dart';
import '../bloc/service_state.dart';

class ExpertOffer {
  final String id;
  final String expertName;
  final String specialty;
  final double rating;
  final int completedJobs;
  final double price; // in Tomans
  final String eta; // e.g. "15 mins"
  final String introMessage;
  final String avatarUrl;
  final List<ChatMessage> chatHistory;
  bool isConsulting;

  ExpertOffer({
    required this.id,
    required this.expertName,
    required this.specialty,
    required this.rating,
    required this.completedJobs,
    required this.price,
    required this.eta,
    required this.introMessage,
    required this.avatarUrl,
    required this.chatHistory,
    this.isConsulting = false,
  });
}

class ChatMessage {
  final String id;
  final String senderId; // "customer" or "expert"
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });
}

class CustomerOffersView extends StatefulWidget {
  final ServiceRequest request;

  const CustomerOffersView({super.key, required this.request});

  @override
  State<CustomerOffersView> createState() => _CustomerOffersViewState();
}

class _CustomerOffersViewState extends State<CustomerOffersView> {
  final List<ExpertOffer> _allAvailableOffers = [
    ExpertOffer(
      id: 'exp_1',
      expertName: 'Ali Rezaei',
      specialty: 'Senior Plumbing Specialist',
      rating: 4.9,
      completedJobs: 142,
      price: 350000,
      eta: '15 mins',
      introMessage: 'Hello! I am a certified senior plumber with all the necessary tools. I can resolve any pipe leaks, blockages, or tap repairs immediately.',
      avatarUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150',
      chatHistory: [],
    ),
    ExpertOffer(
      id: 'exp_2',
      expertName: 'Sina Mohammadi',
      specialty: 'Master Electrical Technician',
      rating: 4.8,
      completedJobs: 98,
      price: 290000,
      eta: '22 mins',
      introMessage: 'Hi there! I specialize in residential electrical systems. I can safely diagnose and repair any short circuits, sockets, or lighting issues.',
      avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
      chatHistory: [],
    ),
    ExpertOffer(
      id: 'exp_3',
      expertName: 'Milad Karimi',
      specialty: 'AC & Cooling Expert',
      rating: 4.7,
      completedJobs: 215,
      price: 320000,
      eta: '18 mins',
      introMessage: 'Hello! I have over 8 years of experience in AC installation, maintenance, and gas refills. I can get your system cooling perfectly today.',
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      chatHistory: [],
    ),
  ];

  final List<ExpertOffer> _receivedOffers = [];
  bool _isSearching = true;
  Timer? _offerTimer1;
  Timer? _offerTimer2;
  Timer? _offerTimer3;

  @override
  void initState() {
    super.initState();
    _startSimulatedRealtimeOffers();
  }

  void _startSimulatedRealtimeOffers() {
    // Offer 1 arrives in 1.5 seconds
    _offerTimer1 = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          final offer = _allAvailableOffers[0];
          offer.chatHistory.add(ChatMessage(
            id: 'msg_init_1',
            senderId: 'expert',
            text: offer.introMessage,
            timestamp: DateTime.now(),
          ));
          _receivedOffers.add(offer);
          _isSearching = false; // At least one offer received
        });
        _showNotificationSnackBar(_allAvailableOffers[0].expertName);
      }
    });

    // Offer 2 arrives in 3.5 seconds
    _offerTimer2 = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() {
          final offer = _allAvailableOffers[1];
          offer.chatHistory.add(ChatMessage(
            id: 'msg_init_2',
            senderId: 'expert',
            text: offer.introMessage,
            timestamp: DateTime.now(),
          ));
          _receivedOffers.add(offer);
        });
        _showNotificationSnackBar(_allAvailableOffers[1].expertName);
      }
    });

    // Offer 3 arrives in 5.5 seconds
    _offerTimer3 = Timer(const Duration(milliseconds: 5500), () {
      if (mounted) {
        setState(() {
          final offer = _allAvailableOffers[2];
          offer.chatHistory.add(ChatMessage(
            id: 'msg_init_3',
            senderId: 'expert',
            text: offer.introMessage,
            timestamp: DateTime.now(),
          ));
          _receivedOffers.add(offer);
        });
        _showNotificationSnackBar(_allAvailableOffers[2].expertName);
      }
    });
  }

  void _showNotificationSnackBar(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text('New proposal received from $name!')),
          ],
        ),
        backgroundColor: Colors.blueGrey.shade900,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _offerTimer1?.cancel();
    _offerTimer2?.cancel();
    _offerTimer3?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.background,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              _buildRequestSummaryCard(theme),
              const Divider(height: 1),
              Expanded(
                child: _receivedOffers.isEmpty
                    ? _buildSearchingRadar(theme)
                    : _buildOffersList(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Offers Hub',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _isSearching ? Colors.amber : Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isSearching ? 'Searching for experts...' : 'Active Proposals',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestSummaryCard(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(Icons.build, color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.request.serviceType,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Location: Tehran, Iran',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'ID: ${widget.request.id.substring(0, min(8, widget.request.id.length))}',
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchingRadar(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary.withOpacity(0.5)),
                ),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                  child: Icon(Icons.radar, size: 40, color: theme.colorScheme.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Broadcasting request to verified experts...',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Experts usually respond in less than a minute',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _receivedOffers.length,
      itemBuilder: (context, index) {
        final offer = _receivedOffers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shadowColor: theme.colorScheme.shadow.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
          ),
          child: ExpansionTile(
            shape: const Border(), // remove borders
            leading: CircleAvatar(
              radius: 26,
              backgroundImage: NetworkImage(offer.avatarUrl),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    offer.expertName,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '${offer.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} Tomans',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  offer.specialty,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${offer.rating}',
                            style: theme.textTheme.labelSmall?.copyWith(color: Colors.amber.shade900, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.check_circle_outline, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                    const SizedBox(width: 4),
                    Text(
                      '${offer.completedJobs} jobs',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                    const SizedBox(width: 4),
                    Text(
                      offer.eta,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  ],
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Proposal Summary:',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      offer.introMessage,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: Text(offer.isConsulting ? 'Continue Chat' : 'Consult & Chat'),
                            onPressed: () => _openConsultationChat(offer),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showConfirmationDialog(offer),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                            ),
                            child: const Text('Accept Proposal'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openConsultationChat(ExpertOffer offer) {
    setState(() {
      offer.isConsulting = true;
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConsultationChatPage(
          offer: offer,
          request: widget.request,
          onAccept: () {
            // Dismiss chat page and accept offer
            Navigator.of(context).pop();
            _acceptOffer(offer);
          },
        ),
      ),
    );
  }

  void _showConfirmationDialog(ExpertOffer offer) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Selection'),
          content: Text('Do you want to accept ${offer.expertName}\'s proposal and confirm the price of ${offer.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} Tomans?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _acceptOffer(offer);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _acceptOffer(ExpertOffer offer) {
    // We update the request status using BLoC!
    // We also set the expert details on the request so they can be shown in the UI tracking state!
    final updatedRequest = widget.request.copyWith(
      status: ServiceStatus.accepted,
      professionalId: offer.id,
      estimatedArrivalTime: 15.0, // mock arrival time
      assignedProfessionalName: offer.expertName,
      assignedProfessionalSpecialty: offer.specialty,
      assignedProfessionalRating: offer.rating,
      confirmedPrice: offer.price,
    );

    context.read<ServiceBloc>().add(ServiceStatusUpdated(updatedRequest));
  }

  int min(int a, int b) => a < b ? a : b;
}

class ConsultationChatPage extends StatefulWidget {
  final ExpertOffer offer;
  final ServiceRequest request;
  final VoidCallback onAccept;

  const ConsultationChatPage({
    super.key,
    required this.offer,
    required this.request,
    required this.onAccept,
  });

  @override
  State<ConsultationChatPage> createState() => _ConsultationChatPageState();
}

class _ConsultationChatPageState extends State<ConsultationChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isExpertTyping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    setState(() {
      widget.offer.chatHistory.add(ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'customer',
        text: text,
        timestamp: DateTime.now(),
      ));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    // Trigger smart context-aware reply
    _simulateExpertReply(text);
  }

  void _simulateExpertReply(String customerMsg) {
    setState(() {
      _isExpertTyping = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    String replyText = '';
    final textLower = customerMsg.toLowerCase();

    if (textLower.contains('price') || textLower.contains('cost') || textLower.contains('تومان') || textLower.contains('هزینه') || textLower.contains('قیمت')) {
      replyText = 'The proposal of ${widget.offer.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} Tomans covers the visit fee and direct labor. If we need to purchase replacement parts on-site, I will buy them with a receipt and share the invoice.';
    } else if (textLower.contains('when') || textLower.contains('time') || textLower.contains('arrival') || textLower.contains('کی') || textLower.contains('ساعت') || textLower.contains('زمان')) {
      replyText = 'I am fully prepared with all tools in my service vehicle. I can be at your address in Tehran within ${widget.offer.eta} once you accept the proposal!';
    } else {
      replyText = 'Excellent! I have successfully noted the details. If you have any other questions, please let me know, or you can click "Accept Proposal" at the bottom of our chat so I can start driving!';
    }

    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isExpertTyping = false;
          widget.offer.chatHistory.add(ChatMessage(
            id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
            senderId: 'expert',
            text: replyText,
            timestamp: DateTime.now(),
          ));
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(widget.offer.avatarUrl),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.offer.expertName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(widget.offer.specialty, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: widget.offer.chatHistory.length,
              itemBuilder: (context, index) {
                final message = widget.offer.chatHistory[index];
                final isMe = message.senderId == 'customer';
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                      ),
                    ),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.text,
                          style: TextStyle(
                            color: isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            '${message.timestamp.hour.toString().padLeft(2, \'0\')}:${message.timestamp.minute.toString().padLeft(2, \'0\')}',
                            style: TextStyle(
                              color: (isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant).withOpacity(0.6),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isExpertTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${widget.offer.expertName} is typing...',
                    style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Ask expert about details, price, ETA...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.send, color: theme.colorScheme.primary),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text('Select Expert & Confirm Price (${widget.offer.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => \'${m[1]},\')} Tomans)'),
                    onPressed: widget.onAccept,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
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
}
