class CommercialConfig {
  const CommercialConfig._();

  static const parentDemoUrl = String.fromEnvironment(
    'PARENT_DEMO_URL',
    defaultValue: 'https://schoolbite-parent.vercel.app/',
  );

  static const adminDemoUrl = String.fromEnvironment(
    'ADMIN_DEMO_URL',
    defaultValue: 'https://schoolbiteadmin.vercel.app/',
  );

  static const contactEmail = String.fromEnvironment(
    'CONTACT_EMAIL',
    defaultValue: 'hola@schoolbite.app',
  );

  static const whatsappUrl = String.fromEnvironment(
    'WHATSAPP_URL',
    defaultValue: 'https://wa.me/50600000000',
  );

  static const monthlyPrice = String.fromEnvironment(
    'MONTHLY_PRICE',
    defaultValue: '₡39.900',
  );

  static const contactUrl = whatsappUrl;
}
