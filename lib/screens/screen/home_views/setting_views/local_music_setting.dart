import 'dart:io';

import 'package:Bloomee/blocs/local_music/cubit/local_music_cubit.dart';
import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/setting_shared_widgets.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/local_music_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:path/path.dart' as p;

class LocalMusicSettings extends StatefulWidget {
  const LocalMusicSettings({super.key});

  @override
  State<LocalMusicSettings> createState() => _LocalMusicSettingsState();
}

class _LocalMusicSettingsState extends State<LocalMusicSettings> {
  late final SettingsDAO _settingsDao;

  bool _autoScan = true;
  String _lastScan = '';
  List<String> _folders = [];
  bool _scanning = false;

  LocalMusicCubit get _cubit => context.read<LocalMusicCubit>();

  @override
  void initState() {
    super.initState();
    _settingsDao = SettingsDAO(DBProvider.db);
    _load();
  }

  Future<void> _load() async {
    final autoScan = await _settingsDao.getSettingBool(
      SettingKeys.localMusicAutoScan,
      defaultValue: true,
    );
    final lastScan = await _settingsDao.getSettingStr(
      SettingKeys.localMusicLastScan,
      defaultValue: '',
    );
    final folders = await _cubit.getFolders();
    if (!mounted) return;
    setState(() {
      _autoScan = autoScan ?? true;
      _lastScan = lastScan ?? '';
      _folders = folders;
    });
  }

  Future<void> _scanNow() async {
    setState(() => _scanning = true);
    try {
      await _cubit.scan();
      final lastScan = await _settingsDao.getSettingStr(
        SettingKeys.localMusicLastScan,
        defaultValue: '',
      );
      if (mounted) setState(() => _lastScan = lastScan ?? '');
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _addFolder() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path == null) return;
    await _cubit.addFolder(path);
    final folders = await _cubit.getFolders();
    if (mounted) setState(() => _folders = folders);
  }

  Future<void> _removeFolder(String path) async {
    await _cubit.removeFolder(path);
    final folders = await _cubit.getFolders();
    if (mounted) setState(() => _folders = folders);
  }

  String _formatLastScan(String iso) {
    if (iso.isEmpty) return 'Never';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Center(
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Default_Theme.primaryColor1,
                size: 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          'Local Tracks',
          style: const TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ).merge(Default_Theme.secondoryTextStyleMedium),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          const SettingSectionHeader(label: 'Scanning'),
          SettingCard(
            children: [
              SettingToggleTile(
                icon: MingCute.refresh_2_line,
                title: 'Auto Scan on Startup',
                subtitle:
                    'Automatically scan for new local tracks when the app starts.',
                value: _autoScan,
                onChanged: (v) async {
                  setState(() => _autoScan = v);
                  await _settingsDao.putSettingBool(
                      SettingKeys.localMusicAutoScan, v);
                },
              ),
              const SettingDivider(),
              SettingNavTile(
                icon: MingCute.time_line,
                title: 'Last Scan',
                subtitle: _formatLastScan(_lastScan),
                onTap: () {},
              ),
              const SettingDivider(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _scanning ? null : _scanNow,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
                  highlightColor:
                      Default_Theme.primaryColor2.withValues(alpha: 0.05),
                  splashColor:
                      Default_Theme.primaryColor2.withValues(alpha: 0.05),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        SettingIconBox(
                          icon: _scanning
                              ? Icons.hourglass_empty_rounded
                              : MingCute.search_line,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Scan Now',
                                style: TextStyle(
                                  color: Default_Theme.primaryColor2,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _scanning
                                    ? 'Scanning in progress…'
                                    : 'Manually trigger a full library scan.',
                                style: TextStyle(
                                  color: Default_Theme.primaryColor2
                                      .withValues(alpha: 0.5),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_scanning)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Default_Theme.accentColor2,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Folder management — desktop only
          if (!LocalMusicService.isMobile && !Platform.isIOS) ...[
            const SizedBox(height: 28),
            const SettingSectionHeader(label: 'Music Folders'),
            SettingCard(
              children: [
                if (_folders.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Text(
                      'No folders added. Add a folder to start scanning.',
                      style: TextStyle(
                        color:
                            Default_Theme.primaryColor2.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ..._folders.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final folder = entry.value;
                  final isLast = idx == _folders.length - 1;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            const SettingIconBox(
                                icon: MingCute.folder_open_line),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.basename(folder),
                                    style: const TextStyle(
                                      color: Default_Theme.primaryColor2,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    folder,
                                    style: TextStyle(
                                      color: Default_Theme.primaryColor2
                                          .withValues(alpha: 0.45),
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline,
                                size: 20,
                                color: Default_Theme.primaryColor2
                                    .withValues(alpha: 0.6),
                              ),
                              onPressed: () => _removeFolder(folder),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast) const SettingDivider(),
                    ],
                  );
                }),
                if (_folders.isNotEmpty) const SettingDivider(),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _addFolder,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20)),
                    highlightColor:
                        Default_Theme.primaryColor2.withValues(alpha: 0.05),
                    splashColor:
                        Default_Theme.primaryColor2.withValues(alpha: 0.05),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          const SettingIconBox(
                            icon: Icons.create_new_folder_outlined,
                            color: Default_Theme.accentColor2,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'Add Folder',
                            style: const TextStyle(
                              color: Default_Theme.accentColor2,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ).merge(Default_Theme.secondoryTextStyleMedium),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
