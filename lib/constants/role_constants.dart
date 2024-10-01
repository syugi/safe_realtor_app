enum UserRoles {
  admin('ROLE_ADMIN', '관리자'),
  agent('ROLE_AGENT', '중개사'),
  user('ROLE_USER', '일반 사용자');

  // 속성 정의
  final String roleName;
  final String roleDescription;

  // 생성자 정의
  const UserRoles(this.roleName, this.roleDescription);

  // 역할에 따라 적절한 설명을 반환
  static String getRoleDescription(String role) {
    switch (role) {
      case 'ROLE_ADMIN':
        return UserRoles.admin.roleDescription;
      case 'ROLE_AGENT':
        return UserRoles.agent.roleDescription;
      default:
        return ''; // 사용자 역할일 경우 빈 문자열 반환
    }
  }
}
