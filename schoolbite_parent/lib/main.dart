import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:schoolbite_parent/branding/brand_assets.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const SchoolBiteParentApp());

enum Cycle { prekinder, iCiclo, iiCiclo }

enum MealType { breakfast, lunch, snack }

enum OrderStatus { pendingDelivery, delivered, cancelled }

enum PaymentStatus { pending, validation, paid, cancelled }

enum PaymentMethod { cash, sinpe, card, balance, unknown }

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
  OrderStatus.pendingDelivery => 'Pendiente de entrega',
  OrderStatus.delivered => 'Entregado',
  OrderStatus.cancelled => 'Cancelado',
};
String paymentLabel(PaymentStatus value) => switch (value) {
  PaymentStatus.pending => 'Pendiente',
  PaymentStatus.validation => 'En validacion',
  PaymentStatus.paid => 'Pagado',
  PaymentStatus.cancelled => 'Cancelado',
};
String paymentMethodLabel(PaymentMethod value) => switch (value) {
  PaymentMethod.cash => 'Efectivo',
  PaymentMethod.sinpe => 'SINPE',
  PaymentMethod.card => 'Tarjeta',
  PaymentMethod.balance => 'Saldo',
  PaymentMethod.unknown => 'No definido',
};
Cycle inferCycleFromSection(String value) {
  final normalized = value.toLowerCase();
  if (normalized.contains('toddler') ||
      normalized.contains('first') ||
      normalized.contains('pk') ||
      normalized.contains('kinder') ||
      normalized.contains('prekinder')) {
    return Cycle.prekinder;
  }
  if (normalized.contains('primero') ||
      normalized.contains('segundo') ||
      normalized.contains('tercero') ||
      normalized.startsWith('1-') ||
      normalized.startsWith('2-') ||
      normalized.startsWith('3-')) {
    return Cycle.iCiclo;
  }
  return Cycle.iiCiclo;
}

String money(int value) =>
    '\u20A1${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}';

class Child {
  Child({
    required this.id,
    required this.name,
    required this.cycle,
    required this.grade,
    required this.section,
    this.notes = '',
    this.dietaryRestrictions = '',
    this.active = true,
  });
  final String id;
  String name;
  Cycle cycle;
  String grade;
  String section;
  String notes;
  String dietaryRestrictions;
  bool active;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'cycle': cycle.name,
    'grade': grade,
    'section': section,
    'notes': notes,
    'dietaryRestrictions': dietaryRestrictions,
    'active': active,
  };
  factory Child.fromJson(Map<String, dynamic> json) => Child(
    id: json['id'],
    name: json['name'],
    cycle: Cycle.values.byName(json['cycle']),
    grade: json['grade'],
    section: json['section'],
    notes: json['notes'] ?? '',
    dietaryRestrictions: json['dietaryRestrictions'] ?? '',
    active: json['active'] ?? true,
  );
}

class MenuOption {
  const MenuOption({
    required this.id,
    required this.mealType,
    required this.optionNumber,
    required this.name,
    required this.description,
    required this.pricesByCycle,
    this.customizationOptions = const [],
    this.available = true,
    this.stockLimit,
  });
  final String id;
  final MealType mealType;
  final int optionNumber;
  final String name;
  final String description;
  final Map<Cycle, int> pricesByCycle;
  final List<CustomizationOption> customizationOptions;
  final bool available;
  final int? stockLimit;
  int priceFor(Cycle cycle) => pricesByCycle[cycle] ?? 0;
}

class CustomizationOption {
  const CustomizationOption({required this.id, required this.label});
  final String id;
  final String label;
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
    'paymentStatus': paymentStatus.name,
    'paymentMethod': paymentMethod.name,
    'customizationTags': customizationTags,
    'customNote': customNote,
    'dietaryRestrictions': dietaryRestrictions,
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
    createdAt: DateTime.parse(json['createdAt']),
  );
}

