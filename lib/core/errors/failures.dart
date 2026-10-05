abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class LocationFailure extends Failure {
  const LocationFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class HospitalLookupFailure extends Failure {
  const HospitalLookupFailure(super.message);
}

class DispatchFailure extends Failure {
  const DispatchFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
