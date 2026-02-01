import '../../../data/models/task_model.dart';

/// Day-epoch key: milliseconds since epoch at midnight (UTC-like date only).
int dayEpochFromDateTime(DateTime date) {
  return DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
}

int normalizeDayEpoch(int epochMs) {
  final d = DateTime.fromMillisecondsSinceEpoch(epochMs);
  return DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
}

/// True if two time ranges [startA, endA) and [startB, endB) intersect.
/// Uses minutes-from-midnight (startMinutes, endMinutes).
bool timeRangesOverlap(int startA, int endA, int startB, int endB) {
  return startA < endB && endA > startB;
}

/// True if two tasks on the same day have overlapping time ranges.
bool tasksOverlap(TaskModel a, TaskModel b) {
  return timeRangesOverlap(
    a.startMinutes,
    a.endMinutes,
    b.startMinutes,
    b.endMinutes,
  );
}

/// True if the day has at least two tasks whose time ranges overlap.
bool dayHasOverlappingTasks(List<TaskModel> dayTasks) {
  if (dayTasks.length < 2) return false;
  for (var i = 0; i < dayTasks.length; i++) {
    for (var j = i + 1; j < dayTasks.length; j++) {
      if (tasksOverlap(dayTasks[i], dayTasks[j])) return true;
    }
  }
  return false;
}

/// Task IDs that overlap with [task] in [dayTasks] (excluding [task] itself).
Set<String> overlappingTaskIds(TaskModel task, List<TaskModel> dayTasks) {
  final ids = <String>{};
  for (final t in dayTasks) {
    if (t.id != task.id && tasksOverlap(task, t)) ids.add(t.id);
  }
  return ids;
}

/// True if [task] overlaps with any other task in [dayTasks].
bool isTaskInConflict(TaskModel task, List<TaskModel> dayTasks) {
  return overlappingTaskIds(task, dayTasks).isNotEmpty;
}

/// Partitions [dayTasks] into overlap groups. Tasks that overlap (directly or
/// transitively) are in the same group. Each inner list is sorted by startMinutes.
List<List<TaskModel>> overlapGroups(List<TaskModel> dayTasks) {
  if (dayTasks.isEmpty) return [];
  final list = List<TaskModel>.from(dayTasks)..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
  final n = list.length;
  final parent = List<int>.generate(n, (i) => i);

  int find(int i) {
    if (parent[i] != i) parent[i] = find(parent[i]);
    return parent[i];
  }

  void union(int i, int j) {
    final pi = find(i);
    final pj = find(j);
    if (pi != pj) parent[pi] = pj;
  }

  for (var i = 0; i < n; i++) {
    for (var j = i + 1; j < n; j++) {
      if (tasksOverlap(list[i], list[j])) union(i, j);
    }
  }

  final map = <int, List<TaskModel>>{};
  for (var i = 0; i < n; i++) {
    map.putIfAbsent(find(i), () => []).add(list[i]);
  }
  return map.values.toList();
}
