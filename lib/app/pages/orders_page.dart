import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:menumia_flutter_partner_app/utils/app_logger.dart';

/// Orders page for managing restaurant orders
/// Displays active, pending, and completed orders
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  static final _logger = AppLogger('OrdersPage');
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final logCtx = _logger.createContext();
    _logger.info('Initializing OrdersPage', logCtx);
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final logCtx = _logger.createContext();
        _logger.debug('Tab changed to: ${_tabController.index}', logCtx);
      }
    });

  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.navbarBackground,
        title: const Text(
          'Siparişler',
          style: TextStyle(
            color: AppColors.navbarText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.brightBlue,
          labelColor: AppColors.brightBlue,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Aktif'),
            Tab(text: 'Bekleyen'),
            Tab(text: 'Tamamlanan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList('active'),
          _buildOrdersList('pending'),
          _buildOrdersList('completed'),
        ],
      ),
    );
  }

  Widget _buildOrdersList(String status) {
    // TODO: Replace with actual order data from Firebase
    final orders = _getMockOrders(status);

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyIcon(status),
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(status),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _OrderCard(order: order);
      },
    );
  }

  IconData _getEmptyIcon(String status) {
    switch (status) {
      case 'active':
        return Icons.receipt_long_outlined;
      case 'pending':
        return Icons.schedule;
      case 'completed':
        return Icons.check_circle_outline;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  String _getEmptyMessage(String status) {
    switch (status) {
      case 'active':
        return 'Aktif sipariş yok';
      case 'pending':
        return 'Bekleyen sipariş yok';
      case 'completed':
        return 'Tamamlanan sipariş yok';
      default:
        return 'Sipariş yok';
    }
  }

  List<Map<String, dynamic>> _getMockOrders(String status) {
    // TODO: Replace with actual Firebase data
    if (status == 'active') {
      return [
        {
          'id': 'ORD-001',
          'tableNumber': '5',
          'items': ['Margherita Pizza', 'Cola'],
          'total': 125.50,
          'time': '10 dk önce',
          'status': 'preparing',
        },
        {
          'id': 'ORD-002',
          'tableNumber': '12',
          'items': ['Burger', 'Fries', 'Sprite'],
          'total': 89.90,
          'time': '5 dk önce',
          'status': 'preparing',
        },
      ];
    } else if (status == 'pending') {
      return [
        {
          'id': 'ORD-003',
          'tableNumber': '8',
          'items': ['Pasta Carbonara'],
          'total': 65.00,
          'time': '2 dk önce',
          'status': 'pending',
        },
      ];
    }
    return [];
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.navbarBackground,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to order details
          _showOrderDetails(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brightBlue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Masa ${order['tableNumber']}',
                          style: const TextStyle(
                            color: AppColors.brightBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        order['id'],
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    order['time'],
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Items
              ...List.generate(
                (order['items'] as List).length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        order['items'][index],
                        style: const TextStyle(
                          color: AppColors.navbarText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              const Divider(color: AppColors.textSecondary, height: 1),
              const SizedBox(height: 12),
              
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order['total'].toStringAsFixed(2)} ₺',
                    style: const TextStyle(
                      color: AppColors.brightBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      _buildActionButton(
                        context,
                        'Detay',
                        Icons.info_outline,
                        () => _showOrderDetails(context),
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        context,
                        'Tamamla',
                        Icons.check,
                        () => _completeOrder(context),
                        isPrimary: true,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed, {
    bool isPrimary = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColors.brightBlue : AppColors.navbarBackground,
        foregroundColor: isPrimary ? Colors.white : AppColors.navbarText,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: isPrimary
              ? BorderSide.none
              : const BorderSide(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navbarBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sipariş Detayları',
              style: const TextStyle(
                color: AppColors.navbarText,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Sipariş No', order['id']),
            _buildDetailRow('Masa', order['tableNumber']),
            _buildDetailRow('Zaman', order['time']),
            const SizedBox(height: 16),
            const Text(
              'Ürünler:',
              style: TextStyle(
                color: AppColors.navbarText,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(
              (order['items'] as List).length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• ${order['items'][index]}',
                  style: const TextStyle(color: AppColors.navbarText),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Toplam', '${order['total'].toStringAsFixed(2)} ₺'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.navbarText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _completeOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: const Text(
          'Siparişi Tamamla',
          style: TextStyle(color: AppColors.navbarText),
        ),
        content: Text(
          'Bu siparişi tamamlamak istediğinizden emin misiniz?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement order completion logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sipariş tamamlandı'),
                  backgroundColor: AppColors.brightBlue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brightBlue,
            ),
            child: const Text('Tamamla'),
          ),
        ],
      ),
    );
  }
}
