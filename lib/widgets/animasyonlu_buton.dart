import 'package:flutter/material.dart';

class AnimasyonluButon extends StatefulWidget {
  final Widget child;
  final Function onTap;
  final double height;
  final double width;
  const AnimasyonluButon({
    super.key,
    required this.child,
    required this.onTap,
    this.height = 100,
    this.width = 100,
  });

  @override
  State<AnimasyonluButon> createState() => AnimasyonluButonState();
}

class AnimasyonluButonState extends State<AnimasyonluButon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = Tween<double>(begin: 1.0, end: 0.9).animate(_controller);

    _controller.addListener(() {
      setState(() {});
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward(from: 0.0); // Tetikleme
        widget.onTap();
      },
      child: Transform.scale(
        scale: _animation.value,
        child: SizedBox(
          height: widget.height,
          width: widget.width,
          child: widget.child,
        ),
      ),
    );
  }
}
