import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/core/constants/categories.dart';
import 'package:wedding_tinder/models/vendor.dart';

void main() {
  group('Vendor', () {
    const Map<String, dynamic> fullJson = {
      'id': 'rest_01',
      'name': 'Casa Doina',
      'category': 'restaurant',
      'description': 'A historic manor.',
      'judet': 'Bucharest',
      'localitate': 'Bucharest',
      'priceMin': 320,
      'priceMax': 480,
      'priceUnit': 'RON/person',
      'rating': 4.8,
      'reviewCount': 142,
      'photos': ['assets/images/vendors/buri.jpeg'],
      'tags': ['Historic manor', 'Garden'],
      'phone': '+40 21 230 1234',
      'website': 'casadoina.ro',
      'instagram': '@casadoina',
    };

    test('fromJson parses all fields', () {
      final v = Vendor.fromJson(fullJson);
      expect(v.id, 'rest_01');
      expect(v.name, 'Casa Doina');
      expect(v.category, VendorCategory.restaurant);
      expect(v.judet, 'Bucharest');
      expect(v.priceMin, 320);
      expect(v.priceMax, 480);
      expect(v.rating, closeTo(4.8, 0.001));
      expect(v.reviewCount, 142);
      expect(v.photos, ['assets/images/vendors/buri.jpeg']);
      expect(v.tags, ['Historic manor', 'Garden']);
      expect(v.phone, '+40 21 230 1234');
      expect(v.website, 'casadoina.ro');
      expect(v.instagram, '@casadoina');
    });

    test('fromJson parses all VendorCategory values', () {
      const categories = {
        'restaurant': VendorCategory.restaurant,
        'fotograf': VendorCategory.fotograf,
        'dj': VendorCategory.dj,
        'formatie': VendorCategory.formatie,
        'florarie': VendorCategory.florarie,
        'tort': VendorCategory.tort,
      };
      for (final entry in categories.entries) {
        final json = {...fullJson, 'category': entry.key};
        expect(Vendor.fromJson(json).category, entry.value);
      }
    });

    test('fromJson omits optional contact fields when absent', () {
      final json = Map<String, dynamic>.from(fullJson)
        ..remove('phone')
        ..remove('website')
        ..remove('instagram');
      final v = Vendor.fromJson(json);
      expect(v.phone, isNull);
      expect(v.website, isNull);
      expect(v.instagram, isNull);
    });

    test('fromJson throws FormatException for unknown category', () {
      final json = Map<String, dynamic>.from(fullJson)
        ..['category'] = 'disco';
      expect(() => Vendor.fromJson(json), throwsFormatException);
    });

    test('fromJson handles numeric price fields as doubles', () {
      final json = Map<String, dynamic>.from(fullJson)
        ..['priceMin'] = 320.0
        ..['priceMax'] = 480.0;
      final v = Vendor.fromJson(json);
      expect(v.priceMin, 320);
      expect(v.priceMax, 480);
    });

    test('toJson round-trips through fromJson', () {
      final v = Vendor.fromJson(fullJson);
      final v2 = Vendor.fromJson(v.toJson());
      expect(v2.id, v.id);
      expect(v2.name, v.name);
      expect(v2.category, v.category);
      expect(v2.priceMin, v.priceMin);
      expect(v2.rating, v.rating);
      expect(v2.photos, v.photos);
      expect(v2.tags, v.tags);
    });

    test('toJson omits null optional fields', () {
      final json = Map<String, dynamic>.from(fullJson)
        ..remove('phone')
        ..remove('website')
        ..remove('instagram');
      final out = Vendor.fromJson(json).toJson();
      expect(out.containsKey('phone'), isFalse);
      expect(out.containsKey('website'), isFalse);
      expect(out.containsKey('instagram'), isFalse);
    });

    test('toJson includes category as its json key string', () {
      final v = Vendor.fromJson(fullJson);
      expect(v.toJson()['category'], 'restaurant');
    });

    test('copyWith replaces only specified field', () {
      final v = Vendor.fromJson(fullJson);
      final copy = v.copyWith(name: 'New Name');
      expect(copy.name, 'New Name');
      expect(copy.id, v.id);
      expect(copy.category, v.category);
      expect(copy.priceMin, v.priceMin);
    });

    test('copyWith with no args returns equivalent vendor', () {
      final v = Vendor.fromJson(fullJson);
      final copy = v.copyWith();
      expect(copy.id, v.id);
      expect(copy.name, v.name);
    });

    test('equality is by id regardless of other fields', () {
      final v1 = Vendor.fromJson(fullJson);
      final v2 = v1.copyWith(name: 'Completely Different Name');
      expect(v1, equals(v2));
      expect(v1.hashCode, v2.hashCode);
    });

    test('vendors with different ids are not equal', () {
      final v1 = Vendor.fromJson(fullJson);
      final v2 = v1.copyWith(id: 'rest_02');
      expect(v1, isNot(equals(v2)));
    });
  });
}
