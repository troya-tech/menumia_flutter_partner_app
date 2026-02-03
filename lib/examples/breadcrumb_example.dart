import '../utils/app_logger.dart';

/// Example demonstrating breadcrumb ID usage
/// 
/// Run this to see how breadcrumb IDs work across services
void main() {
  print('=== Breadcrumb ID Demo ===\n');
  
  // Example 1: Single service with breadcrumb
  print('Example 1: Single Service\n');
  final authService = ExampleAuthService();
  authService.login('user@example.com');
  
  print('\n---\n');
  
  // Example 2: Multiple services with same breadcrumb
  print('Example 2: Cross-Service Tracing\n');
  final orderService = ExampleOrderService();
  orderService.createOrder('ORDER-123');
  
  print('\n=== Demo Complete ===');
}

class ExampleAuthService {
  static final _logger = AppLogger('AuthService');
  
  void login(String email) {
    final context = _logger.createContext();
    
    _logger.info('Starting login process', context);
    _logger.data('Email', email, context);
    
    // Simulate authentication steps
    _logger.debug('Validating credentials...', context);
    _simulateDelay();
    
    _logger.debug('Generating session token...', context);
    _simulateDelay();
    
    _logger.success('Login successful', context);
  }
  
  void _simulateDelay() {
    // Simulate async operation
  }
}

class ExampleOrderService {
  static final _logger = AppLogger('OrderService');
  final _paymentService = ExamplePaymentService();
  final _notificationService = ExampleNotificationService();
  
  void createOrder(String orderId) {
    final context = _logger.createContext();
    
    _logger.info('Creating order', context);
    _logger.data('Order ID', orderId, context);
    
    _logger.debug('Processing payment...', context);
    _paymentService.processPayment(100.0, context);
    
    _logger.debug('Sending confirmation...', context);
    _notificationService.sendEmail('user@example.com', context);
    
    _logger.success('Order created successfully', context);
  }
}

class ExamplePaymentService {
  static final _logger = AppLogger('PaymentService');
  
  void processPayment(double amount, LogContext context) {
    _logger.debug('Charging card...', context);
    _logger.data('Amount', '\$$amount', context);
    _logger.success('Payment successful', context);
  }
}

class ExampleNotificationService {
  static final _logger = AppLogger('NotificationService');
  
  void sendEmail(String email, LogContext context) {
    _logger.debug('Sending email...', context);
    _logger.data('Recipient', email, context);
    _logger.success('Email sent', context);
  }
}
