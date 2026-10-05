import 'package:geolocator/geolocator.dart';
import 'package:noble_pasteur/features/hospital/domain/entities/hospital.dart';
import 'package:noble_pasteur/features/sos/domain/entities/sos_dispatch.dart';

enum SosStatus {
  idle,
  holding,
  locating,
  findingHospital,
  dispatching,
  active,
  failure,
}

class SosState {
  final SosStatus status;
  final double holdProgress; // 0.0 to 1.0
  final Position? position;
  final Hospital? hospital;
  final SosDispatch? dispatch;
  final String? errorMessage;
  final bool isPermissionPermanentlyDenied;

  const SosState({
    this.status = SosStatus.idle,
    this.holdProgress = 0.0,
    this.position,
    this.hospital,
    this.dispatch,
    this.errorMessage,
    this.isPermissionPermanentlyDenied = false,
  });

  bool get isProcessing =>
      status == SosStatus.locating ||
      status == SosStatus.findingHospital ||
      status == SosStatus.dispatching;

  bool get isActive => status == SosStatus.active;

  SosState copyWith({
    SosStatus? status,
    double? holdProgress,
    Position? position,
    Hospital? hospital,
    SosDispatch? dispatch,
    String? errorMessage,
    bool? isPermissionPermanentlyDenied,
  }) {
    return SosState(
      status: status ?? this.status,
      holdProgress: holdProgress ?? this.holdProgress,
      position: position ?? this.position,
      hospital: hospital ?? this.hospital,
      dispatch: dispatch ?? this.dispatch,
      errorMessage: errorMessage ?? this.errorMessage,
      isPermissionPermanentlyDenied:
          isPermissionPermanentlyDenied ?? this.isPermissionPermanentlyDenied,
    );
  }
}
