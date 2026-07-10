import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:schoolbite_admin/branding/brand_assets.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const SchoolBiteAdminApp());

enum Cycle { prekinder, iCiclo, iiCiclo }

enum MealType { breakfast, lunch, snack }

enum OrderStatus { pendingDelivery, delivered, cancelled }

enum PaymentStatus { pending, validation, paid, cancelled, refundPending }

enum PaymentMethod { cash, sinpe, card, balance, unknown }

enum AdminMode { administrator, operation }

String cycleLabel(Cycle value) => switch (value) {
  Cycle.prekinder => 'Prekinder',
  Cycle.iCiclo => 'I Ciclo',
  Cycle.iiCiclo => 'II Ciclo',
};
String mealLabel(MealType value) => switch (value) {
  MealType.breakfast => 'Desayuno',
  MealType.lunch => 'Almuerzo',
  MealType.snack => 'Merienda',
};
String orderLabel(OrderStatus value) => switch (value) {
  OrderStatus.pendingDelivery => 'Pendiente',
  OrderStatus.delivered => 'Entregado',
  OrderStatus.cancelled => 'Cancelado',
};
String paymentLabel(PaymentStatus value) => switch (value) {
  PaymentStatus.pending => 'Pendiente',
  PaymentStatus.validation => 'En validacion',
  PaymentStatus.paid => 'Pagado',
  PaymentStatus.cancelled => 'Cancelado',
  PaymentStatus.refundPending => 'Reembolso pendiente',
};
String paymentMethodLabel(PaymentMethod value) => switch (value) {
  PaymentMethod.cash => 'Efectivo',
  PaymentMethod.sinpe => 'SINPE',
  PaymentMethod.card => 'Tarjeta',
  PaymentMethod.balance => 'Saldo',
  PaymentMethod.unknown => 'No definido',
};
String money(int value) =>
    'CRC ${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}';

Cycle inferCycleFromSection(String value) {
  final normalized = value.toLowerCase();
  if (normalized.contains('toddler') ||
      normalized.contains('first') ||
      normalized.contains('pk') ||
      normalized.contains('kinder') ||
      normalized.contains('prekinder')) {
    return Cycle.prekinder;
  }
  if (normalized.startsWith('1-') ||
      normalized.startsWith('2-') ||
      normalized.startsWith('3-')) {
    return Cycle.iCiclo;
  }
  return Cycle.iiCiclo;
}

int compareOrdersByCycleSection(Order a, Order b) {
  final cycle = cycleSort(a.childCycle).compareTo(cycleSort(b.childCycle));
  if (cycle != 0) return cycle;
  final section = sectionSort(
    a.childSection,
  ).compareTo(sectionSort(b.childSection));
  if (section != 0) return section;
  return a.childName.compareTo(b.childName);
}

int cycleSort(Cycle cycle) => switch (cycle) {
  Cycle.prekinder => 0,
  Cycle.iCiclo => 1,
  Cycle.iiCiclo => 2,
};

String sectionSort(String section) {
  final normalized = section.toUpperCase().replaceAll(' ', '');
  if (normalized.startsWith('TODDLERS')) return '00-$normalized';
  if (normalized.startsWith('FIRST')) return '01-$normalized';
  if (normalized.startsWith('PK')) return '02-$normalized';
  if (normalized.startsWith('KINDER')) return '03-$normalized';
  final grade = RegExp(r'^(\d+)').firstMatch(normalized)?.group(1);
  if (grade != null) return grade.padLeft(2, '0') + normalized;
  return normalized;
}

class Order {
  Order({
    required this.id,
    required this.childId,
    required this.childName,
    required this.childCycle,
    required this.childGrade,
    required this.childSection,
    required this.menuOptionId,
    required this.mealType,
    this.optionNumber,
    required this.menuOptionName,
    required this.price,
    required this.orderStatus,
    required this.paymentStatus,
    this.paymentMethod = PaymentMethod.unknown,
    this.customizationTags = const [],
    this.customNote,
    this.dietaryRestrictions,
    this.paidAt,
    this.deliveredAt,
    required this.createdAt,
  });
  final String id;
  final String childId;
  final String childName;
  final Cycle childCycle;
  final String childGrade;
  final String childSection;
  final String menuOptionId;
  final MealType mealType;
  final int? optionNumber;
  final String menuOptionName;
  final int price;
  OrderStatus orderStatus;
  PaymentStatus paymentStatus;
  PaymentMethod paymentMethod;
  List<String> customizationTags;
  String? customNote;
  String? dietaryRestrictions;
  DateTime? paidAt;
  DateTime? deliveredAt;
  final DateTime createdAt;

  bool get hasCustomization =>
      customizationTags.isNotEmpty || (customNote?.trim().isNotEmpty ?? false);
  bool get hasDietaryRestrictions =>
      dietaryRestrictions?.trim().isNotEmpty ?? false;

  Map<String, dynamic> toJson() => {
    'id': id,
    'sodaId': 'soda_demo',
    'parentId': 'parent_demo',
    'childId': childId,
    'childName': childName,
    'childCycle': childCycle.name,
    'childGrade': childGrade,
    'childSection': childSection,
    'dailyMenuId': 'menu_today',
    'menuOptionId': menuOptionId,
    'mealType': mealType.name,
    'optionNumber': optionNumber,
    'menuOptionName': menuOptionName,
    'price': price,
    'orderStatus': orderStatus.name,
    'deliveryStatus': orderStatus.name,
    'paymentStatus': paymentStatus == PaymentStatus.refundPending
        ? 'refund_pending'
        : paymentStatus.name,
    'paymentMethod': paymentMethod.name,
    'customizationTags': customizationTags,
    'customNote': customNote,
    'dietaryRestrictions': dietaryRestrictions,
    'paidAt': paidAt?.toIso8601String(),
    'deliveredAt': deliveredAt?.toIso8601String(),
    'date': DateTime(
      createdAt.year,
      createdAt.month,
      createdAt.day,
    ).toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };
  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'],
    childId: json['childId'],
    childName: json['childName'],
    childCycle: Cycle.values.byName(json['childCycle']),
    childGrade: json['childGrade'],
    childSection: json['childSection'],
    menuOptionId: json['menuOptionId'],
    mealType: MealType.values.byName(json['mealType']),
    optionNumber: json['optionNumber'],
    menuOptionName: json['menuOptionName'],
    price: json['price'],
    orderStatus: parseOrderStatus(
      json['deliveryStatus'] ?? json['orderStatus'],
    ),
    paymentStatus: parsePaymentStatus(json['paymentStatus']),
    paymentMethod: parsePaymentMethod(json['paymentMethod']),
    customizationTags: List<String>.from(json['customizationTags'] ?? const []),
    customNote: json['customNote'],
    dietaryRestrictions: json['dietaryRestrictions'],
    paidAt: json['paidAt'] == null ? null : DateTime.tryParse(json['paidAt']),
    deliveredAt: json['deliveredAt'] == null
        ? null
        : DateTime.tryParse(json['deliveredAt']),
    createdAt: DateTime.parse(json['createdAt']),
  );
}

OrderStatus parseOrderStatus(Object? value) {
  final name = value?.toString() ?? OrderStatus.pendingDelivery.name;
  if (name == 'received' || name == 'preparing' || name == 'ready') {
    return OrderStatus.pendingDelivery;
  }
  return OrderStatus.values.firstWhere(
    (status) => status.name == name,
    orElse: () => OrderStatus.pendingDelivery,
  );
}

PaymentStatus parsePaymentStatus(Object? value) {
  final name = value?.toString() ?? PaymentStatus.pending.name;
  if (name ==
      'cre'
          'dit') {
    return PaymentStatus.pending;
  }
  return PaymentStatus.values.firstWhere(
    (status) => status.name == name,
    orElse: () {
      if (name == 'refund_pending') return PaymentStatus.refundPending;
      return PaymentStatus.pending;
    },
  );
}

PaymentMethod parsePaymentMethod(Object? value) {
  final name = value?.toString() ?? PaymentMethod.unknown.name;
  return PaymentMethod.values.firstWhere(
    (method) => method.name == name,
    orElse: () => PaymentMethod.unknown,
  );
}

class MenuOption {
  MenuOption({
    required this.id,
    required this.mealType,
    required this.optionNumber,
    required this.name,
    required this.description,
    required this.pricesByCycle,
    required this.available,
    this.stockLimit,
  });
  final String id;
  MealType mealType;
  int optionNumber;
  String name;
  String description;
  Map<Cycle, int> pricesByCycle;
  bool available;
  int? stockLimit;
  int priceFor(Cycle cycle) => pricesByCycle[cycle] ?? 0;
  Map<String, dynamic> toJson() => {
    'id': id,
    'mealType': mealType.name,
    'optionNumber': optionNumber,
    'name': name,
    'description': description,
    'pricesByCycle': pricesByCycle.map((k, v) => MapEntry(k.name, v)),
    'available': available,
    'stockLimit': stockLimit,
  };
  factory MenuOption.fromJson(Map<String, dynamic> json) => MenuOption(
    id: json['id'],
    mealType: MealType.values.byName(json['mealType']),
    optionNumber: json['optionNumber'],
    name: json['name'],
    description: json['description'],
    pricesByCycle: Map<String, dynamic>.from(
      json['pricesByCycle'],
    ).map((k, v) => MapEntry(Cycle.values.byName(k), v)),
    available: json['available'],
    stockLimit: json['stockLimit'],
  );
}

abstract class OrderRepository {
  Future<List<Order>> getOrders();
  Future<void> saveOrders(List<Order> orders);
}

abstract class MenuRepository {
  Future<List<MenuOption>> getMenu();
  Future<void> saveMenu(List<MenuOption> options);
}

