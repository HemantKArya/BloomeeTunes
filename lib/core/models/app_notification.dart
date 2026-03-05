class AppNotification {
  final String title;
  final String body;
  final String type;
  final String? url;
  final String? payload;

  const AppNotification({
    required this.title,
    required this.body,
    required this.type,
    this.url,
    this.payload,
  });
}
