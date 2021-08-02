import 'package:google_sign_in/google_sign_in.dart' as login;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/tagmanager/v2.dart';

Future<void> logarDrive() async {
  final googleSingIn =
      login.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
  googleSingIn.signIn();
  print('User acount $Account');
}
