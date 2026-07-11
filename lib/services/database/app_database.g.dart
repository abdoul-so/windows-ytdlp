// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DownloadHistoryTableTable extends DownloadHistoryTable
    with TableInfo<$DownloadHistoryTableTable, DownloadHistoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _downloadedAtMeta =
      const VerificationMeta('downloadedAt');
  @override
  late final GeneratedColumn<int> downloadedAt = GeneratedColumn<int>(
      'downloaded_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('video'));
  static const VerificationMeta _formatExtMeta =
      const VerificationMeta('formatExt');
  @override
  late final GeneratedColumn<String> formatExt = GeneratedColumn<String>(
      'format_ext', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('mp4'));
  static const VerificationMeta _targetFolderMeta =
      const VerificationMeta('targetFolder');
  @override
  late final GeneratedColumn<String> targetFolder = GeneratedColumn<String>(
      'target_folder', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, url, downloadedAt, type, formatExt, targetFolder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_history_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<DownloadHistoryTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
          _downloadedAtMeta,
          downloadedAt.isAcceptableOrUnknown(
              data['downloaded_at']!, _downloadedAtMeta));
    } else if (isInserting) {
      context.missing(_downloadedAtMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('format_ext')) {
      context.handle(_formatExtMeta,
          formatExt.isAcceptableOrUnknown(data['format_ext']!, _formatExtMeta));
    }
    if (data.containsKey('target_folder')) {
      context.handle(
          _targetFolderMeta,
          targetFolder.isAcceptableOrUnknown(
              data['target_folder']!, _targetFolderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadHistoryTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadHistoryTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      downloadedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}downloaded_at'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      formatExt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}format_ext'])!,
      targetFolder: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_folder'])!,
    );
  }

  @override
  $DownloadHistoryTableTable createAlias(String alias) {
    return $DownloadHistoryTableTable(attachedDatabase, alias);
  }
}

