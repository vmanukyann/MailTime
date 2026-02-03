import 'dart:async';

import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  const CountdownTimer({super.key, required this.targetDate});

  final DateTime targetDate;

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remaining = _calculateRemaining();
      });
    });
  }

  @override
  void didUpdateWidget(covariant CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetDate != widget.targetDate) {
      _remaining = _calculateRemaining();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Duration _calculateRemaining() {
    final now = DateTime.now();
    final difference = widget.targetDate.difference(now);
    return difference.isNegative ? Duration.zero : difference;
  }

  String _format(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    final parts = <String>[];
    if (days > 0) {
      parts.add('$days day${days == 1 ? '' : 's'}');
    }
    parts.add('$hours hour${hours == 1 ? '' : 's'}');
    parts.add('$minutes minute${minutes == 1 ? '' : 's'}');
    parts.add('$seconds second${seconds == 1 ? '' : 's'}');
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) {
      return const Text('Delivering soon...');
    }
    return Text(_format(_remaining));
  }
}
