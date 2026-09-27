import 'package:flutter/cupertino.dart';
import 'artwork_widgets.dart';

class OfficeView extends StatelessWidget {
  const OfficeView({super.key});
  @override
  Widget build(BuildContext context) => const ArtworkFrame(
    child: ArtworkImage('office-location', aspectRatio: 2 / 3),
  );
}
