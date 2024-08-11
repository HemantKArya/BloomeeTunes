part of 'playlist_screen.dart';

class InfoTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color fg;
  final Function()? onTap;
  const InfoTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.fg = Default_Theme.primaryColor1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      dense: true,
      title: Text(
        title,
        style: Default_Theme.secondoryTextStyle.merge(
          TextStyle(
              color: fg.withOpacity(0.5), fontSize: 13, fontFamily: 'Unageo'),
        ),
      ),
      hoverColor: Colors.transparent,
      selectedColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      subtitle: SelectableText(
        subtitle,
        style: Default_Theme.secondoryTextStyle.merge(
          TextStyle(color: fg, fontSize: 15, fontFamily: 'NotoSans'),
        ),
      ),
      leading: Icon(
        icon,
        size: 20,
        color: fg,
      ),
    );
  }
}

String getArtists(List<MediaItemModel> mediaItems) {
  String artists = "";
  List<String> artistList = [];

  for (int i = 0; i < mediaItems.length; i++) {
    if (mediaItems[i].artist != null) {
      artistList.add(mediaItems[i].artist!);
    }
    if (artistList.length > 4) {
      break;
    }
  }
  artists = artistList.toSet().join(", ");
  artists = "$artists +";
  return artists;
}

Future<dynamic> showPlaylistInfo(
  BuildContext context,
  CurrentPlaylistState state, {
  Color bgColor = const Color.fromARGB(255, 15, 0, 19),
  Color fgColor = Default_Theme.primaryColor1,
}) {
  bgColor =
      bgColor == Colors.black ? const Color.fromARGB(255, 15, 0, 19) : bgColor;
  fgColor = fgColor == Colors.white ? Default_Theme.primaryColor1 : fgColor;
  return showDialog(
    context: context,
    useSafeArea: true,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
          backgroundColor: bgColor,
          shadowColor: bgColor,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(
                        state.mediaPlaylist.playlistName,
                        style: Default_Theme.secondoryTextStyle.merge(
                          TextStyle(
                              color: fgColor,
                              fontSize: 16,
                              fontFamily: 'NotoSans',
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    InfoTile(
                      title: "Playlist Length",
                      subtitle:
                          state.mediaPlaylist.mediaItems.length.toString(),
                      icon: MingCute.playlist_2_line,
                      fg: fgColor,
                    ),
                    InfoTile(
                      title: "Artists",
                      subtitle: state.mediaPlaylist.artists ??
                          getArtists(state.mediaPlaylist.mediaItems),
                      icon: MingCute.group_fill,
                      fg: fgColor,
                    ),
                    state.mediaPlaylist.description != null
                        ? InfoTile(
                            title: "Description",
                            subtitle: state.mediaPlaylist.description!,
                            icon: MingCute.document_2_line,
                            fg: fgColor,
                          )
                        : const SizedBox.shrink(),
                    state.mediaPlaylist.lastUpdated != null
                        ? InfoTile(
                            title: "Last Updated",
                            subtitle: state.mediaPlaylist.lastUpdated
                                    ?.toIso8601String() ??
                                "",
                            icon: MingCute.history_line,
                            fg: fgColor,
                          )
                        : const SizedBox.shrink(),
                    state.mediaPlaylist.source != null
                        ? InfoTile(
                            title: "Source",
                            subtitle: state.mediaPlaylist.source!,
                            icon: MingCute.server_line,
                            fg: fgColor,
                          )
                        : const SizedBox.shrink(),
                    state.mediaPlaylist.permaURL != null
                        ? InfoTile(
                            title: "Original URL",
                            subtitle: state.mediaPlaylist.permaURL!,
                            icon: MingCute.external_link_line,
                            fg: fgColor,
                            onTap: () {
                              Clipboard.setData(ClipboardData(
                                  text: state.mediaPlaylist.permaURL!));
                              SnackbarService.showMessage(
                                  "URL Copied to Clipboard");
                            },
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ));
    },
  );
}
