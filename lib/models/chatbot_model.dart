class ChatbotMessage {
  final String message;           // Message text
  final bool isUserMessage;       // Indicates if the message is from the user or the chatbot
  final DateTime timestamp;       // Timestamp for when the message was sent

  // Constructor to initialize the message, isUserMessage, and timestamp
  ChatbotMessage({
    required this.message,
    required this.isUserMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();  // Default to current time if timestamp is null

  /// Converts a JSON object into a ChatbotMessage instance
  factory ChatbotMessage.fromJson(Map<String, dynamic> json) {
    return ChatbotMessage(
      message: json['message'] ?? '',
      isUserMessage: json['isUserMessage'] ?? false,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  /// Converts a ChatbotMessage instance into a JSON object
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'isUserMessage': isUserMessage,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Creates a copy of the ChatbotMessage with updated values
  ChatbotMessage copyWith({
    String? message,
    bool? isUserMessage,
    DateTime? timestamp,
  }) {
    return ChatbotMessage(
      message: message ?? this.message,
      isUserMessage: isUserMessage ?? this.isUserMessage,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

