import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:quest_board/campaign_list/cubit/create_campaign_cubit.dart';
import 'package:quest_board/campaign_list/cubit/join_campaign_cubit.dart';
import 'package:quest_board/campaign_list/view/widgets/month_input_section.dart';
import 'package:quest_board/campaign_list/view/widgets/weekday_input_section.dart';
import 'package:talker_flutter/talker_flutter.dart';

class CreateCampaignBottomSheet extends StatefulWidget {
  const CreateCampaignBottomSheet({super.key, required this.userId});

  final String userId;

  @override
  State<CreateCampaignBottomSheet> createState() =>
      _CreateCampaignBottomSheetState();
}

class _CreateCampaignBottomSheetState extends State<CreateCampaignBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Create Campaign'),
              Tab(text: 'Join Campaign'),
            ],
          ),
          Expanded(
            child: SafeArea(
              child: TabBarView(
                controller: _tabController,
                children: [
                  const _CreateCampaignTabContent(),
                  const _JoinCampaignTabContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateCampaignTabContent extends StatefulWidget {
  const _CreateCampaignTabContent();

  @override
  State<_CreateCampaignTabContent> createState() =>
      _CreateCampaignTabContentState();
}

class _CreateCampaignTabContentState extends State<_CreateCampaignTabContent> {
  final _formKey = GlobalKey<FormState>();
  final _campaignNameController = TextEditingController();
  final _worldNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<CreateCampaignCubit>().state;
    if (_campaignNameController.text != state.campaignName) {
      _campaignNameController.text = state.campaignName;
    }
    if (_worldNameController.text != state.worldName) {
      _worldNameController.text = state.worldName;
    }
  }

  @override
  void dispose() {
    _campaignNameController.dispose();
    _worldNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<CreateCampaignCubit>().updateCampaignName(
        _campaignNameController.text.trim(),
      );
      context.read<CreateCampaignCubit>().updateWorldName(
        _worldNameController.text.trim(),
      );
      context.read<CreateCampaignCubit>().submit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);

    return BlocConsumer<CreateCampaignCubit, CreateCampaignState>(
      listener: (context, state) {
        if (state.status == CreateStatus.success) {
          GetIt.I<Talker>().debug('Campaign created successfully');
          if (mounted) {
            Navigator.pop(context);
          }
        } else if (state.status == CreateStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _campaignNameController,
                  decoration: InputDecoration(
                    labelText: 'Campaign Name',
                    prefixIcon: const Icon(Icons.book_outlined),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: const UnderlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(5),
                        bottomRight: Radius.circular(5),
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter campaign name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _worldNameController,
                  decoration: InputDecoration(
                    labelText: 'World Name',
                    prefixIcon: const Icon(Icons.public_outlined),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: const UnderlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(5),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter world name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const MonthInputSection(),
                const SizedBox(height: 24),
                const WeekdayInputSection(),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: state.status == CreateStatus.loading
                      ? null
                      : _submit,
                  child: state.status == CreateStatus.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create Campaign'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _JoinCampaignTabContent extends StatefulWidget {
  const _JoinCampaignTabContent();

  @override
  State<_JoinCampaignTabContent> createState() =>
      _JoinCampaignTabContentState();
}

class _JoinCampaignTabContentState extends State<_JoinCampaignTabContent> {
  MobileScannerController? _scannerController;
  bool _isScanning = true;
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<JoinCampaignCubit>().state;
    if (_codeController.text != state.inviteCode) {
      _codeController.text = state.inviteCode;
    }
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    final String? code = capture.barcodes.first.rawValue;
    if (code != null && code.isNotEmpty) {
      _isScanning = false;
      context.read<JoinCampaignCubit>().updateInviteCode(code);
      context.read<JoinCampaignCubit>().joinByInviteCode();
    }
  }

  void _join() {
    context.read<JoinCampaignCubit>().joinByInviteCode();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocConsumer<JoinCampaignCubit, JoinCampaignState>(
      listener: (context, state) {
        if (state.status == JoinStatus.success) {
          GetIt.I<Talker>().debug('Joined campaign: ${state.campaignName}');
          if (mounted) {
            Navigator.pop(context);
          }
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                    maxHeight: 500,
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: MobileScanner(
                        controller: _scannerController,
                        onDetect: _onDetect,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Position QR code within the frame',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Invitation Code',
                  prefixIcon: const Icon(Icons.confirmation_number_outlined),
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  border: const UnderlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                    borderSide: BorderSide.none,
                  ),
                ),
                textCapitalization: TextCapitalization.characters,
                onChanged: (value) =>
                    context.read<JoinCampaignCubit>().updateInviteCode(value),
              ),
              const SizedBox(height: 5),
              FilledButton(
                onPressed: state.status == JoinStatus.loading ? null : _join,
                child: state.status == JoinStatus.loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Join Campaign'),
              ),
            ],
          ),
        );
      },
    );
  }
}
