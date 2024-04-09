import 'package:flutter/material.dart';

class BottomCard extends StatelessWidget {
  final String distance;
  final String duration;
  const BottomCard({super.key, required this.distance, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.white,
            
            boxShadow: const [
              BoxShadow(
                  offset: Offset(1.0, 0.0),
                  blurRadius: 20,
                  spreadRadius: 5,
                  color: Colors.grey)
            ]),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "$distance ($duration)",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 24),

                  ),
                ],
              ),
              Image.asset("assets/car.png",height: 50,width: 50,)
            ],
          ),
        ),
      ),
    );
  }
}
