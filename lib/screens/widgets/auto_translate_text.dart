import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/services/translation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AutoTranslateText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  const AutoTranslateText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
  });

  @override
  State<AutoTranslateText> createState() => _AutoTranslateTextState();
}

class _AutoTranslateTextState extends State<AutoTranslateText> {
  String _displayedText = "";
  String _currentLanguage = "en";

  @override
  void initState() {
    super.initState();
    _displayedText = widget.text;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.languageCode != current.languageCode,
      builder: (context, state) {
        if (_currentLanguage != state.languageCode) {
          _currentLanguage = state.languageCode;
          _translate();
        }
        return Text(
          _displayedText,
          style: widget.style,
          textAlign: widget.textAlign,
          overflow: widget.overflow,
          maxLines: widget.maxLines,
        );
      },
    );
  }

  Future<void> _translate() async {
    if (_currentLanguage == 'en') {
      if (mounted) {
        setState(() {
          _displayedText = widget.text;
        });
      }
      return;
    }

    final translationService = BloomeeTranslationService();
    final translated = await translationService.translate(widget.text);
    
    if (mounted && translated != _displayedText) {
      setState(() {
        _displayedText = translated;
      });
    }
  }

  @override
  void didUpdateWidget(AutoTranslateText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _translate();
    }
  }
}
