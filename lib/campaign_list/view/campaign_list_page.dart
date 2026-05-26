import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:quest_board/auth/bloc/auth_bloc.dart';
import 'package:talker_flutter/talker_flutter.dart';

class CampaignListPage extends StatefulWidget {
  const CampaignListPage({super.key});

  @override
  State<CampaignListPage> createState() => _CampaignListPageState();
}

class _CampaignListPageState extends State<CampaignListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocListener<AuthBloc, AuthBlocState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              GetIt.I<Talker>().debug('Logout');
              context.goNamed('login');
            }
          },
          child: FilledButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequest());
            },
            child: Text("Logout"),
          ),
        ),
      ),
    );
  }
}
