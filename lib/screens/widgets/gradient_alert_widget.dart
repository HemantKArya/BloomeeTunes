import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter/material.dart';

class GradientDialog extends StatefulWidget {
  final String message;
  final Future<void> Function(String)? onOk;
  final String? okText;
  final String downloadURL;
  const GradientDialog(
    this.message, {
    this.onOk,
    this.okText,
    required this.downloadURL,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _GradientDialogState();
  }
}

class _GradientDialogState extends State<GradientDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
            height: 200.0,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.pink],
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
                // stops: [0.5, 1.9],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10.0, right: 8, left: 8, bottom: 10.0),
                  child: Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: "ReThink-Sans",
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Text('Cancel',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "ReThink-Sans",
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    OutlinedButton(
                        onPressed: () {
                          if (widget.onOk != null) {
                            widget.onOk!(widget.downloadURL);
                          }
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Default_Theme.accentColor1,
                          side: const BorderSide(
                              color: Default_Theme.accentColor1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                        ),
                        child: Text(widget.okText ?? "OK",
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: "ReThink-Sans",
                              fontSize: 15,
                            ))),
                  ],
                )
              ],
            )),
      ),
      contentPadding: const EdgeInsets.all(0.0),
    );
  }
}
