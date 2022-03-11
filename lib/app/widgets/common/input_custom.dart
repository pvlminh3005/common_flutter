import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputCustom extends StatefulWidget {
  final String? hintText, labelText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextStyle? style;
  final Color backgroundColor, borderColor;
  final double radius, borderWidth;
  final bool enable, readOnly, showBorder, isUnderBorder;
  final bool showPrefixIcon, showSuffixIcon, showClear, isPassword;
  final Widget? prefixIcon, suffixIcon;
  final int? maxLength, minLines, maxLines;
  final EdgeInsetsGeometry? margin, contentPadding;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final Function(String?)? onChanged, onSubmitted;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const InputCustom({
    this.hintText,
    this.labelText,
    this.controller,
    this.focusNode,
    this.style,
    this.backgroundColor = Colors.transparent,
    this.borderColor = Colors.grey,
    this.radius = 5.0,
    this.borderWidth = .8,
    this.enable = true,
    this.readOnly = false,
    this.showBorder = true,
    this.isUnderBorder = false,
    this.showPrefixIcon = true,
    this.showSuffixIcon = true,
    this.showClear = false,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLength,
    this.minLines = 1,
    this.maxLines = 1,
    this.margin,
    this.contentPadding,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    Key? key,
  }) : super(key: key);

  @override
  State<InputCustom> createState() => _InputCustomState();
}

class _InputCustomState extends State<InputCustom> {
  bool obscureText = true;
  bool showClear = false;
  @override
  Widget build(BuildContext context) {
    final style = widget.style ??
        TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        );
    final borderSide = BorderSide(
      width: widget.borderWidth,
      color: widget.showBorder ? widget.borderColor : Colors.transparent,
    );
    final border = widget.isUnderBorder
        ? UnderlineInputBorder(borderSide: borderSide)
        : OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.radius),
            borderSide: borderSide,
          );

    return Padding(
      padding: widget.margin ?? const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        style: style,
        maxLength: widget.maxLength,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        obscureText: widget.isPassword ? obscureText : false,
        onChanged: (value) {
          showClear = false;
          //? check show clear button
          if (widget.showClear && value.length != 0) {
            showClear = true;
          }
          setState(() {});

          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        },
        onFieldSubmitted: widget.onSubmitted,
        textInputAction: widget.textInputAction,
        inputFormatters: widget.inputFormatters,
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
          hintStyle: style.copyWith(color: Colors.grey.shade500),
          labelStyle: style.copyWith(color: Colors.grey.shade500),
          contentPadding: widget.contentPadding ??
              const EdgeInsets.fromLTRB(10, 20, 12, 20),
          counterText: '',
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(
              width: widget.borderWidth + .5,
              color: Theme.of(context).primaryColor,
            ),
          ),
          filled: widget.backgroundColor != Colors.transparent,
          fillColor: widget.backgroundColor,
          prefixIcon: widget.showPrefixIcon ? widget.prefixIcon : null,
          suffixIcon: widget.isPassword
              ? IconButton(
                  onPressed: () => setState(() => obscureText = !obscureText),
                  icon: Icon(
                    !obscureText
                        ? CupertinoIcons.eye_slash_fill
                        : CupertinoIcons.eye_fill,
                  ),
                )
              : widget.showSuffixIcon
                  ? widget.showClear
                      ? showClear
                          ? IconButton(
                              onPressed: () {
                                widget.controller!.clear();
                                setState(() => showClear = false);
                              },
                              icon: Icon(CupertinoIcons.xmark),
                            )
                          : const SizedBox.shrink()
                      : widget.suffixIcon
                  : null,
        ),
      ),
    );
  }
}