class SharedPrefsOrderRepository implements OrderRepository {
  static const key = 'schoolbite.orders.v4';
  @override
  Future<List<Order>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return _seedOrders();
    final savedOrders = (jsonDecode(raw) as List)
        .map((item) => Order.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    final savedIds = savedOrders.map((order) => order.id).toSet();
    final missingSeeds = _seedOrders().where(
      (order) => !savedIds.contains(order.id),
    );
    return [...savedOrders, ...missingSeeds];
  }

  @override
  Future<void> saveOrders(List<Order> orders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      key,
      jsonEncode(orders.map((o) => o.toJson()).toList()),
    );
  }
}

class SharedPrefsMenuRepository implements MenuRepository {
  static const key = 'schoolbite.menu';
  @override
  Future<List<MenuOption>> getMenu() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return _seedMenu();
    return (jsonDecode(raw) as List)
        .map((item) => MenuOption.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<void> saveMenu(List<MenuOption> options) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      key,
      jsonEncode(options.map((o) => o.toJson()).toList()),
    );
  }
}

List<Order> _seedOrders() {
  final students = [
    ('Sofia Ramirez Lopez', Cycle.prekinder, 'Prekinder', 'PK-A'),
    ('Mateo Gonzalez Vargas', Cycle.iCiclo, '2 grado', '2-B'),
    ('Valeria Jimenez Solano', Cycle.iiCiclo, '5 grado', '5-A'),
    ('Daniel Mora Hernandez', Cycle.iCiclo, '1 grado', '1-A'),
    ('Isabella Rojas Castro', Cycle.prekinder, 'Prekinder', 'PK-B'),
    ('Sebastian Castillo Ruiz', Cycle.iiCiclo, '6 grado', '6-C'),
    ('Camila Fernandez Mora', Cycle.iCiclo, '3 grado', '3-A'),
    ('Gabriel Vargas Solis', Cycle.iiCiclo, '4 grado', '4-B'),
    ('Mariana Castro Rojas', Cycle.iCiclo, '2 grado', '2-B'),
    ('Lucas Jimenez Araya', Cycle.prekinder, 'Prekinder', 'PK-A'),
    ('Maria Fernandez Mora', Cycle.iCiclo, '1 grado', '1-A'),
    ('Andres Solano Rojas', Cycle.iiCiclo, '5 grado', '5-A'),
  ];
  final options = [
    ('breakfast_1', MealType.breakfast, 1, 'Pinto con huevo'),
    ('breakfast_2', MealType.breakfast, 2, 'Pancakes con fruta'),
    ('lunch_1', MealType.lunch, 1, 'Casado de pollo'),
    ('lunch_2', MealType.lunch, 2, 'Pasta bolonesa'),
    ('snack_1', MealType.snack, 1, 'Fruta picada'),
    ('snack_2', MealType.snack, 2, 'Yogurt con granola'),
  ];
  final custom = <int, (List<String>, String?)>{
    1: (['sin_queso', 'sin_salchicha'], null),
    4: (['sin_natilla'], null),
    8: (['sin_azucar'], 'Jugo sin azucar'),
    12: (['sin_salsa'], null),
    17: (['sin_tomate'], null),
    21: (['sin_cebolla'], null),
    27: (['otro'], 'Porcion pequena'),
    33: (['sin_queso'], 'Sin aderezo'),
  };
  final restrictions = <int, String>{
    0: 'Alergica al mani. Evitar trazas de nueces.',
    5: 'Sin lacteos.',
    11: 'No puede comer cerdo.',
    18: 'Celiaco. Evitar gluten.',
    24: 'Alergia a mariscos.',
    31: 'Sin colorantes.',
  };
  return List.generate(40, (index) {
    final student = students[index % students.length];
    final option = options[index % options.length];
    final cycle = student.$2;
    final price = switch (option.$2) {
      MealType.breakfast =>
        option.$3 == 1
            ? {
                Cycle.prekinder: 1500,
                Cycle.iCiclo: 1800,
                Cycle.iiCiclo: 2000,
              }[cycle]!
            : {
                Cycle.prekinder: 1600,
                Cycle.iCiclo: 1900,
                Cycle.iiCiclo: 2100,
              }[cycle]!,
      MealType.lunch =>
        option.$3 == 1
            ? {
                Cycle.prekinder: 2500,
                Cycle.iCiclo: 2800,
                Cycle.iiCiclo: 3200,
              }[cycle]!
            : {
                Cycle.prekinder: 2400,
                Cycle.iCiclo: 2700,
                Cycle.iiCiclo: 3100,
              }[cycle]!,
      MealType.snack =>
        option.$3 == 1
            ? {
                Cycle.prekinder: 1000,
                Cycle.iCiclo: 1200,
                Cycle.iiCiclo: 1500,
              }[cycle]!
            : {
                Cycle.prekinder: 1100,
                Cycle.iCiclo: 1300,
                Cycle.iiCiclo: 1600,
              }[cycle]!,
    };
    final paid = index % 5 == 0 || index == 38;
    final validation = index % 11 == 0;
    final delivered = index % 4 == 0;
    final cancelled = index == 38 || index == 39;
    final customization = custom[index];
    return Order(
      id: 'demo_${index + 1}',
      childId: 'child_${index + 1}',
      childName: student.$1,
      childCycle: cycle,
      childGrade: student.$3,
      childSection: student.$4,
      menuOptionId: option.$1,
      mealType: option.$2,
      optionNumber: option.$3,
      menuOptionName: option.$4,
      price: price,
      orderStatus: cancelled
          ? OrderStatus.cancelled
          : delivered
          ? OrderStatus.delivered
          : OrderStatus.pendingDelivery,
      paymentStatus: cancelled && paid
          ? PaymentStatus.refundPending
          : cancelled
          ? PaymentStatus.cancelled
          : paid
          ? PaymentStatus.paid
          : validation
          ? PaymentStatus.validation
          : PaymentStatus.pending,
      paymentMethod: paid
          ? PaymentMethod.cash
          : validation
          ? PaymentMethod.sinpe
          : PaymentMethod.unknown,
      customizationTags: customization?.$1 ?? const [],
      customNote: customization?.$2,
      dietaryRestrictions: restrictions[index],
      paidAt: paid
          ? DateTime.now().subtract(Duration(minutes: index + 8))
          : null,
      deliveredAt: delivered
          ? DateTime.now().subtract(Duration(minutes: index + 5))
          : null,
      createdAt: DateTime.now().subtract(Duration(minutes: index * 3 + 4)),
    );
  });
}

List<MenuOption> _seedMenu() => [
  MenuOption(
    id: 'breakfast_1',
    mealType: MealType.breakfast,
    optionNumber: 1,
    name: 'Pinto con huevo',
    description: 'Pinto tradicional, huevo y fruta.',
    pricesByCycle: {
      Cycle.prekinder: 1500,
      Cycle.iCiclo: 1800,
      Cycle.iiCiclo: 2000,
    },
    available: true,
  ),
  MenuOption(
    id: 'breakfast_2',
    mealType: MealType.breakfast,
    optionNumber: 2,
    name: 'Pancakes con fruta',
    description: 'Pancakes suaves con fruta fresca.',
    pricesByCycle: {
      Cycle.prekinder: 1600,
      Cycle.iCiclo: 1900,
      Cycle.iiCiclo: 2100,
    },
    available: true,
  ),
  MenuOption(
    id: 'lunch_1',
    mealType: MealType.lunch,
    optionNumber: 1,
    name: 'Casado de pollo',
    description: 'Arroz, frijoles, ensalada, pollo y acompanamiento.',
    pricesByCycle: {
      Cycle.prekinder: 2500,
      Cycle.iCiclo: 2800,
      Cycle.iiCiclo: 3200,
    },
    available: true,
    stockLimit: 40,
  ),
  MenuOption(
    id: 'lunch_2',
    mealType: MealType.lunch,
    optionNumber: 2,
    name: 'Pasta bolonesa',
    description: 'Pasta con salsa bolonesa y queso.',
    pricesByCycle: {
      Cycle.prekinder: 2400,
      Cycle.iCiclo: 2700,
      Cycle.iiCiclo: 3100,
    },
    available: true,
    stockLimit: 35,
  ),
  MenuOption(
    id: 'snack_1',
    mealType: MealType.snack,
    optionNumber: 1,
    name: 'Fruta picada',
    description: 'Porcion de frutas frescas.',
    pricesByCycle: {
      Cycle.prekinder: 1000,
      Cycle.iCiclo: 1200,
      Cycle.iiCiclo: 1500,
    },
    available: true,
  ),
  MenuOption(
    id: 'snack_2',
    mealType: MealType.snack,
    optionNumber: 2,
    name: 'Yogurt con granola',
    description: 'Yogurt natural con granola y fruta.',
    pricesByCycle: {
      Cycle.prekinder: 1100,
      Cycle.iCiclo: 1300,
      Cycle.iiCiclo: 1600,
    },
    available: true,
  ),
];

