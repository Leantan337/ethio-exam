import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:exam_grade_8/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFirebaseAuth mockFirebaseAuth;
  late FakeFirebaseFirestore mockFirestore;
  late MockGoogleSignIn mockGoogleSignIn;
  late AuthService authService;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirestore = FakeFirebaseFirestore();
    mockGoogleSignIn = MockGoogleSignIn();
    authService = AuthService(
      auth: mockFirebaseAuth,
      firestore: mockFirestore,
      googleSignIn: mockGoogleSignIn,
    );
  });

  group('AuthService Tests', () {
    test('Sign up with email and password', () async {
      final email = 'test@example.com';
      final password = 'password123';
      final name = 'John';
      final surname = 'Doe';
      final age = 18;
      final schoolName = 'Test School';
      final city = 'Test City';

      final mockUser = MockUser(
        uid: 'test-uid',
        email: email,
        displayName: '$name $surname',
      );

      mockFirebaseAuth.mockUser = mockUser;

      try {
        final result = await authService.signUpWithEmail(
          email: email,
          password: password,
          name: name,
          surname: surname,
          age: age,
          schoolName: schoolName,
          city: city,
        );

        expect(result.user?.email, equals(email));
        
        // Verify user data in Firestore
        final userDoc = await mockFirestore
            .collection('users')
            .doc(result.user!.uid)
            .get();
        
        expect(userDoc.exists, isTrue);
        expect(userDoc.data()?['email'], equals(email));
        expect(userDoc.data()?['name'], equals(name));
        expect(userDoc.data()?['surname'], equals(surname));
        expect(userDoc.data()?['age'], equals(age));
        expect(userDoc.data()?['schoolName'], equals(schoolName));
        expect(userDoc.data()?['city'], equals(city));
        expect(userDoc.data()?['diamonds'], equals(0));
        expect(userDoc.data()?['points'], equals(0));
      } catch (e) {
        fail('Sign up failed: $e');
      }
    });

    test('Sign in with email and password', () async {
      final email = 'test@example.com';
      final password = 'password123';

      final mockUser = MockUser(
        uid: 'test-uid',
        email: email,
      );

      mockFirebaseAuth.mockUser = mockUser;

      try {
        final result = await authService.signInWithEmail(email, password);
        expect(result.user?.email, equals(email));
      } catch (e) {
        fail('Sign in failed: $e');
      }
    });

    test('Reset password', () async {
      final email = 'test@example.com';

      try {
        await authService.resetPassword(email);
        // If no exception is thrown, the test passes
        expect(true, isTrue);
      } catch (e) {
        fail('Password reset failed: $e');
      }
    });

    test('Sign out', () async {
      final mockUser = MockUser(
        uid: 'test-uid',
        email: 'test@example.com',
      );

      mockFirebaseAuth.mockUser = mockUser;
      await mockFirebaseAuth.signInWithCredential(
        EmailAuthProvider.credential(
          email: 'test@example.com',
          password: 'password123',
        ),
      );

      try {
        // First verify we have a user
        expect(mockFirebaseAuth.currentUser, isNotNull);
        
        await authService.signOut();
        
        // After sign out, currentUser should be null
        expect(mockFirebaseAuth.currentUser, isNull);
      } catch (e) {
        fail('Sign out failed: $e');
      }
    });

    test('Get user profile', () async {
      final userId = 'test-uid';
      final userData = {
        'name': 'John',
        'surname': 'Doe',
        'email': 'test@example.com',
        'diamonds': 0,
        'points': 0,
      };

      // Add test data to mock Firestore
      await mockFirestore.collection('users').doc(userId).set(userData);

      try {
        final profile = await authService.getUserProfile(userId);
        expect(profile, equals(userData));
      } catch (e) {
        fail('Get user profile failed: $e');
      }
    });

    test('Update user profile', () async {
      final userId = 'test-uid';
      final initialData = {
        'name': 'John',
        'surname': 'Doe',
        'email': 'test@example.com',
        'diamonds': 0,
        'points': 0,
      };

      final updateData = {
        'diamonds': 100,
        'points': 50,
      };

      // Add initial data to mock Firestore
      await mockFirestore.collection('users').doc(userId).set(initialData);

      try {
        await authService.updateUserProfile(
          userId: userId,
          data: updateData,
        );

        // Verify the update
        final updatedDoc = await mockFirestore
            .collection('users')
            .doc(userId)
            .get();
        
        expect(updatedDoc.data()?['diamonds'], equals(100));
        expect(updatedDoc.data()?['points'], equals(50));
      } catch (e) {
        fail('Update user profile failed: $e');
      }
    });
  });
}
