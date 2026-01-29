import 'package:flutter/material.dart';

class Conversationpage extends StatelessWidget {
  const Conversationpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Conversation',style: TextStyle(fontSize: 18),),
        centerTitle: true,
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
