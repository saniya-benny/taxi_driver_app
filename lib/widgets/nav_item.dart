import 'package:flutter/material.dart';


class NavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final bool isSelected;
  final ValueChanged<int> onTap;

  const NavItem({
    required this.icon,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: AnimatedScale(
          scale: isSelected ? 1.3 : 1.0,
          duration: const Duration(milliseconds: 250),
          child: Icon(
            icon,
            size: 28,
            color: isSelected ? const Color(0xFF0B2A3A) : Colors.white70,
          ),
        ),
      ),
    );
  }
}