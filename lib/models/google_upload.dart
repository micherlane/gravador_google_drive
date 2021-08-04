import 'dart:io';
import 'dart:developer' as d;
import 'package:google_sign_in/google_sign_in.dart' as login;
import 'package:googleapis/drive/v3.dart' as drive;
import 'google_auth_cliente.dart';
import 'package:intl/intl.dart';

class UploadFileDrive {
  final String nomeArquivo;

  UploadFileDrive(this.nomeArquivo);

  final googleSingIn =
      login.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);

  Future logarDrive() async {
    login.GoogleSignInAccount? account = await googleSingIn.signIn();
    return account;
  }

  Future<String> enviarArquivos() async {
    login.GoogleSignInAccount account = await logarDrive();
    final authHeaders = await account.authHeaders;
    final authenticateClient = GoogleAuthCliente(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);

    File file = File(nomeArquivo);

    var f = await driveApi.files
        .list(q: "mimeType = 'application/vnd.google-apps.folder'");
    String folderId = f.toJson()['files'][0]['id'];
    d.log(folderId);
    d.log(f.toJson().toString());

    var driveFile = drive.File();
    driveFile.parents = [folderId];
    driveFile.name =
        "wav - " + DateFormat('d of MMM of y HH:MM').format(DateTime.now());

    final result = await driveApi.files.create(driveFile,
        uploadMedia: drive.Media(file.openRead(), file.lengthSync()));

    d.log(result.toString());
    return "Áudio enviado para o Google Drive";
  }
}
