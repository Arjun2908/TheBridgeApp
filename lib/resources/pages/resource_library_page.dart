import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_bridge_app/bottom_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/resource_provider.dart';
import '../models/resource.dart';
import 'package:the_bridge_app/global_helpers.dart';

class ResourceLibraryPage extends StatelessWidget {
  const ResourceLibraryPage({super.key});

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Resources'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.video_library), text: 'Videos'),
              Tab(icon: Icon(Icons.book), text: 'Study Guides'),
            ],
          ),
        ),
        body: Consumer<ResourceProvider>(
          builder: (context, resourceProvider, child) {
            return TabBarView(
              children: [
                _buildResourceList(context, resourceProvider.videos),
                _buildResourceList(context, resourceProvider.studyGuides),
              ],
            );
          },
        ),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: 3,
          onItemTapped: (index) => onItemTapped(index, context),
        ),
      ),
    );
  }

  Widget _buildResourceList(BuildContext context, List<Resource> resources) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: Icon(
              resource.type == ResourceType.video ? Icons.play_circle : Icons.picture_as_pdf,
              size: 40,
            ),
            title: Text(resource.title),
            subtitle: Text(resource.description),
            onTap: () => _launchUrl(resource.url),
          ),
        );
      },
    );
  }
}
