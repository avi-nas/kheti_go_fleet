import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

ShowLoading(BuildContext context){
  return showDialog(
      barrierDismissible: true,
      context: context, builder: (context){
    return const CustomLoading();
  });
}

class CustomLoading extends StatelessWidget {
  const CustomLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: LoadingAnimationWidget.halfTriangleDot(
        color: Colors.amberAccent,
        size: 60
    ),
    );
  }
}
