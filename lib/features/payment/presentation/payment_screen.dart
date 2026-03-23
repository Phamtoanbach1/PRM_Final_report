import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/constants/app_colors.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethod = 0; 
  bool _isCardFlipped = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh Toán'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: const Text(
                'Tổng thanh toán',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 8),
            FadeInDown(
              delay: const Duration(milliseconds: 100),
              child: const Text(
                '500,000 VNĐ',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 48),
            
            // 3D Credit Card Effect
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isCardFlipped = !_isCardFlipped;
                  });
                },
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: _isCardFlipped ? 3.14159265 : 0),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, double value, child) {
                    bool isBack = value > 1.57079633;
                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.002) // Perspective magic
                        ..rotateY(value),
                      alignment: Alignment.center,
                      child: isBack
                          ? Transform(
                              transform: Matrix4.identity()..rotateY(3.14159265),
                              alignment: Alignment.center,
                              child: _buildCardBack(),
                            )
                          : _buildCardFront(),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            const Text(
              'Phương thức khác',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildOption(0, 'Ví Điện Tử (Momo, ZaloPay)', Icons.account_balance_wallet_rounded),
            const SizedBox(height: 12),
            _buildOption(1, 'Chuyển Khoản Ngân Hàng', Icons.food_bank_rounded),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thanh toán thành công!')),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('Xác Nhận Thanh Toán', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption(int index, String title, IconData icon) {
    bool isSelected = _selectedMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
          boxShadow: [
            if (!isSelected)
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFront() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 30, offset: const Offset(0, 15))
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.contactless, color: Colors.white70, size: 36),
              Text('VISA', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
            ],
          ),
          Text('**** **** **** 1234', style: TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 2)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('NGUYEN VAN A', style: TextStyle(color: Colors.white70, fontSize: 16)),
              Text('12/28', style: TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: AppColors.premiumGradient,
        boxShadow: [
          BoxShadow(color: AppColors.secondary.withValues(alpha: 0.4), blurRadius: 30, offset: const Offset(0, 15))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 50, color: Colors.black87),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    color: Colors.white,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Text('123', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          )
        ],
      ),
    );
  }
}
