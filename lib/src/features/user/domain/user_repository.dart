import 'app_user.dart';

abstract class UserRepository {
  Future<AppUser> fetchUserDetails(String token);
}
