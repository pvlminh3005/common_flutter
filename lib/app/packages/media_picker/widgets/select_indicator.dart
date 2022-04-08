part of media_picker;

class SelectedBackdrop extends StatelessWidget {
  const SelectedBackdrop({
    Key? key,
    required this.selected,
    required this.onReview,
  }) : super(key: key);
  final bool selected;
  final VoidCallback onReview;
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        child: AnimatedContainer(
          duration: switchingPathDuration,
          color: selected
              ? Colors.black.withOpacity(0.45)
              : Colors.black.withOpacity(0.1),
        ),
        onTap: onReview,
      ),
    );
  }
}

class SelectIndicator extends StatelessWidget {
  const SelectIndicator({
    Key? key,
    required this.selected,
    required this.onTap,
    required this.isMulti,
    required this.gridCount,
    required this.selectText,
  }) : super(key: key);
  final bool selected;
  final VoidCallback onTap;
  final bool isMulti;
  final int gridCount;
  final String selectText;

  @override
  Widget build(BuildContext context) {
    final double indicatorSize = context.width / gridCount / 4;
    return Positioned(
      top: 0.0,
      right: 0.0,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: indicatorSize,
          height: indicatorSize,
          margin: EdgeInsets.all(
            context.width / gridCount / (isAppleOS ? 12.0 : 15.0),
          ),
          child: AnimatedContainer(
            duration: switchingPathDuration,
            width: indicatorSize / (isAppleOS ? 1.25 : 1.5),
            height: indicatorSize / (isAppleOS ? 1.25 : 1.5),
            decoration: BoxDecoration(
              border: !selected
                  ? Border.all(color: Colors.white, width: 2.0)
                  : null,
              color: selected ? Theme.of(context).primaryColor : null,
              shape: BoxShape.circle,
            ),
            child: AnimatedSwitcher(
              duration: switchingPathDuration,
              reverseDuration: switchingPathDuration,
              child: selected
                  ? isMulti
                      ? Text(
                          selectText,
                          style: TextStyle(
                            color: selected ? Colors.white : null,
                            fontSize: isAppleOS ? 16.0 : 14.0,
                            fontWeight:
                                isAppleOS ? FontWeight.w600 : FontWeight.bold,
                          ),
                        )
                      : const Icon(Icons.check, size: 18.0, color: Colors.white)
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}
