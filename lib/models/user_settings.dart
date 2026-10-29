class UserSettings {
  final String address;
  final String email;
  final String phoneNumber;
  final bool receiveNewsletter;

  const UserSettings({
    this.address = '',
    this.email = '',
    this.phoneNumber = '',
    this.receiveNewsletter = false,
  });
}
