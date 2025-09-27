enum ServiceType {
  dineIn('Dine In', '🍽️', 'Customer dining in the restaurant'),
  takeaway('Takeaway', '🥡', 'Order for pickup'),
  roomService('Room Service', '🏨', 'Order delivered to hotel room');

  const ServiceType(this.displayName, this.icon, this.description);

  final String displayName;
  final String icon;
  final String description;
}
