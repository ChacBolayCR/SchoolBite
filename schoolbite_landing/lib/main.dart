import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schoolbite_landing/branding/brand_assets.dart';
import 'package:schoolbite_landing/config/demo_links_config.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const SchoolBiteLanding());

class SchoolBiteLanding extends StatelessWidget {
  const SchoolBiteLanding({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const LandingPage()),
        GoRoute(
          path: '/demo',
          builder: (_, __) => const LandingPage(anchor: 'demo'),
        ),
        GoRoute(
          path: '/pricing',
          builder: (_, __) => const LandingPage(anchor: 'planes'),
        ),
        GoRoute(
          path: '/contact',
          builder: (_, __) => const LandingPage(anchor: 'contacto'),
        ),
      ],
    );
    return MaterialApp.router(
      title: 'SchoolBite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981),
          primary: const Color(0xFF10B981),
          secondary: const Color(0xFFF59E0B),
          surface: const Color(0xFFFFFFFF),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Arial',
      ),
      routerConfig: router,
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key, this.anchor});

  final String? anchor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white.withValues(alpha: .94),
            surfaceTintColor: Colors.transparent,
            title: const BrandMark(),
            actions: [
              TextButton(
                onPressed: () => context.go('/pricing'),
                child: const Text('Planes'),
              ),
              TextButton(
                onPressed: () => context.go('/contact'),
                child: const Text('Piloto'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: const [
                HeroSection(),
                ProblemSolutionSection(),
                HowItWorksSection(),
                BenefitsSection(),
                MockScreensSection(),
                PricingSection(),
                FaqSection(),
                FinalCtaSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
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
        const Text('SchoolBite', style: TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFFEFFDF6)],
        ),
      ),
      child: Section(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 900;
            final copy = TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 24 * (1 - value)),
                  child: child,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Pill(text: 'Pedidos escolares sin caos.'),
                  const SizedBox(height: 22),
                  Text(
                    'Olvidese de los pedidos por WhatsApp.',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF082F49),
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'SchoolBite organiza pedidos, pagos y entregas desde una sola plataforma.',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF475569),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Pedidos simples.\nSoda organizada.\nNiños felices.',
                    style: TextStyle(
                      color: Color(0xFF047857),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const WhySodasChoose(),
                  const SizedBox(height: 28),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: const [
                      CtaButton(
                        label: 'Probar Demo',
                        icon: Icons.play_arrow_rounded,
                        url: DemoLinksConfig.parentDemoUrl,
                      ),
                      CtaButton(
                        label: 'Probar como soda',
                        icon: Icons.dashboard_customize,
                        url: DemoLinksConfig.adminDemoUrl,
                      ),
                      GhostButton(label: 'Solicitar piloto'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Demo interactiva sin registro',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
            if (!wide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  copy,
                  const SizedBox(height: 32),
                  const MascotPair(),
                  const SizedBox(height: 18),
                  const ProductPreview(),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 11, child: copy),
                const SizedBox(width: 44),
                const Expanded(
                  flex: 10,
                  child: Column(
                    children: [
                      MascotPair(),
                      SizedBox(height: 18),
                      ProductPreview(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ProductPreview extends StatelessWidget {
  const ProductPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 620),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF052E2B),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33052E2B),
            blurRadius: 35,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          _TopBar(),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _PreviewPanel(
                  title: 'App padres',
                  lines: const [
                    'Sofia - Prekinder A',
                    'Casado de pollo',
                    'Pendiente: CRC 2500',
                  ],
                  color: const Color(0xFFE8FFF4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _PreviewPanel(
                  title: 'Soda dashboard',
                  lines: const [
                    '42 pedidos hoy',
                    'CRC 118.400 ventas',
                    '8 pagos pendientes',
                  ],
                  color: const Color(0xFFFFF7DB),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MascotPair extends StatelessWidget {
  const MascotPair({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: const Color(0xFFD1FAE5)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1A052E2B),
          blurRadius: 28,
          offset: Offset(0, 18),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: BrandMascotCard(
                asset: BrandAssets.osi,
                title: 'Osi',
                subtitle: 'Pedidos y entregas',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BrandMascotCard(
                asset: BrandAssets.ra,
                title: 'Ra',
                subtitle: 'Cocina organizada',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Osi entrega. Ra cocina. Juntos hacen que cada dia sea mejor.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF064E3B),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class BrandMascotCard extends StatelessWidget {
  const BrandMascotCard({
    super.key,
    required this.asset,
    required this.title,
    required this.subtitle,
  });
  final String asset;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: .82,
          child: Image.asset(asset, fit: BoxFit.cover),
        ),
      ),
      const SizedBox(height: 8),
      Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      Text(
        subtitle,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
      ),
    ],
  );
}

class WhySodasChoose extends StatelessWidget {
  const WhySodasChoose({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Pedidos en segundos', 'Los padres hacen sus pedidos desde el celular.'),
      ('Pagos organizados', 'Tarjeta, SINPE o pago en la soda.'),
      (
        'Produccion inteligente',
        'La cocina ve cantidades agrupadas, no pedidos individuales.',
      ),
      ('Entregas por seccion', 'Cada pedido llega al aula correcta.'),
      ('Control total', 'Dashboard con ventas, pagos y pedidos del dia.'),
      ('Menos WhatsApp, mas organizacion', 'Todo en una sola plataforma.'),
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD1FAE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Por qué las sodas eligen SchoolBite?',
            style: TextStyle(
              color: Color(0xFF082F49),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF10B981),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          height: 1.35,
                        ),
                        children: [
                          TextSpan(
                            text: '${item.$1}\n',
                            style: const TextStyle(
                              color: Color(0xFF082F49),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          TextSpan(text: item.$2),
                        ],
                      ),
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

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final color in [
          Colors.redAccent,
          Colors.amber,
          Colors.greenAccent,
        ])
          Container(
            width: 11,
            height: 11,
            margin: const EdgeInsets.only(right: 7),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        const Spacer(),
        const Text(
          'schoolbite.app',
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({
    required this.title,
    required this.lines,
    required this.color,
  });
  final String title;
  final List<String> lines;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF082F49),
            ),
          ),
          const SizedBox(height: 16),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(line)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProblemSolutionSection extends StatelessWidget {
  const ProblemSolutionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Section(
      title: 'El problema',
      subtitle: 'WhatsApp funciona para conversar, no para operar una soda.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 820;
          if (!wide) {
            return const Column(
              children: [
                CompareCard(
                  title: 'WhatsApp',
                  icon: Icons.chat_bubble_outline,
                  accent: Color(0xFFEF4444),
                  items: [
                    'Pedidos perdidos entre mensajes',
                    'Pagos pendientes sin control',
                    'Cambios de menu manuales',
                    'Mucho tiempo respondiendo lo mismo',
                  ],
                ),
                SizedBox(height: 18),
                CompareCard(
                  title: 'SchoolBite',
                  icon: Icons.space_dashboard,
                  accent: Color(0xFF10B981),
                  items: [
                    'Pedidos ordenados por alumno',
                    'Estados de entrega y pago',
                    'Menu diario centralizado',
                    'Dashboard listo para operar',
                  ],
                ),
              ],
            );
          }
          return const Row(
            children: [
              Expanded(
                child: CompareCard(
                  title: 'WhatsApp',
                  icon: Icons.chat_bubble_outline,
                  accent: Color(0xFFEF4444),
                  items: [
                    'Pedidos perdidos entre mensajes',
                    'Pagos pendientes sin control',
                    'Cambios de menu manuales',
                    'Mucho tiempo respondiendo lo mismo',
                  ],
                ),
              ),
              SizedBox(width: 18),
              Expanded(
                child: CompareCard(
                  title: 'SchoolBite',
                  icon: Icons.space_dashboard,
                  accent: Color(0xFF10B981),
                  items: [
                    'Pedidos ordenados por alumno',
                    'Estados de entrega y pago',
                    'Menu diario centralizado',
                    'Dashboard listo para operar',
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Section(
      title: 'Como funciona',
      subtitle:
          'Un flujo simple que cualquier padre y cualquier soda entiende.',
      child: const FlowTimeline(),
    );
  }
}

class BenefitsSection extends StatelessWidget {
  const BenefitsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Section(
      title: 'Beneficios',
      subtitle:
          'La promesa comercial de SchoolBite es menos caos y mas control.',
      child: ResponsiveGrid(
        children: const [
          FeatureCard(
            icon: Icons.check_circle,
            title: 'Mas organizacion',
            body:
                'Cada pedido queda registrado con alumno, ciclo, precio y estado.',
          ),
          FeatureCard(
            icon: Icons.error_outline,
            title: 'Menos errores',
            body:
                'La soda prepara desde una lista clara, no desde mensajes sueltos.',
          ),
          FeatureCard(
            icon: Icons.payments,
            title: 'Control de pagos',
            body:
                'Pendiente, pagado o en validacion visible para operar mejor el dia.',
          ),
          FeatureCard(
            icon: Icons.timer,
            title: 'Menos WhatsApp',
            body:
                'Menos tiempo respondiendo consultas repetidas durante la manana.',
          ),
          FeatureCard(
            icon: Icons.dashboard_customize,
            title: 'Dashboard profesional',
            body: 'KPIs, tabla y filtros que se ven como software de negocio.',
          ),
          FeatureCard(
            icon: Icons.history,
            title: 'Historial completo',
            body:
                'Pedidos recientes y estados para dar seguimiento sin friccion.',
          ),
        ],
      ),
    );
  }
}

class MockScreensSection extends StatelessWidget {
  const MockScreensSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Section(
      title: 'Capturas del sistema',
      subtitle:
          'La primera version ya cuenta una historia completa: elegir, pedir, preparar y cobrar.',
      child: ResponsiveGrid(
        children: const [
          ScreenMock(
            title: 'Home padre',
            metric: 'Sofia tiene 1 pedido activo',
          ),
          ScreenMock(
            title: 'Menu diario',
            metric: 'Precios por Prekinder, I Ciclo y II Ciclo',
          ),
          ScreenMock(
            title: 'Dashboard soda',
            metric: 'Ventas, pendientes y entregados',
          ),
        ],
      ),
    );
  }
}

class PricingSection extends StatelessWidget {
  const PricingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Section(
      title: 'Planes para pilotos',
      subtitle: 'Listos para validar precio durante pilotos comerciales.',
      child: ResponsiveGrid(
        children: const [
          PriceCard(
            name: 'Piloto',
            price: 'CRC 0',
            body: 'Demo guiado para una soda y menu basico.',
          ),
          PriceCard(
            name: 'Soda Pro',
            price: 'CRC 0',
            body: 'Pedidos, dashboard, menu diario y reportes simples.',
          ),
          PriceCard(
            name: 'Escuela',
            price: 'A medida',
            body: 'Multi-soda, permisos y configuracion institucional.',
          ),
        ],
      ),
    );
  }
}

class FaqSection extends StatelessWidget {
  const FaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Section(
      title: 'Preguntas frecuentes',
      child: Column(
        children: const [
          FaqItem(
            question: 'Tiene pagos reales?',
            answer:
                'No en Sprint 1. El demo muestra estados de pago para vender el flujo antes de integrar SINPE o tarjetas.',
          ),
          FaqItem(
            question: 'Funciona en celular?',
            answer:
                'La app de padres corre en Web y Android. El panel de soda esta pensado para desktop y tablet.',
          ),
          FaqItem(
            question: 'Se puede adaptar a mi escuela?',
            answer:
                'La arquitectura ya piensa en escuelas, sodas, usuarios, hijos, menus y pedidos multi-tenant.',
          ),
        ],
      ),
    );
  }
}

class FinalCtaSection extends StatelessWidget {
  const FinalCtaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF052E2B),
      child: Section(
        child: Column(
          children: [
            Text(
              'Pruebe SchoolBite con una soda real esta semana',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Un demo comercial para mostrar, validar y cerrar pilotos.',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 24),
            const CtaButton(
              label: 'Solicitar piloto',
              icon: Icons.rocket_launch,
            ),
            const SizedBox(height: 10),
            const Text(
              'Demo interactiva sin registro',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Section extends StatelessWidget {
  const Section({super.key, required this.child, this.title, this.subtitle});
  final Widget child;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 52),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1160),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Text(
                title!,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF082F49),
                ),
              ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 17),
              ),
            ],
            if (title != null) const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 900
            ? 3
            : constraints.maxWidth > 620
            ? 2
            : 1;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: children
              .map(
                (child) => SizedBox(
                  width: (constraints.maxWidth - (columns - 1) * 16) / columns,
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class CompareCard extends StatelessWidget {
  const CompareCard({
    super.key,
    required this.title,
    required this.icon,
    required this.accent,
    required this.items,
  });
  final String title;
  final IconData icon;
  final Color accent;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: accent.withValues(alpha: .12),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF082F49),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: accent, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w700,
                      ),
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

class FlowTimeline extends StatelessWidget {
  const FlowTimeline({super.key});

  static const steps = [
    (Icons.family_restroom, 'Padre'),
    (Icons.child_care, 'Escoge hijo'),
    (Icons.restaurant_menu, 'Selecciona comida'),
    (Icons.storefront, 'La soda recibe pedido'),
    (Icons.soup_kitchen, 'Prepara'),
    (Icons.done_all, 'Entrega'),
    (Icons.account_balance_wallet, 'Pago controlado'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          SizedBox(
            width: 145,
            child: InfoCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFE8FFF4),
                    child: Icon(steps[i].$1, color: const Color(0xFF10B981)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    steps[i].$2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
          if (i != steps.length - 1)
            const Padding(
              padding: EdgeInsets.only(top: 42),
              child: Icon(Icons.arrow_forward, color: Color(0xFF94A3B8)),
            ),
        ],
      ],
    );
  }
}

class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => InfoCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF10B981), size: 30),
        const SizedBox(height: 18),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF082F49),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          body,
          style: const TextStyle(color: Color(0xFF64748B), height: 1.45),
        ),
      ],
    ),
  );
}

class StepCard extends StatelessWidget {
  const StepCard({
    super.key,
    required this.number,
    required this.title,
    required this.body,
  });
  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => InfoCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFFFFC857),
          foregroundColor: const Color(0xFF052E2B),
          child: Text(
            number,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Text(
          body,
          style: const TextStyle(color: Color(0xFF64748B), height: 1.45),
        ),
      ],
    ),
  );
}

