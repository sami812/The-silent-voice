import 'package:flutter/material.dart';

class Historypage extends StatelessWidget {
  const Historypage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('icons/history.png',width: 20,height: 20,color: Colors.blue,),
            SizedBox(width: 10,),
            Text('History',style: TextStyle(fontSize: 18),),
          ],
        ),
        backgroundColor:Colors.white,
        bottom: PreferredSize(
        preferredSize: Size.fromHeight(2),
        child: Container(
          color: Colors.grey.shade200,
          height: 1.5,
          ),
        ),
      )
    );
  }
}
