import 'package:flutter/material.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/about/presentation/screens/about_screen.dart';
import '../../features/about/presentation/screens/legal_document_screen.dart';
import '../../features/add_payment_method/presentation/screens/add_payment_method_screen.dart';
import '../../features/address/presentation/screens/address_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/cart/presentation/screens/finalize_cart_order_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/login/presentation/screens/customer_login_screen.dart';
import '../../features/login/presentation/screens/customer_tenant_inactive_screen.dart';
import '../../features/login/presentation/screens/login_shell_screen.dart';
import '../../features/login/presentation/screens/onboarding_screen.dart';
import '../../features/login/presentation/screens/signed_in_screen.dart';
import '../../features/login/presentation/screens/tenant_discovery_screen.dart';
import '../../features/navigator/presentation/screens/navigator_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/order_detail/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/profile/features/order_history/presentation/screens/order_history_screen.dart';
import '../../features/profile/features/payment_method/presentation/screens/payment_method_screen.dart';
import '../../features/profile/features/personal_info/presentation/screens/personal_info_screen.dart';
import '../../features/profile/features/reviews/presentation/screens/reviews_screen.dart';
import '../../features/profile/features/settings/features/settings_notifications/presentation/screens/settings_notifications_screen.dart';
import '../../features/profile/features/settings/presentation/screens/appearance_settings_screen.dart';
import '../../features/profile/features/settings/presentation/screens/language_settings_screen.dart';
import '../../features/profile/features/settings/presentation/screens/login_security_settings_screen.dart';
import '../../features/profile/features/settings/presentation/screens/map_settings_screen.dart';
import '../../features/profile/features/settings/presentation/screens/settings_screen.dart';
import '../../features/profile/features/support_requests/presentation/screens/support_requests_screen.dart';
import '../../features/profile/features/wallet/presentation/screens/wallet_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/features/wallet/presentation/screens/transactions_screen.dart';
import '../../features/shop/presentation/screens/articles_screen.dart';
import '../../features/shop/presentation/screens/product_screen.dart';
import '../../features/shop/presentation/screens/shop_screen.dart';
import '../../features/user_subscription/presentation/screens/user_subscription_screen.dart';

/// Version sans generation de code. L'app d'origine utilisait auto_route
/// (voir docs/DEPENDANCES_A_AJOUTER.md).
class AppRouter {
  const AppRouter._();

  static final Map<String, WidgetBuilder> routes = {
    '/splash': (_) => const SplashScreen(),
    '/about': (_) => const AboutScreen(),
    '/legal-document': (_) => const LegalDocumentScreen(),
    '/add-payment-method': (_) => const AddPaymentMethodScreen(),
    '/address': (_) => const AddressScreen(),
    '/cart': (_) => const CartScreen(),
    '/finalize-cart-order': (_) => const FinalizeCartOrderScreen(),
    '/home': (_) => const HomeScreen(),
    '/customer-login': (_) => const CustomerLoginScreen(),
    '/customer-tenant-inactive': (_) => const CustomerTenantInactiveScreen(),
    '/login-shell': (_) => const LoginShellScreen(),
    '/onboarding': (_) => const OnboardingScreen(),
    '/tenant-discovery': (_) => const TenantDiscoveryScreen(),
    '/navigator': (_) => const NavigatorScreen(),
    '/signed-in': (_) => const SignedInScreen(),
    '/notifications': (_) => const NotificationsScreen(),
    '/order-detail': (_) => const OrderDetailScreen(),
    '/orders': (_) => const OrdersScreen(),
    '/order-history': (_) => const OrderHistoryScreen(),
    '/payment-method': (_) => const PaymentMethodScreen(),
    '/personal-info': (_) => const PersonalInfoScreen(),
    '/reviews': (_) => const ReviewsScreen(),
    '/settings-notifications': (_) => const SettingsNotificationsScreen(),
    '/appearance-settings': (_) => const AppearanceSettingsScreen(),
    '/language-settings': (_) => const LanguageSettingsScreen(),
    '/login-security-settings': (_) => const LoginSecuritySettingsScreen(),
    '/map-settings': (_) => const MapSettingsScreen(),
    '/settings': (_) => const SettingsScreen(),
    '/support-requests': (_) => const SupportRequestsScreen(),
    '/wallet': (_) => const WalletScreen(),
    '/transactions': (_) => const TransactionsScreen(),
    '/articles': (_) => const ArticlesScreen(),
    '/profile': (_) => const ProfileScreen(),
    '/product': (_) => const ProductScreen(),
    '/shop': (_) => const ShopScreen(),
    '/user-subscription': (_) => const UserSubscriptionScreen(),
  };

  static const initialRoute = '/splash';
}