class AdminController extends ChangeNotifier {
  AdminController(this.orderRepository, this.menuRepository);
  final OrderRepository orderRepository;
  final MenuRepository menuRepository;
  List<Order> orders = [];
  List<MenuOption> menu = [];
  MealType? mealFilter;
  int? optionFilter;
  Cycle? cycleFilter;
  String? sectionFilter;
  OrderStatus? orderFilter;
  PaymentStatus? paymentFilter;
  bool customOnlyFilter = false;
  bool dietaryOnlyFilter = false;
  AdminMode mode = AdminMode.administrator;
  bool loading = true;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    orders = await orderRepository.getOrders();
    menu = await menuRepository.getMenu();
    loading = false;
    notifyListeners();
  }

  List<Order> get filteredOrders => orders.where((o) {
    if (mealFilter != null && o.mealType != mealFilter) return false;
    if (optionFilter != null && o.optionNumber != optionFilter) return false;
    if (cycleFilter != null && o.childCycle != cycleFilter) return false;
    if (sectionFilter != null &&
        sectionFilter!.isNotEmpty &&
        o.childSection != sectionFilter) {
      return false;
    }
    if (orderFilter != null && o.orderStatus != orderFilter) return false;
    if (paymentFilter != null && o.paymentStatus != paymentFilter) return false;
    if (customOnlyFilter && !o.hasCustomization) return false;
    if (dietaryOnlyFilter && !o.hasDietaryRestrictions) return false;
    return true;
  }).toList()..sort(compareOrdersByCycleSection);

  List<Order> get activeDeliveryOrders =>
      (orders
          .where(
            (order) =>
                order.orderStatus != OrderStatus.delivered &&
                order.orderStatus != OrderStatus.cancelled,
          )
          .toList()
        ..sort(compareOrdersByCycleSection));

  List<Order> get paymentQueue => orders
      .where(
        (order) =>
            order.paymentStatus == PaymentStatus.pending ||
            order.paymentStatus == PaymentStatus.validation ||
            order.paymentStatus == PaymentStatus.refundPending,
      )
      .toList();

  int get recentOrdersCount => orders
      .where(
        (order) => DateTime.now().difference(order.createdAt).inMinutes <= 20,
      )
      .length;

  Future<void> updateOrderStatus(Order order, OrderStatus status) async {
    if (status == OrderStatus.cancelled) {
      await cancelOrder(order);
      return;
    }
    order.orderStatus = status;
    order.deliveredAt = status == OrderStatus.delivered ? DateTime.now() : null;
    await orderRepository.saveOrders(orders);
    notifyListeners();
  }

  Future<void> cancelOrder(Order order) async {
    order.orderStatus = OrderStatus.cancelled;
    order.deliveredAt = null;
    order.paymentStatus = switch (order.paymentStatus) {
      PaymentStatus.paid => PaymentStatus.refundPending,
      PaymentStatus.pending ||
      PaymentStatus.validation => PaymentStatus.cancelled,
      PaymentStatus.cancelled => PaymentStatus.cancelled,
      PaymentStatus.refundPending => PaymentStatus.refundPending,
    };
    if (order.paymentStatus == PaymentStatus.cancelled) {
      order.paymentMethod = PaymentMethod.unknown;
      order.paidAt = null;
    }
    await orderRepository.saveOrders(orders);
    notifyListeners();
  }

  Future<void> updatePaymentStatus(Order order, PaymentStatus status) async {
    order.paymentStatus = status;
    if (status != PaymentStatus.paid) {
      order.paidAt = null;
      if (status == PaymentStatus.pending ||
          status == PaymentStatus.cancelled) {
        order.paymentMethod = PaymentMethod.unknown;
      }
    }
    await orderRepository.saveOrders(orders);
    notifyListeners();
  }

  Future<void> confirmPayment(Order order, PaymentMethod method) async {
    order.paymentStatus = PaymentStatus.paid;
    order.paymentMethod = method;
    order.paidAt = DateTime.now();
    await orderRepository.saveOrders(orders);
    notifyListeners();
  }

  Future<void> approvePaymentValidation(Order order) async {
    order.paymentStatus = PaymentStatus.paid;
    order.paymentMethod = PaymentMethod.sinpe;
    order.paidAt = DateTime.now();
    await orderRepository.saveOrders(orders);
    notifyListeners();
  }

  Future<void> rejectPaymentValidation(Order order) async {
    order.paymentStatus = PaymentStatus.pending;
    order.paymentMethod = PaymentMethod.unknown;
    order.paidAt = null;
    await orderRepository.saveOrders(orders);
    notifyListeners();
  }

  Future<void> markRefundResolved(Order order) async {
    order.paymentStatus = PaymentStatus.cancelled;
    order.paymentMethod = PaymentMethod.unknown;
    order.paidAt = null;
    await orderRepository.saveOrders(orders);
    notifyListeners();
  }

  void setMode(AdminMode value) {
    mode = value;
    notifyListeners();
  }

  void setMealFilter(MealType? value) {
    mealFilter = value;
    notifyListeners();
  }

  void setOptionFilter(int? value) {
    optionFilter = value;
    notifyListeners();
  }

  void setCycleFilter(Cycle? value) {
    cycleFilter = value;
    notifyListeners();
  }

  void setOrderFilter(OrderStatus? value) {
    orderFilter = value;
    notifyListeners();
  }

  void setPaymentFilter(PaymentStatus? value) {
    paymentFilter = value;
    notifyListeners();
  }

  void setCustomOnlyFilter(bool value) {
    customOnlyFilter = value;
    notifyListeners();
  }

  void setDietaryOnlyFilter(bool value) {
    dietaryOnlyFilter = value;
    notifyListeners();
  }

  void setSectionFilter(String value) {
    sectionFilter = value.isEmpty ? null : value;
    notifyListeners();
  }

  void clearFilters() {
    mealFilter = null;
    optionFilter = null;
    cycleFilter = null;
    orderFilter = null;
    paymentFilter = null;
    sectionFilter = null;
    customOnlyFilter = false;
    dietaryOnlyFilter = false;
    notifyListeners();
  }

  Future<void> createCounterOrder({
    required String childName,
    required String section,
    required MenuOption option,
    required PaymentMethod paymentMethod,
    String dietaryRestrictions = '',
  }) async {
    final status = paymentMethod == PaymentMethod.unknown
        ? PaymentStatus.pending
        : PaymentStatus.paid;
    final cycle = inferCycleFromSection(section);
    orders.add(
      Order(
        id: 'counter_${DateTime.now().microsecondsSinceEpoch}',
        childId: 'counter_student',
        childName: childName,
        childCycle: cycle,
        childGrade: section,
        childSection: section,
        menuOptionId: option.id,
        mealType: option.mealType,
        optionNumber: option.optionNumber,
        menuOptionName: option.name,
        price: option.priceFor(cycle),
        orderStatus: OrderStatus.pendingDelivery,
        paymentStatus: status,
        paymentMethod: paymentMethod,
        dietaryRestrictions: dietaryRestrictions.trim().isEmpty
            ? null
            : dietaryRestrictions.trim(),
        paidAt: status == PaymentStatus.paid ? DateTime.now() : null,
        createdAt: DateTime.now(),
      ),
    );
    await orderRepository.saveOrders(orders);
    notifyListeners();
  }

  Future<void> saveMenuOption(MenuOption option) async {
    final index = menu.indexWhere((item) => item.id == option.id);
    if (index >= 0) {
      menu[index] = option;
    } else {
      menu.add(option);
    }
    await menuRepository.saveMenu(menu);
    notifyListeners();
  }
}