PaymentMethod parsePaymentMethod(Object? value) {
  final name = value?.toString() ?? PaymentMethod.unknown.name;
  return PaymentMethod.values.firstWhere(
    (method) => method.name == name,
    orElse: () => PaymentMethod.unknown,
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
    orElse: () => PaymentStatus.pending,
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

abstract class ChildRepository {
  Future<List<Child>> getChildren();
  Future<void> saveChildren(List<Child> children);
}

abstract class OrderRepository {
  Future<List<Order>> getOrders();
  Future<void> saveOrders(List<Order> orders);
}

abstract class MenuRepository {
  Future<List<MenuOption>> getTodayMenu();
}

class SharedPrefsChildRepository implements ChildRepository {
  static const key = 'schoolbite.children.v3';
  @override
  Future<List<Child>> getChildren() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) {
      return [
        Child(
          id: 'child_sofia_ramirez',
          name: 'Sofia Ramirez Lopez',
          cycle: Cycle.prekinder,
          grade: 'Prekinder',
          section: 'PK-A',
          dietaryRestrictions: 'Alergica al mani. Evitar trazas de nueces.',
        ),
      ];
    }
    return (jsonDecode(raw) as List)
        .map((item) => Child.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<void> saveChildren(List<Child> children) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      key,
      jsonEncode(children.map((c) => c.toJson()).toList()),
    );
  }
}

class SharedPrefsOrderRepository implements OrderRepository {
  static const key = 'schoolbite.orders';
  @override
  Future<List<Order>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((item) => Order.fromJson(Map<String, dynamic>.from(item)))
        .toList();
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

class MockMenuRepository implements MenuRepository {
  @override
  Future<List<MenuOption>> getTodayMenu() async => demoMenu;
}

final demoMenu = [
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
    customizationOptions: [
      CustomizationOption(id: 'sin_queso', label: 'Sin queso'),
      CustomizationOption(id: 'sin_natilla', label: 'Sin natilla'),
      CustomizationOption(id: 'sin_salchicha', label: 'Sin salchicha'),
      CustomizationOption(id: 'sin_huevo', label: 'Sin huevo'),
      CustomizationOption(id: 'sin_salsa', label: 'Sin salsa'),
    ],
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
    customizationOptions: [
      CustomizationOption(id: 'sin_miel', label: 'Sin miel'),
      CustomizationOption(id: 'sin_mantequilla', label: 'Sin mantequilla'),
      CustomizationOption(id: 'fruta_aparte', label: 'Fruta aparte'),
      CustomizationOption(id: 'sin_sirope', label: 'Sin sirope'),
    ],
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
    customizationOptions: [
      CustomizationOption(id: 'sin_ensalada', label: 'Sin ensalada'),
      CustomizationOption(id: 'sin_frijoles', label: 'Sin frijoles'),
      CustomizationOption(id: 'sin_tomate', label: 'Sin tomate'),
      CustomizationOption(id: 'sin_cebolla', label: 'Sin cebolla'),
      CustomizationOption(id: 'sin_salsa', label: 'Sin salsa'),
    ],
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
    customizationOptions: [
      CustomizationOption(id: 'sin_queso', label: 'Sin queso'),
      CustomizationOption(id: 'sin_salsa_extra', label: 'Sin salsa extra'),
    ],
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
    customizationOptions: [
      CustomizationOption(id: 'sin_papaya', label: 'Sin papaya'),
      CustomizationOption(id: 'sin_pina', label: 'Sin pina'),
      CustomizationOption(id: 'sin_sandia', label: 'Sin sandia'),
    ],
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
    customizationOptions: [
      CustomizationOption(id: 'sin_granola', label: 'Sin granola'),
      CustomizationOption(id: 'sin_fruta', label: 'Sin fruta'),
      CustomizationOption(id: 'sin_miel', label: 'Sin miel'),
    ],
  ),
];

