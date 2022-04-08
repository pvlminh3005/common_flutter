part of media_picker;

class Header extends StatelessWidget with PreferredSizeWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MediaPickerProvider>(context, listen: false);
    return AppBar(
      elevation: 0.0,
      backgroundColor: Theme.of(context).backgroundColor,
      leading: CloseButton(onPressed: provider.onBack),
      title: const MediaSelector(),
      actions: [
        SelectedButton(),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
