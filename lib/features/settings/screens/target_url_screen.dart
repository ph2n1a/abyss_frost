import 'package:abyss_frost/core/services/data/shared_preferences.dart';
import 'package:abyss_frost/core/theme/app_colors.dart';
import 'package:abyss_frost/features/settings/widgets/target_url_widgets/add_tag_button.dart';
import 'package:abyss_frost/features/settings/widgets/target_url_widgets/selected_button.dart';
import 'package:abyss_frost/features/settings/widgets/target_url_widgets/tag_chip.dart';
import 'package:abyss_frost/features/settings/widgets/target_url_widgets/url_text_field.dart';
import 'package:flutter/material.dart';

class TargetUrlScreen extends StatefulWidget {
  const TargetUrlScreen({super.key});

  @override
  State<TargetUrlScreen> createState() => _TargetUrlScreenState();
}

class _TargetUrlScreenState extends State<TargetUrlScreen> {
  final _prefs = CallSharedPreferences.instance;

  Future<bool> _confirmDelete(String url) async {
    return await showDialog<bool>(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.6),
          builder: (dialogContext) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.maxFinite,
                constraints: const BoxConstraints(maxWidth: 340),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF191921),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Delete $url?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'This target will be deleted permanently.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white24),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Delete'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false;
  }

  void _showSelectedDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxWidth: 340),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF191921),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Select tag',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SelectedButtonTag(
                  onPressed: () {
                    _prefs.setTargetsUrlTags('neutral', index);
                    Navigator.pop(dialogContext);
                  },
                  text: 'neutral',
                  color: Colors.blueGrey,
                ),
                const SizedBox(height: 10),
                SelectedButtonTag(
                  onPressed: () {
                    _prefs.setTargetsUrlTags('whitelist', index);
                    Navigator.pop(dialogContext);
                  },
                  text: 'whitelist',
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                SelectedButtonTag(
                  onPressed: () {
                    _prefs.setTargetsUrlTags('blacklist', index);
                    Navigator.pop(dialogContext);
                  },
                  text: 'blacklist',
                  color: Colors.black,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: appColors.backgroundColor,
        surfaceTintColor: appColors.backgroundColor,
        iconTheme: IconThemeData(color: appColors.backColor),
        title: const Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            'Target URLs',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: _prefs,
        builder: (context, child) {
          final targetsUrl = _prefs.targetsUrl;
          final targetsUrlTags = _prefs.targetsUrlTags;

          return ListView(
            children: [
              if (targetsUrl.isNotEmpty)
                for (int index = 0; index < targetsUrl.length; index++)
                  _TargetUrlCard(
                    key: ValueKey('target_url_$index'),
                    index: index,
                    url: targetsUrl[index],
                    tag: index < targetsUrlTags.length
                        ? targetsUrlTags[index]
                        : '',
                    appColors: appColors,
                    onChanged: (value) => _prefs.setTargetsUrl(value, index),
                    onDeleteTag: () => _prefs.setTargetsUrlTags('', index),
                    onSelectTag: () => _showSelectedDialog(context, index),
                    onDelete: () => _prefs.removeTargetUrl(index),
                    confirmDelete: () => _confirmDelete(targetsUrl[index]),
                  ),
              if (targetsUrl.isEmpty) const SizedBox(height: 24),
              if (targetsUrl.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.folder_off_outlined,
                          size: 46,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'There are no saved targets.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              _AddTargetCard(
                appColors: appColors,
                onTap: _prefs.addEmptyTargetUrl,
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

class _TargetUrlCard extends StatelessWidget {
  final int index;
  final String url;
  final String tag;
  final AppColors appColors;
  final ValueChanged<String> onChanged;
  final VoidCallback onDeleteTag;
  final VoidCallback onSelectTag;
  final Future<void> Function() onDelete;
  final Future<bool> Function() confirmDelete;

  const _TargetUrlCard({
    super.key,
    required this.index,
    required this.url,
    required this.tag,
    required this.appColors,
    required this.onChanged,
    required this.onDeleteTag,
    required this.onSelectTag,
    required this.onDelete,
    required this.confirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasTag = tag.isNotEmpty;

    return Dismissible(
      key: ValueKey('target_url_card_$index'),
      direction: DismissDirection.endToStart,
      resizeDuration: const Duration(milliseconds: 180),
      confirmDismiss: (_) => confirmDelete(),
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.35)),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.redAccent,
          size: 26,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: appColors.gray.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            width: 2,
            color: appColors.gray.withValues(alpha: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Target URL',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  UrlTextField(targetUrl: url, targetUrlChange: onChanged),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Tag:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: appColors.mediumColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (!hasTag)
                        AddTagButton(onPressed: onSelectTag)
                      else
                        TagChip(
                          label: tag,
                          onDeleted: onDeleteTag,
                          avatarColor: switch (tag) {
                            'neutral' => Colors.blueGrey,
                            'whitelist' => Colors.white,
                            'blacklist' => Colors.black,
                            _ => Colors.transparent,
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () async {
                final confirmed = await confirmDelete();
                if (confirmed) {
                  await onDelete();
                }
              },
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTargetCard extends StatelessWidget {
  final AppColors appColors;
  final VoidCallback onTap;

  const _AddTargetCard({required this.appColors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: appColors.gray.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            width: 2,
            color: appColors.gray.withValues(alpha: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: appColors.accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_rounded, color: appColors.backColor, size: 40,),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add target',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Create another URL entry for pinging.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