class SchoolBiteAdminApp extends StatelessWidget {
  const SchoolBiteAdminApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminController(
        SharedPrefsOrderRepository(),
        SharedPrefsMenuRepository(),
      )..load(),
      child: MaterialApp.router(
        title: 'SchoolBite Soda',
        debugShowCheckedModeBanner: false,
        theme: adminTheme(),
        routerConfig: GoRouter(
          routes: [
            GoRoute(path: '/', builder: (_, __) => const LoginScreen()),
            ShellRoute(
              builder: (_, __, child) => AdminShell(child: child),
              routes: [
                GoRoute(
                  path: '/dashboard',
                  builder: (_, __) => const DashboardScreen(),
                ),
                GoRoute(
                  path: '/orders',
                  builder: (_, __) => const OrdersScreen(),
                ),
                GoRoute(
                  path: '/production',
                  builder: (_, __) => const ProductionScreen(),
                ),
                GoRoute(
                  path: '/deliveries',
                  builder: (_, __) => const DeliveriesScreen(),
                ),
                GoRoute(
                  path: '/payments',
                  builder: (_, __) => const PaymentsScreen(),
                ),
                GoRoute(path: '/menu', builder: (_, __) => const MenuScreen()),
                GoRoute(
                  path: '/settings',
                  builder: (_, __) => const AboutScreen(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

ThemeData adminTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF10B981),
    primary: const Color(0xFF10B981),
    secondary: const Color(0xFFFFC857),
  ),
  scaffoldBackgroundColor: const Color(0xFFF6F8FA),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
      side: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
  ),
);

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Brand(),
                const SizedBox(height: 26),
                const Text(
                  'Panel para soda',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF082F49),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Pedidos en tiempo real, estados claros y pagos pendientes bajo control.',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      context.read<AdminController>().setMode(
                        AdminMode.administrator,
                      );
                      context.go('/dashboard');
                    },
                    icon: const Icon(Icons.admin_panel_settings),
                    label: const Text('Entrar como Administrador'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: () {
                      context.read<AdminController>().setMode(
                        AdminMode.operation,
                      );
                      context.go('/production');
                    },
                    icon: const Icon(Icons.touch_app),
                    label: const Text('Entrar como Operacion'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final app = context.watch<AdminController>();
    final adminDestinations = const [
      ('/dashboard', Icons.space_dashboard, 'Dashboard'),
      ('/production', Icons.inventory_2, 'Produccion'),
      ('/deliveries', Icons.local_shipping, 'Entregas'),
      ('/payments', Icons.payments, 'Pagos'),
      ('/menu', Icons.restaurant_menu, 'Menu'),
      ('/settings', Icons.info, 'Acerca de'),
    ];
    final operationDestinations = const [
      ('/production', Icons.inventory_2, 'Produccion'),
      ('/deliveries', Icons.local_shipping, 'Entregas'),
      ('/payments', Icons.payments, 'Pagos'),
    ];
    final destinations = app.mode == AdminMode.administrator
        ? adminDestinations
        : operationDestinations;
    final selected = destinations
        .indexWhere((d) => d.$1 == path)
        .clamp(0, destinations.length - 1)
        .toInt();
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: MediaQuery.of(context).size.width > 980,
            selectedIndex: selected,
            onDestinationSelected: (i) => context.go(destinations[i].$1),
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Brand(compact: true),
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Modo', style: TextStyle(fontSize: 11)),
                  const SizedBox(height: 6),
                  SegmentedButton<AdminMode>(
                    segments: const [
                      ButtonSegment(
                        value: AdminMode.administrator,
                        icon: Icon(Icons.admin_panel_settings),
                      ),
                      ButtonSegment(
                        value: AdminMode.operation,
                        icon: Icon(Icons.touch_app),
                      ),
                    ],
                    selected: {app.mode},
                    onSelectionChanged: (value) {
                      final next = value.first;
                      app.setMode(next);
                      context.go(
                        next == AdminMode.administrator
                            ? '/dashboard'
                            : '/production',
                      );
                    },
                  ),
                ],
              ),
            ),
            destinations: [
              for (final d in destinations)
                NavigationRailDestination(icon: Icon(d.$2), label: Text(d.$3)),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: SafeArea(child: child)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.read<AdminController>().load(),
        icon: const Icon(Icons.sync),
        label: const Text('Actualizar'),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => Consumer<AdminController>(
    builder: (context, app, _) {
      if (app.loading) return const PagePad(child: AdminSkeleton());
      final sales = app.orders
          .where((o) => o.paymentStatus == PaymentStatus.paid)
          .fold<int>(0, (sum, o) => sum + o.price);
      final pending = app.paymentQueue.fold<int>(0, (sum, o) => sum + o.price);
      final validation = app.orders
          .where((o) => o.paymentStatus == PaymentStatus.validation)
          .length;
      final deliveryPending = app.orders
          .where((o) => o.orderStatus == OrderStatus.pendingDelivery)
          .length;
      return PagePad(
        child: ListView(
          children: [
            const Header(
              title: 'Buenos dias',
              subtitle: 'Resumen ejecutivo de operacion para Soda Demo',
            ),
            if (app.recentOrdersCount > 0) ...[
              NewOrderBanner(count: app.recentOrdersCount),
              const SizedBox(height: 16),
            ],
            const MascotMessage(
              mascot: Mascot.ra,
              message: 'Hoy cocinaremos algo delicioso.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                Kpi(
                  label: 'Pedidos del dia',
                  value: '${app.orders.length}',
                  icon: Icons.shopping_bag,
                ),
                Kpi(
                  label: 'Desayunos',
                  value:
                      '${app.orders.where((o) => o.mealType == MealType.breakfast).length}',
                  icon: Icons.free_breakfast,
                ),
                Kpi(
                  label: 'Almuerzos',
                  value:
                      '${app.orders.where((o) => o.mealType == MealType.lunch).length}',
                  icon: Icons.rice_bowl,
                ),
                Kpi(
                  label: 'Meriendas',
                  value:
                      '${app.orders.where((o) => o.mealType == MealType.snack).length}',
                  icon: Icons.cookie,
                ),
                Kpi(
                  label: 'Ventas del dia',
                  value: money(sales),
                  icon: Icons.payments,
                ),
                Kpi(
                  label: 'Pendientes de pago',
                  value: money(pending),
                  icon: Icons.account_balance_wallet,
                ),
                Kpi(
                  label: 'Pagos en validacion',
                  value: '$validation',
                  icon: Icons.fact_check,
                ),
                Kpi(
                  label: 'Entregas pendientes',
                  value: '$deliveryPending',
                  icon: Icons.local_shipping,
                ),
              ],
            ),
            const SizedBox(height: 22),
            MealWindowsSummary(orders: app.orders),
            const SizedBox(height: 22),
            DashboardCharts(orders: app.orders, sales: sales, pending: pending),
            const SizedBox(height: 22),
            DashboardSummary(
              orders: app.orders,
              recent: app.orders.take(3).toList(),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: () => context.go('/orders'),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Ir a pedidos'),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class NewOrderBanner extends StatelessWidget {
  const NewOrderBanner({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: .96, end: 1),
    duration: const Duration(milliseconds: 650),
    curve: Curves.easeOutBack,
    builder: (context, value, child) => Transform.scale(
      scale: value,
      alignment: Alignment.centerLeft,
      child: child,
    ),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8FFF4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF10B981),
            foregroundColor: Colors.white,
            child: Icon(Icons.notifications_active),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              count == 1
                  ? 'Nuevo pedido recibido'
                  : '$count pedidos recientes recibidos',
              style: const TextStyle(
                color: Color(0xFF064E3B),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const StatusChip(
            label: 'Demo local',
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF047857),
            icon: Icons.wifi_tethering,
          ),
        ],
      ),
    ),
  );
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context) => Consumer<AdminController>(
    builder: (context, app, _) {
      return PagePad(
        child: ListView(
          children: [
            const Header(
              title: 'Pedidos',
              subtitle: 'Gestion completa de cocina, entrega y cobro.',
            ),
            const FiltersBar(),
            const SizedBox(height: 14),
            OrdersTable(orders: app.filteredOrders),
          ],
        ),
      );
    },
  );
}

class DashboardSummary extends StatelessWidget {
  const DashboardSummary({
    super.key,
    required this.orders,
    required this.recent,
  });
  final List<Order> orders;
  final List<Order> recent;

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final order in orders) {
      counts[order.menuOptionName] = (counts[order.menuOptionName] ?? 0) + 1;
    }
    final topMeals = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 860;
        final topMealsCard = SummaryCard(
          title: 'Top comidas del dia',
          icon: Icons.trending_up,
          child: Column(
            children: [
              for (final entry in topMeals.take(3))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.restaurant),
                  title: Text(entry.key),
                  trailing: Text(
                    '${entry.value}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
            ],
          ),
        );
        final activityCard = SummaryCard(
          title: 'Actividad reciente',
          icon: Icons.history,
          child: Column(
            children: [
              for (final order in recent)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: StudentAvatar(name: order.childName),
                  title: Text(
                    order.childName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(order.menuOptionName),
                  trailing: OrderStatusChip(status: order.orderStatus),
                ),
            ],
          ),
        );
        if (!wide) {
          return Column(
            children: [topMealsCard, const SizedBox(height: 16), activityCard],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: topMealsCard),
            const SizedBox(width: 16),
            Expanded(child: activityCard),
          ],
        );
      },
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF10B981)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    ),
  );
}

class MealWindowsSummary extends StatelessWidget {
  const MealWindowsSummary({super.key, required this.orders});
  final List<Order> orders;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 14,
    runSpacing: 14,
    children: [
      MealWindowCard(
        title: 'Desayuno',
        closesAt: 'Cierra 8:00 AM',
        count: orders.where((o) => o.mealType == MealType.breakfast).length,
        open: DateTime.now().hour < 8,
      ),
      MealWindowCard(
        title: 'Almuerzo',
        closesAt: 'Cierra 10:30 AM',
        count: orders.where((o) => o.mealType == MealType.lunch).length,
        open:
            DateTime.now().hour < 10 ||
            (DateTime.now().hour == 10 && DateTime.now().minute < 30),
      ),
      MealWindowCard(
        title: 'Merienda',
        closesAt: 'Ventana configurable',
        count: orders.where((o) => o.mealType == MealType.snack).length,
        open: true,
      ),
    ],
  );
}

class MealWindowCard extends StatelessWidget {
  const MealWindowCard({
    super.key,
    required this.title,
    required this.closesAt,
    required this.count,
    required this.open,
  });
  final String title;
  final String closesAt;
  final int count;
  final bool open;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 260,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                StatusChip(
                  label: open ? 'Abierto' : 'Cerrado',
                  backgroundColor: open
                      ? const Color(0xFFE8FFF4)
                      : const Color(0xFFFEE2E2),
                  foregroundColor: open
                      ? const Color(0xFF047857)
                      : const Color(0xFF991B1B),
                  icon: open ? Icons.lock_open : Icons.lock,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(closesAt, style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 14),
            Text(
              '$count pedidos recibidos',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    ),
  );
}

class ProductionScreen extends StatelessWidget {
  const ProductionScreen({super.key});
  @override
  Widget build(BuildContext context) => Consumer<AdminController>(
    builder: (context, app, _) {
      return PagePad(
        child: ListView(
          children: [
            const Header(
              title: 'Produccion',
              subtitle:
                  'Cantidades agrupadas por tipo, opcion y ciclo para alistar en grupo.',
            ),
            const MascotMessage(
              mascot: Mascot.osi,
              message: '¡Todo listo para entregar!',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: () => showCounterOrderDialog(context),
                  icon: const Icon(Icons.point_of_sale),
                  label: const Text('Pedido en soda'),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.print),
                  label: const Text('Imprimir hoja de produccion'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            for (final type in MealType.values) ...[
              SectionTitle(mealLabel(type).toUpperCase()),
              const SizedBox(height: 10),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: productionGroups(
                  app.orders,
                  type,
                ).map((group) => ProductionGroupCard(group: group)).toList(),
              ),
              const SizedBox(height: 22),
            ],
          ],
        ),
      );
    },
  );
}

class ProductionGroup {
  ProductionGroup({
    required this.mealType,
    required this.optionNumber,
    required this.menuOptionName,
    required this.orders,
  });
  final MealType mealType;
  final int? optionNumber;
  final String menuOptionName;
  final List<Order> orders;
}

