part of media_picker;

class DurationIndicator extends StatelessWidget {
  const DurationIndicator({Key? key, required this.duration}) : super(key: key);
  final int duration;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.3),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.only(
          right: 3,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_arrow, color: Colors.white, size: 12),
            Text(
              Duration(seconds: duration).toString().substring(2, 7),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
