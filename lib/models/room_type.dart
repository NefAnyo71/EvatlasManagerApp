class RoomType {
  final String id;
  final String displayName;
  final int bedrooms;
  final int livingRooms;

  const RoomType({
    required this.id,
    required this.displayName,
    required this.bedrooms,
    required this.livingRooms,
  });

  static const List<RoomType> availableRoomTypes = [
    RoomType(id: '0+1', displayName: '0+1', bedrooms: 0, livingRooms: 1),
    RoomType(id: '1+0', displayName: '1+0', bedrooms: 1, livingRooms: 0),
    RoomType(id: '1+1', displayName: '1+1', bedrooms: 1, livingRooms: 1),
    RoomType(id: '2+1', displayName: '2+1', bedrooms: 2, livingRooms: 1),
    RoomType(id: '3+1', displayName: '3+1', bedrooms: 3, livingRooms: 1),
    RoomType(id: '4+1', displayName: '4+1', bedrooms: 4, livingRooms: 1),
    RoomType(id: '5+1', displayName: '5+1', bedrooms: 5, livingRooms: 1),
    RoomType(id: '6+1', displayName: '6+1', bedrooms: 6, livingRooms: 1),
    RoomType(id: '2+2', displayName: '2+2', bedrooms: 2, livingRooms: 2),
    RoomType(id: '3+2', displayName: '3+2', bedrooms: 3, livingRooms: 2),
    RoomType(id: '4+2', displayName: '4+2', bedrooms: 4, livingRooms: 2),
    RoomType(id: '5+2', displayName: '5+2', bedrooms: 5, livingRooms: 2),
  ];

  static RoomType? fromId(String id) {
    try {
      return availableRoomTypes.firstWhere((room) => room.id == id);
    } catch (e) {
      return null;
    }
  }

  int get totalRooms => bedrooms + livingRooms;

  @override
  String toString() => displayName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomType && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
