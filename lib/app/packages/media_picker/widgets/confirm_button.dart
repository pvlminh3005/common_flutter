part of media_picker;

class ConfirmButton extends StatelessWidget {
  const ConfirmButton({
    Key? key,
    required this.items,
    required this.isMulti,
    required this.limit,
  }) : super(key: key);

  final List<AssetEntity> items;
  final bool isMulti;
  final int limit;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: items.isNotEmpty ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: MaterialButton(
        height: 32,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        color: Theme.of(context).backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Text(
          isMulti ? 'Select (${items.length}/$limit)' : 'Select',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        onPressed: () {
          if (items.isNotEmpty) {
            Navigator.of(context).pop(items);
          }
        },
      ),
    );
  }
}
