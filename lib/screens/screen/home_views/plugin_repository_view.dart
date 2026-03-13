import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for Clipboard
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/plugins/blocs/repository/plugin_repository_cubit.dart';
import 'package:Bloomee/plugins/models/plugin_repository.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/screens/screen/home_views/repository_detail_screen.dart';

class PluginRepositoryView extends StatefulWidget {
  const PluginRepositoryView({super.key});

  @override
  State<PluginRepositoryView> createState() => _PluginRepositoryViewState();
}

class _PluginRepositoryViewState extends State<PluginRepositoryView> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<PluginRepositoryCubit>().loadRepositories();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _showAddRepositoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Default_Theme.themeColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
              color: Default_Theme.primaryColor1.withValues(alpha: 0.08)),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        title: const Text(
          'Add Repository',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter the URL of a valid plugin repository JSON file.',
              style: TextStyle(
                color: Default_Theme.primaryColor2.withValues(alpha: 0.65),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 46,
              child: TextField(
                controller: _urlController,
                autofocus: true,
                keyboardType: TextInputType.url,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'https://...',
                  hintStyle: TextStyle(
                      color: Default_Theme.primaryColor1.withValues(alpha: 0.3),
                      fontSize: 14),
                  filled: true,
                  fillColor:
                      Default_Theme.primaryColor1.withValues(alpha: 0.04),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Default_Theme.primaryColor1
                            .withValues(alpha: 0.08)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Default_Theme.primaryColor1
                            .withValues(alpha: 0.08)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color:
                            Default_Theme.primaryColor1.withValues(alpha: 0.2),
                        width: 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _AestheticButton(
              text: 'Add Repository',
              icon: MingCute.add_line,
              color: Default_Theme.accentColor2,
              fullWidth: true,
              onTap: () {
                final url = _urlController.text.trim();
                if (url.isNotEmpty) {
                  context.read<PluginRepositoryCubit>().addRepository(url);
                }
                Navigator.pop(ctx);
                _urlController.clear();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plugin Repositories',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Add a JSON source to browse remote plugins.',
                          style: TextStyle(
                            color: Default_Theme.primaryColor2
                                .withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  _AestheticButton(
                    text: 'Add',
                    icon: MingCute.add_line,
                    color: Default_Theme.accentColor2,
                    onTap: () => _showAddRepositoryDialog(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocConsumer<PluginRepositoryCubit, PluginRepositoryState>(
                listener: (context, state) {
                  if (state is PluginRepositoryError) {
                    SnackbarService.showMessage(state.message);
                  }
                },
                builder: (context, state) {
                  if (state is PluginRepositoryLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: Default_Theme.accentColor2, strokeWidth: 3),
                    );
                  } else if (state is PluginRepositoryLoaded) {
                    if (state.repositories.isEmpty) {
                      return const SignBoardWidget(
                        message: 'No repositories added yet.',
                        icon: MingCute.cloud_snow_line,
                      );
                    }
                    return RefreshIndicator(
                      color: Default_Theme.accentColor2,
                      backgroundColor:
                          Default_Theme.primaryColor1.withValues(alpha: 0.1),
                      onRefresh: () async => await context
                          .read<PluginRepositoryCubit>()
                          .loadRepositories(),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 700;
                          if (isWide) {
                            return GridView.builder(
                              physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 450,
                                mainAxisExtent:
                                    184, // Expanded height to fit the new URL box
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: state.repositories.length,
                              itemBuilder: (context, index) =>
                                  _RepoCard(repo: state.repositories[index]),
                            );
                          }
                          return ListView.separated(
                            physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics()),
                            itemCount: state.repositories.length,
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) =>
                                _RepoCard(repo: state.repositories[index]),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Redesigned Modern Repository Card ──────────────────────────────────────

class _RepoCard extends StatelessWidget {
  final PluginRepositoryModel repo;
  const _RepoCard({required this.repo});

  @override
  Widget build(BuildContext context) {
    final generatedDate = repo.generatedAt == null
        ? 'Unknown update'
        : repo.generatedAt!.toIso8601String().split('T').first;

    return Container(
      decoration: BoxDecoration(
        color: Default_Theme.primaryColor1.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Default_Theme.primaryColor1.withValues(alpha: 0.06)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        RepositoryDetailScreen(repository: repo))),
            splashColor: Default_Theme.primaryColor1.withValues(alpha: 0.06),
            highlightColor: Default_Theme.primaryColor1.withValues(alpha: 0.04),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Header (Icon, Title, Desc, Chevron)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Default_Theme.accentColor2
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Default_Theme.accentColor2
                                  .withValues(alpha: 0.2)),
                        ),
                        child: const Icon(MingCute.cloud_line,
                            size: 20, color: Default_Theme.accentColor2),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              repo.name,
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              repo.description.isEmpty
                                  ? 'No description provided.'
                                  : repo.description,
                              style: TextStyle(
                                  color: Default_Theme.primaryColor2
                                      .withValues(alpha: 0.65),
                                  fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Explicit Navigation Chevron
                      Icon(MingCute.right_line,
                          color: Default_Theme.primaryColor2
                              .withValues(alpha: 0.4),
                          size: 20),
                    ],
                  ),

                  const Spacer(), // Pushes the URL box and footer to the bottom

                  // Row 2: Copiable URL Box
                  Material(
                    color: Default_Theme.primaryColor1.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: repo.url));
                        SnackbarService.showMessage(
                            'Repository URL copied to clipboard');
                      },
                      borderRadius: BorderRadius.circular(10),
                      splashColor:
                          Default_Theme.primaryColor1.withValues(alpha: 0.08),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Default_Theme.primaryColor1
                                  .withValues(alpha: 0.05)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(MingCute.copy_2_line,
                                size: 14,
                                color: Default_Theme.primaryColor2
                                    .withValues(alpha: 0.7)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                repo.url,
                                style: TextStyle(
                                  color: Default_Theme.primaryColor2
                                      .withValues(alpha: 0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Row 3: Footer (Badges + Delete)
                  Row(
                    children: [
                      _Badge(
                          icon: MingCute.plugin_2_line,
                          label: '${repo.plugins.length} plugins'),
                      const SizedBox(width: 8),
                      _Badge(icon: MingCute.clock_2_line, label: generatedDate),
                      const Spacer(),
                      // Muted Premium Delete Button
                      Material(
                        color: Colors.redAccent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () => context
                              .read<PluginRepositoryCubit>()
                              .removeRepository(repo.url),
                          borderRadius: BorderRadius.circular(10),
                          splashColor: Colors.redAccent.withValues(alpha: 0.12),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(MingCute.delete_2_line,
                                color: Colors.redAccent.withValues(alpha: 0.8),
                                size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared UI Helpers ────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Badge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Default_Theme.primaryColor1.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: Default_Theme.primaryColor1.withValues(alpha: 0.03)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: Default_Theme.primaryColor2.withValues(alpha: 0.6),
              size: 11),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: Default_Theme.primaryColor1.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _AestheticButton extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final bool fullWidth;
  final VoidCallback onTap;

  const _AestheticButton({
    required this.text,
    required this.color,
    this.icon,
    this.fullWidth = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: color.withValues(alpha: 0.15),
        highlightColor: color.withValues(alpha: 0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 38,
          width: fullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                    color: color,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
