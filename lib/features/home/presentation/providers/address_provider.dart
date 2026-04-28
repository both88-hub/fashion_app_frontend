import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddressModel {
  final String id;
  final String name;
  final String street;
  final String city;
  final String country;

  AddressModel({
    required this.id,
    required this.name,
    required this.street,
    required this.city,
    required this.country,
  });
}

class AddressState {
  final List<AddressModel> addresses;
  final String? selectedAddressId;

  AddressState({required this.addresses, this.selectedAddressId});

  AddressState copyWith({List<AddressModel>? addresses, String? selectedAddressId}) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
    );
  }

  AddressModel? get selectedAddress {
    if (selectedAddressId == null) return null;
    try {
      return addresses.firstWhere((a) => a.id == selectedAddressId);
    } catch (e) {
      return null;
    }
  }
}

class AddressNotifier extends StateNotifier<AddressState> {
  AddressNotifier()
      : super(AddressState(
          addresses: [
            AddressModel(
              id: '1',
              name: 'Home Address',
              street: '123 Fashion Street, Soho',
              city: 'London',
              country: 'UK',
            ),
          ],
          selectedAddressId: '1',
        ));

  void addAddress(AddressModel address) {
    state = state.copyWith(
      addresses: [...state.addresses, address],
      selectedAddressId: address.id, // Auto-select newly added
    );
  }

  void selectAddress(String id) {
    state = state.copyWith(selectedAddressId: id);
  }

  void removeAddress(String id) {
    final updated = state.addresses.where((a) => a.id != id).toList();
    state = state.copyWith(
      addresses: updated,
      selectedAddressId: state.selectedAddressId == id 
          ? (updated.isNotEmpty ? updated.first.id : null) 
          : state.selectedAddressId,
    );
  }
}

final addressProvider = StateNotifierProvider<AddressNotifier, AddressState>((ref) {
  return AddressNotifier();
});
