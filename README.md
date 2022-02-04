# oauth2_client_aes_storage

An AES encrypted storage backend for oauth2_client.

On some platforms (notably Windows), the platform secure storage has a max length per key that may not be sufficient for storing token responses. This provides a implementation of a storage method where the secret is AES encrypted and stored in shared preferences. The AES key is stored using secure storage.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
import 'package:oauth2_client/src/token_storage.dart';
import 'package:oauth2_client_aes_storage/oauth2_client_aes_storage.dart';


TokenStorage storage = TokenStorage("<resource_id>", storage: EncryptedStorage());

final oauth2 = OAuth2Helper(client, clientId: "...", tokenStorage: storage);
```
