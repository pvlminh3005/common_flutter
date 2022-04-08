part of media_picker;

class AudioItemViewer extends StatelessWidget {
  const AudioItemViewer({Key? key, this.title}) : super(key: key);
  final String? title;
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: AlignmentDirectional.topStart,
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 5.0),
              child: Text(
                title ?? '',
                style: const TextStyle(fontSize: 12.0),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const Center(child: Icon(Icons.audiotrack)),
        ],
      ),
    );
  }
}
