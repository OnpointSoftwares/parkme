class ParkingSpot
{
  int id;
  String name;
  String address;
  var totalSpots;
  var occupiedSpots;
  String imageUrl;
  int costPerHour;
  var owner;

  ParkingSpot({required this.id,required this.name,required this.address,required this.totalSpots,required this.occupiedSpots,required this.imageUrl,required this.costPerHour,required this.owner});
}
