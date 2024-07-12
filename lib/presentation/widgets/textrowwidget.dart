
import 'package:flutter/material.dart';
import 'package:movietix_distributor/presentation/constants/colors.dart';

class CoustomRowIcontext extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function? ontap;
  final Color? color;

  const CoustomRowIcontext({
    super.key,
    this.color,
    this.ontap,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: ontap as void Function()? ?? () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              children: [
                Icon(icon, size: 28, color: color ?? MyColor().white),
               const  SizedBox(width: 20),
                Expanded( 
                  child: Text(
                    text,
                    style: TextStyle(color: color ?? MyColor().white, fontSize: 18),
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: color ?? MyColor().white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}