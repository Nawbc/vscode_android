import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'droid_modal.dart';

class FocusedMenuItem {
  Color? backgroundColor;
  Widget title;
  Icon? trailingIcon;
  final Function onPressed;

  FocusedMenuItem({
    this.trailingIcon,
    this.backgroundColor,
    required this.title,
    required this.onPressed,
  });
}

class FocusedMenuHolder extends StatefulWidget {
  final Widget child;

  final double? menuItemExtent;

  final double? menuWidth;

  final List<FocusedMenuItem> menuItems;

  final bool? animateMenuItems;

  final BoxDecoration? menuBoxDecoration;

  final Duration? duration;

  final Color? maskColor;

  final double? bottomOffsetHeight;

  final double? offsetY;

  final ImageFilter? filter;

  // 兼容 CupertinoTabBar
  final Widget? icon;

  final Widget? activeIcon;

  final Widget? title;

  final Color? backgroundColor;

  const FocusedMenuHolder({
    Key? key,
    required this.child,
    required this.menuItems,
    this.duration,
    this.menuBoxDecoration,
    this.menuItemExtent,
    this.animateMenuItems,
    this.maskColor,
    this.menuWidth,
    this.bottomOffsetHeight,
    this.offsetY,
    this.filter,
    this.icon,
    this.activeIcon,
    this.title,
    this.backgroundColor,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FocusedMenuHolderState createState() => _FocusedMenuHolderState();
}

class _FocusedMenuHolderState extends State<FocusedMenuHolder> {
  GlobalKey containerKey = GlobalKey();
  Offset childOffset = const Offset(0, 0);
  late Size _childSize;

  getOffset() {
    BuildContext? buildContext = containerKey.currentContext;
    Size? size = buildContext!.size;
    RenderBox? renderBox = buildContext.findRenderObject() as RenderBox?;
    Offset? offset = renderBox?.localToGlobal(Offset.zero);
    setState(() {
      if (offset != null && size != null) {
        childOffset = Offset(offset.dx, offset.dy);
        _childSize = size;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: containerKey,
      onTap: () async {
        getOffset();
        await Navigator.of(context, rootNavigator: true).push(
          DroidModalPopupRoute(
            barrierColor: widget.maskColor ??
                CupertinoDynamicColor.resolve(
                  const CupertinoDynamicColor.withBrightness(
                    color: Color(0x33000000),
                    darkColor: Color(0x7A302424),
                  ),
                  context,
                ),
            builder: (context) {
              return FocusedMenuDetails(
                itemExtent: widget.menuItemExtent,
                menuBoxDecoration: widget.menuBoxDecoration,
                childOffset: childOffset,
                childSize: _childSize,
                menuItems: widget.menuItems,
                menuWidth: widget.menuWidth,
                animateMenu: widget.animateMenuItems ?? true,
                bottomOffsetHeight: widget.bottomOffsetHeight ?? 0,
                menuOffset: widget.offsetY ?? 0,
                child: widget.child,
              );
            },
            filter: widget.filter,
            semanticsDismissible: null,
          ),
        );
      },
      // onLongPress:
      child: widget.child,
    );
  }
}

class FocusedMenuDetails extends StatelessWidget {
  final List<FocusedMenuItem> menuItems;
  final BoxDecoration? menuBoxDecoration;
  final Offset childOffset;
  final double? itemExtent;
  final Size childSize;
  final Widget child;
  final bool animateMenu;

  final double? menuWidth;

  final double bottomOffsetHeight;
  final double menuOffset;

  const FocusedMenuDetails({
    Key? key,
    this.itemExtent,
    this.menuWidth,
    this.menuBoxDecoration,
    required this.child,
    required this.menuItems,
    required this.childOffset,
    required this.childSize,
    required this.bottomOffsetHeight,
    required this.menuOffset,
    required this.animateMenu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final maxMenuHeight = size.height * 0.45;
    final listHeight = menuItems.length * (itemExtent ?? 50.0);

    final maxMenuWidth = menuWidth ?? (size.width * 0.70);
    final menuHeight = listHeight < maxMenuHeight ? listHeight : maxMenuHeight;
    final leftOffset = (childOffset.dx + maxMenuWidth) < size.width
        ? childOffset.dx
        : (childOffset.dx - maxMenuWidth + childSize.width);
    final topOffset = (childOffset.dy + menuHeight + childSize.height) < size.height - bottomOffsetHeight
        ? childOffset.dy + childSize.height + menuOffset
        : childOffset.dy - menuHeight - menuOffset;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),
          Positioned(
            top: topOffset,
            left: leftOffset,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 200),
              builder: (BuildContext context, value, Widget? iChild) {
                return Transform.scale(
                  scale: value,
                  alignment: Alignment.center,
                  child: iChild,
                );
              },
              tween: Tween(begin: 0.0, end: 1.0),
              child: Container(
                width: maxMenuWidth,
                height: menuHeight,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  child: ListView.builder(
                    itemCount: menuItems.length,
                    padding: EdgeInsets.zero,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      FocusedMenuItem item = menuItems[index];
                      Widget listItem = GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          item.onPressed();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          color: item.backgroundColor ?? const Color(0xE8FFFFFF),
                          height: itemExtent ?? 50.0,
                          margin: const EdgeInsets.only(bottom: 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                if (item.trailingIcon != null) ...[item.trailingIcon as Widget],
                                item.title,
                              ],
                            ),
                          ),
                        ),
                      );
                      if (animateMenu) {
                        return TweenAnimationBuilder<double>(
                            builder: (context, value, iChild) {
                              return Transform(
                                transform: Matrix4.rotationX(1.5708 * value),
                                alignment: Alignment.bottomCenter,
                                child: iChild,
                              );
                            },
                            tween: Tween(begin: 1.0, end: 0.0),
                            duration: Duration(milliseconds: index * 200),
                            child: listItem);
                      } else {
                        return listItem;
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
