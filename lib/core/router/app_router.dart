import 'package:fashion_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:fashion_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:fashion_app/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:fashion_app/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:fashion_app/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:fashion_app/features/auth/presentation/screens/signup_step1_screen.dart';
import 'package:fashion_app/features/auth/presentation/screens/signup_step2_screen.dart';
import 'package:fashion_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:fashion_app/features/home/presentation/screens/home_screen.dart';
import 'package:fashion_app/features/home/presentation/screens/notifications_screen.dart';
import 'package:fashion_app/features/home/presentation/screens/product_details_screen.dart';
import 'package:fashion_app/features/home/presentation/screens/reviews_screen.dart';
import 'package:fashion_app/features/home/presentation/screens/checkout_screen.dart';
import 'package:fashion_app/features/home/presentation/screens/address_screen.dart';
import 'package:fashion_app/features/home/presentation/screens/add_new_address_screen.dart';
import 'package:fashion_app/features/home/presentation/screens/payment_screen.dart';
import 'package:fashion_app/features/home/presentation/screens/add_new_card_screen.dart';
import 'package:fashion_app/features/home/presentation/screens/order_success_screen.dart';
import 'package:fashion_app/features/home/presentation/screens/account_screen.dart';
import 'package:fashion_app/features/home/presentation/screens/my_orders_screen.dart';
import 'package:fashion_app/features/home/presentation/screens/order_tracking_screen.dart';
import 'package:fashion_app/features/home/presentation/screens/leave_review_screen.dart';
import 'package:fashion_app/features/profile/presentation/screens/my_details_screen.dart';
import 'package:fashion_app/features/profile/presentation/screens/notification_settings_screen.dart';
import 'package:fashion_app/features/profile/presentation/screens/faqs_screen.dart';
import 'package:fashion_app/features/profile/presentation/screens/help_center_screen.dart';
import 'package:fashion_app/features/profile/presentation/screens/live_chat_screen.dart';
import 'package:fashion_app/features/home/domain/models/product.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appRouterStateProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: AppRoute.onboarding.name,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: AppRoute.auth.name,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: AppRoute.forgotPassword.name,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        name: AppRoute.otpVerification.name,
        builder: (context, state) => const OtpVerificationScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        name: AppRoute.resetPassword.name,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/signup-1',
        name: AppRoute.signUpStep1.name,
        builder: (context, state) => const SignUpStep1Screen(),
      ),
      GoRoute(
        path: '/signup-2',
        name: AppRoute.signUpStep2.name,
        builder: (context, state) => const SignUpStep2Screen(),
      ),
      GoRoute(
        path: '/notifications',
        name: AppRoute.notifications.name,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/product-details',
        name: AppRoute.productDetails.name,
        builder: (context, state) {
          final product = state.extra as Product;
          return ProductDetailsScreen(product: product);
        },
      ),
      GoRoute(
        path: '/reviews',
        name: AppRoute.reviews.name,
        builder: (context, state) => const ReviewsScreen(),
      ),
      GoRoute(
        path: '/leave-review',
        name: AppRoute.leaveReview.name,
        builder: (context, state) => const LeaveReviewScreen(),
      ),
      GoRoute(
        path: '/checkout',
        name: AppRoute.checkout.name,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/address',
        name: AppRoute.address.name,
        builder: (context, state) => const AddressScreen(),
      ),
      GoRoute(
        path: '/add-address',
        name: AppRoute.addNewAddress.name,
        builder: (context, state) => const AddNewAddressScreen(),
      ),
      GoRoute(
        path: '/payment',
        name: AppRoute.payment.name,
        builder: (context, state) => const PaymentScreen(),
      ),
      GoRoute(
        path: '/add-card',
        name: AppRoute.addNewCard.name,
        builder: (context, state) => const AddNewCardScreen(),
      ),
      GoRoute(
        path: '/order-success',
        name: AppRoute.orderSuccess.name,
        builder: (context, state) => const OrderSuccessScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: AppRoute.profile.name,
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: '/my-orders',
        name: AppRoute.myOrders.name,
        builder: (context, state) => const MyOrdersScreen(),
      ),
      GoRoute(
        path: '/track-order/:id',
        name: AppRoute.trackOrder.name,
        builder: (context, state) => OrderTrackingScreen(
          orderId: state.pathParameters['id'] ?? '0',
        ),
      ),
      GoRoute(
        path: '/my-details',
        name: AppRoute.myDetails.name,
        builder: (context, state) => const MyDetailsScreen(),
      ),
      GoRoute(
        path: '/notification-settings',
        name: AppRoute.notificationSettings.name,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/faqs',
        name: AppRoute.faqs.name,
        builder: (context, state) => const FaqsScreen(),
      ),
      GoRoute(
        path: '/help-center',
        name: AppRoute.helpCenter.name,
        builder: (context, state) => const HelpCenterScreen(),
      ),
      GoRoute(
        path: '/live-chat',
        name: AppRoute.liveChat.name,
        builder: (context, state) => const LiveChatScreen(),
      ),
      GoRoute(
        path: '/',
        name: AppRoute.home.name,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});

enum AppRoute {
  splash,
  onboarding,
  home,
  shop,
  productDetails,
  cart,
  profile,
  auth,
  forgotPassword,
  otpVerification,
  resetPassword,
  signUpStep1,
  signUpStep2,
  notifications,
  reviews,
  checkout,
  address,
  addNewAddress,
  payment,
  addNewCard,
  orderSuccess,
  myOrders,
  trackOrder,
  myDetails,
  notificationSettings,
  faqs,
  helpCenter,
  liveChat,
  leaveReview,
}
