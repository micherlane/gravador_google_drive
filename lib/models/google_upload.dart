import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart' as login;
import 'package:googleapis/drive/v3.dart' as drive;
import 'google_auth_cliente.dart';

class UploadFileDrive {
  final String nomeArquivo;

  UploadFileDrive(this.nomeArquivo);

  final googleSingIn =
      login.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);

  Future logarDrive() async {
    login.GoogleSignInAccount? account = await googleSingIn.signIn();
    return account;
  }

  Future enviarArquivos() async {
    login.GoogleSignInAccount account = await logarDrive();
    final authHeaders = await account.authHeaders;
    final authenticateClient = GoogleAuthCliente(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);

    File file = File(nomeArquivo);

    var driveFile = drive.File();
    driveFile.name = "audio";
    final result = await driveApi.files.create(driveFile,
        uploadMedia: drive.Media(file.openRead(), file.lengthSync()));
    print("Upload result: $result");
  }
}
