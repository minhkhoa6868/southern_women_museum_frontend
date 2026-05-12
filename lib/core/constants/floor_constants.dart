class FloorLabels {
  static const String firstFloor = '1ST FLOOR';
  static const String groundFloor = 'GROUND FLOOR';
}

String inferFloorLabelFromRoomCode(String roomCode) {
  if (roomCode.startsWith('R3')) {
    return FloorLabels.groundFloor;
  }

  return FloorLabels.firstFloor;
}
