import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const ProCadApp());
}

class ProCadApp extends StatelessWidget {
  const ProCadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pro CAD 3D Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Colors.blueAccent,
          secondary: Colors.tealAccent,
          surface: Color(0xFF1E1E1E),
        ),
      ),
      home: const CadStudioScreen(),
    );
  }
}

class CadObject {
  String id;
  String name;
  String type;
  Offset position;
  double scale;
  Color color;

  CadObject({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
    this.scale = 1.0,
    this.color = Colors.blueAccent,
  });
}

class CadStudioScreen extends StatefulWidget {
  const CadStudioScreen({super.key});

  @override
  State<CadStudioScreen> createState() => _CadStudioScreenState();
}

class _CadStudioScreenState extends State<CadStudioScreen> {
  final List<CadObject> _objects = [
    CadObject(
      id: '1',
      name: 'Ana Küp',
      type: 'cube',
      position: const Offset(0, 0),
      color: Colors.blueAccent,
    ),
    CadObject(
      id: '2',
      name: 'Küre Modeli',
      type: 'sphere',
      position: const Offset(80, -60),
      color: Colors.tealAccent,
    ),
  ];

  String? _selectedObjectId = '1';
  double _rotationX = 0.3;
  double _rotationY = 0.4;
  double _zoom = 1.0;
  bool _gridVisible = true;

