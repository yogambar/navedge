# 🧭 NavEdge – A Cross-Platform Smart Route Planner  
**A cross-platform smart route planner with interactive assistance and user support.**

![Last Commit](https://img.shields.io/github/last-commit/yogambar/navedge) ![Flutter](https://img.shields.io/badge/Built%20With-Flutter-blue)

---

## 🛠️ Built With  
Flutter • Dart • Firebase • C++ (Crow Framework) • SQLite • REST APIs • Flutter Map • Dijkstra • A* • Bellman-Ford • Floyd-Warshall • Knapsack

---

## 📑 Table of Contents  
- [🔍 Overview](#-overview)  
- [🚀 Getting Started](#-getting-started)  
- [✅ Prerequisites](#-prerequisites)  
- [🛠️ Installation](#-installation)  
- [▶️ Usage](#️-usage)  
- [🧠 Architecture](#-architecture)  
- [📦 Project Deliverables](#-project-deliverables)  
- [🧪 Testing](#-testing)  
- [💡 Future Scope](#-future-scope)  
- [🔙 Return](#-return)

---

## 🔍 Overview  
NavEdge is a cross-platform route optimization app built in Flutter with a C++ backend. It provides dynamic route planning with intelligent assistant support, leveraging powerful graph algorithms and an interactive chatbot system. Designed for Android and Web, it combines efficiency with ease of use for educational and practical navigation.

---

## 🚀 Getting Started  
Clone the repository:
```bash
git clone https://github.com/yogambar/navedge
cd navedge
```

---

## ✅ Prerequisites  
- Flutter SDK (latest stable version)  
- Firebase Project with Authentication enabled  
- C++ compiler for backend services  
- SQLite3  
- Dart & Flutter extensions (VS Code recommended)

---

## 🛠️ Installation  

Set up your environment:
```bash
flutter upgrade
flutter upgrade --major
flutter pub upgrade
flutter clean
flutter pub get
```

---

## ▶️ Usage  

### Run the app on available platforms:
```bash
flutter run                      # Default device
flutter run -d chrome            # Run on Web (Chrome)
flutter run -d android           # Run on Android device/emulator
flutter run -d linux             # Run on Linux desktop
flutter run -d windows           # Run on Windows desktop
flutter run -d macos             # Run on macOS desktop
```

### Build for production:
```bash
flutter build apk                # Build Android APK
flutter build linux              # Build for Linux
flutter build windows            # Build for Windows
flutter build macos              # Build for macOS
flutter build web                # Build for Web
```

---

## 🧠 Architecture  
- **Frontend (Flutter):** Reusable widgets like `SourceDestinationBar`, `ChatbotButton`, `ProfileDrawer`. Uses `flutter_map` and supports animations and cross-platform deployment.
- **Backend (C++/Crow):** Implements REST APIs for routing (`/route`) and chatbot. Algorithms include Dijkstra, A*, Bellman-Ford, Floyd-Warshall, and Knapsack.
- **Integration:** REST API communication via Dart `http`, OSM tiles caching for offline use, dynamic UI updates.
- **Chatbot System:** Rule-based with multilingual-ready JSON logic for map guidance and login support.

---

## 📦 Project Deliverables  
- ✅ Firebase-authenticated login/profile system  
- ✅ Real-time map with source/destination pinning and routing  
- ✅ Backend routing using advanced graph algorithms  
- ✅ Rule-based interactive chatbot system  
- ✅ Offline OSM tile support  
- ✅ Modular, scalable codebase for Android/Web  
- ✅ Final APK and web build ready for deployment  

---

## 🧪 Testing  

| Test Type                      | Status  | Notes                                             |
|-------------------------------|---------|---------------------------------------------------|
| Firebase Authentication        | ✅ Pass | Stable login/logout with session persistence      |
| Route Algorithms               | ✅ Pass | Verified with test graphs and real locations      |
| Chatbot                        | 🔄 WIP  | English functional; multilingual in development   |
| Map UI (Polylines + Markers)  | ✅ Pass | Accurate path rendering with pin selection        |
| Offline Support                | ✅ Pass | Tile cache loads correctly in offline mode        |

---

## 💡 Future Scope  
- Add multilingual chatbot support (Hindi, French)  
- Final polish on UI animations and user documentation  
- Enhance route-saving reliability in Firebase  
- Perform large-scale stress testing on algorithm performance  
- Package and deploy final APK and web builds

---

## 🔙 Return  
🔼 [Back to Top](#navedge--a-cross-platform-smart-route-planner)
