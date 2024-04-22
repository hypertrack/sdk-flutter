abstract class OrderStatus {
  const OrderStatus();

  factory OrderStatus.clockIn() => ClockIn();

  factory OrderStatus.clockOut() => ClockOut();

  factory OrderStatus.custom(String value) => Custom(value);
}

class ClockIn extends OrderStatus {
  const ClockIn();
}

class ClockOut extends OrderStatus {
  const ClockOut();
}

class Custom extends OrderStatus {
  const Custom(this.value);

  final String value;
}
