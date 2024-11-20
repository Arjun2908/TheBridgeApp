import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? additionalActions;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;

  const CommonAppBar({
    super.key,
    required this.title,
    this.additionalActions,
    this.bottom,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      actions: [
        if (additionalActions != null) ...additionalActions!,
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => Navigator.pushNamed(context, '/settings'),
        ),
      ],
      bottom: bottom,
      forceMaterialTransparency: true,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(bottom != null ? kToolbarHeight + bottom!.preferredSize.height : kToolbarHeight);
}
