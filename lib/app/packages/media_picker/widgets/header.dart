part of media_picker;

class Header extends StatelessWidget with PreferredSizeWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      leading: CloseButton(),
      title: const MediaSelector(),
      actions: [
        SelectedButton(),
        const SizedBox(width: 10),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
