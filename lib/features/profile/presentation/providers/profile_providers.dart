import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fashion_app/features/auth/providers/auth_provider.dart';

// --- Profile Details ---

class ProfileState {
  final String name;
  final String email;
  final String phone;
  final DateTime? birthday;
  final String gender;
  final String? avatarPath;

  ProfileState({
    required this.name,
    required this.email,
    required this.phone,
    this.birthday,
    required this.gender,
    this.avatarPath,
  });

  ProfileState copyWith({
    String? name,
    String? email,
    String? phone,
    DateTime? birthday,
    String? gender,
    String? avatarPath,
  }) {
    return ProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final Ref _ref;

  ProfileNotifier(this._ref)
      : super(ProfileState(
          name: '',
          email: '',
          phone: '',
          gender: 'Male',
        )) {
    _syncWithAuth();
  }

  void _syncWithAuth() {
    final authState = _ref.read(authProvider);
    final user = authState.user;
    if (user != null) {
      final firstName = user['first_name'] ?? '';
      final lastName = user['last_name'] ?? '';
      state = state.copyWith(
        name: '$firstName $lastName'.trim(),
        email: user['email'] ?? '',
      );
    }
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      state = state.copyWith(avatarPath: image.path);
    }
  }

  void updateProfile({
    required String name,
    required String email,
    required String phone,
    required DateTime? birthday,
    required String gender,
  }) {
    state = state.copyWith(
      name: name,
      email: email,
      phone: phone,
      birthday: birthday,
      gender: gender,
    );
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref);
});

// --- Notification Settings ---

class NotificationSettingsState {
  final bool orderUpdates;
  final bool promotions;
  final bool newArrivals;
  final bool priceDrops;
  final bool appUpdates;

  NotificationSettingsState({
    this.orderUpdates = true,
    this.promotions = false,
    this.newArrivals = true,
    this.priceDrops = false,
    this.appUpdates = true,
  });

  NotificationSettingsState copyWith({
    bool? orderUpdates,
    bool? promotions,
    bool? newArrivals,
    bool? priceDrops,
    bool? appUpdates,
  }) {
    return NotificationSettingsState(
      orderUpdates: orderUpdates ?? this.orderUpdates,
      promotions: promotions ?? this.promotions,
      newArrivals: newArrivals ?? this.newArrivals,
      priceDrops: priceDrops ?? this.priceDrops,
      appUpdates: appUpdates ?? this.appUpdates,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettingsState> {
  NotificationSettingsNotifier() : super(NotificationSettingsState());

  void toggleOrderUpdates(bool value) {
    state = state.copyWith(orderUpdates: value);
  }

  void togglePromotions(bool value) {
    state = state.copyWith(promotions: value);
  }

  void toggleNewArrivals(bool value) {
    state = state.copyWith(newArrivals: value);
  }

  void togglePriceDrops(bool value) {
    state = state.copyWith(priceDrops: value);
  }

  void toggleAppUpdates(bool value) {
    state = state.copyWith(appUpdates: value);
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettingsState>((ref) {
  return NotificationSettingsNotifier();
});

// --- FAQs ---

class FaqItem {
  final String question;
  final String answer;
  final String category;

  FaqItem({required this.question, required this.answer, required this.category});
}

final faqsProvider = Provider<List<FaqItem>>((ref) {
  return [
    FaqItem(
      category: 'Orders',
      question: 'How do I track my order?',
      answer: 'You can track your order in the "My Orders" section by clicking on "Track Order".',
    ),
    FaqItem(
      category: 'Orders',
      question: 'Can I cancel my order?',
      answer: 'Orders can be cancelled within 30 minutes of placement.',
    ),
    FaqItem(
      category: 'Returns',
      question: 'What is your return policy?',
      answer: 'We offer a 30-day return policy for all unworn items with tags.',
    ),
    FaqItem(
      category: 'Returns',
      question: 'How do I start a return?',
      answer: 'Go to "My Orders", select the item, and click "Return Item".',
    ),
    FaqItem(
      category: 'Payments',
      question: 'What payment methods do you accept?',
      answer: 'We accept Credit/Debit cards, PayPal, and Apple Pay.',
    ),
    FaqItem(
      category: 'Account',
      question: 'How do I reset my password?',
      answer: 'Click "Forgot Password" on the login screen and follow the instructions.',
    ),
  ];
});

final faqSearchProvider = StateProvider<String>((ref) => '');

final filteredFaqsProvider = Provider<List<FaqItem>>((ref) {
  final faqs = ref.watch(faqsProvider);
  final search = ref.watch(faqSearchProvider).toLowerCase();

  if (search.isEmpty) return faqs;

  return faqs.where((faq) {
    return faq.question.toLowerCase().contains(search) ||
        faq.answer.toLowerCase().contains(search);
  }).toList();
});

// --- Live Chat ---

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([
    ChatMessage(
      text: 'Hello! How can I help you today?',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ]);

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    state = [...state, userMessage];

    // Simulate bot response
    Future.delayed(const Duration(seconds: 1), () {
      final botMessage = ChatMessage(
        text: "Thanks for your message. An agent will be with you shortly.",
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = [...state, botMessage];
    });
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier();
});
