import 'package:flutter/material.dart';

/// ### Component 2: list of responce suggesiton
///
/// - an empty space in the screan
/// - it take it input from an AI agent to create suggestion
/// - you get 1 or more suggestion bassed on the context
/// - the suggestion is in the shape of a speach bubble
/// - you can tap the bubble to send the conntent to a text-to-speach model
/// - you can continue the tap to go into an edit mode for the text
/// - in the edit mode you open the keyboard to manually edit the text
///
class ResponseSuggestion extends StatefulWidget {
  const ResponseSuggestion({super.key});

  @override
  State<ResponseSuggestion> createState() => _ResponseSuggestionState();
}

class _ResponseSuggestionState extends State<ResponseSuggestion> {
  String? editingResponse;
  final TextEditingController _editController = TextEditingController();

  // just for testing
  final List<String> suggestions = [
    'suggestion number 1',
    //'suggestion number 2',
    //'suggestion number 3',
    //'suggestion number 4',
    //'suggestion number 5',
    //'suggestion number 6',
    //'suggestion number 7',
    //'suggestion number 8',
    //'suggestion number 9',
    //'long suggestion ..........................................................................................',
  ];
  // placeholder function
  void _handleTap(String response) {
    // Send to text-to-speech model (send to the terminal for now)
    print('Sending to TTS: $response');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // well be piped to the tts model
        content: Text('Speaking: $response'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleLongPress(String response) {
    setState(() {
      editingResponse = response;
      _editController.text = response;
    });
  }

  void _closeEdit() {
    setState(() {
      editingResponse = null;
      _editController.clear();
    });
  }

  void _sendEditedResponse() {
    if (_editController.text.isNotEmpty) {
      _handleTap(_editController.text);
      _closeEdit();
    }
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (editingResponse != null) {
      return _buildEditMode();
    }
    return _buildSuggestionList();
  }

  Widget _buildEditMode() {
    /// #### Editing widget
    /// - provide a way to edit the Ai suggestion
    /// - appear when long pressed on any suggestion
    /// - provide a `send` or `cancel` as option

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Edit Response', style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 2,
              ),
            ),
            child: TextField(
              controller: _editController,
              autofocus: true,
              maxLines: 4,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
                hintText: 'Edit your response...',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _closeEdit,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Cancel',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _sendEditedResponse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: Icon(Icons.send, size: 18),
                label: Text(
                  'Send',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionList() {
    /// #### Suggestion list
    /// - give a list of all the suggestion
    /// - allow you to read and interact with the suggestion

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: suggestions.isEmpty
          ? Center(
              child: Text(
                'Listening for suggestions...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          : ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _handleTap(suggestions[index]),
                  onLongPress: () => _handleLongPress(suggestions[index]),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            suggestions[index],
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(
                          Icons.volume_up,
                          size: 20,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