List<ProductionGroup> productionGroups(List<Order> orders, MealType type) {
  final grouped = <String, List<Order>>{};
  for (final order in orders.where((order) => order.mealType == type)) {
    final key = '${order.optionNumber ?? 0}-${order.menuOptionName}';
    grouped.putIfAbsent(key, () => []).add(order);
  }
  final groups = grouped.values
      .map(
        (items) => ProductionGroup(
          mealType: type,
          optionNumber: items.first.optionNumber,
          menuOptionName: items.first.menuOptionName,
          orders: items,
        ),
      )
      .toList();
  groups.sort((a, b) => (a.optionNumber ?? 99).compareTo(b.optionNumber ?? 99));
  return groups;
}

class ProductionGroupCard extends StatelessWidget {
  const ProductionGroupCard({super.key, required this.group});
  final ProductionGroup group;

  @override
  Widget build(BuildContext context) {
    final total = group.orders.length;
    final special = group.orders
        .where(
          (order) => order.hasCustomization || order.hasDietaryRestrictions,
        )
        .length;
    int count(Cycle cycle) =>
        group.orders.where((order) => order.childCycle == cycle).length;
    return SizedBox(
      width: 330,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Opcion ${group.optionNumber ?? '-'}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF082F49),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                group.menuOptionName,
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 18),
              ProductionCount(label: 'Total', value: total),
              ProductionCount(label: 'PK', value: count(Cycle.prekinder)),
              ProductionCount(label: 'I Ciclo', value: count(Cycle.iCiclo)),
              ProductionCount(label: 'II Ciclo', value: count(Cycle.iiCiclo)),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Especiales: $special',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  TextButton(
                    onPressed: special == 0
                        ? null
                        : () => showCustomizationsDialog(
                            context,
                            group.orders
                                .where(
                                  (order) =>
                                      order.hasCustomization ||
                                      order.hasDietaryRestrictions,
                                )
                                .toList(),
                          ),
                    child: const Text('Ver'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductionCount extends StatelessWidget {
  const ProductionCount({super.key, required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text('$value', style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    ),
  );
}

Future<void> showCustomizationsDialog(
  BuildContext context,
  List<Order> orders,
) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Personalizados y restricciones'),
      content: SizedBox(
        width: 520,
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final order in orders)
              ListTile(
                leading: StudentAvatar(name: order.childName),
                title: Text(order.childName),
                subtitle: Text(
                  [
                    order.childSection,
                    if (order.hasCustomization) customizationText(order),
                    if (order.hasDietaryRestrictions)
                      'Restricciones: ${order.dietaryRestrictions}',
                  ].join('\n'),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}

class DeliveriesScreen extends StatelessWidget {
  const DeliveriesScreen({super.key});
  @override
  Widget build(BuildContext context) => Consumer<AdminController>(
    builder: (context, app, _) {
      final orders = app.filteredOrders;
      return PagePad(
        child: ListView(
          children: [
            const Header(
              title: 'Entregas',
              subtitle:
                  'Entrega por aula y seccion, con personalizados visibles.',
            ),
            const FiltersBar(
              showPayment: true,
              showCustomization: true,
              showOption: true,
              showDietary: true,
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 820) {
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      for (final order in orders) DeliveryCard(order: order),
                    ],
                  );
                }
                return DeliveryTable(orders: orders);
              },
            ),
          ],
        ),
      );
    },
  );
}

class DeliveryTable extends StatelessWidget {
  const DeliveryTable({super.key, required this.orders});
  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const EmptyState(
        text: 'No hay entregas para los filtros actuales.',
      );
    }
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF082F49),
          ),
          columns: const [
            DataColumn(label: Text('Seccion')),
            DataColumn(label: Text('Estudiante')),
            DataColumn(label: Text('Tipo comida')),
            DataColumn(label: Text('Opcion')),
            DataColumn(label: Text('Personalizado')),
            DataColumn(label: Text('Restricciones')),
            DataColumn(label: Text('Pago')),
            DataColumn(label: Text('Entrega')),
            DataColumn(label: Text('Acciones')),
          ],
          rows: [
            for (final order in orders)
              DataRow(
                cells: [
                  DataCell(Text(order.childSection)),
                  DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 190),
                      child: Text(
                        order.childName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(Text(mealLabel(order.mealType))),
                  DataCell(Text('Opcion ${order.optionNumber ?? '-'}')),
                  DataCell(
                    order.hasCustomization
                        ? const CustomBadge()
                        : const Text('No'),
                  ),
                  DataCell(
                    order.hasDietaryRestrictions
                        ? Tooltip(
                            message: order.dietaryRestrictions!,
                            child: const RestrictionBadge(),
                          )
                        : const Text('No'),
                  ),
                  DataCell(
                    PaymentStatusChip(
                      status: order.paymentStatus,
                      method: order.paymentMethod,
                    ),
                  ),
                  DataCell(OrderStatusChip(status: order.orderStatus)),
                  DataCell(
                    SizedBox(width: 260, child: DeliveryActions(order: order)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class DeliveryCard extends StatelessWidget {
  const DeliveryCard({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 330,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.childName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                order.childSection,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${mealLabel(order.mealType)} / Opcion ${order.optionNumber ?? '-'}',
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OrderStatusChip(status: order.orderStatus),
                  PaymentStatusChip(
                    status: order.paymentStatus,
                    method: order.paymentMethod,
                  ),
                  if (order.hasCustomization) const CustomBadge(),
                  if (order.hasDietaryRestrictions) const RestrictionBadge(),
                ],
              ),
              if (order.hasDietaryRestrictions) ...[
                const SizedBox(height: 8),
                Text(
                  order.dietaryRestrictions!,
                  style: const TextStyle(
                    color: Color(0xFF9A3412),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              DeliveryActions(order: order),
            ],
          ),
        ),
      ),
    );
  }
}

class DeliveryActions extends StatelessWidget {
  const DeliveryActions({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final app = context.read<AdminController>();
    if (order.orderStatus == OrderStatus.cancelled) {
      return const Text(
        'Pedido cancelado',
        style: TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.w900),
      );
    }
    if (order.orderStatus == OrderStatus.delivered) {
      return const Text(
        'Entrega completada',
        style: TextStyle(color: Color(0xFF047857), fontWeight: FontWeight.w900),
      );
    }
    final canDeliver = order.paymentStatus == PaymentStatus.paid;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (order.paymentStatus == PaymentStatus.pending)
          FilledButton.icon(
            onPressed: () => showConfirmPaymentDialog(context, order),
            icon: const Icon(Icons.payments),
            label: const Text('Confirmar pago'),
          ),
        if (order.paymentStatus == PaymentStatus.validation)
          FilledButton.icon(
            onPressed: () => showValidatePaymentDialog(context, order),
            icon: const Icon(Icons.fact_check),
            label: const Text('Validar pago'),
          ),
        if (canDeliver)
          FilledButton.icon(
            onPressed: () =>
                app.updateOrderStatus(order, OrderStatus.delivered),
            icon: const Icon(Icons.done),
            label: const Text('Marcar entregado'),
          ),
        if (order.paymentStatus == PaymentStatus.refundPending)
          const Text(
            'Reembolso pendiente',
            style: TextStyle(
              color: Color(0xFF92400E),
              fontWeight: FontWeight.w900,
            ),
          ),
      ],
    );
  }
}

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});
  @override
  Widget build(BuildContext context) => Consumer<AdminController>(
    builder: (context, app, _) {
      final queue = app.paymentQueue;
      final amount = queue.fold<int>(0, (sum, order) => sum + order.price);
      final validation = queue
          .where((order) => order.paymentStatus == PaymentStatus.validation)
          .length;
      final refund = queue
          .where((order) => order.paymentStatus == PaymentStatus.refundPending)
          .length;
      return PagePad(
        child: ListView(
          children: [
            const Header(
              title: 'Pagos',
              subtitle:
                  'Control de pendientes, validaciones SINPE y reembolsos.',
            ),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                Kpi(
                  label: 'Total pendiente',
                  value: '${queue.length}',
                  icon: Icons.pending_actions,
                ),
                Kpi(
                  label: 'Por validar',
                  value: '$validation',
                  icon: Icons.fact_check,
                ),
                Kpi(
                  label: 'Reembolsos',
                  value: '$refund',
                  icon: Icons.assignment_return,
                ),
                Kpi(
                  label: 'Monto pendiente',
                  value: money(amount),
                  icon: Icons.account_balance_wallet,
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (queue.isEmpty)
              const EmptyState(text: 'No hay pagos pendientes por gestionar.')
            else
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final order in queue) PaymentQueueCard(order: order),
                ],
              ),
          ],
        ),
      );
    },
  );
}

class PaymentQueueCard extends StatelessWidget {
  const PaymentQueueCard({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 420,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StudentAvatar(name: order.childName),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.childName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      Text('${order.menuOptionName} / ${money(order.price)}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            PaymentStatusChip(
              status: order.paymentStatus,
              method: order.paymentMethod,
            ),
            const SizedBox(height: 14),
            OrderPaymentActions(order: order),
          ],
        ),
      ),
    ),
  );
}

