import 'package:flutter_test/flutter_test.dart';
import 'package:schoolbite_admin/main.dart';

void main() {
  testWidgets('renders admin demo entry', (tester) async {
    await tester.pumpWidget(const SchoolBiteAdminApp());
    await tester.pump();

    expect(find.text('SchoolBite'), findsWidgets);
    expect(find.text('Entrar como Administrador'), findsOneWidget);
    expect(find.text('Entrar como Operacion'), findsOneWidget);
  });

  test('updates order and payment status for dashboard state', () async {
    final order = Order(
      id: 'order_test',
      childId: 'child_test',
      childName: 'Sofia Ramirez Lopez',
      childCycle: Cycle.prekinder,
      childGrade: 'Prekinder',
      childSection: 'A',
      menuOptionId: 'lunch_1',
      mealType: MealType.lunch,
      optionNumber: 1,
      menuOptionName: 'Casado de pollo',
      price: 2500,
      orderStatus: OrderStatus.pendingDelivery,
      paymentStatus: PaymentStatus.pending,
      createdAt: DateTime(2026, 7, 5, 8, 30),
    );
    final orderRepo = _FakeOrderRepository([order]);
    final controller = AdminController(orderRepo, _FakeMenuRepository());

    await controller.load();
    await controller.updateOrderStatus(order, OrderStatus.delivered);
    await controller.updatePaymentStatus(order, PaymentStatus.paid);

    expect(controller.orders.single.orderStatus, OrderStatus.delivered);
    expect(controller.orders.single.paymentStatus, PaymentStatus.paid);
    expect(orderRepo.saved.single.orderStatus, OrderStatus.delivered);
    expect(orderRepo.saved.single.paymentStatus, PaymentStatus.paid);
  });
}

class _FakeOrderRepository implements OrderRepository {
  _FakeOrderRepository(this._orders);
  final List<Order> _orders;
  List<Order> saved = [];

  @override
  Future<List<Order>> getOrders() async => _orders;

  @override
  Future<void> saveOrders(List<Order> orders) async {
    saved = [...orders];
  }
}

class _FakeMenuRepository implements MenuRepository {
  @override
  Future<List<MenuOption>> getMenu() async => [];

  @override
  Future<void> saveMenu(List<MenuOption> options) async {}
}
