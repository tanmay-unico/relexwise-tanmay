import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// Tables
class Videos extends Table {
  TextColumn get videoId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get thumbnailUrl => text()();
  TextColumn get channelId => text()();
  TextColumn get channelName => text().nullable()();
  DateTimeColumn get publishedAt => dateTime()();
  IntColumn get durationSeconds => integer().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {videoId};
}

class Progress extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get videoId => text()();
  IntColumn get positionSeconds => integer().withDefault(const Constant(0))();
  RealColumn get completedPercent => real().withDefault(const Constant(0.0))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Index get userIdVideoIdIndex => unique([
        userId,
        videoId,
      ]);
}

class Favorites extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get videoId => text()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Index get userIdVideoIdIndex => unique([
        userId,
        videoId,
      ]);
}

class Notifications extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get metadata => text().nullable()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get sent => boolean().withDefault(const Constant(false))();
  DateTimeColumn get receivedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class PendingActions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get actionType => text()();
  TextColumn get payload => text()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Videos, Progress, Favorites, Notifications, PendingActions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}

