library fancy_bottom_navigation;

import 'package:fancy_bottom_navigation/internal/tab_item.dart';
import 'package:fancy_bottom_navigation/paint/half_painter.dart';
import 'package:flutter/material.dart';

const double RECTANGLE_SIZE = 60;
const double ARC_HEIGHT = 70;
const double ARC_WIDTH = 90;
// const double CIRCLE_OUTLINE = 10;
const double SHADOW_ALLOWANCE = 60;
const double BAR_HEIGHT = 70;
const double ICON_SIZE=28;

class FancyBottomNavigation extends StatefulWidget {
  FancyBottomNavigation(
      {required this.tabs,
      required this.onTabChangedListener,
      this.key,
      this.initialSelection = 0,
      this.circleColor,
      this.activeIconColor,
      this.inactiveIconColor,
      this.textColor,
      this.barBackgroundColor, this.fontSize, this.unSelected=false})
      : assert(onTabChangedListener != null),
        assert(tabs != null),
        assert(tabs.length > 1 && tabs.length < 6);

  final Function(int position) onTabChangedListener;
  final Color? circleColor;
  final Color? activeIconColor;
  final Color? inactiveIconColor;
  final Color? textColor;
  final Color? barBackgroundColor;
  final List<TabData> tabs;
  final int initialSelection;
  final double? fontSize;
  final bool unSelected;
  final Key? key;

  @override
  FancyBottomNavigationState createState() => FancyBottomNavigationState();
}

class FancyBottomNavigationState extends State<FancyBottomNavigation>
    with TickerProviderStateMixin, RouteAware {
  IconData nextIcon = Icons.search;
  IconData activeIcon = Icons.search;

  int currentSelected = 0;
  double _circleAlignX = 0;
  double _IconAlpha = 1;

  late Color circleColor;
  late Color activeIconColor;
  late Color inactiveIconColor;
  late Color barBackgroundColor;
  late Color textColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    activeIcon = widget.tabs[currentSelected].iconData;

    circleColor = widget.circleColor ??
        ((Theme.of(context).brightness == Brightness.dark)
            ? Colors.white
            : Theme.of(context).primaryColor);

    activeIconColor = widget.activeIconColor ??
        ((Theme.of(context).brightness == Brightness.dark)
            ? Colors.black54
            : Colors.white);

    barBackgroundColor = widget.barBackgroundColor ??
        ((Theme.of(context).brightness == Brightness.dark)
            ? Color(0xFF212121)
            : Colors.white);
    textColor = widget.textColor ??
        ((Theme.of(context).brightness == Brightness.dark)
            ? Colors.white
            : Colors.black54);
    inactiveIconColor = (widget.inactiveIconColor) ??
        ((Theme.of(context).brightness == Brightness.dark)
            ? Colors.white
            : Theme.of(context).primaryColor);
  }

  @override
  void initState() {
    super.initState();
    _setSelected(widget.tabs[widget.initialSelection].key);
  }

  _setSelected(UniqueKey key) {
    int selected = widget.tabs.indexWhere((tabData) => tabData.key == key);

    if (mounted) {
      setState(() {
        currentSelected = selected;
        _circleAlignX = -1 + (2 / (widget.tabs.length - 1) * selected);
        nextIcon = widget.tabs[selected].iconData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:const EdgeInsets.only(right: 10,left: 10,bottom: 10),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Container(
            height: BAR_HEIGHT,
            decoration: BoxDecoration(color: barBackgroundColor, boxShadow: [
              BoxShadow(
                  color: Colors.black12, offset: Offset(0, -1), blurRadius: 8)
            ]),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: widget.tabs
                  .map((t) => TabItem(
                      uniqueKey: t.key,
                      selected: widget.unSelected ?false:t.key == widget.tabs[currentSelected].key,
                      iconData: t.iconData,
                      title: t.title,
                      iconColor: inactiveIconColor,
                      textColor: textColor,
                      fontSize: widget.fontSize!,
                      callbackFunction: (uniqueKey) {
                        int selected = widget.tabs
                            .indexWhere((tabData) => tabData.key == uniqueKey);
                        widget.onTabChangedListener(selected);
                        _setSelected(uniqueKey);
                        _initAnimationAndStart(_circleAlignX, 1);
                      }, ))
                  .toList(),
            ),
          ),
          Visibility(
            visible: !widget.unSelected,
            child: Positioned.fill(
              top: -(SHADOW_ALLOWANCE) / 2,
              child: Container(
                child: AnimatedAlign(
                  duration: Duration(milliseconds: ANIM_DURATION),
                  curve: Curves.easeOut,
                  alignment: Alignment(_circleAlignX, 1),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: FractionallySizedBox(
                      widthFactor: 1 / widget.tabs.length,
                      child: GestureDetector(
                        onTap: widget.tabs[currentSelected].onclick as void
                            Function()?,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            SizedBox(
                                height: ARC_HEIGHT,
                                width: ARC_WIDTH,
                                child: CustomPaint(
                                  painter: HalfPainter(barBackgroundColor),
                                )),
                            SizedBox(
                              height: RECTANGLE_SIZE +20,
                              width: RECTANGLE_SIZE,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(13),
                                    color: circleColor),
                                margin: EdgeInsets.only(bottom: 20),
                                child: Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: AnimatedOpacity(
                                    duration:
                                        Duration(milliseconds: ANIM_DURATION ~/ 5),
                                    opacity: _IconAlpha,
                                    child: Icon(
                                      activeIcon,
                                      size: ICON_SIZE,
                                      color: activeIconColor,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  _initAnimationAndStart(double from, double to) {
    _IconAlpha = 0;

    Future.delayed(Duration(milliseconds: ANIM_DURATION ~/ 5), () {
      setState(() {
        activeIcon = nextIcon;
      });
    }).then((_) {
      Future.delayed(Duration(milliseconds: (ANIM_DURATION ~/ 5 * 3)), () {
        setState(() {
          _IconAlpha = 1;
        });
      });
    });
  }

  void setPage(int page) {
    widget.onTabChangedListener(page);
    _setSelected(widget.tabs[page].key);
    _initAnimationAndStart(_circleAlignX, 1);

    setState(() {
      currentSelected = page;
    });
  }
}

class TabData {
  TabData({required this.iconData, required this.title, this.onclick});

  IconData iconData;
  String title;
  Function? onclick;
  final UniqueKey key = UniqueKey();
}
