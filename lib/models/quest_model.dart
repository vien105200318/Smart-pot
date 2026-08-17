import 'package:cloud_firestore/cloud_firestore.dart';






enum QuestType{
  waterPlant, 
  monitorTemp,
  dailyLogin,
  sharePost,
}


class QuestModel {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final int reward;
  final int target;        
  final int progress;      
  final bool isCompleted;
  final DateTime? completedAt;
  final String dateKey;


  QuestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.reward,
    required this.target,
    this.dateKey = '',
    this.progress = 0,
    this.isCompleted = false,
    this.completedAt, 
  });

  factory QuestModel.fromFireStore(
    String id, 
    Map<String, dynamic> data, 
  )
  {
    return QuestModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: _questTypeFromString(data['type'] ?? ''),
      reward: data['reward'] ?? 0,
      target: data['target'] ?? 1,
      progress: data['progress'] ?? 0,
      isCompleted: data['isCompleted'] ?? false,
      dateKey: data['dateKey'] ?? '',
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }
  Map<String, dynamic> toMap(){
    return {
      'title': title,
      'description': description,
      'type': type.name,
      'reward': reward,
      'target': target,
      'progress': progress,
      'isCompleted': isCompleted,
      'dateKey': dateKey,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
    };
  }
  QuestModel copyWith({
    int? progress,
    bool? isCompleted,
    DateTime? completedAt,
  }){
    return QuestModel(
      id: id,
      title: title,
      description: description,
      type: type,
      reward: reward,
      target: target,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      dateKey: dateKey,
    );
  }
  static QuestType _questTypeFromString(String value) {
    for (final type in QuestType.values) {
      if (type.name == value) return type;
    }
    return QuestType.dailyLogin;
  }
}