class FiltersBar extends StatelessWidget {
  const FiltersBar({
    super.key,
    this.showPayment = true,
    this.showCustomization = false,
    this.showOption = false,
    this.showDietary = false,
  });
  final bool showPayment;
  final bool showCustomization;
  final bool showOption;
  final bool showDietary;
  @override
  Widget build(BuildContext context) => Consumer<AdminController>(
    builder: (context, app, _) {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          filterDropdown<MealType>(
            'Tipo',
            app.mealFilter,
            MealType.values,
            mealLabel,
            app.setMealFilter,
          ),
          if (showOption)
            filterDropdown<int>(
              'Opcion',
              app.optionFilter,
              const [1, 2],
              (value) => 'Opcion $value',
              app.setOptionFilter,
            ),
          filterDropdown<Cycle>(
            'Ciclo',
            app.cycleFilter,
            Cycle.values,
            cycleLabel,
            app.setCycleFilter,
          ),
          filterDropdown<OrderStatus>(
            'Estado entrega',
            app.orderFilter,
            OrderStatus.values,
            orderLabel,
            app.setOrderFilter,
          ),
          if (showPayment)
            filterDropdown<PaymentStatus>(
              'Estado pago',
              app.paymentFilter,
              PaymentStatus.values,
              paymentLabel,
              app.setPaymentFilter,
            ),
          SizedBox(
            width: 140,
            child: TextField(
              decoration: const InputDecoration(labelText: 'Seccion'),
              onChanged: app.setSectionFilter,
            ),
          ),
          if (showCustomization)
            FilterChip(
              label: const Text('Personalizados'),
              selected: app.customOnlyFilter,
              onSelected: app.setCustomOnlyFilter,
            ),
          if (showDietary)
            FilterChip(
              label: const Text('Restricciones'),
              selected: app.dietaryOnlyFilter,
              onSelected: app.setDietaryOnlyFilter,
            ),
          OutlinedButton.icon(
            onPressed: app.clearFilters,
            icon: const Icon(Icons.clear),
            label: const Text('Limpiar'),
          ),
        ],
      );
    },
  );
}

Widget filterDropdown<T>(
  String label,
  T? value,
  List<T> values,
  String Function(T) labeler,
  ValueChanged<T?> onChanged,
) => SizedBox(
  width: 190,
  child: DropdownButtonFormField<T>(
    value: value,
    decoration: InputDecoration(labelText: label),
    items: values
        .map((v) => DropdownMenuItem(value: v, child: Text(labeler(v))))
        .toList(),
    onChanged: onChanged,
  ),
);

class DashboardCharts extends StatelessWidget {
  const DashboardCharts({
    super.key,
    required this.orders,
    required this.sales,
    required this.pending,
  });
  final List<Order> orders;
  final int sales;
  final int pending;

  @override
  Widget build(BuildContext context) {
    final breakfast = orders
        .where((o) => o.mealType == MealType.breakfast)
        .length;
    final lunch = orders.where((o) => o.mealType == MealType.lunch).length;
    final snack = orders.where((o) => o.mealType == MealType.snack).length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 880;
        final salesChart = ChartCard(
          title: 'Ventas del dia',
          subtitle: '${money(sales)} cobrados / ${money(pending)} pendientes',
          bars: const [.45, .68, .54, .82, .62, .9, .74],
          color: const Color(0xFF10B981),
        );
        final typeChart = ChartCard(
          title: 'Pedidos por tipo',
          subtitle: 'Desayuno $breakfast / Almuerzo $lunch / Merienda $snack',
          bars: [
            breakfast == 0 ? .08 : breakfast / (orders.length + 1),
            lunch == 0 ? .08 : lunch / (orders.length + 1),
            snack == 0 ? .08 : snack / (orders.length + 1),
          ],
          color: const Color(0xFFF59E0B),
        );
        if (!wide) {
          return Column(
            children: [salesChart, const SizedBox(height: 16), typeChart],
          );
        }
        return Row(
          children: [
            Expanded(child: salesChart),
            const SizedBox(width: 16),
            Expanded(child: typeChart),
          ],
        );
      },
    );
  }
}

class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.bars,
    required this.color,
  });
  final String title;
  final String subtitle;
  final List<double> bars;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 18),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final bar in bars)
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: .05, end: bar.clamp(.05, .95)),
                        duration: const Duration(milliseconds: 650),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) => Container(
                          height: 110 * value,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: .18 + value * .55),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String studentMeta(Order order) {
  return '${order.childSection} / ${cycleLabel(order.childCycle)}';
}

String optionLabel(Order order) => order.optionNumber == null
    ? mealLabel(order.mealType)
    : '${mealLabel(order.mealType)} / Opcion ${order.optionNumber}';

String customizationText(Order order) {
  final labels = {
    'sin_queso': 'Sin queso',
    'sin_salchicha': 'Sin salchicha',
    'sin_natilla': 'Sin natilla',
    'sin_azucar': 'Sin azucar',
    'sin_salsa': 'Sin salsa',
    'sin_tomate': 'Sin tomate',
    'sin_cebolla': 'Sin cebolla',
    'otro': 'Otro',
  };
  final tags = order.customizationTags
      .map((tag) => labels[tag] ?? tag)
      .toList();
  if (order.customNote?.trim().isNotEmpty ?? false) {
    tags.add(order.customNote!.trim());
  }
  return tags.join(', ');
}

class CustomBadge extends StatelessWidget {
  const CustomBadge({super.key});

  @override
  Widget build(BuildContext context) => const StatusChip(
    label: 'Personalizado',
    backgroundColor: Color(0xFFFFEDD5),
    foregroundColor: Color(0xFF9A3412),
    icon: Icons.tune,
  );
}

class RestrictionBadge extends StatelessWidget {
  const RestrictionBadge({super.key});

  @override
  Widget build(BuildContext context) => const StatusChip(
    label: 'Restricciones',
    backgroundColor: Color(0xFFFFF7ED),
    foregroundColor: Color(0xFF9A3412),
    icon: Icons.warning_amber,
  );
}

class StudentAvatar extends StatelessWidget {
  const StudentAvatar({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.length > 1
        ? '${parts.first[0]}${parts[1][0]}'.toUpperCase()
        : name.substring(0, 1).toUpperCase();
    return CircleAvatar(
      backgroundColor: const Color(0xFFE8FFF4),
      foregroundColor: const Color(0xFF047857),
      child: Text(
        initials,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}

class StudentCell extends StatelessWidget {
  const StudentCell({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StudentAvatar(name: order.childName),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.childName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              Text(
                studentMeta(order),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OrdersTable extends StatelessWidget {
  const OrdersTable({super.key, required this.orders});
  final List<Order> orders;
  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const EmptyState(text: 'No hay pedidos para estos filtros.');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth >= 1320;
        return Column(
          children: [
            for (final order in orders)
              OrderCard(order: order, horizontal: horizontal),
          ],
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, required this.horizontal});
  final Order order;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final background = switch (order.paymentStatus) {
      PaymentStatus.pending => const Color(0xFFFFFBF4),
      PaymentStatus.validation => const Color(0xFFF0F9FF),
      _ => Colors.white,
    };
    final border = switch (order.paymentStatus) {
      PaymentStatus.pending => const Color(0xFFFED7AA),
      PaymentStatus.validation => const Color(0xFFBAE6FD),
      _ => const Color(0xFFE2E8F0),
    };
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: horizontal
          ? _HorizontalOrderCard(order: order)
          : _VerticalOrderCard(order: order),
    );
  }
}

class _HorizontalOrderCard extends StatelessWidget {
  const _HorizontalOrderCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 74, child: OrderTime(order: order)),
        const SizedBox(width: 14),
        StudentAvatar(name: order.childName),
        const SizedBox(width: 14),
        Expanded(flex: 6, child: StudentBlock(order: order)),
        const SizedBox(width: 20),
        Expanded(flex: 5, child: MealBlock(order: order)),
        const SizedBox(width: 20),
        SizedBox(width: 170, child: OrderStatusBlock(order: order)),
        const SizedBox(width: 16),
        SizedBox(width: 210, child: PaymentStatusBlock(order: order)),
        const SizedBox(width: 16),
        SizedBox(width: 360, child: OrderActions(order: order)),
      ],
    );
  }
}

class _VerticalOrderCard extends StatelessWidget {
  const _VerticalOrderCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            OrderTime(order: order),
            const Spacer(),
            OrderStatusChip(status: order.orderStatus),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StudentAvatar(name: order.childName),
            const SizedBox(width: 12),
            Expanded(child: StudentBlock(order: order)),
          ],
        ),
        const SizedBox(height: 16),
        MealBlock(order: order),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OrderStatusBlock(order: order),
            PaymentStatusBlock(order: order),
          ],
        ),
        const SizedBox(height: 16),
        OrderActions(order: order),
      ],
    );
  }
}

class OrderTime extends StatelessWidget {
  const OrderTime({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Hora',
        style: TextStyle(
          color: Color(0xFF64748B),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}',
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
    ],
  );
}

class StudentBlock extends StatelessWidget {
  const StudentBlock({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        order.childName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 4),
      Text(
        studentMeta(order),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class MealBlock extends StatelessWidget {
  const MealBlock({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'Opcion ${order.optionNumber ?? '-'}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 4),
      Text(
        '${mealLabel(order.mealType)} / ${money(order.price)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        order.menuOptionName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
      ),
      if (order.hasCustomization) ...[
        const SizedBox(height: 6),
        const CustomBadge(),
      ],
      if (order.hasDietaryRestrictions) ...[
        const SizedBox(height: 6),
        Tooltip(
          message: order.dietaryRestrictions!,
          child: const RestrictionBadge(),
        ),
      ],
    ],
  );
}

class OrderStatusBlock extends StatelessWidget {
  const OrderStatusBlock({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      const BlockLabel('Estado'),
      const SizedBox(height: 6),
      OrderStatusChip(status: order.orderStatus),
    ],
  );
}

class PaymentStatusBlock extends StatelessWidget {
  const PaymentStatusBlock({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      const BlockLabel('Pago'),
      const SizedBox(height: 6),
      PaymentStatusChip(
        status: order.paymentStatus,
        method: order.paymentMethod,
      ),
      if (order.paymentStatus == PaymentStatus.paid) ...[
        const SizedBox(height: 6),
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock, size: 14, color: Color(0xFF047857)),
            SizedBox(width: 4),
            Text(
              'Confirmado',
              style: TextStyle(
                color: Color(0xFF047857),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    ],
  );
}

class BlockLabel extends StatelessWidget {
  const BlockLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: Color(0xFF64748B),
      fontSize: 11,
      fontWeight: FontWeight.w900,
    ),
  );
}

class OrderTableHeader extends StatelessWidget {
  const OrderTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          SizedBox(width: 70, child: Text('Hora')),
          Expanded(flex: 4, child: Text('Alumno')),
          Expanded(flex: 3, child: Text('Pedido')),
          SizedBox(width: 156, child: Text('Estado')),
          SizedBox(width: 170, child: Text('Pago')),
          SizedBox(width: 330, child: Text('Acciones')),
        ],
      ),
    );
  }
}

