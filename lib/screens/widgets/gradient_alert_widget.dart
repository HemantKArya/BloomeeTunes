import 'package:flutter/material.dart';

class GradientPreset {
  final String name;
  final Color start;
  final Color end;
  final Color buttonColor; // primary color to use for buttons
  const GradientPreset(this.name, this.start, this.end, this.buttonColor);
}

class GradientDialogAction {
  final String label;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isText; // render as plain text button (no background)
  const GradientDialogAction(this.label,
      {this.onPressed, this.isDestructive = false, this.isText = false});
}

class GradientDialog extends StatefulWidget {
  final String title;
  final String? content;
  final Widget? contentWidget;
  final List<GradientDialogAction>? actions;
  final int presetIndex; // choose which preset to use (index into presets)

  const GradientDialog(
    this.title, {
    this.content,
    this.contentWidget,
    this.actions,
    this.presetIndex = 0,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _GradientDialogState();
  }
}

class _GradientDialogState extends State<GradientDialog> {
  // Presets curated for dark-themed UIs. Slightly darker / more saturated
  // variants so white text remains readable while keeping the same palettes.
  static const List<GradientPreset> presets = [
    GradientPreset('Pink Sunset', Color(0xFFFF3B5A), Color(0xFFFFB570),
        Color(0xFFE63A63)), // default (darker pink-to-warm)
    GradientPreset('Cherry Blossom', Color(0xFFFF9DB8), Color(0xFFFFC9DE),
        Color(0xFFFF7FA6)),
    GradientPreset(
        'Sky Blue', Color(0xFF38A8FF), Color(0xFF6FD9FF), Color(0xFF1E90FF)),
    GradientPreset(
        'Lavender', Color(0xFF7A4DFF), Color(0xFFFF6FB3), Color(0xFF6B3CFF)),
    GradientPreset(
        'Mint', Color(0xFF3ED6A5), Color(0xFF24C1A0), Color(0xFF12B886)),
    GradientPreset(
        'Ocean', Color(0xFF0F84D4), Color(0xFF00A8E6), Color(0xFF007ACC)),
    GradientPreset(
        'Aurora', Color(0xFF00D28C), Color(0xFF00A3E6), Color(0xFF00B57A)),
    GradientPreset(
        'Peach', Color(0xFFFF8C5A), Color(0xFFFFB177), Color(0xFFFF6F3D)),
  ];

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final presetIndex =
        (widget.presetIndex >= 0 && widget.presetIndex < presets.length)
            ? widget.presetIndex
            : 0;
    final preset = presets[presetIndex];

    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      content: ClipRRect(
        borderRadius: BorderRadius.circular(14.0),
        child: Container(
          constraints: BoxConstraints(
            // Keep dialog compact and responsive; never full-screen
            maxWidth: mq.width * 0.9 < 520 ? mq.width * 0.9 : 520,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF2E2E33), // plain grey dark background
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: Colors.white.withOpacity(0.04), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Small gradient header strip with centered title
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [preset.start, preset.end],
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: "ReThink-Sans",
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              // Body area (keeps plain background)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.contentWidget != null) widget.contentWidget!,
                    if (widget.contentWidget == null && widget.content != null)
                      Text(
                        widget.content!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontFamily: 'ReThink-Sans',
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),

              // Buttons row
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Build action buttons from provided list. If none provided,
                    // show a single OK button that just closes the dialog.
                    ...?_buildActions(context, preset),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget>? _buildActions(BuildContext context, GradientPreset preset) {
    if (widget.actions == null || widget.actions!.isEmpty) {
      return [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: preset.buttonColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          ),
          child: const Text('OK'),
        ),
      ];
    }

    final List<Widget> built = [];
    for (var i = 0; i < widget.actions!.length; i++) {
      final a = widget.actions![i];
      Widget btn;
      if (a.isDestructive) {
        btn = TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            a.onPressed?.call();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            textStyle:
                const TextStyle(fontFamily: 'ReThink-Sans', fontSize: 15),
          ),
          child: Text(a.label),
        );
      } else if (a.isText) {
        btn = TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            a.onPressed?.call();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            textStyle: const TextStyle(
                fontFamily: 'ReThink-Sans',
                fontSize: 15,
                fontWeight: FontWeight.w600),
          ),
          child: Text(a.label),
        );
      } else {
        btn = ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            a.onPressed?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: preset.buttonColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            textStyle:
                const TextStyle(fontFamily: 'ReThink-Sans', fontSize: 15),
          ),
          child: Text(a.label),
        );
      }

      built.add(Padding(
        padding: EdgeInsets.only(left: i == 0 ? 0 : 12),
        child: btn,
      ));
    }

    return built;
  }
}
