import 'package:flutter/material.dart';

class Conversationpage extends StatelessWidget {
  const Conversationpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversation',style: Theme.of(context).textTheme.titleLarge,),
        centerTitle: true,
        bottom: PreferredSize(
        preferredSize: Size.fromHeight(2),
        child: Container(
          color: Theme.of(context).colorScheme.outline,
          height: 1,
          ),
        ),
      )
    );
  }
}
