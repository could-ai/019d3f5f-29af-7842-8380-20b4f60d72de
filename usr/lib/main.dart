import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SCR Capacitor Circuit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ScrCircuitScreen(),
      },
    );
  }
}

class ScrCircuitScreen extends StatefulWidget {
  const ScrCircuitScreen({super.key});

  @override
  State<ScrCircuitScreen> createState() => _ScrCircuitScreenState();
}

class _ScrCircuitScreenState extends State<ScrCircuitScreen> {
  double firingAngle = 45.0; // in degrees
  double capacitance = 2.0; // arbitrary RC time constant factor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Single SCR with Capacitor Filter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Block Diagram / Schematic Section
            const Text(
              'Circuit Block Diagram',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 4,
              child: Container(
                height: 250,
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                child: CustomPaint(
                  painter: SchematicPainter(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Waveform Output Section
            const Text(
              'Output Waveform (Oscilloscope)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 4,
              color: Colors.black87,
              child: Container(
                height: 250,
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                child: CustomPaint(
                  painter: WaveformPainter(
                    firingAngle: firingAngle * pi / 180,
                    rcConstant: capacitance,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Controls Section
            const Text(
              'Interactive Controls',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.speed),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Firing Angle (α): ${firingAngle.toInt()}°'),
                              Slider(
                                value: firingAngle,
                                min: 0,
                                max: 180,
                                divisions: 180,
                                label: '${firingAngle.toInt()}°',
                                onChanged: (value) {
                                  setState(() {
                                    firingAngle = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        const Icon(Icons.battery_charging_full),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Capacitance (Filter Size): ${capacitance.toStringAsFixed(1)}'),
                              Slider(
                                value: capacitance,
                                min: 0.1,
                                max: 10.0,
                                onChanged: (value) {
                                  setState(() {
                                    capacitance = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SchematicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    void drawLabel(String text, Offset offset) {
      textPainter.text = TextSpan(
        text: text,
        style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, offset);
    }

    // Coordinates
    double startX = size.width * 0.1;
    double midY = size.height * 0.4;
    double bottomY = size.height * 0.8;
    
    double sourceX = startX + 20;
    double scrX = size.width * 0.4;
    double capX = size.width * 0.65;
    double loadX = size.width * 0.85;

    // 1. Draw AC Source
    canvas.drawCircle(Offset(sourceX, (midY + bottomY) / 2), 20, paint);
    // Sine wave inside source
    Path sinePath = Path();
    sinePath.moveTo(sourceX - 10, (midY + bottomY) / 2);
    sinePath.quadraticBezierTo(sourceX - 5, (midY + bottomY) / 2 - 10, sourceX, (midY + bottomY) / 2);
    sinePath.quadraticBezierTo(sourceX + 5, (midY + bottomY) / 2 + 10, sourceX + 10, (midY + bottomY) / 2);
    canvas.drawPath(sinePath, paint);
    drawLabel('AC Source', Offset(sourceX - 25, bottomY + 10));

    // 2. Draw Wires
    // Top wire
    canvas.drawLine(Offset(sourceX, midY), Offset(scrX - 15, midY), paint);
    canvas.drawLine(Offset(scrX + 15, midY), Offset(loadX, midY), paint);
    // Bottom wire
    canvas.drawLine(Offset(sourceX, bottomY), Offset(loadX, bottomY), paint);
    // Source vertical wires
    canvas.drawLine(Offset(sourceX, midY), Offset(sourceX, (midY + bottomY) / 2 - 20), paint);
    canvas.drawLine(Offset(sourceX, (midY + bottomY) / 2 + 20), Offset(sourceX, bottomY), paint);

    // 3. Draw SCR
    Path scrPath = Path();
    // Triangle
    scrPath.moveTo(scrX - 15, midY - 15);
    scrPath.lineTo(scrX - 15, midY + 15);
    scrPath.lineTo(scrX + 10, midY);
    scrPath.close();
    canvas.drawPath(scrPath, paint);
    // Vertical line
    canvas.drawLine(Offset(scrX + 10, midY - 15), Offset(scrX + 10, midY + 15), paint);
    // Gate terminal
    canvas.drawLine(Offset(scrX, midY + 10), Offset(scrX + 10, midY + 25), paint);
    canvas.drawLine(Offset(scrX + 10, midY + 25), Offset(scrX + 10, midY + 40), paint);
    drawLabel('SCR', Offset(scrX - 10, midY - 35));

    // 4. Draw Gate Control Block
    Rect gateRect = Rect.fromCenter(center: Offset(scrX + 10, midY + 60), width: 60, height: 30);
    canvas.drawRect(gateRect, paint);
    drawLabel('Gate\nPulse', Offset(scrX - 5, midY + 45));

    // 5. Draw Capacitor
    canvas.drawLine(Offset(capX, midY), Offset(capX, midY + 30), paint);
    canvas.drawLine(Offset(capX - 15, midY + 30), Offset(capX + 15, midY + 30), paint);
    canvas.drawLine(Offset(capX - 15, midY + 40), Offset(capX + 15, midY + 40), paint);
    canvas.drawLine(Offset(capX, midY + 40), Offset(capX, bottomY), paint);
    // Nodes
    canvas.drawCircle(Offset(capX, midY), 3, fillPaint);
    canvas.drawCircle(Offset(capX, bottomY), 3, fillPaint);
    drawLabel('C', Offset(capX + 20, midY + 25));

    // 6. Draw Load Resistor
    canvas.drawLine(Offset(loadX, midY), Offset(loadX, midY + 15), paint);
    Path resPath = Path();
    resPath.moveTo(loadX, midY + 15);
    for (int i = 0; i < 5; i++) {
      resPath.lineTo(loadX - 10, midY + 15 + (i * 8) + 4);
      resPath.lineTo(loadX + 10, midY + 15 + (i * 8) + 8);
    }
    resPath.lineTo(loadX, midY + 15 + 40);
    canvas.drawPath(resPath, paint);
    canvas.drawLine(Offset(loadX, midY + 55), Offset(loadX, bottomY), paint);
    drawLabel('Load (R)', Offset(loadX + 15, midY + 25));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WaveformPainter extends CustomPainter {
  final double firingAngle;
  final double rcConstant;

  WaveformPainter({required this.firingAngle, required this.rcConstant});

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 1.0;

    final inputPaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final outputPaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final triggerPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double midY = size.height / 2;
    double amplitude = size.height * 0.4;

    // Draw X and Y axes
    canvas.drawLine(Offset(0, midY), Offset(size.width, midY), axisPaint);
    canvas.drawLine(Offset(20, 0), Offset(20, size.height), axisPaint);

    Path inputPath = Path();
    Path outputPath = Path();
    
    double vc = 0.0; // Capacitor voltage tracking
    bool isFirstPoint = true;

    // We will draw 2 full cycles (4 * pi)
    double totalCycles = 2.0;
    double totalAngle = totalCycles * 2 * pi;

    for (double x = 20; x <= size.width; x++) {
      // Map x coordinate to time/angle (t)
      double t = ((x - 20) / (size.width - 20)) * totalAngle;
      
      // Input Sine Wave
      double vin = sin(t);
      double vinScaled = midY - (vin * amplitude);
      
      if (x == 20) {
        inputPath.moveTo(x, vinScaled);
      } else {
        inputPath.lineTo(x, vinScaled);
      }

      // Output Waveform Logic (Half-wave SCR with Capacitor)
      double tInCycle = t % (2 * pi);
      
      // SCR conducts if we are past firing angle in positive half cycle AND Vin > Vc
      if (tInCycle >= firingAngle && tInCycle < pi && vin > vc) {
        vc = vin; // Capacitor charges to Vin
        
        // Draw trigger pulse marker at the exact firing moment
        if (tInCycle - firingAngle < 0.05) {
           canvas.drawLine(Offset(x, midY), Offset(x, midY + 20), triggerPaint);
        }
      } else {
        // Capacitor discharges through load
        // dt is the time step
        double dt = totalAngle / (size.width - 20);
        vc = vc * exp(-dt / rcConstant);
        if (vc < 0) vc = 0;
      }

      double voutScaled = midY - (vc * amplitude);

      if (isFirstPoint) {
        outputPath.moveTo(x, voutScaled);
        isFirstPoint = false;
      } else {
        outputPath.lineTo(x, voutScaled);
      }
    }

    // Draw waveforms
    canvas.drawPath(inputPath, inputPaint);
    canvas.drawPath(outputPath, outputPaint);

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    
    void drawLegend(String text, Color color, Offset offset) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, offset);
    }

    drawLegend('Input Voltage (Vin)', Colors.grey, const Offset(30, 10));
    drawLegend('Output Voltage (Vout)', Colors.greenAccent, const Offset(30, 30));
    drawLegend('Gate Pulse', Colors.redAccent, const Offset(30, 50));
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.firingAngle != firingAngle || oldDelegate.rcConstant != rcConstant;
  }
}
