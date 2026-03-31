import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../modules/dashboard/controllers/dashboard_controller.dart';
import 'app_colors.dart';

Widget sidebarItem({
  required IconData icon,
  required String title,
  required bool collapsed,
  required int index,
  required DashboardController nav,
}) {
  return Obx(() {
    final isSelected = nav.selectedIndex.value == index;

    return InkWell(
      onTap: () => nav.changePage(index),
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.contentColorBlue.withAlpha(100)
                  : Colors.transparent,
        ),
        child: Row(
          children: [
            /// LEFT INDICATOR
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 4,
              height: 48,
              color:
                  isSelected
                      ? AppColors.contentColorWhite.withAlpha(100)
                      : Colors.transparent,
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                    if (!collapsed) ...[
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  });
}

Widget sidebarExpansion({
  // required BuildContext context,
  required IconData icon,
  required String title,
  required int index,
  required List<Widget> children,
  required DashboardController nav,
}) {
  return Obx(() {
    final collapsed = nav.isCollapsed.value;
    final isOpen = nav.expandedIndex.value == index;

    return Builder(
      builder: (ctx) {
        return MouseRegion(
          onEnter: (_) {
            _closeTimer?.cancel();
            if (collapsed) {
              _showFloatingMenu(ctx, children);
            }
          },
          onExit: (_) {
            if (collapsed) {
              _scheduleClose();
            }
          },
          child: Column(
            children: [
              Tooltip(
                message: collapsed ? title : "",
                child: InkWell(
                  onTap: () {
                    if (collapsed) {
                      _showFloatingMenu(ctx, children);
                    } else {
                      nav.toggleExpansion(index);
                    }
                  },
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(icon, color: Colors.white),
                        if (!collapsed) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          AnimatedRotation(
                            turns: isOpen ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color:
                                    isOpen
                                        ? Colors.white.withOpacity(.5)
                                        : Colors.transparent,
                              ),
                              child: const Icon(
                                Icons.expand_more,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              /// 🔥 Animated Dropdown
              if (!collapsed)
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState:
                      isOpen
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                  firstChild: Column(children: children),
                  secondChild: const SizedBox(),
                ),
            ],
          ),
        );
      },
    );
  });
}

Widget sidebarSubItem({
  required IconData icon,
  required String title,
  required int index,
  required DashboardController nav,
}) {
  return Obx(() {
    final isSelected = nav.selectedIndex.value == index;

    return InkWell(
      onTap: () {
        nav.changePage(index);
        Get.back();
      },
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.contentColorBlue.withAlpha(100)
                  : Colors.transparent,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 4,
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? AppColors.contentColorWhite.withAlpha(100)
                        : Colors.transparent,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Icon(icon, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        title,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  });
}

OverlayEntry? _floatingMenu;
Timer? _closeTimer;
bool _mouseOnMenu = false;
void _showFloatingMenu(BuildContext context, List<Widget> children) {
  final overlay = Overlay.of(context);

  /// 🔥 selalu remove menu lama
  _floatingMenu?.remove();
  _floatingMenu = null;
  RenderBox box = context.findRenderObject() as RenderBox;
  Offset pos = box.localToGlobal(Offset.zero);
  _floatingMenu = OverlayEntry(
    builder: (context) {
      return Positioned(
        left: pos.dx + box.size.width,
        top: pos.dy,
        child: MouseRegion(
          onEnter: (_) {
            _mouseOnMenu = true;
            _closeTimer?.cancel();
          },
          onExit: (_) {
            _mouseOnMenu = false;
            _scheduleClose();
          },
          child: Material(
            elevation: 8,
            child: Container(
              width: 180,
              color: Colors.blueGrey[900],
              child: Column(mainAxisSize: MainAxisSize.min, children: children),
            ),
          ),
        ),
      );
    },
  );

  overlay.insert(_floatingMenu!);
}

void _hideFloatingMenu() {
  _closeTimer?.cancel();
  _floatingMenu?.remove();
  _floatingMenu = null;
}

void _scheduleClose() {
  _closeTimer?.cancel();

  _closeTimer = Timer(const Duration(milliseconds: 200), () {
    if (!_mouseOnMenu) {
      _hideFloatingMenu();
    }
  });
}
