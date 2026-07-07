class DemoLinksConfig {
  const DemoLinksConfig._();

  static const parentDemoUrl = String.fromEnvironment(
    'SCHOOLBITE_PARENT_DEMO_URL',
    defaultValue: 'http://127.0.0.1:8102',
  );

  static const adminDemoUrl = String.fromEnvironment(
    'SCHOOLBITE_ADMIN_DEMO_URL',
    defaultValue: 'http://127.0.0.1:8103',
  );
}
