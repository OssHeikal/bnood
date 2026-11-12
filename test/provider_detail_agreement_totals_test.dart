import 'package:bnood/core/agreements/app_agreement_record.dart';
import 'package:bnood/features/providers/provider_detail_agreement_totals.dart';
import 'package:bnood/features/providers/provider_detail_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('aggregateProviderAgreements', () {
    test('sums agreed, labor paid, and signed remaining', () {
      final rows = [
        ProviderDetailClientRow(
          clientName: 'A',
          agreement: AppAgreement(
            id: '1',
            clientId: 'c1',
            providerId: 'p1',
            amountPiastres: null,
            amountMajor: 5,
            paidMajor: 1,
            remainingMajor: 4,
          ),
        ),
        ProviderDetailClientRow(
          clientName: 'B',
          agreement: AppAgreement(
            id: '2',
            clientId: 'c2',
            providerId: 'p1',
            amountPiastres: null,
            amountMajor: 3,
            paidMajor: 2,
            remainingMajor: 1,
          ),
        ),
      ];

      final totals = aggregateProviderAgreements(rows);

      expect(totals.agreedMinor, 8000);
      expect(totals.paidMinor, 3000);
      expect(totals.remainingMinor, 5000);
    });

    test('omits agreed and remaining when unset on all agreements', () {
      final rows = [
        ProviderDetailClientRow(
          clientName: 'A',
          agreement: const AppAgreement(
            id: '1',
            clientId: 'c1',
            providerId: 'p1',
            amountPiastres: null,
            paidMajor: 1.5,
          ),
        ),
      ];

      final totals = aggregateProviderAgreements(rows);

      expect(totals.agreedMinor, isNull);
      expect(totals.paidMinor, 1500);
      expect(totals.remainingMinor, isNull);
    });
  });
}
