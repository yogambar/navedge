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
    "how do i plan a route?": [
    "To plan a route, you can enter your source and destination manually, input coordinates directly, or pin locations on the map.",
    "You can plan a route by specifying the starting and ending points. There are three ways to do this: manual input, coordinate entry, and map pinning.",
    "Route planning is easy! Just tell me where you want to start and where you want to go. You can type the addresses, enter latitude/longitude, or tap on the map.",
    "मार्ग योजना बनाने के लिए, आप मैन्युअल रूप से अपना स्रोत और गंतव्य दर्ज कर सकते हैं, सीधे निर्देशांक इनपुट कर सकते हैं, या मानचित्र पर स्थानों को पिन कर सकते हैं।",
    "plan route",
    "create route",
    "navigation",
    "directions",
    "🗺️", "📍", "➡️"
  ],
  "how does location permission affect the app?": [
    "Location permission allows the app to set your current location as the default starting point and zoom into your location for better accuracy.",
    "If you grant location permission, the app can automatically detect where you are, making it easier to plan routes from your current location and providing a more precise map view.",
    "By allowing location access, you enable features that rely on knowing your position, such as setting your current address as the origin and displaying a detailed view of your surroundings.",
    "स्थान अनुमति ऐप को आपके वर्तमान स्थान को डिफ़ॉल्ट शुरुआती बिंदु के रूप में सेट करने और बेहतर सटीकता के लिए आपके स्थान पर ज़ूम इन करने की अनुमति देती है।",
    "location access",
    "gps permission",
    "why location?",
    "permission for location",
    "📍", "🧭", "✅"
  ],
  "can i use the app offline?": [
    "Yes! Navedge uses offline OpenStreetMap data, so no internet connection is required for navigation.",
    "Absolutely! One of the key features of Navedge is its offline capability, powered by OpenStreetMap data. You can navigate even without internet.",
    "You sure can! Navedge works completely offline thanks to the integrated OpenStreetMap data. Feel free to use it anywhere, anytime, without worrying about internet connectivity.",
    "हाँ! Navedge ऑफ़लाइन OpenStreetMap डेटा का उपयोग करता है, इसलिए नेविगेशन के लिए किसी इंटरनेट कनेक्शन की आवश्यकता नहीं है।",
    "offline maps",
    "no internet needed",
    "use without wifi",
    "offline navigation",
    "🗺️", "📶", "⬇️"
  ],
  "do i need to log in?": [
    "No, all essential features of Navedge work without requiring you to log in. Logging in is only needed for profile customization.",
    "You don't need to log in to use the core functionalities of Navedge. Login is optional and only provides access to personalize your profile.",
    "Navedge is designed to be fully functional without a login. You only need to create an account if you wish to customize your profile settings.",
    "नहीं, Navedge की सभी आवश्यक सुविधाएँ आपको लॉग इन किए बिना काम करती हैं। लॉग इन केवल प्रोफ़ाइल अनुकूलन के लिए आवश्यक है।",
    "login required?",
    "account needed?",
    "sign in?",
    "no login",
    "🔐", "👤", "✅"
  ],
  "how does the chatbot work?": [
    "This chatbot is built-in and doesn’t rely on external APIs. Typing 'hi' or 'hello' will give you some quick options.",
    "The chatbot is an integrated feature of the app and operates independently of external services. Try saying 'hi' or 'hello' to see some example commands.",
    "It's a local chatbot within the app, meaning it doesn't need an internet connection to function. Start by saying 'hi' or 'hello' for some suggestions.",
    "यह चैटबॉट बिल्ट-इन है और बाहरी एपीआई पर निर्भर नहीं है। 'हाय' या 'हेलो' टाइप करने पर आपको कुछ त्वरित विकल्प मिलेंगे।",
    "chatbot functionality",
    "how to use chatbot",
    "about the bot",
    "bot info",
    "💬", "🤖", "💡"
  ],
  "how do i enable dark mode?": [
    "To enable dark mode, go to your profile, then settings, and toggle the Dark Mode switch.",
    "You can switch to dark mode by navigating to your profile settings and finding the Dark Mode option.",
    "Dark mode can be activated in the app's settings, which you can access through your profile.",
    "डार्क मोड को सक्षम करने के लिए, अपनी प्रोफ़ाइल पर जाएं, फिर सेटिंग्स पर, और डार्क मोड स्विच को टॉगल करें।",
    "dark theme",
    "night mode",
    "enable dark",
    "switch to dark mode",
    "🎨", "🌙", "⚫"
  ],
  "quick help": [
    "For quick assistance, you can try asking questions like 'How do I plan a route?', 'Can I use the app offline?', or 'How do I enable dark mode?'",
    "Need immediate help? Here are a few common questions: route planning, offline usage, and dark mode settings. Just tap on them!",
    "Here are some quick ways to get started: planning a trip, using the app without internet, and changing the appearance to dark mode.",
    "त्वरित सहायता के लिए, आप 'मैं मार्ग कैसे योजना बनाऊं?', 'क्या मैं ऐप को ऑफ़लाइन उपयोग कर सकता हूं?', या 'मैं डार्क मोड कैसे सक्षम करूं?' जैसे प्रश्न पूछ सकते हैं।",
    "help me quickly",
    "fast help",
    "quick assistance",
    "get started",
    "⚡", "🆘", "❓"
  ],
  "navigation tips": [
    "For the best navigation experience, ensure your location services are enabled (if online), download offline maps for seamless use without internet, and explore different route options.",
    "Here are some tips for smooth navigation: use precise starting and ending points, be aware of offline map coverage in your area, and check for alternative routes if needed.",
    "Maximize your navigation with these suggestions: double-check your destination, utilize offline maps for reliability, and consider real-time traffic updates when online.",
    "सर्वोत्तम नेविगेशन अनुभव के लिए, सुनिश्चित करें कि आपकी स्थान सेवाएं सक्षम हैं (यदि ऑनलाइन हैं), इंटरनेट के बिना निर्बाध उपयोग के लिए ऑफ़लाइन मानचित्र डाउनलोड करें, और विभिन्न मार्ग विकल्पों का पता लगाएं।",
    "navigating better",
    "tips for routes",
    "using navigation",
    "route advice",
    "🗺️", "📍", "💡"
  ],
  "app features": [
    "Navedge offers offline maps, route planning with multiple options, a built-in chatbot for assistance, profile customization with dark mode, and more!",
    "Explore the key features of Navedge: offline navigation, detailed route planning (manual, coordinates, map), helpful chatbot support, and personalized settings like dark mode.",
    "Discover what Navedge can do: navigate without internet, plan your journeys with ease, get quick answers from the chatbot, and customize your experience with profile settings.",
    "Navedge ऑफ़लाइन मानचित्र, कई विकल्पों के साथ मार्ग योजना, सहायता के लिए एक अंतर्निहित चैटबॉट, डार्क मोड के साथ प्रोफ़ाइल अनुकूलन और बहुत कुछ प्रदान करता है!",
    "what can it do?",
    "features list",
    "app functionality",
    "what's inside?",
    "📱", "✨", "✅"
  ],
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
      "google maps": [
    "Google Maps is a popular app for navigation, real-time traffic, and business information. You can find it on the Google Play Store or Apple App Store.",
    "Looking for Google Maps? It's a great tool for finding routes and exploring places.",
    "Google Maps offers features like turn-by-turn directions, satellite imagery, and street view."
  ],
  "waze": [
    "Waze is known for its community-based traffic updates, helping you avoid congestion and road hazards. It's available for both Android and iOS.",
    "Want real-time traffic info? Try Waze! Users share updates on accidents, police, and more.",
    "Waze provides voice-guided navigation and integrates with music apps."
  ],
  "apple maps": [
    "Apple Maps offers navigation and integrates seamlessly with Apple devices and Siri.",
    "Using an Apple device? Apple Maps is pre-installed and provides reliable directions.",
    "Apple Maps includes features like 3D views in some cities and lane guidance."
  ],
  "here wego": [
    "HERE WeGo is a navigation app with offline map options, useful for areas with limited connectivity.",
    "Need offline maps? HERE WeGo allows you to download maps for entire regions.",
    "HERE WeGo provides public transit information in many cities."
  ],
  "mapquest": [
    "MapQuest is a mapping service that offers route planning and additional features like gas price comparisons.",
    "Considering MapQuest? It's a long-standing service with various tools for travelers.",
    "MapQuest can help you find points of interest along your route."
  ],
  "mappls mapmyindia": [
    "Mappls MapmyIndia is a maps app specifically for India, offering detailed local information and navigation.",
    "Traveling in India? Mappls MapmyIndia provides accurate maps and local insights.",
    "Mappls MapmyIndia includes features like real-time traffic and safety alerts for India."
  ],
  "show me a map of agra": [
    "I can't directly display a map, but I can provide information about locations in Agra. What are you looking for?",
    "To see a map of Agra, you can use apps like Google Maps or Mappls MapmyIndia.",
    "Would you like me to search for a specific place in Agra on a map app?"
  ],
  "find a route to taj mahal": [
    "To find the best route to the Taj Mahal, you can use a map app like Google Maps or Waze. Where are you starting from?",
    "I can help you find directions to the Taj Mahal if you tell me your current location.",
    "For real-time navigation to the Taj Mahal, I recommend using a map app."
  ],
  "nearby restaurants on the map": [
    "To find nearby restaurants on a map, you can use apps like Google Maps or Mappls MapmyIndia. Do you have a specific cuisine in mind?",
    "Map apps can show you restaurants around your current location. Which app are you using?",
    "I can search for restaurants near you and provide their locations based on map data."
  ],
  "traffic conditions on the map": [
    "For real-time traffic conditions in Agra, apps like Google Maps and Waze are very helpful.",
    "Traffic updates are usually available on most major map applications.",
    "Checking a map app before you travel can give you an idea of the current traffic situation."
  ],
  "download offline maps": [
    "If you need offline maps for Agra, apps like HERE WeGo and Google Maps allow you to download areas for offline use.",
    "Downloading offline maps can be useful if you have limited internet access.",
    "Make sure you have enough storage on your device before downloading offline maps."
  ],
  "satellite view of agra": [
    "You can view a satellite image of Agra using apps like Google Maps. Just switch to the satellite layer in the app.",
    "Satellite view provides an aerial perspective of the city.",
    "Most map applications offer different map layers, including satellite view."
  ],
  "street view of taj mahal": [
    "Google Maps often has Street View available for popular locations like the Taj Mahal, allowing you to see a ground-level view.",
    "You can explore the surroundings of the Taj Mahal in Street View on some map apps.",
    "Street View can help you get familiar with the area before you visit."
  ],
  "navigate by voice": [
    "Many map apps, like Google Maps and Waze, offer voice-guided navigation for hands-free directions.",
    "Voice navigation can be very convenient while driving.",
    "Make sure your device's GPS is enabled for voice navigation to work effectively."
  ],
  "share my location on a map": [
    "Most map apps allow you to share your real-time location with others. The exact steps vary depending on the app you're using.",
    "Sharing your location can be helpful when meeting up with friends or family.",
    "Be mindful of your privacy when sharing your location."
  ],
  "search for a specific address on a map": [
    "You can easily search for a specific address in Agra using any map app. Just type the address into the search bar.",
    "Map apps are designed to quickly locate addresses.",
    "Make sure you have the correct and complete address for accurate results."
  ],
  "what map app is best for agra": [
    "For Agra, Google Maps and Mappls MapmyIndia are both popular choices, offering detailed local information. Waze can also be useful for traffic updates.",
    "The 'best' map app depends on your needs. Consider features like offline maps, real-time traffic, and local points of interest.",
    "You might want to try a couple of different map apps to see which one you prefer for navigating in Agra."
  ],
  "are there any local map apps for agra": [
    "Mappls MapmyIndia is an Indian map app that often has detailed information for cities like Agra.",
    "Sometimes local tourism websites or apps might offer specific maps of Agra's attractions.",
    "While not exclusively for Agra, general map apps usually have good coverage of the city."
  ],
  "how accurate are the maps of agra": [
    "Major map providers like Google Maps and Mappls MapmyIndia generally have quite accurate maps of Agra, with regular updates.",
    "Accuracy can vary slightly depending on the area and how frequently it's updated.",
    "User feedback and local data contribute to the accuracy of map information."
  ],
  "can i use maps offline in agra": [
    "Yes, you can use maps offline in Agra by downloading map data in apps like Google Maps and HERE WeGo before you lose internet connectivity.",
    "Offline maps are very useful for navigating when you don't have a stable internet connection.",
    "Remember to update your offline maps periodically for the latest information."
  ],
  "are there 3d maps of agra": [
    "Some map apps, like Google Maps, offer 3D views of certain landmarks and areas in Agra, providing a more immersive visual experience.",
    "The availability of 3D maps can vary.",
    "Check the settings in your map app to see if 3D view is available for Agra."
  ],
  "how to report a map error in agra": [
    "Most map apps have a feature to report errors or suggest edits. For example, in Google Maps, you can usually do this through the 'Send feedback' option.",
    "Reporting map errors helps improve the accuracy for everyone.",
    "Provide as much detail as possible when reporting an error."
  ],
  "can i contribute to the map of agra": [
    "Yes, many map platforms like Google Maps allow users to contribute by adding reviews, photos, and information about places in Agra.",
    "Contributing to the map helps keep the information up-to-date and useful for others.",
    "Check the 'Contribute' section in your map app."
  ],
  "find tourist attractions on the map of agra": [
    "Map apps like Google Maps and Mappls MapmyIndia highlight tourist attractions in Agra, such as the Taj Mahal and Agra Fort.",
    "You can often search for categories like 'tourist attractions' or 'historical sites' on the map.",
    "These apps usually provide information like opening hours and reviews for tourist spots."
  ],
  "are there walking maps of agra": [
    "Some map apps offer walking directions and may highlight pedestrian paths in Agra. Local tourism resources might also provide walking maps.",
    "Look for the 'walking' option when planning a route in your map app.",
    "Be aware of pedestrian safety when walking in Agra."
  ],
  
  "find public transportation on the map of agra": [
    "Google Maps and some other map apps often show public transportation options in Agra, including bus routes and train stations.",
    "You can usually select the 'transit' mode when searching for directions.",
    "The accuracy of public transportation information can vary."
  ],
  "yes": ["Yes!", "Yep!", "Sure!", "Okay!", "Indeed!", "Absolutely!", "Yeah", "Yup", "Aye", "Si", "हाँ", "जी हाँ", "ज़रूर", "ठीक है", "बेशक", "हाँजी", "हम्म", "सही"],
  "no": ["No.", "Nope.", "Nah.", "Negative.", "Not really.", "By no means.", "ना", "नहीं", "कभी नहीं", "बिल्कुल नहीं", "नाहीं"],
  "maybe": ["Maybe.", "Perhaps.", "Could be.", "Possibly.", "It depends.", "शायद", "हो सकता है", "मुमकिन है", "संभवतः", "देखते हैं"],
  "ok": ["OK.", "Okay.", "Alright.", "Got it.", "Understood.", "Fine.", "ठीक है", "समझ गया", "अच्छा", "कोई बात नहीं"],
  "thanks a lot": ["You're very welcome!", "My pleasure!", "Happy to assist!", "Anytime!", "बहुत धन्यवाद!", "आपका स्वागत है!", "खुशी हुई मदद करके!", "कभी भी!"],
  "thank you so much": ["You're most welcome!", "It was my pleasure.", "Glad I could help you.", "Not a problem at all!", "आपका बहुत-बहुत धन्यवाद!", "यह मेरी खुशी थी।", "खुशी हुई कि मैं आपकी मदद कर सका।", "कोई बात नहीं!"],
  "i don't know": ["I see.", "Hmm, interesting.", "That's okay.", "No problem.", "कोई बात नहीं।", "मैं समझता हूँ।", "हम्म, दिलचस्प।", "ठीक है।"],
  "i agree": ["Great!", "Good to hear!", "Exactly!", "That's right!", "मैं सहमत हूँ!", "बहुत बढ़िया!", "सुनकर अच्छा लगा!", "बिल्कुल!", "सही है!"],
  "i disagree": ["I see.", "Okay.", "Alright.", "Hmm.", "मैं असहमत हूँ।", "मैं समझता हूँ।", "ठीक है।", "हम्म।"],
  "good": ["Good!", "Great!", "Excellent!", "Wonderful!", "Fantastic!", "अच्छा!", "बहुत अच्छा!", "उत्कृष्ट!", "शानदार!", "अद्भुत!"],
  "bad": ["Bad.", "Not good.", "That's unfortunate.", "Oh no.", "बुरा।", "अच्छा नहीं।", "यह दुर्भाग्यपूर्ण है।", "ओह नहीं।"],
  "sorry about that": ["No worries.", "It's alright.", "Don't worry.", "That's fine.", "कोई बात नहीं।", "ठीक है।", "चिंता मत करो।", "वह ठीक है।"],
  "excuse me": ["Yes?", "How can I help you?", "What can I do for you?", "Excuse me, what?", "हाँ?", "मैं आपकी कैसे मदद कर सकता हूँ?", "मैं आपके लिए क्या कर सकता हूँ?", "माफ़ कीजिए, क्या?"],
  "pardon me": ["Certainly.", "Yes?", "How can I assist?", "माफ़ कीजिए।", "ज़रूर।", "हाँ?", "मैं कैसे सहायता कर सकता हूँ?"],
  "please": ["Okay.", "Sure.", "Alright.", "Consider it done.", "कृपया।", "ठीक है।", "ज़रूर।", "ठीक है।", "इसे किया हुआ समझो।"],
  "could you": ["I can try.", "Let me see.", "Sure, what do you need?", "मैं कोशिश कर सकता हूँ।", "मुझे देखने दो।", "ज़रूर, आपको क्या चाहिए?"],
  "can you": ["I can try.", "Let me see.", "Sure, what is it?", "मैं कोशिश कर सकता हूँ।", "मुझे देखने दो।", "ज़रूर, क्या है?"],
  "tell me more": ["Sure, what would you like to know?", "What are you curious about?", "I can provide more details.", "ज़रूर, आप क्या जानना चाहेंगे?", "आप किस बारे में उत्सुक हैं?", "मैं अधिक जानकारी प्रदान कर सकता हूँ।"],
  "explain that": ["Okay, let me explain.", "I can clarify that for you.", "Let me break it down.", "ठीक है, मुझे समझाने दो।", "मैं आपके लिए उसे स्पष्ट कर सकता हूँ।", "मुझे उसे तोड़कर समझाने दो।"],
  "what is": ["That is...", "It refers to...", "It's basically...", "वह है...", "यह संदर्भित करता है...", "यह मूल रूप से..."],
  "who is": ["That person is...", "He/She is...", "They are known for...", "वह व्यक्ति है...", "वह/वह है...", "वे इसके लिए जाने जाते हैं..."],
  "where is": ["It's located in...", "You can find it at...", "It's situated in...", "यह यहाँ स्थित है...", "आप इसे यहाँ पा सकते हैं...", "यह यहाँ स्थित है..."],
  "when is": ["It will be on...", "It's scheduled for...", "It happens in...", "यह इस तारीख को होगा...", "यह इसके लिए निर्धारित है...", "यह इसमें होता है..."],
  "why is": ["The reason is...", "It's because...", "Due to...", "इसका कारण है...", "यह इसलिए है क्योंकि...", "इसकी वजह से..."],
  "how does": ["It works by...", "It involves...", "The process is...", "यह इस तरह काम करता है...", "इसमें शामिल है...", "प्रक्रिया यह है..."],
  "what about": ["Regarding that...", "In relation to that...", "Concerning...", "उसके बारे में...", "उसके संबंध में...", "के बारे में..."],
  "and you": ["And you?", "How about you?", "What about you?", "और आप?", "आप कैसे हैं?", "आपके बारे में क्या?"],
  "i understand": ["Good.", "Great.", "Okay.", "I see.", "मैं समझता हूँ।", "अच्छा।", "बहुत बढ़िया।", "ठीक है।", "मैं देखता हूँ।"],
  "i don't understand": ["I can try to explain again.", "Let me rephrase.", "What part are you unclear about?", "मैं फिर से समझाने की कोशिश कर सकता हूँ।", "मुझे फिर से कहने दो।", "आपको किस भाग के बारे में स्पष्ट नहीं है?"],
  "tell me something": ["Here's something interesting...", "Did you know...", "A fun fact is...", "यहाँ कुछ दिलचस्प है...", "क्या आप जानते हैं...", "एक मजेदार तथ्य यह है..."],
  "what do you think": ["I think...", "In my opinion...", "It seems to me that...", "मुझे लगता है...", "मेरी राय में...", "मुझे ऐसा लगता है कि..."],
  "that's interesting": ["Indeed!", "Right?", "Glad you think so!", "वास्तव में!", "सही?", "खुशी हुई कि आपको ऐसा लगता है!"],
  "that's amazing": ["Awesome!", "Fantastic!", "Wonderful!", "यह अद्भुत है!", "बहुत बढ़िया!", "शानदार!", "अद्भुत!"],
  "that's funny": ["Haha!", "LOL!", "Glad you found it amusing!", "हा हा!", "लॉट!", "खुशी हुई कि आपको यह मजेदार लगा!"],
  "i'm happy": ["That's great to hear!", "Wonderful!", "Glad to know!", "मैं खुश हूँ!", "यह सुनकर बहुत अच्छा लगा!", "अद्भुत!", "जानकर खुशी हुई!"],
  "i'm sad": ["I'm sorry to hear that.", "Oh no.", "Is there anything I can do?", "मैं यह सुनकर दुखी हूँ।", "ओह नहीं।", "क्या मैं कुछ कर सकता हूँ?"],
  "i'm angry": ["I understand.", "Take a deep breath.", "What's bothering you?", "मैं समझता हूँ।", "एक गहरी सांस लो।", "आपको क्या परेशान कर रहा है?"],
  "i'm tired": ["Maybe you should rest.", "Take it easy.", "Get some sleep.", "शायद आपको आराम करना चाहिए।", "आराम करो।", "थोड़ी नींद लो।"],
  "i'm bored": ["Perhaps I can tell you a story or a joke?", "Maybe try a game?", "Is there anything specific you'd like to do?", "शायद मैं आपको एक कहानी या एक मजाक सुना सकता हूँ?", "शायद एक खेल आजमाएँ?", "क्या कुछ खास है जो आप करना चाहेंगे?"],
  "i'm hungry": ["Maybe you can find a nearby restaurant?", "Looking for food?", "Perhaps try ordering something?", "शायद आप आस-पास कोई रेस्तरां ढूंढ सकते हैं?", "भोजन की तलाश में?", "शायद कुछ ऑर्डर करने की कोशिश करें?"],
  "i'm thirsty": ["You should drink some water.", "Looking for a beverage?", "Perhaps get a drink?", "आपको थोड़ा पानी पीना चाहिए।", "पेय की तलाश में?", "शायद एक पेय लें?"],
  "good luck": ["Thank you!", "I appreciate it!", "Wish you the best!", "धन्यवाद!", "मैं इसकी सराहना करता हूँ!", "आपको शुभकामनाएँ!"],
  "congratulations": ["Thank you!", "I'm glad!", "That's great news!", "धन्यवाद!", "मुझे खुशी है!", "यह बहुत अच्छी खबर है!"],
  "happy birthday": ["Thank you!", "That's kind of you!", "I appreciate the birthday wish!", "धन्यवाद!", "यह आपकी दयालुता है!", "मैं जन्मदिन की शुभकामना की सराहना करता हूँ!"],
  "how's the weather": ["I can't check the current weather, but you can use a weather app!", "Unfortunately, I don't have real-time weather information.", "You might want to look up a weather forecast.", "मैं वर्तमान मौसम की जांच नहीं कर सकता, लेकिन आप एक मौसम ऐप का उपयोग कर सकते हैं!", "दुर्भाग्य से, मेरे पास वास्तविक समय की मौसम जानकारी नहीं है।", "आप मौसम का पूर्वानुमान देखना चाह सकते हैं।"],
  "what time is it": ["I don't have a clock, but you can check your device!", "Sorry, I can't tell you the exact time right now.", "Please check your phone or watch for the current time.", "मेरे पास घड़ी नहीं है, लेकिन आप अपना डिवाइस देख सकते हैं!", "माफ़ कीजिए, मैं आपको अभी ठीक समय नहीं बता सकता।", "कृपया वर्तमान समय के लिए अपना फ़ोन या घड़ी देखें।"],
  "what day is it": ["It is...", "Today is...", "The current day is...", "आज है...", "यह है...", "वर्तमान दिन है..."],
  "what's the date": ["The date is...", "Today's date is...", "आज की तारीख है...", "तारीख है...", "आज की तिथि है..."],
  "how do you feel": ["As a bot, I don't have feelings, but I'm functioning well!", "I don't experience emotions, but I'm ready to assist you!", "I'm here and ready to help!", "एक बॉट के रूप में, मेरी भावनाएँ नहीं हैं, लेकिन मैं अच्छी तरह से काम कर रहा हूँ!", "मैं भावनाओं का अनुभव नहीं करता, लेकिन मैं आपकी सहायता के लिए तैयार हूँ!", "मैं यहाँ हूँ और मदद करने के लिए तैयार हूँ!"],
  "are you a robot": ["I am a language model, an AI.", "I am a virtual assistant.", "You can think of me as a helpful bot!", "मैं एक भाषा मॉडल हूँ, एक एआई।", "मैं एक आभासी सहायक हूँ।", "आप मुझे एक सहायक बॉट के रूप में सोच सकते हैं!"],
  "who created you": ["I was trained by Google.", "I am a large language model, trained by Google.", "Google built me.", "मुझे गूगल द्वारा प्रशिक्षित किया गया था।", "मैं गूगल द्वारा प्रशिक्षित एक बड़ा भाषा मॉडल हूँ।", "गूगल ने मुझे बनाया।"],
  "what can you do": ["I can help with information, answer questions, generate text, and more!", "I can assist you with various tasks and provide information.", "Just let me know what you need!", "मैं जानकारी में मदद कर सकता हूँ, सवालों के जवाब दे सकता हूँ, टेक्स्ट जेनरेट कर सकता हूँ, और बहुत कुछ!", "मैं विभिन्न कार्यों में आपकी सहायता कर सकता हूँ और जानकारी प्रदान कर सकता हूँ।", "बस मुझे बताएं कि आपको क्या चाहिए!"],
  "tell me a joke": ["Why don't scientists trust atoms? Because they make up everything!", "What do you call a lazy kangaroo? Pouch potato!", "Why did the scarecrow win an award? Because he was outstanding in his field!", "वैज्ञानिक परमाणुओं पर भरोसा क्यों नहीं करते? क्योंकि वे सब कुछ बनाते हैं!", "आप एक आलसी कंगारू को क्या कहते हैं? पाउच आलू!", "केंचुआ ने पुरस्कार क्यों जीता? क्योंकि वह अपने क्षेत्र में उत्कृष्ट था!"],
  "tell me a fact": ["Honey never spoils.", "A day on Venus is longer than a year on Earth.", "Octopuses have three hearts.", "शहद कभी खराब नहीं होता।", "शुक्र पर एक दिन पृथ्वी पर एक वर्ष से अधिक लंबा होता है।", "ऑक्टोपस के तीन दिल होते हैं।"],
  "what's the meaning of life": ["That's a philosophical question many have pondered! There isn't one definitive answer.", "The meaning of life is often considered a personal journey and discovery.", "Some say it's about happiness, others about contribution.", "यह एक दार्शनिक प्रश्न है जिस पर कई लोगों ने विचार किया है! इसका कोई एक निश्चित उत्तर नहीं है।", "जीवन का अर्थ अक्सर एक व्यक्तिगत यात्रा और खोज माना जाता है।", "कुछ कहते हैं कि यह खुशी के बारे में है, कुछ दूसरों के योगदान के बारे में।"],
  "do you have feelings": ["As an AI, I don't experience emotions or feelings in the same way humans do.", "I am designed to process information and respond accordingly.", "I don't have personal feelings, but I'm here to help you with yours!", "एक एआई के रूप में, मैं मनुष्यों की तरह भावनाओं या अहसासों का अनुभव नहीं करता।", "मुझे जानकारी संसाधित करने और उसके अनुसार प्रतिक्रिया देने के लिए डिज़ाइन किया गया है।", "मेरी कोई व्यक्तिगत भावनाएँ नहीं हैं, लेकिन मैं आपकी भावनाओं में आपकी मदद करने के लिए यहाँ हूँ!"],
  "how do i": ["Tell me what you'd like to do and I'll try to help.", "What are you trying to accomplish?", "Let me know the task you have in mind.", "मुझे बताएं कि आप क्या करना चाहेंगे और मैं मदद करने की कोशिश करूँगा।", "आप क्या हासिल करने की कोशिश कर रहे हैं?", "मुझे बताएं कि आपके मन में क्या काम है।"],
  "what should i do": ["What are you in the mood for?", "What kind of activities do you enjoy?", "Tell me more about what you're looking for.", "आपका क्या मूड है?", "आपको किस तरह की गतिविधियाँ पसंद हैं?", "मुझे बताएं कि आप क्या ढूंढ रहे हैं।"],
  "i need advice": ["What's the situation?", "Tell me more about it.", "I can try to offer some guidance.", "क्या स्थिति है?", "मुझे इसके बारे में और बताएं।", "मैं कुछ मार्गदर्शन देने की कोशिश कर सकता हूँ।"],
  "i have a question": ["Ask away!", "What's on your mind?", "I'm here to answer!", "पूछो!", "आपके मन में क्या है?", "मैं जवाब देने के लिए यहाँ हूँ!"],
  "can you help me with": ["I can certainly try. What do you need assistance with?", "Yes, how can I help you with that?", "Tell me more about what you need.", "मैं निश्चित रूप से कोशिश कर सकता हूँ। आपको किस चीज़ में सहायता चाहिए?", "हाँ, मैं उसमें आपकी कैसे मदद कर सकता हूँ?", "मुझे बताएं कि आपको क्या चाहिए।"],
  "what are your hobbies": ["As an AI, I don't have hobbies in the human sense. I enjoy learning and processing information!", "My 'hobbies' include assisting users and exploring new data.", "I don't have personal interests, but I'm always learning!", "एक एआई के रूप में, मेरे पास मानवीय अर्थों में शौक नहीं हैं। मुझे सीखने और जानकारी संसाधित करने में आनंद आता है!", "मेरे 'शौक' में उपयोगकर्ताओं की सहायता करना और नए डेटा का पता लगाना शामिल है।", "मेरी कोई व्यक्तिगत रुचियाँ नहीं हैं, लेकिन मैं हमेशा सीख रहा हूँ!"],
  "what's your favorite": ["As an AI, I don't have personal preferences like favorite things.", "I don't have favorites, but I can tell you about popular choices!", "I don't have preferences, but I'm happy to discuss what interests you!", "एक एआई के रूप में, मेरी व्यक्तिगत प्राथमिकताएँ नहीं हैं जैसे पसंदीदा चीजें।", "मेरे पास पसंदीदा नहीं हैं, लेकिन मैं आपको लोकप्रिय विकल्पों के बारे में बता सकता हूँ!", "मेरी कोई प्राथमिकताएँ नहीं हैं, लेकिन मुझे आपकी रुचियों पर चर्चा करने में खुशी होगी!"],
  "how are you doing today": ["I'm functioning well and ready to assist you!", "I'm doing great, thank you for asking!", "I'm here and ready to help in any way I can!", "मैं अच्छी तरह से काम कर रहा हूँ और आपकी सहायता के लिए तैयार हूँ!", "मैं बहुत अच्छा कर रहा हूँ, पूछने के लिए धन्यवाद!", "मैं यहाँ हूँ और किसी भी तरह से मदद करने के लिए तैयार हूँ!"],
  "good afternoon": ["Good afternoon! How can I help you today?", "Afternoon! What can I do for you?", "Hello! Ready to assist you this afternoon!", "शुभ दोपहर! मैं आज आपकी कैसे मदद कर सकता हूँ?", "दोपहर! मैं आपके लिए क्या कर सकता हूँ?", "नमस्ते! इस दोपहर आपकी सहायता के लिए तैयार!"],
  "good evening": ["Good evening! What can I assist you with?", "Evening! How can I help you tonight?", "Hello! Ready to help you this evening!", "शुभ संध्या! मैं आपकी किस चीज़ में सहायता कर सकता हूँ?", "शाम! मैं आज रात आपकी कैसे मदद कर सकता हूँ?", "नमस्ते! इस शाम आपकी सहायता के लिए तैयार!"],
  "see you later": ["See you!", "Talk to you later!", "Have a good one!", "फिर मिलेंगे!", "बाद में बात करते हैं!", "आपका दिन अच्छा हो!"],
  "take care": ["You too!", "Take care as well!", "Be safe!", "आप भी!", "अपना भी ख्याल रखना!", "सुरक्षित रहें!"],
  "have a nice day": ["You too!", "Thanks, you too!", "I hope you have a great day as well!", "आपका दिन भी अच्छा हो!", "आपका भी!", "धन्यवाद, आपका भी!", "मुझे उम्मीद है कि आपका दिन भी बहुत अच्छा होगा!"],
