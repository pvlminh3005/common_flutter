part of media_picker;

class SelectedButton extends StatelessWidget {
  const SelectedButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MediaPickerProvider>(context, listen: false);

    return Center(
      child: Selector<MediaPickerProvider, List<AssetEntity>>(
        selector: (_, MediaPickerProvider e) => e.selects,
        builder: (_, List<AssetEntity> selects, __) {
          return ConfirmButton(
            items: selects,
            isMulti: provider.enableMultiple,
            limit: provider.limit,
          );
        },
      ),
    );
  }
}
