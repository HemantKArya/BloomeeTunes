import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:Bloomee/services/db/GlobalDB.dart';
import 'package:Bloomee/services/db/cubit/bloomee_db_cubit.dart';
import 'package:Bloomee/theme_data/default.dart';

void createPlaylistBottomSheet(BuildContext context) {
  final _focusNode = FocusNode();
  showMaterialModalBottomSheet(
    context: context,
    expand: false,
    animationCurve: Curves.easeIn,
    duration: const Duration(milliseconds: 300),
    elevation: 20,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40)),
          child: Container(
            height: (MediaQuery.of(context).size.height * 0.45) + 10,
            color: Default_Theme.accentColor2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Spacer(),
                LayoutBuilder(builder: (context, constraints) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.45,
                    width: constraints.maxWidth,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40)),
                      child: Container(
                        color: Default_Theme.themeColor,
                        child: SingleChildScrollView(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, top: 30),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "Create new Playlist 😍",
                                      style: Default_Theme
                                          .secondoryTextStyleMedium
                                          .merge(const TextStyle(
                                              color: Default_Theme.accentColor2,
                                              fontSize: 35)),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                    top: 10,
                                  ),
                                  child: TextField(
                                    autofocus: true,
                                    textInputAction: TextInputAction.done,
                                    maxLines: 3,
                                    textAlignVertical: TextAlignVertical.center,
                                    textAlign: TextAlign.center,
                                    focusNode: _focusNode,
                                    cursorHeight: 60,
                                    showCursor: true,
                                    cursorWidth: 5,
                                    cursorRadius: const Radius.circular(5),
                                    cursorColor: Default_Theme.accentColor2,
                                    style: const TextStyle(
                                            fontSize: 45,
                                            color: Default_Theme.accentColor2)
                                        .merge(Default_Theme
                                            .secondoryTextStyleMedium),
                                    decoration: const InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              style: BorderStyle.none),
                                          // borderRadius: BorderRadius.circular(50)
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          // borderRadius: BorderRadius.circular(50),
                                        )),
                                    onTapOutside: (event) {
                                      _focusNode.unfocus();
                                    },
                                    onSubmitted: (value) {
                                      _focusNode.unfocus();

                                      if (value.isNotEmpty &&
                                          value.length > 2) {
                                        context
                                            .read<BloomeeDBCubit>()
                                            .addNewPlaylistToDB(MediaPlaylistDB(
                                                playlistName: value));
                                        context.pop();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      );
    },
  );
}
