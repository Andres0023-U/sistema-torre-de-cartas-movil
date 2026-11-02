enum UserRole {
  player,
  organizer,
  admin,
  user, // Cuenta pendiente de aprobación
}

UserRole parseUserRole(String roleStr) {
  switch (roleStr.toLowerCase()) {
    case 'admin':
      return UserRole.admin;
    case 'organizer':
      return UserRole.organizer;
    case 'player':
      return UserRole.player;
    case 'pending':
      return UserRole.user;
    default:
      throw Exception('Rol desconocido');
  }
}
