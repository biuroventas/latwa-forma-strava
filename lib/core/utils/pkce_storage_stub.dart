import 'package:supabase_flutter/supabase_flutter.dart';

/// Na platformach innych niż web używamy domyślnego storage (null = SharedPreferences).
GotrueAsyncStorage? getPkceStorageForWeb() => null;
