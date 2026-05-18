import 'package:flutter/material.dart';

/// Stub HomeShell — S10 will implement the real BottomNavigationBar + tabs.
///
/// Displays a minimal scaffold with a visible label for each tab index.
/// [IndexedStack] is already wired so tab state is preserved on switch.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.initialIndex = 0});

  /// Which tab to show on first render (0 = Habits, 1 = Goals, 2 = Profile).
  final int initialIndex;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _labels = ['Habits', 'Goals', 'Profile'];

  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('home_shell'),
      body: IndexedStack(
        key: const Key('home_shell_stack'),
        index: _index,
        children: List.generate(
          3,
          (i) => Center(
            key: Key('home_tab_$i'),
            child: Text(
              _labels[i],
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Hábitos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_outlined),
            label: 'Metas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
