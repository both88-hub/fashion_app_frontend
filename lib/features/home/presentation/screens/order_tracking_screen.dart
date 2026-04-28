import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fashion_app/core/router/app_router.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Track Order',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: Colors.black),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Mock Background Map (Light grey streets)
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://snazzy-maps-cdn.azureedge.net/assets/74-shades-of-grey.png'),
                fit: BoxFit.cover,
                opacity: 0.8,
              ),
            ),
            child: Stack(
              children: [
                // Route Line
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RoutePainter(),
                  ),
                ),
                // Origin / Warehouse Marker
                Positioned(
                  top: 30,
                  left: 280,
                  child: _buildMapMarker(Icons.location_on),
                ),
                // Truck Marker
                Positioned(
                  top: 100,
                  left: 150,
                  child: _buildMapMarker(Icons.local_shipping),
                ),
                // Home Marker
                Positioned(
                  top: 200,
                  left: 100,
                  child: _buildMapMarker(Icons.home),
                ),
              ],
            ),
          ),
          
          // Bottom Info Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5)),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Order Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.black),
                                onPressed: () => context.pop(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildStatusTimeline(),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),
                          _buildDeliveryProfile(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapMarker(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildStatusTimeline() {
    return Column(
      children: [
        _buildStep(title: 'Packing', address: '2336 Jack Warren Rd, Delta Junction...', isCompleted: true, isLast: false),
        _buildStep(title: 'Picked', address: '2417 Tongass Ave #111, Ketchikan...', isCompleted: true, isLast: false),
        _buildStep(title: 'In Transit', address: '16 Rr 2, Ketchikan, Alaska 99901...', isCompleted: true, isLast: false, isActive: true),
        _buildStep(title: 'Delivered', address: '925 S Chugach St #APT 10, Alaska...', isCompleted: false, isLast: true),
      ],
    );
  }

  Widget _buildStep({
    required String title,
    required String address,
    required bool isCompleted,
    required bool isLast,
    bool isActive = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.black : Colors.white,
                border: Border.all(color: isCompleted ? Colors.black : Colors.grey[300]!, width: 2),
                shape: BoxShape.circle,
              ),
              child: isCompleted 
                ? Container(margin: const EdgeInsets.all(3), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Container(margin: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)))
                : null,
            ),
            if (!isLast)
              SizedBox(
                height: 40,
                child: CustomPaint(
                  painter: _DashedLinePainter(color: isCompleted ? Colors.black : Colors.grey[300]!),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isCompleted ? Colors.black : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (!isLast) const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryProfile() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.network(
            'https://randomuser.me/api/portraits/men/32.jpg',
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Jacob Jones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Delivery Guy', style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.call, color: Colors.black),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    // Origin
    path.moveTo(300, 50);
    // Right, Down, Left to Truck
    path.lineTo(300, 80);
    path.lineTo(170, 80);
    path.lineTo(170, 120);
    // Truck
    path.moveTo(170, 120);
    // Left, Down, Right to Home
    path.lineTo(70, 120);
    path.lineTo(70, 220);
    path.lineTo(120, 220);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startY = 0;
    final endY = size.height;

    while (startY < endY) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
