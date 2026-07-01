import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/skeleton_list.dart';
import '../../servers/domain/models/server_model.dart';
import '../../servers/presentation/servers_provider.dart';
import '../../vpn/domain/vpn_service.dart';
import '../../vpn/presentation/vpn_provider.dart';
import 'widgets/connect_button.dart';
import 'widgets/server_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<void> _refresh() async {
    ref.invalidate(officialServersProvider);
    await ref.read(officialServersProvider.future);
  }

  Future<void> _onConnectTap(List<ServerModel> allServers) async {
    final vpnState = ref.read(vpnProvider);
    final vpnNotifier = ref.read(vpnProvider.notifier);

    if (vpnState.connectionState == VpnConnectionState.connected) {
      await vpnNotifier.disconnect();
      return;
    }

    // انتخاب بهترین سرور پیشنهادی (کمترین پینگ در بین آنلاین‌ها)
    final online = allServers.where((s) => s.isOnline).toList()
      ..sort((a, b) => a.pingMs.compareTo(b.pingMs));
    if (online.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سروری برای اتصال یافت نشد.')),
      );
      return;
    }
    await vpnNotifier.connect(online.first);
  }

  @override
  Widget build(BuildContext context) {
    final officialAsync = ref.watch(officialServersProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final vpnState = ref.watch(vpnProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shield_moon_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('کانفیگ رایگان'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _ServerSearchDelegate(
                  officialAsync.value ?? [],
                  ref.read(personalServersProvider),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: officialAsync.when(
          loading: () => const _HomeSkeleton(),
          error: (err, _) => ListView(
            children: [
              const SizedBox(height: 40),
              const EmptyState(
                icon: Icons.wifi_off_rounded,
                message:
                    'آخرین اطلاعات ذخیره شده نمایش داده می‌شود.',
              ),
            ],
          ),
          data: (servers) => _HomeContent(
            servers: servers,
            selectedCategory: selectedCategory,
            vpnState: vpnState,
            onConnectTap: () => _onConnectTap(servers),
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  final List<ServerModel> servers;
  final String selectedCategory;
  final dynamic vpnState;
  final VoidCallback onConnectTap;

  const _HomeContent({
    required this.servers,
    required this.selectedCategory,
    required this.vpnState,
    required this.onConnectTap,
  });

  List<ServerModel> _filtered() {
    if (selectedCategory == 'همه') return servers;
    return servers.where((s) {
      final matchesTag = s.tags.contains(selectedCategory);
      final matchesProtocol =
          protocolLabel(s.protocol).toLowerCase() ==
              selectedCategory.toLowerCase();
      return matchesTag || matchesProtocol;
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = _filtered();
    final onlineCount = servers.where((s) => s.isOnline).length;
    final avgPing = servers.isEmpty
        ? 0
        : (servers.map((s) => s.pingMs > 0 ? s.pingMs : 0).reduce((a, b) => a + b) /
                servers.length)
            .round();
    final best = ([...servers]..sort((a, b) => a.pingMs.compareTo(b.pingMs)))
        .firstOrNull;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _StatsRow(onlineCount: onlineCount, avgPing: avgPing, best: best),
        const SizedBox(height: 20),
        ConnectButton(
          state: vpnState.connectionState,
          onTap: onConnectTap,
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: kCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = kCategories[i];
              final selected = cat == selectedCategory;
              return ChoiceChip(
                label: Text(cat),
                selected: selected,
                onSelected: (_) =>
                    ref.read(selectedCategoryProvider.notifier).state = cat,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: EmptyState(
              icon: Icons.search_off_rounded,
              message: 'سروری در این دسته‌بندی یافت نشد.',
            ),
          )
        else
          ...filtered.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ServerCard(
                server: s,
                onTap: () => ref.read(vpnProvider.notifier).connect(s),
              ),
            ),
          ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int onlineCount;
  final int avgPing;
  final ServerModel? best;

  const _StatsRow({required this.onlineCount, required this.avgPing, this.best});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(label: 'سرور آنلاین', value: '$onlineCount'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(label: 'میانگین پینگ', value: '${avgPing}ms'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'بهترین سرور',
            value: best?.name ?? '—',
            small: true,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool small;

  const _StatCard({required this.label, required this.value, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: small ? 13 : 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 16),
      child: SkeletonServerList(),
    );
  }
}

class _ServerSearchDelegate extends SearchDelegate<String> {
  final List<ServerModel> official;
  final List<ServerModel> personal;

  _ServerSearchDelegate(this.official, this.personal);

  List<ServerModel> get _all => [...official, ...personal];

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_forward),
        onPressed: () => close(context, ''),
      );

  @override
  Widget buildResults(BuildContext context) => _buildList();

  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    final results = _all
        .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    if (results.isEmpty) {
      return const EmptyState(message: 'نتیجه‌ای یافت نشد.');
    }
    return ListView(
      children: results
          .map((s) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ServerCard(server: s, onTap: () {}),
              ))
          .toList(),
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