class ParentController extends ChangeNotifier {
  ParentController(
    this.childRepository,
    this.orderRepository,
    this.menuRepository,
  );
  final ChildRepository childRepository;
  final OrderRepository orderRepository;
  final MenuRepository menuRepository;
  List<Child> children = [];
  List<Order> orders = [];
  List<MenuOption> menu = [];
  Child? selectedChild;
  bool loading = true;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    children = await childRepository.getChildren();
    orders = await orderRepository.getOrders();
    menu = await menuRepository.getTodayMenu();
    selectedChild = children.isNotEmpty ? children.first : null;
    loading = false;
    notifyListeners();
  }

  Future<void> refreshOrders() async {
    orders = await orderRepository.getOrders();
    notifyListeners();
  }

  void selectChild(Child child) {
    selectedChild = child;
    notifyListeners();
  }

  Future<void> saveChild(Child child) async {
    final index = children.indexWhere((c) => c.id == child.id);
    if (index >= 0) {
      children[index] = child;
    } else {
      children.add(child);
    }
    selectedChild = child;
    await childRepository.saveChildren(children);
    notifyListeners();
  }

  Future<void> deleteChild(String id) async {
    children.removeWhere((c) => c.id == id);
    selectedChild = children.isNotEmpty ? children.first : null;
    await childRepository.saveChildren(children);
    notifyListeners();
  }

  Future<Order> createOrder(
    MenuOption option, {
    List<String> customizationTags = const [],
    String? customNote,
    PaymentStatus paymentStatus = PaymentStatus.pending,
    PaymentMethod paymentMethod = PaymentMethod.unknown,
  }) async {
    final child = selectedChild!;
    final order = Order(
      id: 'order_${DateTime.now().microsecondsSinceEpoch}',
      childId: child.id,
      childName: child.name,
      childCycle: child.cycle,
      childGrade: child.grade,
      childSection: child.section,
      menuOptionId: option.id,
      mealType: option.mealType,
      optionNumber: option.optionNumber,
      menuOptionName: option.name,
      price: option.priceFor(child.cycle),
      orderStatus: OrderStatus.pendingDelivery,
      paymentStatus: paymentStatus,
      paymentMethod: paymentMethod,
      customizationTags: customizationTags,
      customNote: customNote?.trim().isEmpty ?? true
          ? null
          : customNote!.trim(),
      dietaryRestrictions: child.dietaryRestrictions.trim().isEmpty
          ? null
          : child.dietaryRestrictions.trim(),
      createdAt: DateTime.now(),
    );
    orders.insert(0, order);
    await orderRepository.saveOrders(orders);
    notifyListeners();
    return order;
  }
}

