import 'package:Bloomee/screens/widgets/ambient_artwork_texture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('blur is baked into a bounded texture and reused on rebuild',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.runAsync(() => precacheImage(
          ResizeImage.resizeIfNeeded(256, 256,
              const AssetImage('assets/icons/bloomee_new_logo_c.png')),
          tester.element(find.byType(SizedBox).first),
        ));
    Widget view(String url) => MaterialApp(
          home: AmbientArtworkTexture(imageUrl: url),
        );
    await tester.pumpWidget(view('asset:preview'));
    // Picture.toImage completes on the real engine, outside fake test time.
    for (var i = 0; i < 30 && find.byType(RawImage).evaluate().isEmpty; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    final image = tester.widget<RawImage>(find.byType(RawImage)).image!;
    expect(image.width, 256);
    expect(image.height, 256);
    expect(find.byType(ImageFiltered), findsNothing);
    expect(find.byType(BackdropFilter), findsNothing);
    await tester.pumpWidget(view('asset:preview'));
    expect(tester.widget<RawImage>(find.byType(RawImage)).image, same(image));

    // Replacing or disposing while another texture is in flight must not
    // publish stale data or dispose the outgoing crossfade child's handle.
    await tester.pumpWidget(view('asset:next'));
    await tester.pumpWidget(view(''));
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pumpAndSettle();
    expect(find.byType(RawImage), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
