import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter/material.dart';

class SignBoardWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  const SignBoardWidget({
    Key? key,
    required this.message,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  icon,
                  color: Default_Theme.primaryColor2.withValues(alpha: 0.7),
                  size: 40,
                ),
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Default_Theme.tertiaryTextStyle.merge(TextStyle(
                    color: Default_Theme.primaryColor2.withValues(alpha: 0.7),
                    fontSize: 14)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