class OrderTableRow extends StatelessWidget {
  const OrderTableRow({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: order.paymentStatus == PaymentStatus.pending
            ? const Color(0xFFFFFBF4)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: order.paymentStatus == PaymentStatus.pending
              ? const Color(0xFFFED7AA)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(flex: 4, child: StudentCell(order: order)),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.menuOptionName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  '${mealLabel(order.mealType)} / ${money(order.price)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 156,
            child: OrderStatusChip(status: order.orderStatus),
          ),
          SizedBox(
            width: 170,
            child: PaymentStatusChip(
              status: order.paymentStatus,
              method: order.paymentMethod,
            ),
          ),
          SizedBox(width: 330, child: OrderActions(order: order)),
        ],
      ),
    );
  }
}

class OrderMobileCard extends StatelessWidget {
  const OrderMobileCard({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              OrderStatusChip(status: order.orderStatus),
            ],
          ),
          const SizedBox(height: 12),
          StudentCell(order: order),
          const SizedBox(height: 12),
          Text(
            order.menuOptionName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text('${mealLabel(order.mealType)} / ${money(order.price)}'),
          const SizedBox(height: 12),
          PaymentStatusChip(
            status: order.paymentStatus,
            method: order.paymentMethod,
          ),
          const SizedBox(height: 12),
          OrderActions(order: order),
        ],
      ),
    ),
  );
}

class OrderActions extends StatelessWidget {
  const OrderActions({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final app = context.read<AdminController>();
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        SizedBox(
          width: 190,
          child: DropdownButtonFormField<OrderStatus>(
            value: order.orderStatus,
            isDense: true,
            decoration: const InputDecoration(
              labelText: 'Entrega',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            items: OrderStatus.values
                .map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(
                      orderLabel(status),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (status) {
              if (status != null) {
                app.updateOrderStatus(order, status);
              }
            },
          ),
        ),
        OrderPaymentActions(order: order),
      ],
    );
  }
}

class OrderPaymentActions extends StatelessWidget {
  const OrderPaymentActions({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final app = context.read<AdminController>();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: switch (order.paymentStatus) {
        PaymentStatus.pending => [
          FilledButton.icon(
            onPressed: () => showConfirmPaymentDialog(context, order),
            icon: const Icon(Icons.check_circle),
            label: const Text('Confirmar pago'),
          ),
        ],
        PaymentStatus.validation => [
          FilledButton.icon(
            onPressed: () => showValidatePaymentDialog(context, order),
            icon: const Icon(Icons.fact_check),
            label: const Text('Validar pago'),
          ),
        ],
        PaymentStatus.paid => [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, size: 16, color: Color(0xFF047857)),
              SizedBox(width: 6),
              Text(
                'Confirmado',
                style: TextStyle(
                  color: Color(0xFF047857),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
        PaymentStatus.cancelled => [
          const Text(
            'Pago cancelado',
            style: TextStyle(
              color: Color(0xFF991B1B),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
        PaymentStatus.refundPending => [
          FilledButton.tonalIcon(
            onPressed: () => app.markRefundResolved(order),
            icon: const Icon(Icons.assignment_return),
            label: const Text('Marcar reembolsado'),
          ),
        ],
      },
    );
  }
}

Future<void> showConfirmPaymentDialog(BuildContext context, Order order) async {
  var selected = PaymentMethod.cash;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) {
        return AlertDialog(
          title: const Text('Confirmar pago'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${order.childName} / ${order.menuOptionName}'),
              const SizedBox(height: 12),
              DropdownButtonFormField<PaymentMethod>(
                value: selected,
                decoration: const InputDecoration(labelText: 'Metodo de pago'),
                items:
                    const [
                          PaymentMethod.cash,
                          PaymentMethod.sinpe,
                          PaymentMethod.card,
                          PaymentMethod.balance,
                        ]
                        .map(
                          (method) => DropdownMenuItem(
                            value: method,
                            child: Text(paymentMethodLabel(method)),
                          ),
                        )
                        .toList(),
                onChanged: (method) {
                  if (method != null) {
                    setDialogState(() => selected = method);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                context.read<AdminController>().confirmPayment(order, selected);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Confirmar pago'),
            ),
          ],
        );
      },
    ),
  );
}

Future<void> showValidatePaymentDialog(
  BuildContext context,
  Order order,
) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Validar pago SINPE'),
      content: const Text(
        'Comprobante recibido por SINPE Movil. En una version real aqui se mostraria la imagen del comprobante o confirmacion automatica.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.read<AdminController>().rejectPaymentValidation(order);
            Navigator.of(dialogContext).pop();
          },
          child: const Text('Rechazar'),
        ),
        FilledButton(
          onPressed: () {
            context.read<AdminController>().approvePaymentValidation(order);
            Navigator.of(dialogContext).pop();
          },
          child: const Text('Aprobar'),
        ),
      ],
    ),
  );
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});
  @override
  Widget build(BuildContext context) => Consumer<AdminController>(
    builder: (context, app, _) {
      return PagePad(
        child: ListView(
          children: [
            const Header(
              title: 'Menu',
              subtitle:
                  'Configure opciones por fecha, disponibilidad, precios y stock.',
            ),
            Row(
              children: [
                const Expanded(child: SectionTitle('Menu de hoy')),
                OutlinedButton.icon(
                  onPressed: () => showMonthlyMenuImportDialog(context),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Importar menu mensual'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: () => showMenuForm(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Crear opcion'),
                ),
              ],
            ),
            for (final type in MealType.values) ...[
              const SizedBox(height: 16),
              Text(
                mealLabel(type),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final option in app.menu.where(
                    (m) => m.mealType == type,
                  ))
                    SizedBox(
                      width: 360,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      option.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  Switch(
                                    value: option.available,
                                    onChanged: (v) {
                                      option.available = v;
                                      app.saveMenuOption(option);
                                    },
                                  ),
                                ],
                              ),
                              Text(
                                option.description,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Prekinder ${money(option.pricesByCycle[Cycle.prekinder] ?? 0)} / I Ciclo ${money(option.pricesByCycle[Cycle.iCiclo] ?? 0)} / II Ciclo ${money(option.pricesByCycle[Cycle.iiCiclo] ?? 0)}',
                              ),
                              Text(
                                'Stock: ${option.stockLimit?.toString() ?? 'Sin limite'}',
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () =>
                                      showMenuForm(context, option: option),
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Editar'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      );
    },
  );
}

Future<void> showMonthlyMenuImportDialog(BuildContext context) async {
  var selectedFile = false;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('Importar menu mensual'),
        content: SizedBox(
          width: 620,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Base lista para cargar archivos .xlsx. En esta demo se valida visualmente el formato; el parser real se conectara en la fase de backend.',
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => setDialogState(() => selectedFile = true),
                  icon: const Icon(Icons.attach_file),
                  label: Text(
                    selectedFile
                        ? 'menu_mensual_schoolbite.xlsx'
                        : 'Seleccionar archivo .xlsx',
                  ),
                ),
                const SizedBox(height: 18),
                const SectionTitle('Formato esperado'),
                const SizedBox(height: 8),
                const Text(
                  'Fecha | Tipo comida | Opcion | Nombre plato | Descripcion | Precio Preescolar | Precio I Ciclo | Precio II Ciclo | Personalizaciones permitidas',
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  child: const Text(
                    '2026-07-08 | Desayuno | Opcion 1 | Pinto con huevo | Pinto, huevo y fruta | 1500 | 1800 | 2000 | Sin queso; Sin natilla; Sin salchicha',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                if (selectedFile) ...[
                  const SizedBox(height: 16),
                  const StatusChip(
                    label: 'Validacion mock correcta',
                    backgroundColor: Color(0xFFE8FFF4),
                    foregroundColor: Color(0xFF047857),
                    icon: Icons.check_circle,
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cerrar'),
          ),
          FilledButton(
            onPressed: selectedFile
                ? () => Navigator.of(dialogContext).pop()
                : null,
            child: const Text('Cargar para la fecha actual'),
          ),
        ],
      ),
    ),
  );
}

Future<void> showCounterOrderDialog(BuildContext context) async {
  final app = context.read<AdminController>();
  final student = TextEditingController();
  final section = TextEditingController(text: 'PK-A');
  final restrictions = TextEditingController();
  var mealType = MealType.breakfast;
  var paymentMethod = PaymentMethod.cash;
  MenuOption? selectedOption = app.menu.firstWhere(
    (option) => option.mealType == mealType && option.available,
    orElse: () => app.menu.first,
  );

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) {
        final options = app.menu
            .where((option) => option.mealType == mealType && option.available)
            .toList();
        if (options.isNotEmpty && !options.contains(selectedOption)) {
          selectedOption = options.first;
        }
        return AlertDialog(
          title: const Text('Pedido en soda'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: student,
                    onChanged: (_) => setDialogState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Estudiante',
                      hintText: 'Nombre completo o estudiante invitado',
                    ),
                  ),
                  TextField(
                    controller: section,
                    decoration: const InputDecoration(
                      labelText: 'Seccion',
                      hintText: 'PK-A, 1-A, 2-B, 6-C...',
                    ),
                  ),
                  DropdownButtonFormField<MealType>(
                    value: mealType,
                    decoration: const InputDecoration(labelText: 'Tipo comida'),
                    items: MealType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(mealLabel(type)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setDialogState(() {
                      mealType = value!;
                      selectedOption = app.menu.firstWhere(
                        (option) =>
                            option.mealType == mealType && option.available,
                        orElse: () => app.menu.first,
                      );
                    }),
                  ),
                  DropdownButtonFormField<MenuOption>(
                    value: selectedOption,
                    decoration: const InputDecoration(labelText: 'Opcion'),
                    items: options
                        .map(
                          (option) => DropdownMenuItem(
                            value: option,
                            child: Text(
                              'Opcion ${option.optionNumber} / ${option.name}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setDialogState(() => selectedOption = value),
                  ),
                  DropdownButtonFormField<PaymentMethod>(
                    value: paymentMethod,
                    decoration: const InputDecoration(labelText: 'Pago'),
                    items:
                        const [
                              PaymentMethod.cash,
                              PaymentMethod.sinpe,
                              PaymentMethod.card,
                              PaymentMethod.balance,
                              PaymentMethod.unknown,
                            ]
                            .map(
                              (method) => DropdownMenuItem(
                                value: method,
                                child: Text(
                                  method == PaymentMethod.unknown
                                      ? 'Pagar despues'
                                      : paymentMethodLabel(method),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) =>
                        setDialogState(() => paymentMethod = value!),
                  ),
                  TextField(
                    controller: restrictions,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Restricciones alimenticias',
                      hintText: 'Opcional: alergias o notas importantes',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: selectedOption == null || student.text.trim().isEmpty
                  ? null
                  : () async {
                      await app.createCounterOrder(
                        childName: student.text.trim(),
                        section: section.text.trim().isEmpty
                            ? 'Sin seccion'
                            : section.text.trim(),
                        option: selectedOption!,
                        paymentMethod: paymentMethod,
                        dietaryRestrictions: restrictions.text,
                      );
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    },
              child: const Text('Confirmar pedido'),
            ),
          ],
        );
      },
    ),
  );
}

void showMenuForm(BuildContext context, {MenuOption? option}) {
  final name = TextEditingController(text: option?.name ?? '');
  final description = TextEditingController(text: option?.description ?? '');
  final prekinder = TextEditingController(
    text: '${option?.pricesByCycle[Cycle.prekinder] ?? 1500}',
  );
  final iCiclo = TextEditingController(
    text: '${option?.pricesByCycle[Cycle.iCiclo] ?? 1800}',
  );
  final iiCiclo = TextEditingController(
    text: '${option?.pricesByCycle[Cycle.iiCiclo] ?? 2000}',
  );
  final stock = TextEditingController(
    text: option?.stockLimit?.toString() ?? '',
  );
  var type = option?.mealType ?? MealType.breakfast;
  var available = option?.available ?? true;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: EdgeInsets.fromLTRB(
          22,
          22,
          22,
          MediaQuery.of(context).viewInsets.bottom + 22,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                option == null ? 'Crear opcion de menu' : 'Editar opcion',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              DropdownButtonFormField<MealType>(
                value: type,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: MealType.values
                    .map(
                      (m) =>
                          DropdownMenuItem(value: m, child: Text(mealLabel(m))),
                    )
                    .toList(),
                onChanged: (v) => setState(() => type = v!),
              ),
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: description,
                decoration: const InputDecoration(labelText: 'Descripcion'),
              ),
              TextField(
                controller: prekinder,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Precio Prekinder',
                ),
              ),
              TextField(
                controller: iCiclo,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio I Ciclo'),
              ),
              TextField(
                controller: iiCiclo,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio II Ciclo'),
              ),
              TextField(
                controller: stock,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock opcional'),
              ),
              SwitchListTile(
                value: available,
                onChanged: (v) => setState(() => available = v),
                title: const Text('Disponible'),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    context.read<AdminController>().saveMenuOption(
                      MenuOption(
                        id:
                            option?.id ??
                            'menu_${DateTime.now().microsecondsSinceEpoch}',
                        mealType: type,
                        optionNumber: option?.optionNumber ?? 1,
                        name: name.text,
                        description: description.text,
                        pricesByCycle: {
                          Cycle.prekinder: int.tryParse(prekinder.text) ?? 0,
                          Cycle.iCiclo: int.tryParse(iCiclo.text) ?? 0,
                          Cycle.iiCiclo: int.tryParse(iiCiclo.text) ?? 0,
                        },
                        available: available,
                        stockLimit: int.tryParse(stock.text),
                      ),
                    );
                    Navigator.pop(sheetContext);
                  },
                  child: const Text('Guardar menu'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => PagePad(
    child: ListView(
      children: [
        const Header(
          title: 'Acerca de',
          subtitle: 'Identidad oficial de la Demo Comercial SchoolBite.',
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Image.asset(BrandAssets.logo, height: 150, fit: BoxFit.contain),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    MascotMini(mascot: Mascot.osi, size: 108),
                    SizedBox(width: 18),
                    MascotMini(mascot: Mascot.ra, size: 108),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Card(
          child: ListTile(
            leading: Icon(Icons.lunch_dining),
            title: Text('SchoolBite'),
            subtitle: Text('Version Demo Comercial'),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.code),
            title: Text('Desarrollado por'),
            subtitle: Text('Jos&Vic Devs'),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.verified),
            title: Text('Licencia'),
            subtitle: Text('Demo Comercial'),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.language),
            title: Text('Contacto'),
            subtitle: Text('Sitio web'),
          ),
        ),
      ],
    ),
  );
}

