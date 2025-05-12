import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For more icons

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  bool _isLoading = true;
  List<FAQItem> _faqItems = [];
  List<ContactOption> _contactOptions = [];
  List<LinkOption> _usefulLinks = [];

  @override
  void initState() {
    super.initState();
    _loadHelpSupportData();
  }

  Future<void> _loadHelpSupportData() async {
    await Future.delayed(const Duration(seconds: 2));

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
    ];

    _contactOptions = [
      ContactOption(
        icon: Icons.email_rounded,
        title: 'Email Support',
        subtitle: 'yogambarsingh2480@gmail.com',
        url: 'mailto:yogambarsingh2480@gmail.com',
      ),
      ContactOption(
        icon: Icons.phone_rounded,
        title: 'Phone Support',
        subtitle: '+91 84399 02894',
        url: 'tel:+918439902894',
      ),
    ];

    _usefulLinks = [
      LinkOption(
        icon: FontAwesomeIcons.github,
        title: 'GitHub Profile',
        url: 'https://github.com/yogambar',
      ),
      LinkOption(
        icon: FontAwesomeIcons.githubAlt,
        title: 'GitHub Repo (NavEdge)',
        url: 'https://github.com/yogambar/navedge',
      ),
      LinkOption(
        icon: FontAwesomeIcons.linkedin,
        title: 'LinkedIn Profile',
        url: 'https://www.linkedin.com/in/yogambar-singh-b42b5927a',
      ),
      LinkOption(
        icon: FontAwesomeIcons.instagram,
        title: 'Instagram',
        url: 'https://www.instagram.com/rakeshbisht2480/',
      ),
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
        const SnackBar(content: Text('Could not open the link.')),
      );
    }
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 220,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildShimmerItem(),
          const SizedBox(height: 16),
          _buildShimmerItem(),
          const SizedBox(height: 20),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 180,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildShimmerItem(),
          _buildShimmerItem(),
          const SizedBox(height: 20),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 160,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildShimmerItem(),
          _buildShimmerItem(),
        ],
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: Colors.white),
        title: Container(height: 18, width: 160, color: Colors.white),
        subtitle: Container(height: 14, width: 200, color: Colors.white),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white),
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
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 16),
        ..._faqItems.map((item) => FadeIn(
              duration: const Duration(milliseconds: 400),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: Text(item.question, style: const TextStyle(fontWeight: FontWeight.w500)),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(item.answer, style: const TextStyle(color: Colors.black87)),
                    ),
                  ],
                ),
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
            'Contact Information',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 16),
        ..._contactOptions.map((option) => FadeIn(
              duration: const Duration(milliseconds: 600),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(option.icon, color: Theme.of(context).colorScheme.primary),
                  title: Text(option.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(option.subtitle),
                  onTap: () => _launchURL(option.url),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildUsefulLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeIn(
          duration: const Duration(milliseconds: 700),
          child: const Text(
            'Useful Links',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 16),
        ..._usefulLinks.map((link) => FadeIn(
              duration: const Duration(milliseconds: 800),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(link.icon, color: Theme.of(context).colorScheme.secondary),
                  title: Text(link.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () => _launchURL(link.url),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                ),
              ),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 3,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).iconTheme,
      ),
      body: RefreshIndicator(
        onRefresh: _loadHelpSupportData,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isLoading ? _buildShimmerLoading() : _buildHelpSupportContent(),
        ),
      ),
    );
  }

  Widget _buildHelpSupportContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeIn(
            duration: const Duration(milliseconds: 200),
            child: Text(
              'Need Assistance?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 16),
          FadeIn(
            delay: const Duration(milliseconds: 100),
            duration: const Duration(milliseconds: 300),
            child: Text(
              'Here you can find answers to frequently asked questions, contact support, and explore helpful resources.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54),
            ),
          ),
          const SizedBox(height: 32),
          _buildFAQSection(),
          const SizedBox(height: 32),
          _buildContactSection(),
          const SizedBox(height: 32),
          _buildUsefulLinksSection(),
          const SizedBox(height: 40),
          FadeIn(
            delay: const Duration(milliseconds: 900),
            duration: const Duration(milliseconds: 300),
            child: Center(
              child: Text(
                'Thank you for using our app!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
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

class LinkOption {
  final IconData icon;
  final String title;
  final String url;

  LinkOption({required this.icon, required this.title, required this.url});
}
