import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/presentation/widgets/server_card.dart';
import '../../servers/domain/models/server_model.dart';
import '../../servers/presentation/servers_provider.dart';
import '../../vpn/presentation/vpn_provider.dart';

class AddServerScreen extends ConsumerStatefulWidget {
  final ServerModel? editingServer;
  const AddServerScreen({super.key, this.editingServer});

  @override
  ConsumerState<AddServerScreen> createState() => _AddServerScreenState();
}

class _AddServerScreenState extends ConsumerState<AddServerScreen> {
  final _configController = TextEditingController();
  final _nameController = TextEditingController();
  final _countryController = TextEditingController();
  ServerProtocol _detected = ServerProtocol.unknown;

  @override
  void initState() {
    super.initState();
    final editing = widget.editingServer;
    if (editing != null) {
      _configController.text = editing.rawConfig;
      _nameController.text = editing.name;
      _countryController.text = editing.countryCode;
      _detected = editing.protocol;
    }
    _configController.addListener(_onConfigChanged);
  }

  void _onConfigChanged() {
    setState(() {
      _detected = ServerModel.detectProtocolFromLink(_configController.text);
    });
  }

  @override
  void dispose() {
    _configController.dispose();
    _nameController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _configController.text = data!.text!;
    }
  }

  Future<void> _save({bool connectAfter = false}) async {
    final link = _configController.text.trim();
    if (link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً لینک کانفیگ را وارد کنید.')),
      );
      return;
    }

    final notifier = ref.read(personalServersProvider.notifier);
    await notifier.addFromLink(
      link,
      name: _nameController.text,
      country: _countryController.text,
    );

    if (connectAfter) {
      final added = ref.read(personalServersProvider).last;
      await ref.read(vpnProvider.notifier).connect(added);
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editingServer != null ? 'ویرایش کانفیگ' : 'افزودن کانفیگ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _configController,
            maxLines: 5,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              labelText: 'لینک کانفیگ (vmess:// vless:// trojan:// ss://)',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.paste_rounded),
                tooltip: 'Paste سریع',
                onPressed: _pasteFromClipboard,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Chip(
              avatar: const Icon(Icons.auto_awesome_rounded, size: 16),
              label: Text('تشخیص خودکار: ${protocolLabel(_detected)}'),
              backgroundColor: AppColors.primary.withOpacity(0.1),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'نام سرور (اختیاری)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _countryController,
            maxLength: 2,
            decoration: InputDecoration(
              labelText: 'کد کشور (اختیاری، مثل IR)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _save(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('ذخیره در سرورهای من'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => _save(connectAfter: true),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('اتصال فوری'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
