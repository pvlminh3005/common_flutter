part of gallery_media_picker;

class PickerDecoration {
  Widget? cancelIcon;

  double blurStrength;

  int columnCount;

  ActionBarPosition actionBarPosition;

  TextStyle? albumTitleStyle;

  TextStyle? albumTextStyle;

  TextStyle? albumCountTextStyle;

  String completeText;

  TextStyle? completeTextStyle;

  ButtonStyle? completeButtonStyle;

  Widget? loadingWidget;

  PickerDecoration({
    this.actionBarPosition = ActionBarPosition.top,
    this.cancelIcon,
    this.columnCount = 3,
    this.blurStrength = 10,
    this.albumTitleStyle,
    this.completeText = '',
    this.completeTextStyle,
    this.completeButtonStyle,
    this.loadingWidget,
    this.albumTextStyle,
    this.albumCountTextStyle,
  });
}