class DownloadHistoryTableData extends DataClass
    implements Insertable<DownloadHistoryTableData> {
  final int id;
  final String title;
  final String url;
  final int downloadedAt;
  final String type;
  final String formatExt;
  final String targetFolder;
  const DownloadHistoryTableData(
      {required this.id,
      required this.title,
      required this.url,
      required this.downloadedAt,
      required this.type,
      required this.formatExt,
      required this.targetFolder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['url'] = Variable<String>(url);
    map['downloaded_at'] = Variable<int>(downloadedAt);
    map['type'] = Variable<String>(type);
    map['format_ext'] = Variable<String>(formatExt);
    map['target_folder'] = Variable<String>(targetFolder);
    return map;
  }

  DownloadHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return DownloadHistoryTableCompanion(
      id: Value(id),
      title: Value(title),
      url: Value(url),
      downloadedAt: Value(downloadedAt),
      type: Value(type),
      formatExt: Value(formatExt),
      targetFolder: Value(targetFolder),
    );
  }

  factory DownloadHistoryTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadHistoryTableData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<String>(json['url']),
      downloadedAt: serializer.fromJson<int>(json['downloadedAt']),
      type: serializer.fromJson<String>(json['type']),
      formatExt: serializer.fromJson<String>(json['formatExt']),
      targetFolder: serializer.fromJson<String>(json['targetFolder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String>(url),
      'downloadedAt': serializer.toJson<int>(downloadedAt),
      'type': serializer.toJson<String>(type),
      'formatExt': serializer.toJson<String>(formatExt),
      'targetFolder': serializer.toJson<String>(targetFolder),
    };
  }

  DownloadHistoryTableData copyWith(
          {int? id,
          String? title,
          String? url,
          int? downloadedAt,
          String? type,
          String? formatExt,
          String? targetFolder}) =>
      DownloadHistoryTableData(
        id: id ?? this.id,
        title: title ?? this.title,
        url: url ?? this.url,
        downloadedAt: downloadedAt ?? this.downloadedAt,
        type: type ?? this.type,
        formatExt: formatExt ?? this.formatExt,
        targetFolder: targetFolder ?? this.targetFolder,
      );
  DownloadHistoryTableData copyWithCompanion(
      DownloadHistoryTableCompanion data) {
    return DownloadHistoryTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
      type: data.type.present ? data.type.value : this.type,
      formatExt: data.formatExt.present ? data.formatExt.value : this.formatExt,
      targetFolder: data.targetFolder.present
          ? data.targetFolder.value
          : this.targetFolder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadHistoryTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('type: $type, ')
          ..write('formatExt: $formatExt, ')
          ..write('targetFolder: $targetFolder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, url, downloadedAt, type, formatExt, targetFolder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadHistoryTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.url == this.url &&
          other.downloadedAt == this.downloadedAt &&
          other.type == this.type &&
          other.formatExt == this.formatExt &&
          other.targetFolder == this.targetFolder);
}

class DownloadHistoryTableCompanion
    extends UpdateCompanion<DownloadHistoryTableData> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> url;
  final Value<int> downloadedAt;
  final Value<String> type;
  final Value<String> formatExt;
  final Value<String> targetFolder;
  const DownloadHistoryTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.type = const Value.absent(),
    this.formatExt = const Value.absent(),
    this.targetFolder = const Value.absent(),
  });
  DownloadHistoryTableCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String url,
    required int downloadedAt,
    this.type = const Value.absent(),
    this.formatExt = const Value.absent(),
    this.targetFolder = const Value.absent(),
  })  : title = Value(title),
        url = Value(url),
        downloadedAt = Value(downloadedAt);
  static Insertable<DownloadHistoryTableData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? url,
    Expression<int>? downloadedAt,
    Expression<String>? type,
    Expression<String>? formatExt,
    Expression<String>? targetFolder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (type != null) 'type': type,
      if (formatExt != null) 'format_ext': formatExt,
      if (targetFolder != null) 'target_folder': targetFolder,
    });
  }

  DownloadHistoryTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? url,
      Value<int>? downloadedAt,
      Value<String>? type,
      Value<String>? formatExt,
      Value<String>? targetFolder}) {
    return DownloadHistoryTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      type: type ?? this.type,
      formatExt: formatExt ?? this.formatExt,
      targetFolder: targetFolder ?? this.targetFolder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<int>(downloadedAt.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (formatExt.present) {
      map['format_ext'] = Variable<String>(formatExt.value);
    }
    if (targetFolder.present) {
      map['target_folder'] = Variable<String>(targetFolder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadHistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('type: $type, ')
          ..write('formatExt: $formatExt, ')
          ..write('targetFolder: $targetFolder')
          ..write(')'))
        .toString();
  }
}

class $MetadataCacheTableTable extends MetadataCacheTable
    with TableInfo<$MetadataCacheTableTable, MetadataCacheTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetadataCacheTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _thumbnailMeta =
      const VerificationMeta('thumbnail');
  @override
  late final GeneratedColumn<String> thumbnail = GeneratedColumn<String>(
      'thumbnail', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _formatsJsonMeta =
      const VerificationMeta('formatsJson');
  @override
  late final GeneratedColumn<String> formatsJson = GeneratedColumn<String>(
      'formats_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<int> cachedAt = GeneratedColumn<int>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [url, title, thumbnail, formatsJson, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metadata_cache_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<MetadataCacheTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('thumbnail')) {
      context.handle(_thumbnailMeta,
          thumbnail.isAcceptableOrUnknown(data['thumbnail']!, _thumbnailMeta));
    }
    if (data.containsKey('formats_json')) {
      context.handle(
          _formatsJsonMeta,
          formatsJson.isAcceptableOrUnknown(
              data['formats_json']!, _formatsJsonMeta));
    } else if (isInserting) {
      context.missing(_formatsJsonMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {url};
  @override
  MetadataCacheTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetadataCacheTableData(
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      thumbnail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail'])!,
      formatsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}formats_json'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $MetadataCacheTableTable createAlias(String alias) {
    return $MetadataCacheTableTable(attachedDatabase, alias);
  }
}

class MetadataCacheTableData extends DataClass
    implements Insertable<MetadataCacheTableData> {
  final String url;
  final String title;
  final String thumbnail;
  final String formatsJson;
  final int cachedAt;
  const MetadataCacheTableData(
      {required this.url,
      required this.title,
      required this.thumbnail,
      required this.formatsJson,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['url'] = Variable<String>(url);
    map['title'] = Variable<String>(title);
    map['thumbnail'] = Variable<String>(thumbnail);
    map['formats_json'] = Variable<String>(formatsJson);
    map['cached_at'] = Variable<int>(cachedAt);
    return map;
  }

  MetadataCacheTableCompanion toCompanion(bool nullToAbsent) {
    return MetadataCacheTableCompanion(
      url: Value(url),
      title: Value(title),
      thumbnail: Value(thumbnail),
      formatsJson: Value(formatsJson),
      cachedAt: Value(cachedAt),
    );
  }

  factory MetadataCacheTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetadataCacheTableData(
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String>(json['title']),
      thumbnail: serializer.fromJson<String>(json['thumbnail']),
      formatsJson: serializer.fromJson<String>(json['formatsJson']),
      cachedAt: serializer.fromJson<int>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String>(title),
      'thumbnail': serializer.toJson<String>(thumbnail),
      'formatsJson': serializer.toJson<String>(formatsJson),
      'cachedAt': serializer.toJson<int>(cachedAt),
    };
  }

  MetadataCacheTableData copyWith(
          {String? url,
          String? title,
          String? thumbnail,
          String? formatsJson,
          int? cachedAt}) =>
      MetadataCacheTableData(
        url: url ?? this.url,
        title: title ?? this.title,
        thumbnail: thumbnail ?? this.thumbnail,
        formatsJson: formatsJson ?? this.formatsJson,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  MetadataCacheTableData copyWithCompanion(MetadataCacheTableCompanion data) {
    return MetadataCacheTableData(
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      thumbnail: data.thumbnail.present ? data.thumbnail.value : this.thumbnail,
      formatsJson:
          data.formatsJson.present ? data.formatsJson.value : this.formatsJson,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetadataCacheTableData(')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('formatsJson: $formatsJson, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(url, title, thumbnail, formatsJson, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetadataCacheTableData &&
          other.url == this.url &&
          other.title == this.title &&
          other.thumbnail == this.thumbnail &&
          other.formatsJson == this.formatsJson &&
          other.cachedAt == this.cachedAt);
}

class MetadataCacheTableCompanion
    extends UpdateCompanion<MetadataCacheTableData> {
  final Value<String> url;
  final Value<String> title;
  final Value<String> thumbnail;
  final Value<String> formatsJson;
  final Value<int> cachedAt;
  final Value<int> rowid;
  const MetadataCacheTableCompanion({
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.thumbnail = const Value.absent(),
    this.formatsJson = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetadataCacheTableCompanion.insert({
    required String url,
    required String title,
    this.thumbnail = const Value.absent(),
    required String formatsJson,
    required int cachedAt,
    this.rowid = const Value.absent(),
  })  : url = Value(url),
        title = Value(title),
        formatsJson = Value(formatsJson),
        cachedAt = Value(cachedAt);
  static Insertable<MetadataCacheTableData> custom({
    Expression<String>? url,
    Expression<String>? title,
    Expression<String>? thumbnail,
    Expression<String>? formatsJson,
    Expression<int>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (formatsJson != null) 'formats_json': formatsJson,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetadataCacheTableCompanion copyWith(
      {Value<String>? url,
      Value<String>? title,
      Value<String>? thumbnail,
      Value<String>? formatsJson,
      Value<int>? cachedAt,
      Value<int>? rowid}) {
    return MetadataCacheTableCompanion(
      url: url ?? this.url,
      title: title ?? this.title,
      thumbnail: thumbnail ?? this.thumbnail,
      formatsJson: formatsJson ?? this.formatsJson,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (thumbnail.present) {
      map['thumbnail'] = Variable<String>(thumbnail.value);
    }
    if (formatsJson.present) {
      map['formats_json'] = Variable<String>(formatsJson.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<int>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetadataCacheTableCompanion(')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('formatsJson: $formatsJson, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DownloadHistoryTableTable downloadHistoryTable =
      $DownloadHistoryTableTable(this);
  late final $MetadataCacheTableTable metadataCacheTable =
      $MetadataCacheTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [downloadHistoryTable, metadataCacheTable];
}

typedef $$DownloadHistoryTableTableCreateCompanionBuilder
    = DownloadHistoryTableCompanion Function({
  Value<int> id,
  required String title,
  required String url,
  required int downloadedAt,
  Value<String> type,
  Value<String> formatExt,
  Value<String> targetFolder,
});
typedef $$DownloadHistoryTableTableUpdateCompanionBuilder
    = DownloadHistoryTableCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> url,
  Value<int> downloadedAt,
  Value<String> type,
  Value<String> formatExt,
  Value<String> targetFolder,
});

class $$DownloadHistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadHistoryTableTable> {
  $$DownloadHistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get formatExt => $composableBuilder(
      column: $table.formatExt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetFolder => $composableBuilder(
      column: $table.targetFolder, builder: (column) => ColumnFilters(column));
}

class $$DownloadHistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadHistoryTableTable> {
  $$DownloadHistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get formatExt => $composableBuilder(
      column: $table.formatExt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetFolder => $composableBuilder(
      column: $table.targetFolder,
      builder: (column) => ColumnOrderings(column));
}

class $$DownloadHistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadHistoryTableTable> {
  $$DownloadHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get formatExt =>
      $composableBuilder(column: $table.formatExt, builder: (column) => column);

  GeneratedColumn<String> get targetFolder => $composableBuilder(
      column: $table.targetFolder, builder: (column) => column);
}

class $$DownloadHistoryTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DownloadHistoryTableTable,
    DownloadHistoryTableData,
    $$DownloadHistoryTableTableFilterComposer,
    $$DownloadHistoryTableTableOrderingComposer,
    $$DownloadHistoryTableTableAnnotationComposer,
    $$DownloadHistoryTableTableCreateCompanionBuilder,
    $$DownloadHistoryTableTableUpdateCompanionBuilder,
    (
      DownloadHistoryTableData,
      BaseReferences<_$AppDatabase, $DownloadHistoryTableTable,
          DownloadHistoryTableData>
    ),
    DownloadHistoryTableData,
    PrefetchHooks Function()> {
  $$DownloadHistoryTableTableTableManager(
      _$AppDatabase db, $DownloadHistoryTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadHistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadHistoryTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadHistoryTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<int> downloadedAt = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> formatExt = const Value.absent(),
            Value<String> targetFolder = const Value.absent(),
          }) =>
              DownloadHistoryTableCompanion(
            id: id,
            title: title,
            url: url,
            downloadedAt: downloadedAt,
            type: type,
            formatExt: formatExt,
            targetFolder: targetFolder,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required String url,
            required int downloadedAt,
            Value<String> type = const Value.absent(),
            Value<String> formatExt = const Value.absent(),
            Value<String> targetFolder = const Value.absent(),
          }) =>
              DownloadHistoryTableCompanion.insert(
            id: id,
            title: title,
            url: url,
            downloadedAt: downloadedAt,
            type: type,
            formatExt: formatExt,
            targetFolder: targetFolder,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DownloadHistoryTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $DownloadHistoryTableTable,
        DownloadHistoryTableData,
        $$DownloadHistoryTableTableFilterComposer,
        $$DownloadHistoryTableTableOrderingComposer,
        $$DownloadHistoryTableTableAnnotationComposer,
        $$DownloadHistoryTableTableCreateCompanionBuilder,
        $$DownloadHistoryTableTableUpdateCompanionBuilder,
        (
          DownloadHistoryTableData,
          BaseReferences<_$AppDatabase, $DownloadHistoryTableTable,
              DownloadHistoryTableData>
        ),
        DownloadHistoryTableData,
        PrefetchHooks Function()>;
typedef $$MetadataCacheTableTableCreateCompanionBuilder
    = MetadataCacheTableCompanion Function({
  required String url,
  required String title,
  Value<String> thumbnail,
  required String formatsJson,
  required int cachedAt,
  Value<int> rowid,
});
typedef $$MetadataCacheTableTableUpdateCompanionBuilder
    = MetadataCacheTableCompanion Function({
  Value<String> url,
  Value<String> title,
  Value<String> thumbnail,
  Value<String> formatsJson,
  Value<int> cachedAt,
  Value<int> rowid,
});

class $$MetadataCacheTableTableFilterComposer
    extends Composer<_$AppDatabase, $MetadataCacheTableTable> {
  $$MetadataCacheTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnail => $composableBuilder(
      column: $table.thumbnail, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get formatsJson => $composableBuilder(
      column: $table.formatsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$MetadataCacheTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MetadataCacheTableTable> {
  $$MetadataCacheTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnail => $composableBuilder(
      column: $table.thumbnail, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get formatsJson => $composableBuilder(
      column: $table.formatsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$MetadataCacheTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetadataCacheTableTable> {
  $$MetadataCacheTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get thumbnail =>
      $composableBuilder(column: $table.thumbnail, builder: (column) => column);

  GeneratedColumn<String> get formatsJson => $composableBuilder(
      column: $table.formatsJson, builder: (column) => column);

  GeneratedColumn<int> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$MetadataCacheTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MetadataCacheTableTable,
    MetadataCacheTableData,
    $$MetadataCacheTableTableFilterComposer,
    $$MetadataCacheTableTableOrderingComposer,
    $$MetadataCacheTableTableAnnotationComposer,
    $$MetadataCacheTableTableCreateCompanionBuilder,
    $$MetadataCacheTableTableUpdateCompanionBuilder,
    (
      MetadataCacheTableData,
      BaseReferences<_$AppDatabase, $MetadataCacheTableTable,
          MetadataCacheTableData>
    ),
    MetadataCacheTableData,
    PrefetchHooks Function()> {
  $$MetadataCacheTableTableTableManager(
      _$AppDatabase db, $MetadataCacheTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetadataCacheTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetadataCacheTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetadataCacheTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> url = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> thumbnail = const Value.absent(),
            Value<String> formatsJson = const Value.absent(),
            Value<int> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MetadataCacheTableCompanion(
            url: url,
            title: title,
            thumbnail: thumbnail,
            formatsJson: formatsJson,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String url,
            required String title,
            Value<String> thumbnail = const Value.absent(),
            required String formatsJson,
            required int cachedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              MetadataCacheTableCompanion.insert(
            url: url,
            title: title,
            thumbnail: thumbnail,
            formatsJson: formatsJson,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MetadataCacheTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MetadataCacheTableTable,
    MetadataCacheTableData,
    $$MetadataCacheTableTableFilterComposer,
    $$MetadataCacheTableTableOrderingComposer,
    $$MetadataCacheTableTableAnnotationComposer,
    $$MetadataCacheTableTableCreateCompanionBuilder,
    $$MetadataCacheTableTableUpdateCompanionBuilder,
    (
      MetadataCacheTableData,
      BaseReferences<_$AppDatabase, $MetadataCacheTableTable,
          MetadataCacheTableData>
    ),
    MetadataCacheTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DownloadHistoryTableTableTableManager get downloadHistoryTable =>
      $$DownloadHistoryTableTableTableManager(_db, _db.downloadHistoryTable);
  $$MetadataCacheTableTableTableManager get metadataCacheTable =>
      $$MetadataCacheTableTableTableManager(_db, _db.metadataCacheTable);
}
