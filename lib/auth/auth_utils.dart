import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rue_app/firebase_options.dart';
import 'package:rue_app/models/employee_model.dart';

class AuthService {
  var firebaseAuth = FirebaseAuth.instance;
  var db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> registration({
    required String email,
    required String password,
  }) async {
    FirebaseApp app = await Firebase.initializeApp(
      name: 'Secondary',
      options: DefaultFirebaseOptions.currentPlatform,
    );
    try {
      UserCredential userCredential;
      userCredential = await FirebaseAuth.instanceFor(app: app)
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      String uid = user!.uid;
      await FirebaseAuth.instanceFor(app: app).signOut();
      return {"message": "success", "object": uid};
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return {"message": 'The password provided is too weak.'};
      } else if (e.code == 'email-already-in-use') {
        return {"message": 'The account already exists for that email.'};
      } else {
        return {"message": e.message.toString()};
      }
    } catch (e) {
      return {"message": e.toString()};
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid = firebaseAuth.currentUser!.uid;
      final ref = await db
          .collection("employees")
          .doc(uid)
          .withConverter(
            fromFirestore: Employee.fromFirestore,
            toFirestore: (Employee employee, _) => employee.toFirestore(),
          )
          .get();
      if (ref.exists) return 'success';
      logout();
      return "User got deleted and not exist anymore";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else {
        return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> editAccount({
    required String uid,
    required String email,
    required String currentPassword,
    required String newPassword,
    required String fullName,
    required String phoneNumber,
    required String position,
    required bool isAdmin,
    required bool isPasswordChanged,
  }) async {
    try {
      if (isAdmin) {
        db.collection("employees").doc(uid).update({
          "fullName": fullName,
          "phoneNumber": phoneNumber,
          "position": position,
        });
        return "success";
      } else {
        User? user = firebaseAuth.currentUser;
        if (email.compareTo((user!.email).toString()) != 0) {
          var cred = EmailAuthProvider.credential(
            email: (user.email).toString(),
            password: currentPassword,
          );
          await user.reauthenticateWithCredential(cred);
          await user.updateEmail(email);
        }
        if (isPasswordChanged) {
          var cred = EmailAuthProvider.credential(
            email: (user.email).toString(),
            password: currentPassword,
          );
          await user.reauthenticateWithCredential(cred);
          await user.updatePassword(newPassword);
        }
        db.collection("employees").doc(uid).update({
          "fullName": fullName,
          "phoneNumber": phoneNumber,
          "position": position,
          "email": email,
        });
        return "success";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else {
        return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      return "success";
    } on Exception catch (e) {
      return e.toString();
    }
  }
}
