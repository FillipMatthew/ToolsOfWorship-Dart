class UserConnection {
  String? _userId;
  int? _signInType;
  String? _accountId;
  String? _authDetails;

  UserConnection();

  UserConnection.create(
      String userId, int signInType, String accountId, String? authDetails)
      : _userId = userId,
        _signInType = signInType,
        _accountId = accountId,
        _authDetails = authDetails;

  UserConnection.fromJson(Map<String, dynamic> userData) {
    _userId = userData['userId'];
    _signInType = userData['signInType'];
    _accountId = userData['accountId'];
    _authDetails = userData['authDetails'];
  }

  String get userId => _userId!;
  int get signInType => _signInType!;
  String get accountId => _accountId!;
  String? get authDetails => _authDetails;

  bool get isValid =>
      _userId != null && _signInType != null && _accountId != null;
}