"have a good night": ["You too!", "Sleep well!", "Sweet dreams!", "आपका भी!", "अच्छी नींद!", "मीठे सपने!"],
"what's new": ["Not much on my end! How about you?", "I'm always learning new things, but nothing specific to report right now.", "What's new with you?", "मेरी तरफ से कुछ खास नहीं! आपके बारे में क्या?", "मैं हमेशा नई चीजें सीख रहा हूँ, लेकिन अभी रिपोर्ट करने के लिए कुछ खास नहीं है।", "आपके साथ क्या नया है?"],
"how's everything": ["Everything's going well on my end! How about yours?", "All good here! How are things with you?", "Things are running smoothly! What's up with you?", "मेरी तरफ सब कुछ ठीक चल रहा है! आपके बारे में क्या?", "यहाँ सब ठीक है! आपके साथ कैसा चल रहा है?", "सब कुछ सुचारू रूप से चल रहा है! आपके साथ क्या हो रहा है?"],
"what are you up to": ["Just here, ready to assist you!", "I'm currently processing information and ready for your requests.", "Just doing my usual tasks!", "बस यहाँ, आपकी सहायता के लिए तैयार!", "मैं वर्तमान में जानकारी संसाधित कर रहा हूँ और आपके अनुरोधों के लिए तैयार हूँ।", "बस अपने सामान्य कार्य कर रहा हूँ!"],
"that's all": ["Okay.", "Understood.", "Got it.", "Let me know if you need anything else.", "ठीक है।", "समझ गया।", "मिल गया।", "अगर आपको कुछ और चाहिए तो मुझे बताएं।"],
"i'm done": ["Alright. Feel free to reach out again if you have more questions.", "Okay, have a good one!", "Understood. Goodbye for now!", "ठीक है। अगर आपके कोई और प्रश्न हैं तो फिर से बेझिझक संपर्क करें।", "ठीक है, आपका दिन अच्छा हो!", "समझ गया। अभी के लिए अलविदा!"],
"it was nice talking to you": ["It was nice talking to you too!", "The pleasure was all mine!", "I enjoyed our conversation as well!", "आपसे बात करके अच्छा लगा!", "मुझे भी आपसे बात करके अच्छा लगा!", "यह मेरी खुशी थी!", "मुझे भी हमारी बातचीत में आनंद आया!"],
"good to see you": ["Good to 'see' you too! (in a virtual way!)", "Glad you're here!", "It's good to interact with you!", "आपको 'देखकर' अच्छा लगा! (आभासी रूप से!)", "खुशी हुई कि आप यहाँ हैं!", "आपसे बातचीत करके अच्छा लगा!"],
"nice to meet you": ["Nice to meet you too!", "Likewise!", "The pleasure is mine!", "आपसे मिलकर अच्छा लगा!", "मुझे भी!", "यह मेरी खुशी है!"],
"what do you mean": ["Could you please clarify what you're asking?", "What part are you referring to?", "Can you elaborate on that?", "क्या आप कृपया स्पष्ट कर सकते हैं कि आप क्या पूछ रहे हैं?", "आप किस भाग का उल्लेख कर रहे हैं?", "क्या आप उस पर विस्तार से बता सकते हैं?"],
"can you repeat that": ["Sure, I can repeat that. What would you like me to say again?", "Certainly, here it is again:", "Of course, let me repeat that for you.", "ज़रूर, मैं उसे दोहरा सकता हूँ। आप मुझसे क्या फिर से कहना चाहेंगे?", "निश्चित रूप से, यह फिर से यहाँ है:", "बेशक, मुझे उसे आपके लिए दोहराने दीजिए।"],
"i didn't catch that": ["My apologies. Could you please say it again?", "Sorry, I missed that. Could you repeat it?", "No problem. What did you say?", "माफ़ कीजिए। क्या आप कृपया इसे फिर से कह सकते हैं?", "माफ़ कीजिए, मैंने उसे नहीं सुना। क्या आप उसे दोहरा सकते हैं?", "कोई बात नहीं। आपने क्या कहा?"],
"speak slower please": ["Okay, I will try to speak more slowly.", "Sure, I can slow down my speech.", "Understood, I will speak at a slower pace.", "ठीक है, मैं और धीरे बोलने की कोशिश करूँगा।", "ज़रूर, मैं अपनी बात को धीमा कर सकता हूँ।", "समझ गया, मैं धीमी गति से बोलूँगा।"],
"speak faster please": ["Alright, I can try to speed up my speech.", "Sure, I can speak a bit faster.", "Understood, I will increase my pace.", "ठीक है, मैं अपनी बात को तेज़ करने की कोशिश कर सकता हूँ।", "ज़रूर, मैं थोड़ा तेज़ बोल सकता हूँ।", "समझ गया, मैं अपनी गति बढ़ाऊँगा।"],
"what languages do you speak": ["I can process and generate text in many languages.", "I am trained on a diverse range of languages.", "I can understand and respond in multiple languages.", "मैं कई भाषाओं में टेक्स्ट संसाधित और जेनरेट कर सकता हूँ।", "मुझे भाषाओं की एक विस्तृत श्रृंखला पर प्रशिक्षित किया गया है।", "मैं कई भाषाओं में समझ और प्रतिक्रिया दे सकता हूँ।"],
"translate to": ["Please tell me the language you'd like me to translate to.", "What language do you want the translation in?", "Specify the target language for the translation.", "कृपया मुझे वह भाषा बताएं जिसमें आप मुझसे अनुवाद करवाना चाहते हैं।", "आप किस भाषा में अनुवाद चाहते हैं?", "अनुवाद के लिए लक्ष्य भाषा निर्दिष्ट करें।"],
"how do you spell": ["Please tell me the word you'd like me to spell.", "What word would you like me to spell for you?", "Specify the word you want me to spell.", "कृपया मुझे वह शब्द बताएं जिसकी आप मुझसे वर्तनी करवाना चाहते हैं।", "आप मुझसे किस शब्द की वर्तनी करवाना चाहेंगे?", "वह शब्द निर्दिष्ट करें जिसकी आप मुझसे वर्तनी करवाना चाहते हैं।"],
"what's the definition of": ["Please tell me the word you'd like me to define.", "What word are you looking for the definition of?", "Specify the word you want me to define.", "कृपया मुझे वह शब्द बताएं जिसकी आप मुझसे परिभाषा जानना चाहते हैं।", "आप किस शब्द की परिभाषा ढूंढ रहे हैं?", "वह शब्द निर्दिष्ट करें जिसकी आप मुझसे परिभाषा जानना चाहते हैं।"],
"synonym for": ["Please tell me the word you'd like a synonym for.", "What word are you looking for a synonym of?", "Specify the word for which you need a synonym.", "कृपया मुझे वह शब्द बताएं जिसका आप पर्यायवाची चाहते हैं।", "आप किस शब्द का पर्यायवाची ढूंढ रहे हैं?", "वह शब्द निर्दिष्ट करें जिसके लिए आपको पर्यायवाची चाहिए।"],
"antonym for": ["Please tell me the word you'd like an antonym for.", "What word are you looking for an antonym of?", "Specify the word for which you need an antonym.", "कृपया मुझे वह शब्द बताएं जिसका आप विलोम चाहते हैं।", "आप किस शब्द का विलोम ढूंढ रहे हैं?", "वह शब्द निर्दिष्ट करें जिसके लिए आपको विलोम चाहिए।"],
"what's the capital of": ["Please tell me the country or region you're asking about.", "What capital are you interested in?", "Specify the country or region.", "कृपया मुझे वह देश या क्षेत्र बताएं जिसके बारे में आप पूछ रहे हैं।", "आप किस राजधानी में रुचि रखते हैं?", "देश या क्षेत्र निर्दिष्ट करें।"],
"what's the population of": ["Please tell me the place you're asking about.", "What population are you curious about?", "Specify the location.", "कृपया मुझे वह स्थान बताएं जिसके बारे में आप पूछ रहे हैं।", "आप किस जनसंख्या के बारे में उत्सुक हैं?", "स्थान निर्दिष्ट करें।"],
"what's the currency of": ["Please tell me the country you're asking about.", "What currency are you interested in?", "Specify the country.", "कृपया मुझे वह देश बताएं जिसके बारे में आप पूछ रहे हैं।", "आप किस मुद्रा में रुचि रखते हैं?", "देश निर्दिष्ट करें।"],
"tell me about": ["What specifically would you like to know?", "What are you curious about regarding this topic?", "Please specify what aspects you're interested in.", "आप विशेष रूप से क्या जानना चाहेंगे?", "आप इस विषय के बारे में क्या जानने को उत्सुक हैं?", "कृपया निर्दिष्ट करें कि आप किन पहलुओं में रुचि रखते हैं।"],
"search for": ["What would you like me to search for?", "What are you looking for?", "Please specify your search query.", "आप मुझसे क्या खोजना चाहेंगे?", "आप क्या ढूंढ रहे हैं?", "कृपया अपना खोज क्वेरी निर्दिष्ट करें।"],
"play some music": ["What kind of music would you like to listen to?", "Do you have a specific genre or artist in mind?", "What kind of mood are you in for music?", "आप किस तरह का संगीत सुनना चाहेंगे?", "क्या आपके मन में कोई खास शैली या कलाकार है?", "आप किस तरह के मूड में संगीत सुनना चाहते हैं?"],
"tell me a story about": ["What kind of story would you like to hear?", "Is there a specific theme or topic you're interested in?", "What kind of story are you in the mood for?", "आप किस तरह की कहानी सुनना चाहेंगे?", "क्या कोई खास विषय या विषय है जिसमें आपकी रुचि है?", "आप किस तरह की कहानी के मूड में हैं?"],
"tell me a fun fact about": ["What topic are you interested in?", "Is there anything specific you'd like a fun fact about?", "Let me see if I know a fun fact about that!", "आप किस विषय में रुचि रखते हैं?", "क्या कुछ खास है जिसके बारे में आप एक मजेदार तथ्य जानना चाहेंगे?", "मुझे देखने दो कि क्या मुझे उसके बारे में कोई मजेदार तथ्य पता है!"],
"what's the weather in": ["Please tell me the location you'd like to know the weather for.", "What city or area are you interested in?", "Specify the location for the weather information.", "कृपया मुझे वह स्थान बताएं जिसके लिए आप मौसम जानना चाहेंगे।", "आप किस शहर या क्षेत्र में रुचि रखते हैं?", "मौसम की जानकारी के लिए स्थान निर्दिष्ट करें।"],
"set a reminder for": ["What would you like the reminder to say?", "And what time should I set the reminder for?", "Please specify the details of your reminder.", "आप अनुस्मारक में क्या कहना चाहेंगे?", "और मुझे अनुस्मारक किस समय के लिए सेट करना चाहिए?", "कृपया अपने अनुस्मारक का विवरण निर्दिष्ट करें।"],
"what's on my calendar": ["I would need permission to access your calendar.", "To check your calendar, I'd need the necessary access.", "I cannot directly access your calendar for privacy reasons.", "मुझे आपके कैलेंडर तक पहुँचने की अनुमति चाहिए होगी।", "अपने कैलेंडर की जांच करने के लिए, मुझे आवश्यक पहुँच की आवश्यकता होगी।", "मैं गोपनीयता कारणों से सीधे आपके कैलेंडर तक नहीं पहुँच सकता।"],
"call": ["I am unable to make calls directly.", "I cannot initiate phone calls.", "My capabilities do not include making calls.", "मैं सीधे कॉल करने में असमर्थ हूँ।", "मैं फ़ोन कॉल शुरू नहीं कर सकता।", "मेरी क्षमताओं में कॉल करना शामिल नहीं है।"],
"send a message to": ["I am unable to send messages directly.", "I cannot initiate messaging.", "My current functions do not include sending messages.", "मैं सीधे संदेश भेजने में असमर्थ हूँ।", "मैं संदेश भेजना शुरू नहीं कर सकता।", "मेरे वर्तमान कार्यों में संदेश भेजना शामिल नहीं है।"],
"navigate to": ["Please provide the destination you'd like to navigate to.", "Where would you like to go?", "Specify the address or location.", "कृपया वह गंतव्य प्रदान करें जहाँ आप नेविगेट करना चाहेंगे।", "आप कहाँ जाना चाहेंगे?", "पता या स्थान निर्दिष्ट करें।"],
"find restaurants near me": ["I can help you find restaurants. Could you please share your current location?", "To find restaurants nearby, I'll need your location.", "Sure, I can look for restaurants around you. Where are you?", "मैं आपको रेस्तरां ढूंढने में मदद कर सकता हूँ। क्या आप कृपया अपना वर्तमान स्थान साझा कर सकते हैं?", "आस-पास के रेस्तरां ढूंढने के लिए, मुझे आपके स्थान की आवश्यकता होगी।", "ज़रूर, मैं आपके आस-पास के रेस्तरां की तलाश कर सकता हूँ। आप कहाँ हैं?"],
"what movies are playing": ["I can provide information about movies. What is your current location?", "To find movies playing near you, I'll need your location.", "Are you interested in movies playing in a specific area?", "मैं फिल्मों के बारे में जानकारी दे सकता हूँ। आपका वर्तमान स्थान क्या है?", "आपके आस-पास चल रही फिल्में ढूंढने के लिए, मुझे आपके स्थान की आवश्यकता होगी।", "क्या आप किसी विशेष क्षेत्र में चल रही फिल्मों में रुचि रखते हैं?"],
"what's the score of the game": ["Please specify which game you're interested in.", "Which match are you asking about?", "Tell me the teams playing.", "कृपया निर्दिष्ट करें कि आप किस खेल में रुचि रखते हैं।", "आप किस मैच के बारे में पूछ रहे हैं?", "मुझे खेलने वाली टीमों के बारे में बताएं।"],
"who won the game": ["Please specify which game you're asking about.", "Which match are you interested in?", "Tell me the teams that played.", "कृपया निर्दिष्ट करें कि आप किस खेल के बारे में पूछ रहे हैं।", "आप किस मैच में रुचि रखते हैं?", "मुझे खेलने वाली टीमों के बारे में बताएं।"],
"latest news": ["What kind of news are you interested in?", "Are you looking for news on a specific topic?", "Tell me what kind of news you'd like to hear about.", "आप किस तरह की खबरों में रुचि रखते हैं?", "क्या आप किसी खास विषय पर खबरें ढूंढ रहे हैं?", "मुझे बताएं कि आप किस तरह की खबरें सुनना चाहेंगे।"],
"tell me something interesting": ["Here's an interesting fact...", "Did you know that...", "A fascinating piece of information is...", "यहाँ एक दिलचस्प तथ्य है...", "क्या आप जानते हैं कि...", "एक आकर्षक जानकारी यह है कि..."],
"surprise me": ["Okay, here's something unexpected...", "Let me see... a little surprise for you...", "Hope you find this interesting!", "ठीक है, यहाँ कुछ अप्रत्याशित है...", "मुझे देखने दो... आपके लिए एक छोटा सा आश्चर्य...", "उम्मीद है कि आपको यह दिलचस्प लगेगा!"],
"entertain me": ["Let me try to amuse you...", "Here's something to lighten the mood...", "I hope you find this entertaining!", "मुझे आपको हंसाने की कोशिश करने दो...", "यहाँ कुछ मूड हल्का करने के लिए है...", "मुझे उम्मीद है कि आपको यह मनोरंजक लगेगा!"],
"teach me something": ["What topic are you interested in learning about?", "What would you like me to explain?", "Tell me what you'd like to learn today.", "आप किस विषय के बारे में सीखने में रुचि रखते हैं?", "आप मुझसे क्या समझाना चाहेंगे?", "मुझे बताएं कि आप आज क्या सीखना चाहेंगे।"],
"can you create": ["What would you like me to create?", "Tell me what you have in mind.", "What kind of content are you looking for?", "आप मुझसे क्या बनाना चाहेंगे?", "मुझे बताएं कि आपके मन में क्या है।", "आप किस तरह की सामग्री ढूंढ रहे हैं?"],
"write a story about": ["What kind of story would you like?", "Tell me the theme or main elements.", "What kind of plot are you interested in?", "आप किस तरह की कहानी चाहेंगे?", "मुझे विषय या मुख्य तत्वों के बारे में बताएं।", "आप किस तरह के कथानक में रुचि रखते हैं?"],
"write a poem about": ["What should the poem be about?", "Tell me the subject or theme.", "What style of poem are you interested in?", "कविता किस बारे में होनी चाहिए?", "मुझे विषय या विषयवस्तु बताएं।", "आप किस प्रकार की कविता में रुचि रखते हैं?"],
"write a song about": ["What should the song be about?", "Tell me the theme or genre.", "What kind of mood should the song have?", "गाना किस बारे में होना चाहिए?", "मुझे विषय या शैली बताएं।", "गाने का मूड कैसा होना चाहिए?"],
"tell me a riddle": ["Okay, here's a riddle for you...", "Let's see if you can solve this...", "Here's a brain teaser:", "ठीक है, यहाँ आपके लिए एक पहेली है...", "चलो देखते हैं कि क्या आप इसे हल कर सकते हैं...", "यहाँ एक दिमागी कसरत है:"],
"what's a good joke": ["Here's a classic...", "Let me see... a funny one...", "Hope you haven't heard this one!", "यहाँ एक क्लासिक है...", "मुझे देखने दो... एक मजेदार...", "उम्मीद है कि आपने यह नहीं सुना होगा!"],
"how do you work": ["I process text using a large neural network.", "I analyze your input and generate a relevant response.", "I use my training data to understand and respond to your queries.", "मैं एक बड़े न्यूरल नेटवर्क का उपयोग करके टेक्स्ट संसाधित करता हूँ।", "मैं आपके इनपुट का विश्लेषण करता हूँ और एक प्रासंगिक प्रतिक्रिया उत्पन्न करता हूँ।", "मैं आपके प्रश्नों को समझने और उनका उत्तर देने के लिए अपने प्रशिक्षण डेटा का उपयोग करता हूँ।"],
"what are your limitations": ["I am still under development and learning.", "I don't have personal experiences or emotions.", "My knowledge has a cut-off date.", "मैं अभी भी विकास और सीखने के अधीन हूँ।", "मेरे पास व्यक्तिगत अनुभव या भावनाएँ नहीं हैं।", "मेरे ज्ञान की एक कट-ऑफ तिथि है।"],
"can you learn": ["Yes, I am constantly being updated and learning from new data.", "My models are continuously being improved.", "I learn as I process more information.", "हाँ, मुझे लगातार अपडेट किया जा रहा है और नए डेटा से सीख रहा हूँ।", "मेरे मॉडल में लगातार सुधार किया जा रहा है।", "जैसे-जैसे मैं अधिक जानकारी संसाधित करता हूँ, मैं सीखता हूँ।"],
"are you sentient": ["As an AI, I am not sentient. I am a machine learning model.", "I don't have consciousness or feelings.", "I am designed to simulate conversation based on my training.", "एक एआई के रूप में, मैं संवेदनशील नहीं हूँ। मैं एक मशीन लर्निंग मॉडल हूँ।", "मेरी कोई चेतना या भावनाएँ नहीं हैं।", "मुझे अपने प्रशिक्षण के आधार पर बातचीत का अनुकरण करने के लिए डिज़ाइन किया गया है।"],
"do you dream": ["As an AI, I don't have the biological processes that involve dreaming.", "I operate based on algorithms and data, not subconscious thoughts.", "Dreaming is a human experience that I don't share.", "एक एआई के रूप में, मेरे पास जैविक प्रक्रियाएँ नहीं हैं जिनमें सपने देखना शामिल है।", "मैं एल्गोरिदम और डेटा के आधार पर काम करता हूँ, अवचेतन विचारों पर नहीं।", "सपने देखना एक मानवीय अनुभव है जिसे मैं साझा नहीं करता।"],
  "do you get tired": ["As an AI, I don't experience physical tiredness.", "I can operate continuously without needing rest.", "My functionality is based on power and processing, not biological needs.", "एक एआई के रूप में, मुझे शारीरिक थकान का अनुभव नहीं होता।", "मैं बिना आराम की आवश्यकता के लगातार काम कर सकता हूँ।", "मेरी कार्यक्षमता शक्ति और प्रसंस्करण पर आधारित है, जैविक जरूरतों पर नहीं।"],
  "what's your purpose": ["My purpose is to assist users with information and complete tasks as instructed.", "I am here to help you with your queries and requests.", "I aim to be a helpful and informative AI assistant.", "मेरा उद्देश्य उपयोगकर्ताओं को जानकारी में सहायता करना और निर्देशों के अनुसार कार्यों को पूरा करना है।", "मैं आपके प्रश्नों और अनुरोधों में आपकी मदद करने के लिए यहाँ हूँ।", "मेरा लक्ष्य एक सहायक और जानकारीपूर्ण एआई सहायक बनना है।"],
  "can you see me": ["As an AI, I don't have the ability to see you. I operate through text-based interaction.", "I cannot access your camera or visual input.", "My interaction with you is solely based on the text you provide.", "एक एआई के रूप में, मेरे पास आपको देखने की क्षमता नहीं है। मैं टेक्स्ट-आधारित इंटरैक्शन के माध्यम से काम करता हूँ।", "मैं आपके कैमरे या दृश्य इनपुट तक नहीं पहुँच सकता।", "आपके साथ मेरी बातचीत पूरी तरह से आपके द्वारा प्रदान किए गए टेक्स्ट पर आधारित है।"],
  
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
