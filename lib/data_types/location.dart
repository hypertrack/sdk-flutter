class Location {
  double latitude;
  double longitude;

  Location(this.latitude, this.longitude);

  @override
  String toString() {
    return "{$latitude, $longitude}";
  }
}
