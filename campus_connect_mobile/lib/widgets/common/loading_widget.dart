import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String message;
  final double? size;
  final Color? color;

  const LoadingWidget({
    Key? key,
    this.message = 'Loading...',
    this.size,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 50.0,
            height: size ?? 50.0,
            child: CircularProgressIndicator(
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: color ?? Theme.of(context).colorScheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }
}
