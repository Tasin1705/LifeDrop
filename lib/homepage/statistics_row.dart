import 'package:flutter/material.dart';

class StatisticsRow extends StatefulWidget {
  const StatisticsRow({super.key});

  @override
  State<StatisticsRow> createState() => _StatisticsRowState();
}

class _StatisticsRowState extends State<StatisticsRow>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;
  
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();
    
    // Create animation controllers with different durations for staggered effect
    _controller1 = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _controller2 = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );
    
    _controller3 = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );

    // Create animations with curved interpolation for smooth counting
    _animation1 = Tween<double>(
      begin: 0,
      end: 25000,
    ).animate(CurvedAnimation(
      parent: _controller1,
      curve: Curves.easeOutCubic,
    ));
    
    _animation2 = Tween<double>(
      begin: 0,
      end: 15000,
    ).animate(CurvedAnimation(
      parent: _controller2,
      curve: Curves.easeOutCubic,
    ));
    
    _animation3 = Tween<double>(
      begin: 0,
      end: 500,
    ).animate(CurvedAnimation(
      parent: _controller3,
      curve: Curves.easeOutCubic,
    ));

    // Start animations with staggered delays
    _startAnimations();
  }

  void _startAnimations() {
    // Add a small delay to ensure widget is properly mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      // Start first animation immediately
      _controller1.forward();
      
      // Start second animation after 200ms delay
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _controller2.forward();
      });
      
      // Start third animation after 400ms delay
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _controller3.forward();
      });
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 32, // space between items horizontally
          runSpacing: 16, // space between lines when wrapped
          children: [
            AnimatedBuilder(
              animation: _animation1,
              builder: (context, child) {
                final value = _animation1.isCompleted || _animation1.isAnimating 
                    ? _animation1.value 
                    : 0.0;
                return _StatCard(
                  number: '${value.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}+',
                  label: 'Lives Saved',
                );
              },
            ),
            AnimatedBuilder(
              animation: _animation2,
              builder: (context, child) {
                final value = _animation2.isCompleted || _animation2.isAnimating 
                    ? _animation2.value 
                    : 0.0;
                return _StatCard(
                  number: '${value.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}+',
                  label: 'Active Donors',
                );
              },
            ),
            AnimatedBuilder(
              animation: _animation3,
              builder: (context, child) {
                final value = _animation3.isCompleted || _animation3.isAnimating 
                    ? _animation3.value 
                    : 0.0;
                return _StatCard(
                  number: '${value.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}+',
                  label: 'Partner Hospitals',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String number;
  final String label;

  const _StatCard({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0.8, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: 110, // fixed width ensures consistent sizing and wrap support
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<Color?>(
                  duration: const Duration(milliseconds: 800),
                  tween: ColorTween(
                    begin: Colors.grey[400],
                    end: Colors.red,
                  ),
                  builder: (context, color, child) {
                    return Text(
                      number,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
                const SizedBox(height: 4),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  curve: Curves.easeInOut,
                  builder: (context, opacity, child) {
                    return Opacity(
                      opacity: opacity,
                      child: Text(
                        label,
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
