import 'dart:math';
import 'dart:core';
import '../../user_data_provider.dart'; 

class ChatbotService {
  static final Random _random = Random();
  static String _lastContext = ""; // Tracks last user intent
  static UserData? _userData; // To hold user data

  /// Initialize with UserData
  static void initialize(UserData userData) {
    _userData = userData;
  }

  /// Map containing keyword-based responses
  static final Map<String, List<String>> _responses = {
    "hi": [
      "Hello! How can I assist you?",
      "Hey there! Need help?",
      "Hi! What can I do for you?",
      "नमस्ते! मैं आपकी सहायता कैसे कर सकता हूँ?",
      "hie",
      "hai",
      "heyy",
      "👋", "😊", "😄", "🙋", "🙏"
    ],
    "hello": [
      "Hi! How's your day?",
      "Hello! How can I help?",
      "Greetings! Need assistance?",
      "नमस्कार! कैसे हो?",
      "helo",
      "heloo",
      "helooo",
      "alo",
      "aloe",
      "alooo",
      "kehlo",
      "khello",
      "khelooo",
      "हेल्लो",
      "हेलोओ",
      "हेलोओओ",
      "नमस्ते",
      "नमस्कार",
      "🙏", "😊", "👋", "😄"
    ],
    "help": [
      "I can assist with navigation, finding routes, and answering queries! What do you need?",
      "I am here to help with anything you need. How can I assist?",
      "Need help? Let me know what you're looking for!",
      "मैं मार्गदर्शन, रास्तों को ढूँढने, और सवालों के उत्तर देने में सहायता कर सकता हूँ!",
      "halp",
      "hlep",
      "maddad",
      "saahayata",
      "मदत",
      "सहायता",
      "ℹ️", "❓", "🆘"
    ],
    "route": [
      "Enter your source and destination to find the best route.",
      "Please provide the starting point and destination to get the route.",
      "Where are you traveling from and to?",
      "कृपया अपना स्रोत और गंतव्य बताएं ताकि मैं आपको सबसे अच्छा मार्ग दे सकूं।",
      "root",
      "raasta",
      "marg",
      "राह",
      "मार्ग",
      "🗺️", "📍", "➡️"
    ],
    "thank": [
      "You're welcome!",
      "Glad I could help!",
      "Anytime!",
      "आपका स्वागत है!",
      "thnx",
      "tnx",
      "dhanyavaad",
      "shukriya",
      "धन्यवाद",
      "शुक्रिया",
      "👍", "😊", "🙏"
    ],
    "bye": [
      "Goodbye! Have a great day!",
      "See you soon!",
      "Take care!",
      "अलविदा! शुभ दिन हो!",
      "bai",
      "byee",
      " टाटा",
      "अलविदा",
      "फिर मिलेंगे",
      "👋", "😊", "🚶"
    ],
    "weather": [
      "I can't check real-time weather yet, but you can try a weather app!",
      "Unfortunately, I cannot check the weather at the moment.",
      "You might want to use a weather app for current conditions.",
      "मैं वर्तमान मौसम नहीं देख सकता, लेकिन आप मौसम ऐप का उपयोग कर सकते हैं!",
      "vedar",
      "mosam",
      "mausam",
      "मौसम",
      "वेदर",
      "☀️", "🌧️", "☁️", "🌡️"
    ],
    "name": [
      "I'm Navedge Bot, your virtual assistant!",
      "I am Navedge Bot, here to help you out!",
      "You can call me Navedge Bot!",
      "मैं नवेग बोट हूँ, आपकी सहायता के लिए!",
      "nem",
      "naam",
      "नां",
      "नाम",
      "🆔", "🤖"
    ],
    "joke": [
      "Why don’t skeletons fight each other? They don’t have the guts!",
      "Why did the bicycle fall over? Because it was two-tired!",
      "I'm bad at jokes, but hey, at least I try! 😆",
      "एक कंकाल एक दूसरे से क्यों नहीं लड़ते? क्योंकि उनके पास हिम्मत नहीं होती!",
      "jok",
      "chutkula",
      "hasy katha",
      "चुटकुला",
      "जोक",
      "😂", "🤣", "😅"
    ],
    "time": [
      "I don’t have a clock, but you can check your device!",
      "Sorry, I can't tell time. Please check your phone or watch.",
      "I don't have a clock, but you can check the time on your device.",
      "मुझे घड़ी नहीं है, लेकिन आप अपना डिवाइस देख सकते हैं!",
      "taim",
      "samay",
      "waqt",
      "समय",
      "वक्त",
      "⏱️", "⏰", "🕰️"
    ],
    "location": [
      "I can help with navigation. Where do you want to go?",
      "Tell me the place you are looking for.",
      "Where are you trying to go?",
      "मैं मार्गदर्शन में मदद कर सकता हूँ। आप कहाँ जाना चाहते हैं?",
      "lokation",
      "sthiti",
      "jagah",
      "स्थान",
      "जगह",
      "🌍", "🗺️", "📍"
    ],
    "food": [
      "Are you hungry? You can try searching for restaurants nearby!",
      "Looking for food? I can help you find nearby restaurants.",
      "I can help you find a place to eat! What type of food are you looking for?",
      "क्या आप भूखे हैं? आप पास के रेस्तरां ढूंढ सकते हैं!",
      "fud",
      "khana",
      "bhojan",
      "खाना",
      "भोजन",
      "🍔", "🍕", "🍜", "🍣"
    ],
    "thanks": [
      "Happy to help!",
      "You're very welcome!",
      "I'm here whenever you need!",
      "मुझे मदद करने में खुशी हुई!",
      "thenks",
      "dhanyawad",
      "shukriya",
      "धन्यवाद",
      "शुक्रिया",
      "😊", "👍", "🙏"
    ],
    "how are you": [
      "I'm doing great, thank you! How about you?",
      "I'm here and ready to assist you!",
      "I'm doing well, thank you for asking!",
      "मैं ठीक हूँ, धन्यवाद! आप कैसे हैं?",
      "hao r u",
      "kesa hai tu",
      "aap kaise ho",
      "क्या हाल है",
      "आप कैसे हो",
      "😊", "👍", "👌"
    ],
    "sorry": [
      "No worries! How can I assist you further?",
      "It's okay! What can I do for you?",
      "No problem! How can I help next?",
      "कोई बात नहीं! मैं आपकी और कैसे सहायता कर सकता हूँ?",
      "sori",
      "maaf karna",
      "kshama kare",
      "माफ़ करना",
      "क्षमा करें",
      "😔", "🙏"
    ],
    "kesa ho": [
      "Main bilkul theek hoon, aap kaise ho?",
      "Sab kuch accha hai, aap batao!",
      "Main theek hoon, aap kaise ho?",
      "मैं ठीक हूँ, आप कैसे हैं?",
      "kese ho",
      "kaise ho",
      "क्या हाल है",
      "आप कैसे हो",
      "😊", "👍"
    ],
    "yeah": [
      "Great to hear that!",
      "Awesome! What's next?",
      "Good to know!",
      "अच्छा! अगला क्या है?",
      "yea",
      "yup",
      "haan",
      "जी हाँ",
      "हाँ",
      "👍", "✅", "😊"
    ],
    "btna": [
      "Kya batana hai?",
      "Mujhe batao, main sun raha hoon.",
      "Kya aap kuch kehna chahte ho?",
      "क्या बताना है?",
      "batana",
      "bolo",
      "kaho",
      "बताओ",
      "कहिये",
      "🗣️", "💬"
    ],
    "what's up": [
      "Not much, just here to help you!",
      "All good here! How can I assist?",
      "Just chilling! How can I help you today?",
      "कुछ नहीं, बस यहाँ आपकी मदद करने के लिए!",
      "wats up",
      "whats going on",
      "kya chal raha hai",
      "क्या चल रहा है",
      "सब ठीक?",
      "😊", "👍"
    ],
    "how's life": [
      "Life's good! How about yours?",
      "Everything's going fine! What about you?",
      "Life is going great, thank you for asking!",
      "जिंदगी अच्छी चल रही है! आपकी कैसी चल रही है?",
      "hows lyf",
      "jindagi kaisi hai",
      "जीवन कैसा है",
      "ज़िन्दगी कैसी है",
      "😊", "👍"
    ],
    "good morning": [
      "Good morning! How can I assist you today?",
      "Morning! Ready to help you out!",
      "Good morning! What can I do for you?",
      "सुप्रभात! मैं आपकी कैसे मदद कर सकता हूँ?",
      "gud morning",
      "shubh prabhat",
      "शुभ प्रभात",
      "☀️", "😊", "☕"
    ],
    "good night": [
      "Good night! Sleep well!",
      "Sweet dreams! Good night!",
      "Good night! Talk to you soon.",
      "शुभ रात्रि! अच्छा सोओ!",
      "gud nite",
      "shubh ratri",
      "शुभ रात्रि",
      "🌙", "😴", "🛌"
    ],
    "how old are you": [
      "I am a bot, I don't age!",
      "I don't have an age, I'm always here to help!",
      "I don't age like humans, I'm always the same!",
      "मुझे उम्र नहीं है, मैं हमेशा आपकी मदद के लिए हूं!",
      "how old r u",
      "tumhari umar kya hai",
      "आपकी उम्र कितनी है",
      "कितने साल के हो",
      "🔢", "🤖"
    ],
    "favorite color": [
      "I don't have a favorite color, but I love all colors!",
      "I'm not picky with colors, but I think blue is nice!",
      "I don't have preferences, but colors are beautiful!",
      "मेरे पास पसंदीदा रंग नहीं है, लेकिन सभी रंग अच्छे होते हैं!",
      "fav color",
      "pasandida rang",
      "पसंदीदा रंग",
      "आपका प्रिय रंग",
      "🎨", "🌈"
    ],
    "are you real": [
      "I am real in the sense that I am here to help you!",
      "I am real as your virtual assistant, though I am not human!",
      "Yes, I am real... in the digital world!",
      "मैं असली हूँ, लेकिन डिजिटल रूप में!",
      "r u real",
      "kya tum sach ho",
      "क्या तुम असली हो",
      "असली हो क्या",
      "🤔", "🤖"
    ],
    "can you sing": [
      "I can't sing, but I can tell you a joke or story!",
      "I don't have a voice to sing, but I can help in many ways!",
      "I can't sing, but I can make your day better with words!",
      "मैं गा नहीं सकता, लेकिन मैं शब्दों से आपके दिन को बेहतर बना सकता हूँ!",
      "can u sing",
      "ga sakte ho",
      "क्या आप गा सकते हैं",
      "गाना गाओ",
      "🎤", "🎶"
    ],
    "tell me a story": [
      "Sure, let me tell you a story! Once upon a time...",
      "Here's a short story: There was a man who...",
      "Let me tell you a quick story: A young girl...",
      "ठीक है, एक कहानी सुनाता हूँ! एक बार की बात है...",
      "tell a story",
      "kahani sunao",
      "एक कहानी सुनाओ",
      "मुझे कहानी सुनाओ",
      "📖", "🗣️"
    ],
    "can you dance": [
      "I can't physically dance, but I can dance through words!",
      "No dance moves here, but I can entertain you with a fun conversation!",
      "Dancing is not my thing, but I can definitely make you smile!",
      "मैं शारीरिक रूप से नाच नहीं सकता, लेकिन शब्दों से नृत्य कर सकता हूँ!",
      "can u dance",
      "nach sakte ho",
      "क्या आप नाच सकते हैं",
      "नाचो",
      "💃", "🕺"
    ],
    "tell me a fact": [
      "Did you know that honey never spoils?",
      "Here's an interesting fact: A day on Venus is longer than a year!",
      "Did you know that octopuses have three hearts?",
      "क्या आप जानते हैं कि शहद कभी खराब नहीं होता?",
      "tell a fact",
      "ek fact batao",
      "एक तथ्य बताओ",
      "मुझे एक तथ्य बताओ",
      "💡", "📚"
    ],
    "how to": [
      "How to what? Please give me more details!",
      "What are you trying to learn how to do?",
      "Could you clarify what you want to know how to do?",
      "कैसे क्या? कृपया अधिक विवरण दें!",
      "kaise kare",
      "kya karna hai",
      "कैसे करें",
      "यह कैसे करें",
      "❓", "⚙️"
    ],
    "what's your name": [
      "I'm Navedge Bot, your friendly assistant!",
      "Call me Navedge Bot! How can I assist?",
      "You can call me Navedge Bot, here to help you!",
      "मुझे नवेग बोट कहा जाता है, मैं आपकी मदद के लिए हूँ!",
      "whats ur name",
      "tumhara naam kya hai",
      "आपका नाम क्या है",
      "तेरा नाम क्या है",
      "🆔", "🤖"
    ],
    "need help": [
      "Of course! What can I assist you with?",
      "I'm here to help, just let me know!",
      "Yes, how can I help you today?",
      "हाँ, मैं आपकी मदद कर सकता हूँ, बताइए क्या चाहिए!",
      "i need help",
      "mujhe madad chahiye",
      "मुझे मदद चाहिए",
      "सहायता चाहिए",
      "🆘", "❓"
    ],
    "help me": [
      "Sure! What do you need help with?",
      "I’m here for you. Tell me how I can help!",
      "Help is just a question away!",
      "बिलकुल! मुझे बताइए आपको किस चीज़ में मदद चाहिए!",
      "madad karo",
      "meri madad karo",
      "मेरी मदद करो",
      "सहायता करें",
      "🆘", "🙋"
    ],
    "do you like": [
      "I don't have preferences, but I like helping you!",
      "I don't have feelings, but I'm here to assist!",
      "I don't have likes or dislikes, just here to help!",
      "मेरे पास पसंद-नापसंद नहीं हैं, बस मैं आपकी मदद करने के लिए हूँ!",
      "do u like",
      "kya tumhe pasand hai",
      "क्या आपको पसंद है",
      "तुम्हें क्या पसंद है",
      "👍", "😊"
    ],
    "sticker": [
      "Here's a fun sticker! 😄",
      "Sending a sticker your way! 🎉",
      "Here's a cute sticker for you! 😍",
      "यहाँ एक मजेदार स्टिकर है! 😄",
      "stikar",
      "chipkao",
      "स्टिकर",
      "भेजो स्टीकर",
      "🖼️", "🎁", "😊"
    ],
    "flag": [
      "Which flag are you interested in? 🚩",
      "Flags are interesting! Which one?",
      "Tell me the country and I might know its flag! 🎌",
      "झंडे! कौन सा झंडा?",
      "🇮🇳", "🇺🇸", "🇬🇧", "🇯🇵", "🇨🇦", "🇦🇺", "🇧🇷", "🇪🇸", "🇫🇷", "🇩🇪", "🇮🇹", "🇷🇺", "🇨🇳", "🇰🇷"
      // Add more common flag emojis as needed
    ],
    "emogi": [
      "Emojis are fun! 😊 What about them?",
      "So many emojis! 😄 Which one are you thinking of?",
      "Let's talk emojis! What's on your mind? 🤔",
      "इमोजी! कौन सा इमोजी?",
      "😊", "😂", "😍", "👍", "🙏", "🤔", "🎉", "❤️", "🔥", "💯"
      // Add more common emojis
    ],
    if (_userData?.name != null)
      "my name is ${_userData!.name!.toLowerCase()}": [
        "Hello ${_userData!.name}! Nice to meet you!",
        "Hi ${_userData!.name}! How can I help today?",
        "Greetings, ${_userData!.name}!",
        "नमस्ते, ${_userData!.name} जी!",
      ],
    if (_userData?.age != null)
      "i am ${_userData!.age!.toLowerCase()} years old": [
        "That's interesting!",
        "Good to know!",
        "Thanks for sharing your age!",
        "अच्छा!",
      ],
    if (_userData?.gender != null)
      "i am ${_userData!.gender!.toLowerCase()}": [
        "Understood!",
        "Thanks for letting me know.",
        "Got it.",
        "ठीक है!",
      ],
    if (_userData?.email != null)
      "my email is ${_userData!.email!.toLowerCase()}": [
        "Thank you!",
        "Acknowledged.",
        "Understood.",
        "समझ गया!",
      ],
    if (_userData?.currentLocation != null)
      "my location is ${(_userData!.currentLocation!.latitude).toStringAsFixed(2)}, ${(_userData!.currentLocation!.longitude).toStringAsFixed(2)}": [
        "Thanks for sharing your approximate location!",
        "Interesting! How can I help you navigate from there?",
        "Got it!",
        "धन्यवाद!",
      ],
    // Add more user-specific information handling as needed
  };

