import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pot/features/wallet/constants/wallet_constants.dart';

void main() {
  group('WalletConstants', () {
    test('slotCost is 200 greenCoins', () {
      expect(WalletConstants.slotCost, 200);
    });

    test('maxSlots is 10', () {
      expect(WalletConstants.maxSlots, 10);
    });

    test('slotCost is positive', () {
      expect(WalletConstants.slotCost, greaterThan(0));
    });

    test('maxSlots is greater than the default unlocked slot count', () {
      expect(WalletConstants.maxSlots, greaterThan(1));
    });
  });
}
