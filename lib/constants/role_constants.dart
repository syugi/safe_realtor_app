enum UserRoles {
  admin('ROLE_ADMIN'),
  agent('ROLE_AGENT'),
  user('ROLE_USER');

  // 속성 정의
  final String roleName;

  // 생성자 정의
  const UserRoles(this.roleName);
}
