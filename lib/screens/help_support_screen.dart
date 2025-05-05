import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animate_do/animate_do.dart'; // For fade in animation

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  bool _isLoading = true;
  List<FAQItem> _faqItems = [];
  List<ContactOption> _contactOptions = [];
  List<TutorialGuide> _tutorialGuides = [];

  @override
  void initState() {
    super.initState();
    _loadHelpSupportData();
  }

  // Simulate loading data from an API or local source
  Future<void> _loadHelpSupportData() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    _faqItems = [
      FAQItem(
        question: 'How do I use the main feature?',
        answer:
            'Go to the main screen and follow the on-screen instructions. Look for the [Specific Button Name] button.',
      ),
      FAQItem(
        question: 'What are the system requirements?',
        answer:
            'The app requires Android 7.0 or iOS 13.0 and above. Ensure you have at least 100MB of free storage.',
      ),
      FAQItem(
        question: 'Is there a tutorial available?',
        answer:
            'Yes, please check the Tutorials & Guides section below for video and PDF guides.',
      ),
      // Add more FAQ items
    ];

    _contactOptions = [
      ContactOption(
        icon: Icons.email,
        title: 'Email Support',
        subtitle: 'yogambarsingh2480@gmail.com',
        url: 'mailto:yogambarsingh2480@gmail.com',
      ),
      ContactOption(
        icon: Icons.web,
        title: 'Visit our Website',
        subtitle: 'www.yourapp.com/support',
        url: 'https://www.yourapp.com/support',
      ),
      ContactOption(
        icon: Icons.phone,
        title: 'Phone Support',
        subtitle: '+91 84399 02894 (Mon-Fri, 9 AM - 5 PM IST)',
        url: 'tel:+918439902894',
      ),
      // Add more contact options
    ];

    _tutorialGuides = [
      TutorialGuide(
        icon: Icons.play_circle_fill,
        title: 'Getting Started Guide (Video)',
        url: 'https://www.youtube.com/your-tutorial-link',
      ),
      TutorialGuide(
        icon: Icons.picture_as_pdf, // Corrected icon name
        title: 'User Manual (PDF)',
        url: 'https://www.yourapp.com/user-manual.pdf',
      ),
      TutorialGuide(
        icon: Icons.help,
        title: 'Detailed Feature Walkthrough',
        url: 'https://www.yourapp.com/feature-walkthrough',
      ),
      // Add more tutorials and guides
    ];

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch $url');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the link: $url')),
      );
    }
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 200,
              height: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          _buildShimmerListItem(),
          const SizedBox(height: 16),
          _buildShimmerListItem(),
          const SizedBox(height: 24),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 150,
              height: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildShimmerListItem(),
          _buildShimmerListItem(),
          const SizedBox(height: 24),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 180,
              height: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildShimmerListItem(),
          _buildShimmerListItem(),
        ],
      ),
    );
  }

  Widget _buildShimmerListItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: const ListTile(
        leading: CircleAvatar(backgroundColor: Colors.white),
        title: SizedBox(height: 16, width: 150, child: ColoredBox(color: Colors.white)),
        subtitle: SizedBox(height: 12, width: 200, child: ColoredBox(color: Colors.white)),
        trailing: Icon(Icons.chevron_right, color: Colors.white),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeIn(
          duration: const Duration(milliseconds: 300),
          child: const Text(
            'Frequently Asked Questions (FAQ)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        ..._faqItems.map((item) => FadeIn(
              duration: const Duration(milliseconds: 400),
              child: ExpansionTile(
                title: Text(item.question),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(item.answer),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeIn(
          duration: const Duration(milliseconds: 500),
          child: const Text(
            'Contact Us',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        ..._contactOptions.map((option) => FadeIn(
              duration: const Duration(milliseconds: 600),
              child: ListTile(
                leading: Icon(option.icon),
                title:
                    Text(option.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(option.subtitle),
                onTap: () => _launchURL(option.url),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            )),
      ],
    );
  }

  Widget _buildTutorialsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeIn(
          duration: const Duration(milliseconds: 700),
          child: const Text(
            'Tutorials & Guides',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        ..._tutorialGuides.map((guide) => FadeIn(
              duration: const Duration(milliseconds: 800),
              child: ListTile(
                leading: Icon(guide.icon),
                title:
                    Text(guide.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () => _launchURL(guide.url),
                trailing: const Icon(Icons.open_in_new, size: 16),
              ),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
        elevation: 2,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isLoading ? _buildShimmerLoading() : _buildHelpSupportContent(),
      ),
    );
  }

  Widget _buildHelpSupportContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeIn(
            duration: const Duration(milliseconds: 200),
            child: Text(
              'How can we help you?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 24),
          _buildFAQSection(),
          const SizedBox(height: 24),
          _buildContactSection(),
          const SizedBox(height: 24),
          _buildTutorialsSection(),
          const SizedBox(height: 32),
          FadeIn(
            duration: const Duration(milliseconds: 900),
            child: const Text(
              'If you still need assistance, please contact our support team directly.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}

class ContactOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final String url;

  ContactOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.url,
  });
}

class TutorialGuide {
  final IconData icon;
  final String title;
  final String url;

  TutorialGuide({required this.icon, required this.title, required this.url});
}
