class CallModel {
  final String id;
  final String roomID;
  final String roomToken;
  String status;
  final String createdAt;
  String updatedAt;

  CallModel({
    required this.id,
    required this.roomID,
    required this.roomToken,
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });
  
  void updateStatus(String status){
    status = status;
    updatedAt = DateTime.now().toIso8601String();
  }

  factory CallModel.fromCallID(String callID){
    return CallModel(
      id: callID,
      roomID: '',
      roomToken: '',
      status: 'pending',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
  }
}