class ScreenMock extends StatelessWidget {
  const ScreenMock({super.key, required this.title, required this.metric});
  final String title;
  final String metric;

  @override
  Widget build(BuildContext context) => InfoCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFE8FFF4),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: Icon(
              Icons.space_dashboard,
              color: Color(0xFF10B981),
              size: 44,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(metric, style: const TextStyle(color: Color(0xFF64748B))),
      ],
    ),
  );
}

class PriceCard extends StatelessWidget {
  const PriceCard({
    super.key,
    required this.name,
    required this.price,
    required this.body,
  });
  final String name;
  final String price;
  final String body;

  @override
  Widget build(BuildContext context) => InfoCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Text(
          price,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 34,
            color: Color(0xFF052E2B),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          body,
          style: const TextStyle(color: Color(0xFF64748B), height: 1.45),
        ),
      ],
    ),
  );
}

class FaqItem extends StatelessWidget {
  const FaqItem({super.key, required this.question, required this.answer});
  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: Text(
              answer,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 210),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class Pill extends StatelessWidget {
  const Pill({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8FFF4),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF047857),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class CtaButton extends StatelessWidget {
  const CtaButton({
    super.key,
    required this.label,
    required this.icon,
    this.url,
  });
  final String label;
  final IconData icon;
  final String? url;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: url == null ? () {} : () => openDemoUrl(url!),
    icon: Icon(icon),
    label: Text(label),
    style: FilledButton.styleFrom(
      backgroundColor: const Color(0xFF10B981),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
    ),
  );
}

Future<void> openDemoUrl(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, webOnlyWindowName: '_blank')) {
    throw FlutterError('No se pudo abrir $url');
  }
}

class GhostButton extends StatelessWidget {
  const GhostButton({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: () {},
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      foregroundColor: const Color(0xFF052E2B),
    ),
    child: Text(label),
  );
}
