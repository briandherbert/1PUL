import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';


final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'https://www.googleapis.com/auth/spreadsheets',
    'https://www.googleapis.com/auth/drive.file',
  ],
);

Future<GoogleSignInAccount?> signInWithGoogle() async {
  try {
    return await _googleSignIn.signIn();
  } catch (error) {
    print(error);
    return null;
  }
}

Future<AuthClient?> getAuthenticatedHttpClient() async {
  final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  if (googleUser == null) {
    return null;
  }

  final authHeaders = await googleUser.authHeaders;
  final client = authenticatedClient(
    Client(),
    AccessCredentials(
      AccessToken(
        'Bearer',
        authHeaders['Authorization']!.substring(7),
        DateTime.now().add(Duration(hours: 1)),
      ),
      null,
      ['https://www.googleapis.com/auth/spreadsheets', 'https://www.googleapis.com/auth/drive.file'],
    ),
  );

  return client;
}