class PagePad extends StatelessWidget {
  const PagePad({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.all(24), child: child);
}

class Header extends StatelessWidget {
  const Header({super.key, required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Color(0xFF082F49),
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Color(0xFF64748B))),
      ],
    ),
  );
}

class Kpi extends StatelessWidget {
  const Kpi({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 220,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE8FFF4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF10B981)),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF082F49),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

enum Mascot { osi, ra }

class MascotMini extends StatelessWidget {
  const MascotMini({super.key, required this.mascot, this.size = 96});
  final Mascot mascot;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isOsi = mascot == Mascot.osi;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isOsi ? const Color(0xFFE8FFF4) : const Color(0xFFFFFBEB),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF10B981), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A052E2B),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          isOsi ? BrandAssets.osiThumb : BrandAssets.raThumb,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class MascotMessage extends StatelessWidget {
  const MascotMessage({super.key, required this.mascot, required this.message});
  final Mascot mascot;
  final String message;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          MascotMini(mascot: mascot, size: 58),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF082F49),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class Brand extends StatelessWidget {
  const Brand({super.key, this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) => Image.asset(
    BrandAssets.logo,
    height: compact ? 40 : 56,
    width: compact ? 40 : null,
    fit: BoxFit.contain,
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key});
  final String title;
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
  );
}

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) => StatusChip(
    label: orderLabel(status),
    backgroundColor: switch (status) {
      OrderStatus.pendingDelivery => const Color(0xFFFFF7DB),
      OrderStatus.delivered => const Color(0xFFE8FFF4),
      OrderStatus.cancelled => const Color(0xFFFEE2E2),
    },
    foregroundColor: switch (status) {
      OrderStatus.pendingDelivery => const Color(0xFF92400E),
      OrderStatus.delivered => const Color(0xFF047857),
      OrderStatus.cancelled => const Color(0xFF991B1B),
    },
    icon: switch (status) {
      OrderStatus.pendingDelivery => Icons.local_shipping,
      OrderStatus.delivered => Icons.done_all,
      OrderStatus.cancelled => Icons.cancel,
    },
  );
}

class PaymentStatusChip extends StatelessWidget {
  const PaymentStatusChip({super.key, required this.status, this.method});
  final PaymentStatus status;
  final PaymentMethod? method;

  @override
  Widget build(BuildContext context) => StatusChip(
    label:
        status == PaymentStatus.paid &&
            method != null &&
            method != PaymentMethod.unknown
        ? '${paymentLabel(status)} · ${paymentMethodLabel(method!)}'
        : status == PaymentStatus.validation &&
              method != null &&
              method != PaymentMethod.unknown
        ? '${paymentLabel(status)} · ${paymentMethodLabel(method!)}'
        : paymentLabel(status),
    backgroundColor: switch (status) {
      PaymentStatus.pending => const Color(0xFFFFEDD5),
      PaymentStatus.validation => const Color(0xFFE0F2FE),
      PaymentStatus.paid => const Color(0xFFE8FFF4),
      PaymentStatus.cancelled => const Color(0xFFFEE2E2),
      PaymentStatus.refundPending => const Color(0xFFFFF7DB),
    },
    foregroundColor: switch (status) {
      PaymentStatus.pending => const Color(0xFF9A3412),
      PaymentStatus.validation => const Color(0xFF075985),
      PaymentStatus.paid => const Color(0xFF047857),
      PaymentStatus.cancelled => const Color(0xFF991B1B),
      PaymentStatus.refundPending => const Color(0xFF92400E),
    },
    icon: switch (status) {
      PaymentStatus.pending => Icons.warning_amber,
      PaymentStatus.validation => Icons.fact_check,
      PaymentStatus.paid => Icons.paid,
      PaymentStatus.cancelled => Icons.money_off,
      PaymentStatus.refundPending => Icons.assignment_return,
    },
  );
}

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
  });
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(icon, size: 16, color: foregroundColor),
    label: Text(label),
    labelStyle: TextStyle(color: foregroundColor, fontWeight: FontWeight.w800),
    backgroundColor: backgroundColor,
    side: BorderSide.none,
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          ClipOval(
            child: Image.asset(
              BrandAssets.raThumb,
              width: 82,
              height: 82,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
}

class AdminSkeleton extends StatelessWidget {
  const AdminSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (var i = 0; i < 4; i++)
              Container(
                width: 220,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          height: 260,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
        ),
      ],
    );
  }
}
