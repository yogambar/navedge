import 'package:flutter/material.dart';

class AlgorithmSelector extends StatelessWidget {
  final String selectedAlgorithm;
  final Function(String) onAlgorithmSelected;
  final bool isDarkMode;

  const AlgorithmSelector({
    super.key,
    required this.selectedAlgorithm,
    required this.onAlgorithmSelected,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.algorithm,
            color: Colors.blueAccent,
            size: 24,
          ),
          const SizedBox(width: 10),
          Text(
            'Algorithm: $selectedAlgorithm',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.blueAccent,
              size: 30,
            ),
            onPressed: () async {
              final algorithm = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return AlgorithmDialog(
                    currentAlgorithm: selectedAlgorithm,
                    isDarkMode: isDarkMode,
                  );
                },
              );
              if (algorithm != null) {
                onAlgorithmSelected(algorithm);
              }
            },
          ),
        ],
      ),
    );
  }
}

class AlgorithmDialog extends StatelessWidget {
  final String currentAlgorithm;
  final bool isDarkMode;

  const AlgorithmDialog({
    super.key,
    required this.currentAlgorithm,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select an Algorithm'),
      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAlgorithmOption(context, 'Dijkstra'),
            _buildAlgorithmOption(context, 'Bellman-Ford'),
            _buildAlgorithmOption(context, 'A*'),
          ],
        ),
      ),
    );
  }

  Widget _buildAlgorithmOption(BuildContext context, String algorithm) {
    return ListTile(
      title: Text(
        algorithm,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      trailing: currentAlgorithm == algorithm
          ? const Icon(
              Icons.check,
              color: Colors.blueAccent,
            )
          : null,
      onTap: () {
        Navigator.pop(context, algorithm);
      },
    );
  }
}

