import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

class CampaignListPage extends StatefulWidget {
  const CampaignListPage({super.key});

  @override
  State<CampaignListPage> createState() => _CampaignListPageState();
}

class _CampaignListPageState extends State<CampaignListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quest Board', textAlign: TextAlign.center),
        actions: [
          IconButton(
            onPressed: () {
              context.pushNamed('settings');
            },
            icon: Icon(Icons.settings_outlined),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Center(child: Text('Test build')),
      floatingActionButton: FloatingActionButton(onPressed: () {}),
    );
  }
}
