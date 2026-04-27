class WindDownEntry {
  String id;
  DateTime date;
  String? winReflection;
  String? tomorrowPreview;
  int windDownMinutes;

  WindDownEntry({
    required this.id,
    required this.date,
    this.winReflection,
    this.tomorrowPreview,
    this.windDownMinutes = 0,
  });

  WindDownEntry.create({
    this.winReflection,
    this.tomorrowPreview,
    this.windDownMinutes = 0,
  })  : id = DateTime.now().millisecondsSinceEpoch.toString(),
        date = DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'winReflection': winReflection,
    'tomorrowPreview': tomorrowPreview,
    'windDownMinutes': windDownMinutes,
  };

  factory WindDownEntry.fromJson(Map<String, dynamic> json) => WindDownEntry(
    id: json['id'],
    date: DateTime.parse(json['date']),
    winReflection: json['winReflection'],
    tomorrowPreview: json['tomorrowPreview'],
    windDownMinutes: json['windDownMinutes'] ?? 0,
  );
}