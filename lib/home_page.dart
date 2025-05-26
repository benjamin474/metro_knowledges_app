import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, int> _lineRidership = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRidershipData();
  }

  Future<void> _fetchRidershipData() async {
    const url = 'https://data.taipei/api/v1/dataset/153264fe-3301-43b4-a82b-5c64b113bf8b?scope=resourceAquire';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['result']['results'] as List;
        final Map<String, int> ridership = {};

        for (var item in results) {
          final line = item['線別'] as String;
          final count = int.tryParse(item['總運量'] ?? '0') ?? 0;
          ridership[line] = count;
        }

        setState(() {
          _lineRidership = ridership;
          _isLoading = false;
        });
      } else {
        debugPrint('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('北捷運量統計', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              children: _lineRidership.entries.map((entry) {
                return AnimatedLineTile(
                  lineName: entry.key,
                  color: _getLineColor(entry.key),
                  ridership: entry.value,
                );
              }).toList(),
            ),
    );
  }

  Color _getLineColor(String lineName) {
    switch (lineName) {
      case '板南線':
        return Colors.blue;
      case '文湖線':
        return Colors.brown;
      case '淡水信義線':
        return Colors.red;
      case '中和新蘆線':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class AnimatedLineTile extends StatefulWidget {
  final String lineName;
  final Color color;
  final int ridership;

  const AnimatedLineTile({
    super.key,
    required this.lineName,
    required this.color,
    required this.ridership,
  });

  @override
  _AnimatedLineTileState createState() => _AnimatedLineTileState();
}

class _AnimatedLineTileState extends State<AnimatedLineTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint('Tapped on ${widget.lineName}');
      },
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.4),
                blurRadius: 8.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lineName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '旅運量: ${widget.ridership}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
