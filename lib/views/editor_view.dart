import 'package:compilador_lya/widgets/file_widget.dart';
import 'package:flutter/material.dart';

class EditorView extends StatefulWidget {
  const EditorView({super.key});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        
        children: [
          Text('Compilador lya'),
          SizedBox(
            width: 200,
            height: 100,
            child: FileWidget(),
          ),
          Row(
            children: [
      
            ],
          )
        ],
      ),
    );
  }
}