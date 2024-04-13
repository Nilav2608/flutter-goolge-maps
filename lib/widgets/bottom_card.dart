import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String distance;
  final String duration;
  final bool isValidLocation;
  const InfoCard({super.key, required this.distance, required this.duration, required this.isValidLocation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 80,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: isValidLocation? Colors.green.shade400 : Colors.red.shade400,
            boxShadow: const [
              BoxShadow(
                  offset: Offset(1.0, 0.0),
                  blurRadius: 20,
                  spreadRadius: 5,
                  color: Colors.grey)
            ]),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: isValidLocation ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "$distance ($duration)",
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ],
              ),
              Image.asset(
                "assets/car.png",
                height: 50,
                width: 50,
              )
            ],
          ): const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.warning,color: Colors.white,),
                Text(
                          "The selected location is not available",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
              ],
            ),
          ), 
        ),
      ),
    );
  }
}