  @override
  Widget build(BuildContext context) {
    final selectedObject = _objects.firstWhere(
      (obj) => obj.id == _selectedObjectId,
      orElse: () => _objects.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adex Pro CAD 3D Studio'),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_gridVisible ? Icons.grid_on : Icons.grid_off),
            tooltip: 'Izgarayı Aç/Kapat',
            onPressed: () {
              setState(() {
                _gridVisible = !_gridVisible;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Açıyı Sıfırla',
            onPressed: () {
              setState(() {
                _rotationX = 0.3;
                _rotationY = 0.4;
                _zoom = 1.0;
              });
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 180,
            color: const Color(0xFF1E1E1E),
            child: Column(
              crossAxisAlignment: CrossAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Sahne Nesneleri',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: _objects.length,
                    itemBuilder: (context, index) {
                      final obj = _objects[index];
                      final isSelected = obj.id == _selectedObjectId;
                      return ListTile(
                        dense: true,
                        selected: isSelected,
                        selectedTileColor: Colors.blueAccent.withOpacity(0.2),
                        leading: Icon(
                          obj.type == 'cube'
                              ? Icons.view_in_ar
                              : Icons.blur_on,
                          color: obj.color,
                          size: 20,
                        ),
                        title: Text(obj.name, style: const TextStyle(fontSize: 13)),
                        onTap: () {
                          setState(() {
                            _selectedObjectId = obj.id;
                          });
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        onPressed: () => _addObject('cube'),
                        child: const Text('+ Küp', style: TextStyle(fontSize: 12)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        onPressed: () => _addObject('sphere'),
                        child: const Text('+ Küre', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _rotationY += details.delta.dx * 0.01;
                  _rotationX -= details.delta.dy * 0.01;
                });
              },
              child: Container(
                color: const Color(0xFF141414),
                child: CustomPaint(
                  painter: Cad3DPainter(
                    objects: _objects,
                    selectedObjectId: _selectedObjectId,
                    rotationX: _rotationX,
                    rotationY: _rotationY,
                    zoom: _zoom,
                    showGrid: _gridVisible,
                  ),
                  child: Container(),
                ),
              ),
            ),
          ),
          Container(
            width: 200,
            color: const Color(0xFF1E1E1E),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAlignment.start,
              children: [
                const Text(
                  'Özellikler',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Divider(height: 16),
                Text('Nesne: ${selectedObject.name}', style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 16),
                const Text('Boyut / Ölçek:', style: TextStyle(fontSize: 12)),
                Slider(
                  value: selectedObject.scale,
                  min: 0.5,
                  max: 2.5,
                  onChanged: (val) {
                    setState(() {
                      selectedObject.scale = val;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Kamera Yakınlaştırma:', style: TextStyle(fontSize: 12)),
                Slider(
                  value: _zoom,
                  min: 0.5,
                  max: 2.0,
                  onChanged: (val) {
                    setState(() {
                      _zoom = val;
                    });
                  },
                ),
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size.fromHeight(36),
                  ),
                  onPressed: _objects.length > 1
                      ? () {
                          setState(() {
                            _objects.removeWhere(
                                (element) => element.id == selectedObject.id);
                            _selectedObjectId = _objects.first.id;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Sil', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addObject(String type) {
    setState(() {
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      _objects.add(
        CadObject(
          id: newId,
          name: type == 'cube' ? 'Yeni Küp' : 'Yeni Küre',
          type: type,
          position: Offset(
            (math.Random().nextDouble() - 0.5) * 100,
            (math.Random().nextDouble() - 0.5) * 100,
          ),
          color: type == 'cube' ? Colors.orangeAccent : Colors.purpleAccent,
        ),
      );
      _selectedObjectId = newId;
    });
  }
}

class Cad3DPainter extends CustomPainter {
  final List<CadObject> objects;
  final String? selectedObjectId;
  final double rotationX;
  final double rotationY;
  final double zoom;
  final bool showGrid;

  Cad3DPainter({
    required this.objects,
    required this.selectedObjectId,
    required this.rotationX,
    required this.rotationY,
    required this.zoom,
    required this.showGrid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    if (showGrid) {
      final gridPaint = Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..strokeWidth = 1.0;

      for (int i = -5; i <= 5; i++) {
        final p1 = _project(i * 30.0, 0, -150, center);
        final p2 = _project(i * 30.0, 0, 150, center);
        canvas.drawLine(p1, p2, gridPaint);

        final p3 = _project(-150, 0, i * 30.0, center);
        final p4 = _project(150, 0, i * 30.0, center);
        canvas.drawLine(p3, p4, gridPaint);
      }
    }

    for (var obj in objects) {
      final isSelected = obj.id == selectedObjectId;
      final paint = Paint()
        ..color = isSelected ? obj.color : obj.color.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 2.5 : 1.5;

      final radius = 40.0 * obj.scale;

      if (obj.type == 'cube') {
        _draw3DCube(canvas, center, obj.position, radius, paint);
      } else {
        _draw3DSphere(canvas, center, obj.position, radius, paint);
      }
    }
  }

  void _draw3DCube(
      Canvas canvas, Offset center, Offset pos, double r, Paint paint) {
    final vertices = [
      Offset3D(pos.dx - r, pos.dy - r, -r),
      Offset3D(pos.dx + r, pos.dy - r, -r),
      Offset3D(pos.dx + r, pos.dy + r, -r),
      Offset3D(pos.dx - r, pos.dy + r, -r),
      Offset3D(pos.dx - r, pos.dy - r, r),
      Offset3D(pos.dx + r, pos.dy - r, r),
      Offset3D(pos.dx + r, pos.dy + r, r),
      Offset3D(pos.dx - r, pos.dy + r, r),
    ];

    final projected =
        vertices.map((v) => _project(v.x, v.y, v.z, center)).toList();

    final edges = [
      [0, 1], [1, 2], [2, 3], [3, 0],
      [4, 5], [5, 6], [6, 7], [7, 4],
      [0, 4], [1, 5], [2, 6], [3, 7],
    ];

    for (var edge in edges) {
      canvas.drawLine(projected[edge[0]], projected[edge[1]], paint);
    }
  }

  void _draw3DSphere(
      Canvas canvas, Offset center, Offset pos, double r, Paint paint) {
    final pCenter = _project(pos.dx, pos.dy, 0, center);
    canvas.drawCircle(pCenter, r * zoom, paint);
    canvas.drawOval(
      Rect.fromCenter(
          center: pCenter, width: r * 2 * zoom, height: r * 0.8 * zoom),
      paint,
    );
  }

  Offset _project(double x, double y, double z, Offset center) {
    double radX = rotationX;
    double y1 = y * math.cos(radX) - z * math.sin(radX);
    double z1 = y * math.sin(radX) + z * math.cos(radX);

    double radY = rotationY;
    double x2 = x * math.cos(radY) + z1 * math.sin(radY);

    double scale = zoom;
    return Offset(
      center.dx + x2 * scale,
      center.dy + y1 * scale,
    );
  }

  @override
  bool shouldRepaint(covariant Cad3DPainter oldDelegate) => true;
}

class Offset3D {
  final double x;
  final double y;
  final double z;

  Offset3D(this.x, this.y, this.z);
}