class SchoolBiteParentApp extends StatelessWidget {
  const SchoolBiteParentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ParentController(
        SharedPrefsChildRepository(),
        SharedPrefsOrderRepository(),
        MockMenuRepository(),
      )..load(),
      child: MaterialApp.router(
        title: 'SchoolBite Padres',
        debugShowCheckedModeBanner: false,
        theme: schoolBiteTheme(),
        routerConfig: GoRouter(
          routes: [
            GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
            GoRoute(path: '/entry', builder: (_, __) => const LoginScreen()),
            ShellRoute(
              builder: (_, __, child) => ParentShell(child: child),
              routes: [
                GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
                GoRoute(
                  path: '/children',
                  builder: (_, __) => const ChildrenScreen(),
                ),
                GoRoute(path: '/menu', builder: (_, __) => const MenuScreen()),
                GoRoute(
                  path: '/orders',
                  builder: (_, __) => const OrdersScreen(),
                ),
                GoRoute(
                  path: '/profile',
                  builder: (_, __) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

ThemeData schoolBiteTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF10B981),
    primary: const Color(0xFF10B981),
    secondary: const Color(0xFFFFC857),
  ),
  scaffoldBackgroundColor: const Color(0xFFF7FAF7),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
  ),
);

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Brand(),
                  const SizedBox(height: 28),
                  const Text(
                    'Pedidos escolares sin caos.',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF082F49),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Vea el menu de hoy y cree un pedido en segundos.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => context.go('/home'),
                      icon: const Icon(Icons.login),
                      label: const Text('Entrar a la app'),
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
}

class ParentShell extends StatelessWidget {
  const ParentShell({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return Scaffold(
      appBar: AppBar(
        title: const Brand(),
        actions: [
          IconButton(
            onPressed: () => context.read<ParentController>().refreshOrders(),
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: [
          '/home',
          '/children',
          '/menu',
          '/orders',
          '/profile',
        ].indexOf(location).clamp(0, 4).toInt(),
        onDestinationSelected: (i) => context.go(
          ['/home', '/children', '/menu', '/orders', '/profile'][i],
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.child_care_outlined),
            selectedIcon: Icon(Icons.child_care),
            label: 'Hijos',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<ParentController>(
      builder: (context, app, _) {
        if (app.loading) {
          return const PagePad(child: SkeletonList());
        }
        final pending = app.orders
            .where((o) => o.paymentStatus == PaymentStatus.pending)
            .fold<int>(0, (sum, o) => sum + o.price);
        final pendingCount = app.orders
            .where((o) => o.paymentStatus == PaymentStatus.pending)
            .length;
        final validationCount = app.orders
            .where((o) => o.paymentStatus == PaymentStatus.validation)
            .length;
        final childMessage = app.children.length == 1
            ? 'Hoy tienes opciones disponibles para ${app.children.first.name.split(' ').first}.'
            : 'Hoy tienes opciones disponibles para tus hijos.';
        return PagePad(
          child: ListView(
            children: [
              const Text(
                'Buenos dias Laura Mendez',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF082F49),
                ),
              ),
              const SizedBox(height: 6),
              Text(childMessage, style: TextStyle(color: Color(0xFF64748B))),
              const SizedBox(height: 18),
              PaymentFamilyStatus(
                pending: pendingCount,
                validation: validationCount,
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  StatCard(
                    label: 'Hijos registrados',
                    value: '${app.children.length}',
                    icon: Icons.child_care,
                  ),
                  StatCard(
                    label: 'Pedidos activos',
                    value:
                        '${app.orders.where((o) => o.orderStatus != OrderStatus.delivered && o.orderStatus != OrderStatus.cancelled).length}',
                    icon: Icons.timelapse,
                  ),
                  StatCard(
                    label: 'Pendiente pago',
                    value: money(pending),
                    icon: Icons.payments,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const MealWindowsInfo(),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => context.go('/menu'),
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('Hacer pedido'),
              ),
              const SizedBox(height: 18),
              SectionTitle(title: 'Pedidos de hoy por hijo'),
              for (final child in app.children)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.child_care),
                    title: Text(child.name),
                    subtitle: Text(child.section),
                    trailing: Text(
                      '${app.orders.where((order) => order.childId == child.id).length}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class ChildrenScreen extends StatelessWidget {
  const ChildrenScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<ParentController>(
      builder: (context, app, _) {
        return PagePad(
          child: ListView(
            children: [
              SectionTitle(
                title: 'Hijos',
                action: 'Crear hijo',
                onTap: () => showChildForm(context),
              ),
              if (app.children.isEmpty)
                const EmptyState(text: 'No hay hijos registrados.'),
              ...app.children.map(
                (child) => Card(
                  child: ListTile(
                    title: Text(
                      child.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text('${child.section}\n${child.notes}'),
                    isThreeLine: child.notes.isNotEmpty,
                    leading: Radio<String>(
                      value: child.id,
                      groupValue: app.selectedChild?.id,
                      onChanged: (_) {
                        app.selectChild(child);
                      },
                    ),
                    trailing: Wrap(
                      children: [
                        IconButton(
                          onPressed: () => showChildForm(context, child: child),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () => app.deleteChild(child.id),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PaymentFamilyStatus extends StatelessWidget {
  const PaymentFamilyStatus({
    super.key,
    required this.pending,
    required this.validation,
  });
  final int pending;
  final int validation;

  @override
  Widget build(BuildContext context) {
    final color = pending > 0
        ? const Color(0xFFDC2626)
        : validation > 0
        ? const Color(0xFFF59E0B)
        : const Color(0xFF10B981);
    final icon = pending > 0
        ? Icons.error
        : validation > 0
        ? Icons.hourglass_top
        : Icons.check_circle;
    final text = pending > 0
        ? 'Hay pagos pendientes.'
        : validation > 0
        ? 'Hay pedidos pendientes de validar.'
        : 'Todos los pedidos del dia estan confirmados.';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

void showChildForm(BuildContext context, {Child? child}) {
  final name = TextEditingController(text: child?.name ?? '');
  final gradeOptions = const [
    'Toddlers',
    'Toddlers 2',
    'First Steps',
    'PK',
    'PK-A',
    'PK-B',
    'Kinder',
    'Prekinder',
    '1-A',
    '1-B',
    '1-C',
    '2-A',
    '2-B',
    '2-C',
    '3-A',
    '3-B',
    '3-C',
    '4-A',
    '4-B',
    '4-C',
    '5-A',
    '5-B',
    '5-C',
    '6-A',
    '6-B',
    '6-C',
  ];
  var selectedGrade = child?.section ?? 'PK-A';
  final notes = TextEditingController(text: child?.notes ?? '');
  final dietaryRestrictions = TextEditingController(
    text: child?.dietaryRestrictions ?? '',
  );
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                child == null ? 'Crear hijo' : 'Editar hijo',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              DropdownButtonFormField<String>(
                value: selectedGrade,
                decoration: const InputDecoration(labelText: 'Grado / seccion'),
                items: gradeOptions
                    .map(
                      (grade) =>
                          DropdownMenuItem(value: grade, child: Text(grade)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => selectedGrade = v!),
              ),
              TextField(
                controller: notes,
                decoration: const InputDecoration(labelText: 'Notas'),
              ),
              TextField(
                controller: dietaryRestrictions,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Restricciones alimenticias / notas importantes',
                  hintText:
                      'Ejemplo: alergico al mani, sin lacteos, no puede comer cerdo...',
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    context.read<ParentController>().saveChild(
                      Child(
                        id:
                            child?.id ??
                            'child_${DateTime.now().millisecondsSinceEpoch}',
                        name: name.text,
                        cycle: inferCycleFromSection(selectedGrade),
                        grade: selectedGrade,
                        section: selectedGrade,
                        notes: notes.text,
                        dietaryRestrictions: dietaryRestrictions.text,
                      ),
                    );
                    Navigator.pop(sheetContext);
                  },
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final bool showOsi = Random().nextBool();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/entry');
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = showOsi ? 'Osi' : 'Ra';
    final message = showOsi
        ? '¡Tu pedido está en buenas patas!'
        : '¡Cocinamos con amor para ti!';
    return Scaffold(
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: .82, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutBack,
          builder: (context, value, child) => Opacity(
            opacity: value.clamp(0, 1),
            child: Transform.scale(scale: value, child: child),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MascotIllustration(mascot: showOsi ? Mascot.osi : Mascot.ra),
              const SizedBox(height: 20),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF082F49),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF047857),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum Mascot { osi, ra }

class MascotIllustration extends StatelessWidget {
  const MascotIllustration({super.key, required this.mascot, this.size = 136});
  final Mascot mascot;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isOsi = mascot == Mascot.osi;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isOsi ? const Color(0xFFE8FFF4) : const Color(0xFFFFFBEB),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF10B981), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A052E2B),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          isOsi ? BrandAssets.osiSplash : BrandAssets.raSplash,
          fit: BoxFit.cover,
          alignment: isOsi
              ? const Alignment(-0.35, -0.2)
              : const Alignment(0.55, -0.05),
        ),
      ),
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<ParentController>(
      builder: (context, app, _) {
        return PagePad(
          child: ListView(
            children: [
              const Text(
                'Menu del dia',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF082F49),
                ),
              ),
              const SizedBox(height: 12),
              const MealWindowsInfo(),
              const SizedBox(height: 12),
              ChildSelector(app: app),
              for (final type in MealType.values) ...[
                const SizedBox(height: 18),
                Text(
                  mealLabel(type),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                ...app.menu
                    .where((o) => o.mealType == type)
                    .map(
                      (option) => FoodCard(
                        option: option,
                        child: app.selectedChild,
                        onOrder: () async {
                          await showCustomizeOrderDialog(context, option);
                        },
                      ),
                    ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<ParentController>(
      builder: (context, app, _) {
        final pending = app.orders
            .where((o) => o.paymentStatus == PaymentStatus.pending)
            .fold<int>(0, (sum, o) => sum + o.price);
        return PagePad(
          child: RefreshIndicator(
            onRefresh: app.refreshOrders,
            child: ListView(
              children: [
                const Text(
                  'Pedidos',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF082F49),
                  ),
                ),
                const SizedBox(height: 12),
                StatCard(
                  label: 'Total pendiente',
                  value: money(pending),
                  icon: Icons.account_balance_wallet,
                ),
                const SizedBox(height: 12),
                if (app.orders.isEmpty)
                  const EmptyState(
                    text: 'Cuando cree un pedido aparecera aqui.',
                  ),
                ...app.orders.map((order) => OrderTile(order: order)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const PagePad(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Perfil familiar',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF082F49),
          ),
        ),
        SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text('Laura Mendez'),
            subtitle: Text('Madre demo - laura@schoolbite.app'),
          ),
        ),
      ],
    ),
  );
}

class ChildSelector extends StatelessWidget {
  const ChildSelector({super.key, required this.app});
  final ParentController app;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: DropdownButtonFormField<String>(
        value: app.selectedChild?.id,
        decoration: const InputDecoration(
          labelText: 'Hijo seleccionado',
          border: InputBorder.none,
        ),
        items: app.children
            .map(
              (c) => DropdownMenuItem(
                value: c.id,
                child: Text('${c.name} - ${c.section}'),
              ),
            )
            .toList(),
        onChanged: (id) {
          app.selectChild(app.children.firstWhere((c) => c.id == id));
        },
      ),
    ),
  );
}

class MealWindowsInfo extends StatelessWidget {
  const MealWindowsInfo({super.key});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 10,
    runSpacing: 10,
    children: const [
      _WindowChip(icon: Icons.free_breakfast, text: 'Desayuno hasta 8:00 AM'),
      _WindowChip(icon: Icons.rice_bowl, text: 'Almuerzo hasta 10:30 AM'),
      _WindowChip(icon: Icons.cookie, text: 'Merienda configurable'),
    ],
  );
}

class _WindowChip extends StatelessWidget {
  const _WindowChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(icon, size: 16, color: const Color(0xFF047857)),
    label: Text(text),
    backgroundColor: const Color(0xFFE8FFF4),
    side: BorderSide.none,
  );
}

class FoodCard extends StatelessWidget {
  const FoodCard({
    super.key,
    required this.option,
    required this.child,
    this.onOrder,
  });
  final MenuOption option;
  final Child? child;
  final VoidCallback? onOrder;
  @override
  Widget build(BuildContext context) {
    final price = child == null ? 0 : option.priceFor(child!.cycle);
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 132,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: foodGradient(option.mealType),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 20,
                  bottom: -8,
                  child: Icon(
                    option.mealType == MealType.lunch
                        ? Icons.rice_bowl
                        : option.mealType == MealType.breakfast
                        ? Icons.egg_alt
                        : Icons.local_cafe,
                    size: 96,
                    color: Colors.white.withValues(alpha: .45),
                  ),
                ),
                Positioned(
                  left: 18,
                  top: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${mealLabel(option.mealType)} / Opcion ${option.optionNumber}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
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
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          color: Color(0xFF082F49),
                        ),
                      ),
                    ),
                    Text(
                      money(price),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  option.description,
                  style: const TextStyle(color: Color(0xFF64748B), height: 1.4),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: option.available ? onOrder : null,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Pedir'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<Color> foodGradient(MealType type) => switch (type) {
  MealType.breakfast => [const Color(0xFFFFC857), const Color(0xFFFFF1B8)],
  MealType.lunch => [const Color(0xFF10B981), const Color(0xFFA7F3D0)],
  MealType.snack => [const Color(0xFFF97316), const Color(0xFFFED7AA)],
};

void showOrderConfirmation(BuildContext context, Order order) {
  showDialog(
    context: context,
    builder: (dialogContext) => TweenAnimationBuilder<double>(
      tween: Tween(begin: .88, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                color: Color(0xFFE8FFF4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF10B981),
                size: 48,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Pedido confirmado',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              '${order.childName} / ${order.childSection}\n${mealLabel(order.mealType)} / Opcion ${order.optionNumber}\n${order.menuOptionName}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            if (order.hasCustomization) ...[
              const SizedBox(height: 8),
              Text(
                customizationText(order),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              money(order.price),
              style: const TextStyle(
                color: Color(0xFF047857),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              paymentMessage(order),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.go('/orders');
            },
            child: const Text('Ver pedidos'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Seguir viendo menu'),
          ),
        ],
      ),
    ),
  );
}

Future<void> showCustomizeOrderDialog(
  BuildContext context,
  MenuOption option,
) async {
  final noteController = TextEditingController();
  final selected = <String>{};
  final quickOptions = [
    ...option.customizationOptions,
    const CustomizationOption(id: 'otro', label: 'Otro'),
  ];
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) {
        final child = context.read<ParentController>().selectedChild;
        final restrictions = child?.dietaryRestrictions.trim() ?? '';
        return AlertDialog(
          title: Text(
            '${mealLabel(option.mealType)} / Opcion ${option.optionNumber}',
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(option.description),
                  const SizedBox(height: 18),
                  if (restrictions.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFED7AA)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.warning_amber,
                                color: Color(0xFF9A3412),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Este estudiante tiene restricciones alimenticias registradas.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF9A3412),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(restrictions),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  const Text(
                    'Observaciones del pedido',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final item in quickOptions)
                        FilterChip(
                          label: Text(item.label),
                          selected: selected.contains(item.id),
                          onSelected: (checked) {
                            setDialogState(() {
                              checked
                                  ? selected.add(item.id)
                                  : selected.remove(item.id);
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    maxLength: 100,
                    decoration: const InputDecoration(
                      labelText: 'Detalle adicional',
                      hintText:
                          'Ejemplo: sin queso, sin salchicha, jugo sin azucar...',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton.tonal(
              onPressed: () => createDemoPaidOrder(
                context,
                dialogContext,
                option,
                selected,
                noteController.text,
                PaymentStatus.validation,
                PaymentMethod.sinpe,
              ),
              child: const Text('Pagar por SINPE'),
            ),
            FilledButton.tonal(
              onPressed: () => createDemoPaidOrder(
                context,
                dialogContext,
                option,
                selected,
                noteController.text,
                PaymentStatus.paid,
                PaymentMethod.card,
              ),
              child: const Text('Pagar con tarjeta'),
            ),
            FilledButton(
              onPressed: () => createDemoPaidOrder(
                context,
                dialogContext,
                option,
                selected,
                noteController.text,
                PaymentStatus.pending,
                PaymentMethod.unknown,
              ),
              child: const Text('Pagar en soda'),
            ),
          ],
        );
      },
    ),
  );
  noteController.dispose();
}

Future<void> createDemoPaidOrder(
  BuildContext context,
  BuildContext dialogContext,
  MenuOption option,
  Set<String> selected,
  String note,
  PaymentStatus paymentStatus,
  PaymentMethod paymentMethod,
) async {
  final order = await context.read<ParentController>().createOrder(
    option,
    customizationTags: selected.toList(),
    customNote: note,
    paymentStatus: paymentStatus,
    paymentMethod: paymentMethod,
  );
  if (dialogContext.mounted) Navigator.pop(dialogContext);
  if (!context.mounted) return;
  if (paymentStatus == PaymentStatus.validation &&
      paymentMethod == PaymentMethod.sinpe) {
    showSinpeReceiptDialog(context, order);
  } else {
    showOrderConfirmation(context, order);
  }
}

Future<void> showSinpeReceiptDialog(BuildContext context, Order order) async {
  var warning = false;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) {
        Future<void> pick(ImageSource source) async {
          await ImagePicker().pickImage(source: source);
          if (dialogContext.mounted) Navigator.pop(dialogContext);
          if (context.mounted) showOrderConfirmation(context, order);
        }

        return AlertDialog(
          title: const Text('Adjuntar comprobante'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tu pedido fue recibido correctamente.\nLa soda validara el comprobante en pocos minutos.',
              ),
              if (warning) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Aun no has adjuntado el comprobante de SINPE.\n\nTu pedido fue registrado, pero la soda podria solicitar el comprobante antes de validar el pago.',
                    style: TextStyle(
                      color: Color(0xFF991B1B),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () => pick(ImageSource.camera),
              icon: const Icon(Icons.photo_camera),
              label: const Text('Camara'),
            ),
            TextButton.icon(
              onPressed: () => pick(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Galeria'),
            ),
            TextButton(
              onPressed: () => setDialogState(() => warning = true),
              child: const Text('Lo hare despues'),
            ),
            if (warning)
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  showOrderConfirmation(context, order);
                },
                child: const Text('Adjuntar comprobante despues'),
              ),
          ],
        );
      },
    ),
  );
}

class OrderTile extends StatelessWidget {
  const OrderTile({super.key, required this.order});
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
              const CircleAvatar(
                backgroundColor: Color(0xFFFFF7DB),
                child: Icon(Icons.receipt_long, color: Color(0xFFF59E0B)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${mealLabel(order.mealType)} / Opcion ${order.optionNumber ?? '-'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                money(order.price),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('${order.childName} / ${order.childSection}'),
          Text(order.menuOptionName),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(orderLabel(order.orderStatus))),
              Chip(label: Text(paymentLabel(order.paymentStatus))),
              if (order.hasCustomization)
                const Chip(label: Text('Personalizado')),
              if (order.hasDietaryRestrictions)
                const Chip(
                  avatar: Icon(Icons.warning_amber, size: 16),
                  label: Text('Restricciones'),
                ),
            ],
          ),
          if (order.hasDietaryRestrictions) ...[
            const SizedBox(height: 8),
            Text(
              order.dietaryRestrictions!,
              style: const TextStyle(
                color: Color(0xFF9A3412),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

String customizationText(Order order) {
  final labels = {
    'sin_queso': 'Sin queso',
    'sin_salchicha': 'Sin salchicha',
    'sin_natilla': 'Sin natilla',
    'sin_huevo': 'Sin huevo',
    'sin_azucar': 'Sin azucar',
    'sin_salsa': 'Sin salsa',
    'sin_miel': 'Sin miel',
    'sin_mantequilla': 'Sin mantequilla',
    'fruta_aparte': 'Fruta aparte',
    'sin_sirope': 'Sin sirope',
    'sin_ensalada': 'Sin ensalada',
    'sin_frijoles': 'Sin frijoles',
    'sin_tomate': 'Sin tomate',
    'sin_cebolla': 'Sin cebolla',
    'sin_salsa_extra': 'Sin salsa extra',
    'sin_papaya': 'Sin papaya',
    'sin_pina': 'Sin pina',
    'sin_sandia': 'Sin sandia',
    'sin_granola': 'Sin granola',
    'sin_fruta': 'Sin fruta',
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

String paymentMessage(Order order) => switch (order.paymentStatus) {
  PaymentStatus.validation =>
    'Comprobante pendiente de validacion por la soda.',
  PaymentStatus.paid => 'Pago simulado exitoso.',
  PaymentStatus.pending => 'Pendiente de pago en soda.',
  PaymentStatus.cancelled => 'Pago cancelado.',
};

class PagePad extends StatelessWidget {
  const PagePad({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.all(18), child: child);
}

class Brand extends StatelessWidget {
  const Brand({super.key});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFF052E2B),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.lunch_dining,
          color: Color(0xFFFFC857),
          size: 20,
        ),
      ),
      const SizedBox(width: 10),
      const Text('SchoolBite', style: TextStyle(fontWeight: FontWeight.w900)),
    ],
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.action, this.onTap});
  final String title;
  final String? action;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
        ),
      ),
      if (action != null) TextButton(onPressed: onTap, child: Text(action!)),
    ],
  );
}

class StatCard extends StatelessWidget {
  const StatCard({
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
    width: 180,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF10B981)),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            Text(label, style: const TextStyle(color: Color(0xFF64748B))),
          ],
        ),
      ),
    ),
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
          Container(
            width: 74,
            height: 74,
            decoration: const BoxDecoration(
              color: Color(0xFFE8FFF4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long,
              color: Color(0xFF10B981),
              size: 34,
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

class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (final width in [220.0, 320.0, 260.0, 340.0])
          Container(
            width: width,
            height: 72,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
          ),
      ],
    );
  }
}