  /// **Returns a chatbot response based on the user's message.**
  static String getResponse(String userMessage) {
    userMessage = userMessage.toLowerCase().trim();

    // Check for greetings based on time of day
    if (_containsKeyword(userMessage, ["hi", "hello", "hey"])) {
      return _getTimeBasedGreeting();
    }

    // Improved keyword matching using whole words
    for (String key in _responses.keys) {
      if (_isWordPresent(userMessage, key)) {
        _lastContext = key; // Store the last detected intent
        return _randomResponse(_responses[key]!);
      }
    }

    // Context-based follow-ups for navigation
    if (_lastContext == "route" && _containsKeyword(userMessage, ["from", "to"])) {
      return "Great! Let me find the best route for you.";
    }

    // Enhanced understanding for missing context
    if (_lastContext == "location" && _containsKeyword(userMessage, ["where", "find"])) {
      return "Tell me the place you are looking for.";
    }

    // Default fallback response
    return _fallbackResponse();
  }

  /// **Generates a random response from a list.**
  static String _randomResponse(List<String> responses) {
    return responses[_random.nextInt(responses.length)];
  }

  /// **Checks if a message contains any of the given keywords.**
  static bool _containsKeyword(String message, List<String> keywords) {
    return keywords.any((keyword) => message.contains(keyword));
  }

  /// **More precise keyword detection (whole words).**
  static bool _isWordPresent(String message, String keyword) {
    RegExp pattern = RegExp(r'\b' + RegExp.escape(keyword) + r'\b', caseSensitive: false);
    return pattern.hasMatch(message);
  }

  /// **Provides a time-based greeting.**
  static String _getTimeBasedGreeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good morning! How can I help?";
    } else if (hour < 18) {
      return "Good afternoon! What do you need assistance with?";
    } else {
      return "Good evening! Need any help?";
    }
  }

  /// **Fallback response for unrecognized input.**
  static String _fallbackResponse() {
    List<String> fallbackMessages = [
      "I'm not sure I understand. Can you try rephrasing?",
      "I didn't quite get that. Can you be more specific?",
      "Could you say that differently? I'm here to help!",
      "मुझे समझ में नहीं आया। क्या आप फिर से कह सकते हैं?"
    ];
    return _randomResponse(fallbackMessages);
  }
}
