import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/skeleton_list.dart';
import '../../home/presentation/widgets/server_card.dart';
import '../../vpn/presentation/vpn_provider.dart';
import 'servers_provider.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final officialAsync = ref.watch(officialServersProvider);
    final personal = ref.watch(personalServersProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('دسته‌بندی‌ها')),
      body: officialAsync.when(
        loading: () => const SkeletonServerList(),
        error: (_, __) => const EmptyState(message: 'خطا در بارگذاری سرورها.'),
        data: (official) {
          final all = [...official, ...personal];
          final filtered = selectedCategory == 'همه'
              ? all
              : all.where((s) {
                  final matchesTag = s.tags.contains(selectedCategory);
                  final matchesProtocol =
                      protocolLabel(s.protocol).toLowerCase() ==
                          selectedCategory.toLowerCase();
                  return matchesTag || matchesProtocol;
                }).toList();

          return Column(
            children: [
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: kCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final cat = kCategories[i];
                    final selected = cat == selectedCategory;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: selected,
                      onSelected: (_) => ref
                          .read(selectedCategoryProvider.notifier)
                          .state = cat,
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off_rounded,
                        message: 'سروری در این دسته‌بندی یافت نشد.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final s = filtered[i];
                          return ServerCard(
                            server: s,
                            onTap: () =>
                                ref.read(vpnProvider.notifier).connect(s),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
