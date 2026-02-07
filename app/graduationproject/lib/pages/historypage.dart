import 'package:flutter/material.dart';

class Historypage extends StatelessWidget {
  const Historypage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.history,color: Colors.blue,),
            //Image.asset('assets/icons/history.png',width: 20,height: 20,color: Colors.blue,),
            const SizedBox(width: 10,),
            Text('History',style: Theme.of(context).textTheme.titleLarge,),
          ],
        ),
        bottom: PreferredSize(
        preferredSize: Size.fromHeight(2),
        child: Container(
          color:Theme.of(context).colorScheme.outline,
          height: 1,
          ),
        ),
      )
    );
  }
}
