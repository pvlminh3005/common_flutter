part of media_picker;

class LoadingDecoration extends StatelessWidget {
  const LoadingDecoration({
    this.color = Colors.blue,
    this.strokeWidth = 2.0,
    Key? key,
  }) : super(key: key);

  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: color,
      strokeWidth: strokeWidth,
    );
  }
}
