import 'package:bnood/core/contacts/device_contact_import.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolveContactPhone prefers selectedPhoneNumber', () {
    final contact = Contact(
      fullName: 'Ali',
      phoneNumbers: ['010', '011'],
      selectedPhoneNumber: '+20 10 1234 5678',
    );
    expect(resolveContactPhoneForImport(contact), '+20 10 1234 5678');
  });

  test('resolveContactPhone uses sole number without selection', () {
    final contact = Contact(fullName: 'Sara', phoneNumbers: ['01225556677']);
    expect(resolveContactPhoneForImport(contact), '01225556677');
  });

  test('resolveContactPhone returns null for multiple without selection', () {
    final contact = Contact(fullName: 'Sara', phoneNumbers: ['010', '011']);
    expect(resolveContactPhoneForImport(contact), isNull);
    expect(contactPhoneChoices(contact), ['010', '011']);
  });

  test('applyDeviceContactFields does not clear phone when contact has no number', () {
    final name = TextEditingController(text: 'draft');
    final phone = TextEditingController(text: '01099998888');
    applyDeviceContactFields(
      name: name,
      phone: phone,
      fields: const DeviceContactFields(name: 'From Contact'),
    );
    expect(name.text, 'From Contact');
    expect(phone.text, '01099998888');
  });

  test('applyDeviceContactFields westernizes digits and preserves plus', () {
    final name = TextEditingController();
    final phone = TextEditingController();
    applyDeviceContactFields(
      name: name,
      phone: phone,
      fields: const DeviceContactFields(name: 'عميل', phone: '+20 ١٠١٢٣٤٥٦٧٨'),
    );
    expect(phone.text, '+20 1012345678');
  });

}
