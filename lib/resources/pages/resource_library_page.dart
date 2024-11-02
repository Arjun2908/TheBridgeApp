import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_bridge_app/bottom_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:the_bridge_app/widgets/common_app_bar.dart';
import '../providers/resource_provider.dart';
import '../models/resource.dart';
import 'package:the_bridge_app/global_helpers.dart';

class ResourceLibraryPage extends StatefulWidget {
  const ResourceLibraryPage({super.key});

  @override
  State<ResourceLibraryPage> createState() => _ResourceLibraryPageState();
}

class _ResourceLibraryPageState extends State<ResourceLibraryPage> {
  bool _isPressed = false;

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
        appBar: CommonAppBar(
          title: 'Resources',
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3,
            tabs: const [
              Tab(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.video_library),
                    SizedBox(width: 8),
                    Text('Videos'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.book),
                    SizedBox(width: 8),
                    Text('Study Guides'),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Consumer<ResourceProvider>(
          builder: (context, resourceProvider, child) {
            return TabBarView(
              children: [
                _buildTabContent(context, resourceProvider.videos),
                _buildTabContent(context, resourceProvider.studyGuides),
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

  Widget _buildTabContent(BuildContext context, List<Resource> resources) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
        return _buildResourceCard(context, resource);
      },
    );
  }

  Widget _buildResourceCard(BuildContext context, Resource resource) {
    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            _launchUrl(resource.url);
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
            child: Card(
              elevation: _isPressed ? 5 : 10,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        resource.type == ResourceType.video ? Icons.play_circle : Icons.picture_as_pdf,
                        size: 28,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resource.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            resource.description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
