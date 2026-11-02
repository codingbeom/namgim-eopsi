// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $IngredientsTable extends Ingredients
    with TableInfo<$IngredientsTable, IngredientRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  late final GeneratedColumnWithTypeConverter<StorageLocation, int>
  storageLocation = GeneratedColumn<int>(
    'storage_location',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  ).withConverter<StorageLocation>($IngredientsTable.$converterstorageLocation);
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
    'expiry_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isOpenedMeta = const VerificationMeta(
    'isOpened',
  );
  @override
  late final GeneratedColumn<bool> isOpened = GeneratedColumn<bool>(
    'is_opened',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_opened" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<IngredientStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<IngredientStatus>($IngredientsTable.$converterstatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    quantity,
    storageLocation,
    expiryDate,
    isOpened,
    openedAt,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<IngredientRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_expiryDateMeta);
    }
    if (data.containsKey('is_opened')) {
      context.handle(
        _isOpenedMeta,
        isOpened.isAcceptableOrUnknown(data['is_opened']!, _isOpenedMeta),
      );
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IngredientRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IngredientRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      storageLocation: $IngredientsTable.$converterstorageLocation.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}storage_location'],
        )!,
      ),
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry_date'],
      )!,
      isOpened: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_opened'],
      )!,
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_at'],
      ),
      status: $IngredientsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $IngredientsTable createAlias(String alias) {
    return $IngredientsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<StorageLocation, int, int>
  $converterstorageLocation = const EnumIndexConverter<StorageLocation>(
    StorageLocation.values,
  );
  static JsonTypeConverter2<IngredientStatus, int, int> $converterstatus =
      const EnumIndexConverter<IngredientStatus>(IngredientStatus.values);
}

class IngredientRow extends DataClass implements Insertable<IngredientRow> {
  final int id;
  final String name;
  final double quantity;
  final StorageLocation storageLocation;
  final DateTime expiryDate;
  final bool isOpened;
  final DateTime? openedAt;
  final IngredientStatus status;
  final DateTime createdAt;
  const IngredientRow({
    required this.id,
    required this.name,
    required this.quantity,
    required this.storageLocation,
    required this.expiryDate,
    required this.isOpened,
    this.openedAt,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['quantity'] = Variable<double>(quantity);
    {
      map['storage_location'] = Variable<int>(
        $IngredientsTable.$converterstorageLocation.toSql(storageLocation),
      );
    }
    map['expiry_date'] = Variable<DateTime>(expiryDate);
    map['is_opened'] = Variable<bool>(isOpened);
    if (!nullToAbsent || openedAt != null) {
      map['opened_at'] = Variable<DateTime>(openedAt);
    }
    {
      map['status'] = Variable<int>(
        $IngredientsTable.$converterstatus.toSql(status),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  IngredientsCompanion toCompanion(bool nullToAbsent) {
    return IngredientsCompanion(
      id: Value(id),
      name: Value(name),
      quantity: Value(quantity),
      storageLocation: Value(storageLocation),
      expiryDate: Value(expiryDate),
      isOpened: Value(isOpened),
      openedAt: openedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(openedAt),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory IngredientRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IngredientRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<double>(json['quantity']),
      storageLocation: $IngredientsTable.$converterstorageLocation.fromJson(
        serializer.fromJson<int>(json['storageLocation']),
      ),
      expiryDate: serializer.fromJson<DateTime>(json['expiryDate']),
      isOpened: serializer.fromJson<bool>(json['isOpened']),
      openedAt: serializer.fromJson<DateTime?>(json['openedAt']),
      status: $IngredientsTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<double>(quantity),
      'storageLocation': serializer.toJson<int>(
        $IngredientsTable.$converterstorageLocation.toJson(storageLocation),
      ),
      'expiryDate': serializer.toJson<DateTime>(expiryDate),
      'isOpened': serializer.toJson<bool>(isOpened),
      'openedAt': serializer.toJson<DateTime?>(openedAt),
      'status': serializer.toJson<int>(
        $IngredientsTable.$converterstatus.toJson(status),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  IngredientRow copyWith({
    int? id,
    String? name,
    double? quantity,
    StorageLocation? storageLocation,
    DateTime? expiryDate,
    bool? isOpened,
    Value<DateTime?> openedAt = const Value.absent(),
    IngredientStatus? status,
    DateTime? createdAt,
  }) => IngredientRow(
    id: id ?? this.id,
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    storageLocation: storageLocation ?? this.storageLocation,
    expiryDate: expiryDate ?? this.expiryDate,
    isOpened: isOpened ?? this.isOpened,
    openedAt: openedAt.present ? openedAt.value : this.openedAt,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  IngredientRow copyWithCompanion(IngredientsCompanion data) {
    return IngredientRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      storageLocation: data.storageLocation.present
          ? data.storageLocation.value
          : this.storageLocation,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      isOpened: data.isOpened.present ? data.isOpened.value : this.isOpened,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IngredientRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('storageLocation: $storageLocation, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('isOpened: $isOpened, ')
          ..write('openedAt: $openedAt, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    quantity,
    storageLocation,
    expiryDate,
    isOpened,
    openedAt,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IngredientRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.storageLocation == this.storageLocation &&
          other.expiryDate == this.expiryDate &&
          other.isOpened == this.isOpened &&
          other.openedAt == this.openedAt &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class IngredientsCompanion extends UpdateCompanion<IngredientRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> quantity;
  final Value<StorageLocation> storageLocation;
  final Value<DateTime> expiryDate;
  final Value<bool> isOpened;
  final Value<DateTime?> openedAt;
  final Value<IngredientStatus> status;
  final Value<DateTime> createdAt;
  const IngredientsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.storageLocation = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.isOpened = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  IngredientsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.quantity = const Value.absent(),
    required StorageLocation storageLocation,
    required DateTime expiryDate,
    this.isOpened = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       storageLocation = Value(storageLocation),
       expiryDate = Value(expiryDate);
  static Insertable<IngredientRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? quantity,
    Expression<int>? storageLocation,
    Expression<DateTime>? expiryDate,
    Expression<bool>? isOpened,
    Expression<DateTime>? openedAt,
    Expression<int>? status,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (storageLocation != null) 'storage_location': storageLocation,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (isOpened != null) 'is_opened': isOpened,
      if (openedAt != null) 'opened_at': openedAt,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  IngredientsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? quantity,
    Value<StorageLocation>? storageLocation,
    Value<DateTime>? expiryDate,
    Value<bool>? isOpened,
    Value<DateTime?>? openedAt,
    Value<IngredientStatus>? status,
    Value<DateTime>? createdAt,
  }) {
    return IngredientsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      storageLocation: storageLocation ?? this.storageLocation,
      expiryDate: expiryDate ?? this.expiryDate,
      isOpened: isOpened ?? this.isOpened,
      openedAt: openedAt ?? this.openedAt,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (storageLocation.present) {
      map['storage_location'] = Variable<int>(
        $IngredientsTable.$converterstorageLocation.toSql(
          storageLocation.value,
        ),
      );
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (isOpened.present) {
      map['is_opened'] = Variable<bool>(isOpened.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $IngredientsTable.$converterstatus.toSql(status.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('storageLocation: $storageLocation, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('isOpened: $isOpened, ')
          ..write('openedAt: $openedAt, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTable extends Favorites
    with TableInfo<$FavoritesTable, FavoriteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<StorageLocation, int>
  defaultStorageLocation =
      GeneratedColumn<int>(
        'default_storage_location',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<StorageLocation>(
        $FavoritesTable.$converterdefaultStorageLocation,
      );
  static const VerificationMeta _defaultShelfDaysMeta = const VerificationMeta(
    'defaultShelfDays',
  );
  @override
  late final GeneratedColumn<int> defaultShelfDays = GeneratedColumn<int>(
    'default_shelf_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    defaultStorageLocation,
    defaultShelfDays,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('default_shelf_days')) {
      context.handle(
        _defaultShelfDaysMeta,
        defaultShelfDays.isAcceptableOrUnknown(
          data['default_shelf_days']!,
          _defaultShelfDaysMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FavoriteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      defaultStorageLocation: $FavoritesTable.$converterdefaultStorageLocation
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.int,
              data['${effectivePrefix}default_storage_location'],
            )!,
          ),
      defaultShelfDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_shelf_days'],
      ),
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<StorageLocation, int, int>
  $converterdefaultStorageLocation = const EnumIndexConverter<StorageLocation>(
    StorageLocation.values,
  );
}

class FavoriteRow extends DataClass implements Insertable<FavoriteRow> {
  final int id;
  final String name;
  final StorageLocation defaultStorageLocation;
  final int? defaultShelfDays;
  const FavoriteRow({
    required this.id,
    required this.name,
    required this.defaultStorageLocation,
    this.defaultShelfDays,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['default_storage_location'] = Variable<int>(
        $FavoritesTable.$converterdefaultStorageLocation.toSql(
          defaultStorageLocation,
        ),
      );
    }
    if (!nullToAbsent || defaultShelfDays != null) {
      map['default_shelf_days'] = Variable<int>(defaultShelfDays);
    }
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(
      id: Value(id),
      name: Value(name),
      defaultStorageLocation: Value(defaultStorageLocation),
      defaultShelfDays: defaultShelfDays == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultShelfDays),
    );
  }

  factory FavoriteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      defaultStorageLocation: $FavoritesTable.$converterdefaultStorageLocation
          .fromJson(serializer.fromJson<int>(json['defaultStorageLocation'])),
      defaultShelfDays: serializer.fromJson<int?>(json['defaultShelfDays']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'defaultStorageLocation': serializer.toJson<int>(
        $FavoritesTable.$converterdefaultStorageLocation.toJson(
          defaultStorageLocation,
        ),
      ),
      'defaultShelfDays': serializer.toJson<int?>(defaultShelfDays),
    };
  }

  FavoriteRow copyWith({
    int? id,
    String? name,
    StorageLocation? defaultStorageLocation,
    Value<int?> defaultShelfDays = const Value.absent(),
  }) => FavoriteRow(
    id: id ?? this.id,
    name: name ?? this.name,
    defaultStorageLocation:
        defaultStorageLocation ?? this.defaultStorageLocation,
    defaultShelfDays: defaultShelfDays.present
        ? defaultShelfDays.value
        : this.defaultShelfDays,
  );
  FavoriteRow copyWithCompanion(FavoritesCompanion data) {
    return FavoriteRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      defaultStorageLocation: data.defaultStorageLocation.present
          ? data.defaultStorageLocation.value
          : this.defaultStorageLocation,
      defaultShelfDays: data.defaultShelfDays.present
          ? data.defaultShelfDays.value
          : this.defaultShelfDays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('defaultStorageLocation: $defaultStorageLocation, ')
          ..write('defaultShelfDays: $defaultShelfDays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, defaultStorageLocation, defaultShelfDays);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.defaultStorageLocation == this.defaultStorageLocation &&
          other.defaultShelfDays == this.defaultShelfDays);
}

class FavoritesCompanion extends UpdateCompanion<FavoriteRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<StorageLocation> defaultStorageLocation;
  final Value<int?> defaultShelfDays;
  const FavoritesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.defaultStorageLocation = const Value.absent(),
    this.defaultShelfDays = const Value.absent(),
  });
  FavoritesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required StorageLocation defaultStorageLocation,
    this.defaultShelfDays = const Value.absent(),
  }) : name = Value(name),
       defaultStorageLocation = Value(defaultStorageLocation);
  static Insertable<FavoriteRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? defaultStorageLocation,
    Expression<int>? defaultShelfDays,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (defaultStorageLocation != null)
        'default_storage_location': defaultStorageLocation,
      if (defaultShelfDays != null) 'default_shelf_days': defaultShelfDays,
    });
  }

  FavoritesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<StorageLocation>? defaultStorageLocation,
    Value<int?>? defaultShelfDays,
  }) {
    return FavoritesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultStorageLocation:
          defaultStorageLocation ?? this.defaultStorageLocation,
      defaultShelfDays: defaultShelfDays ?? this.defaultShelfDays,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (defaultStorageLocation.present) {
      map['default_storage_location'] = Variable<int>(
        $FavoritesTable.$converterdefaultStorageLocation.toSql(
          defaultStorageLocation.value,
        ),
      );
    }
    if (defaultShelfDays.present) {
      map['default_shelf_days'] = Variable<int>(defaultShelfDays.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('defaultStorageLocation: $defaultStorageLocation, ')
          ..write('defaultShelfDays: $defaultShelfDays')
          ..write(')'))
        .toString();
  }
}

class $ShelfLifeDefaultsTable extends ShelfLifeDefaults
    with TableInfo<$ShelfLifeDefaultsTable, ShelfLifeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShelfLifeDefaultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameKeywordMeta = const VerificationMeta(
    'nameKeyword',
  );
  @override
  late final GeneratedColumn<String> nameKeyword = GeneratedColumn<String>(
    'name_keyword',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<StorageLocation, int>
  storageLocation =
      GeneratedColumn<int>(
        'storage_location',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<StorageLocation>(
        $ShelfLifeDefaultsTable.$converterstorageLocation,
      );
  static const VerificationMeta _daysMeta = const VerificationMeta('days');
  @override
  late final GeneratedColumn<int> days = GeneratedColumn<int>(
    'days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openedDaysMeta = const VerificationMeta(
    'openedDays',
  );
  @override
  late final GeneratedColumn<int> openedDays = GeneratedColumn<int>(
    'opened_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refrigerateAfterOpenMeta =
      const VerificationMeta('refrigerateAfterOpen');
  @override
  late final GeneratedColumn<bool> refrigerateAfterOpen = GeneratedColumn<bool>(
    'refrigerate_after_open',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("refrigerate_after_open" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nameKeyword,
    category,
    storageLocation,
    days,
    openedDays,
    refrigerateAfterOpen,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shelf_life_defaults';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShelfLifeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name_keyword')) {
      context.handle(
        _nameKeywordMeta,
        nameKeyword.isAcceptableOrUnknown(
          data['name_keyword']!,
          _nameKeywordMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nameKeywordMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('days')) {
      context.handle(
        _daysMeta,
        days.isAcceptableOrUnknown(data['days']!, _daysMeta),
      );
    } else if (isInserting) {
      context.missing(_daysMeta);
    }
    if (data.containsKey('opened_days')) {
      context.handle(
        _openedDaysMeta,
        openedDays.isAcceptableOrUnknown(data['opened_days']!, _openedDaysMeta),
      );
    }
    if (data.containsKey('refrigerate_after_open')) {
      context.handle(
        _refrigerateAfterOpenMeta,
        refrigerateAfterOpen.isAcceptableOrUnknown(
          data['refrigerate_after_open']!,
          _refrigerateAfterOpenMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShelfLifeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShelfLifeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nameKeyword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_keyword'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      storageLocation: $ShelfLifeDefaultsTable.$converterstorageLocation
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.int,
              data['${effectivePrefix}storage_location'],
            )!,
          ),
      days: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days'],
      )!,
      openedDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opened_days'],
      ),
      refrigerateAfterOpen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}refrigerate_after_open'],
      )!,
    );
  }

  @override
  $ShelfLifeDefaultsTable createAlias(String alias) {
    return $ShelfLifeDefaultsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<StorageLocation, int, int>
  $converterstorageLocation = const EnumIndexConverter<StorageLocation>(
    StorageLocation.values,
  );
}

class ShelfLifeRow extends DataClass implements Insertable<ShelfLifeRow> {
  final int id;
  final String nameKeyword;
  final String? category;
  final StorageLocation storageLocation;
  final int days;
  final int? openedDays;
  final bool refrigerateAfterOpen;
  const ShelfLifeRow({
    required this.id,
    required this.nameKeyword,
    this.category,
    required this.storageLocation,
    required this.days,
    this.openedDays,
    required this.refrigerateAfterOpen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name_keyword'] = Variable<String>(nameKeyword);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    {
      map['storage_location'] = Variable<int>(
        $ShelfLifeDefaultsTable.$converterstorageLocation.toSql(
          storageLocation,
        ),
      );
    }
    map['days'] = Variable<int>(days);
    if (!nullToAbsent || openedDays != null) {
      map['opened_days'] = Variable<int>(openedDays);
    }
    map['refrigerate_after_open'] = Variable<bool>(refrigerateAfterOpen);
    return map;
  }

  ShelfLifeDefaultsCompanion toCompanion(bool nullToAbsent) {
    return ShelfLifeDefaultsCompanion(
      id: Value(id),
      nameKeyword: Value(nameKeyword),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      storageLocation: Value(storageLocation),
      days: Value(days),
      openedDays: openedDays == null && nullToAbsent
          ? const Value.absent()
          : Value(openedDays),
      refrigerateAfterOpen: Value(refrigerateAfterOpen),
    );
  }

  factory ShelfLifeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShelfLifeRow(
      id: serializer.fromJson<int>(json['id']),
      nameKeyword: serializer.fromJson<String>(json['nameKeyword']),
      category: serializer.fromJson<String?>(json['category']),
      storageLocation: $ShelfLifeDefaultsTable.$converterstorageLocation
          .fromJson(serializer.fromJson<int>(json['storageLocation'])),
      days: serializer.fromJson<int>(json['days']),
      openedDays: serializer.fromJson<int?>(json['openedDays']),
      refrigerateAfterOpen: serializer.fromJson<bool>(
        json['refrigerateAfterOpen'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nameKeyword': serializer.toJson<String>(nameKeyword),
      'category': serializer.toJson<String?>(category),
      'storageLocation': serializer.toJson<int>(
        $ShelfLifeDefaultsTable.$converterstorageLocation.toJson(
          storageLocation,
        ),
      ),
      'days': serializer.toJson<int>(days),
      'openedDays': serializer.toJson<int?>(openedDays),
      'refrigerateAfterOpen': serializer.toJson<bool>(refrigerateAfterOpen),
    };
  }

  ShelfLifeRow copyWith({
    int? id,
    String? nameKeyword,
    Value<String?> category = const Value.absent(),
    StorageLocation? storageLocation,
    int? days,
    Value<int?> openedDays = const Value.absent(),
    bool? refrigerateAfterOpen,
  }) => ShelfLifeRow(
    id: id ?? this.id,
    nameKeyword: nameKeyword ?? this.nameKeyword,
    category: category.present ? category.value : this.category,
    storageLocation: storageLocation ?? this.storageLocation,
    days: days ?? this.days,
    openedDays: openedDays.present ? openedDays.value : this.openedDays,
    refrigerateAfterOpen: refrigerateAfterOpen ?? this.refrigerateAfterOpen,
  );
  ShelfLifeRow copyWithCompanion(ShelfLifeDefaultsCompanion data) {
    return ShelfLifeRow(
      id: data.id.present ? data.id.value : this.id,
      nameKeyword: data.nameKeyword.present
          ? data.nameKeyword.value
          : this.nameKeyword,
      category: data.category.present ? data.category.value : this.category,
      storageLocation: data.storageLocation.present
          ? data.storageLocation.value
          : this.storageLocation,
      days: data.days.present ? data.days.value : this.days,
      openedDays: data.openedDays.present
          ? data.openedDays.value
          : this.openedDays,
      refrigerateAfterOpen: data.refrigerateAfterOpen.present
          ? data.refrigerateAfterOpen.value
          : this.refrigerateAfterOpen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShelfLifeRow(')
          ..write('id: $id, ')
          ..write('nameKeyword: $nameKeyword, ')
          ..write('category: $category, ')
          ..write('storageLocation: $storageLocation, ')
          ..write('days: $days, ')
          ..write('openedDays: $openedDays, ')
          ..write('refrigerateAfterOpen: $refrigerateAfterOpen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nameKeyword,
    category,
    storageLocation,
    days,
    openedDays,
    refrigerateAfterOpen,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShelfLifeRow &&
          other.id == this.id &&
          other.nameKeyword == this.nameKeyword &&
          other.category == this.category &&
          other.storageLocation == this.storageLocation &&
          other.days == this.days &&
          other.openedDays == this.openedDays &&
          other.refrigerateAfterOpen == this.refrigerateAfterOpen);
}

class ShelfLifeDefaultsCompanion extends UpdateCompanion<ShelfLifeRow> {
  final Value<int> id;
  final Value<String> nameKeyword;
  final Value<String?> category;
  final Value<StorageLocation> storageLocation;
  final Value<int> days;
  final Value<int?> openedDays;
  final Value<bool> refrigerateAfterOpen;
  const ShelfLifeDefaultsCompanion({
    this.id = const Value.absent(),
    this.nameKeyword = const Value.absent(),
    this.category = const Value.absent(),
    this.storageLocation = const Value.absent(),
    this.days = const Value.absent(),
    this.openedDays = const Value.absent(),
    this.refrigerateAfterOpen = const Value.absent(),
  });
  ShelfLifeDefaultsCompanion.insert({
    this.id = const Value.absent(),
    required String nameKeyword,
    this.category = const Value.absent(),
    required StorageLocation storageLocation,
    required int days,
    this.openedDays = const Value.absent(),
    this.refrigerateAfterOpen = const Value.absent(),
  }) : nameKeyword = Value(nameKeyword),
       storageLocation = Value(storageLocation),
       days = Value(days);
  static Insertable<ShelfLifeRow> custom({
    Expression<int>? id,
    Expression<String>? nameKeyword,
    Expression<String>? category,
    Expression<int>? storageLocation,
    Expression<int>? days,
    Expression<int>? openedDays,
    Expression<bool>? refrigerateAfterOpen,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nameKeyword != null) 'name_keyword': nameKeyword,
      if (category != null) 'category': category,
      if (storageLocation != null) 'storage_location': storageLocation,
      if (days != null) 'days': days,
      if (openedDays != null) 'opened_days': openedDays,
      if (refrigerateAfterOpen != null)
        'refrigerate_after_open': refrigerateAfterOpen,
    });
  }

  ShelfLifeDefaultsCompanion copyWith({
    Value<int>? id,
    Value<String>? nameKeyword,
    Value<String?>? category,
    Value<StorageLocation>? storageLocation,
    Value<int>? days,
    Value<int?>? openedDays,
    Value<bool>? refrigerateAfterOpen,
  }) {
    return ShelfLifeDefaultsCompanion(
      id: id ?? this.id,
      nameKeyword: nameKeyword ?? this.nameKeyword,
      category: category ?? this.category,
      storageLocation: storageLocation ?? this.storageLocation,
      days: days ?? this.days,
      openedDays: openedDays ?? this.openedDays,
      refrigerateAfterOpen: refrigerateAfterOpen ?? this.refrigerateAfterOpen,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nameKeyword.present) {
      map['name_keyword'] = Variable<String>(nameKeyword.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (storageLocation.present) {
      map['storage_location'] = Variable<int>(
        $ShelfLifeDefaultsTable.$converterstorageLocation.toSql(
          storageLocation.value,
        ),
      );
    }
    if (days.present) {
      map['days'] = Variable<int>(days.value);
    }
    if (openedDays.present) {
      map['opened_days'] = Variable<int>(openedDays.value);
    }
    if (refrigerateAfterOpen.present) {
      map['refrigerate_after_open'] = Variable<bool>(
        refrigerateAfterOpen.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShelfLifeDefaultsCompanion(')
          ..write('id: $id, ')
          ..write('nameKeyword: $nameKeyword, ')
          ..write('category: $category, ')
          ..write('storageLocation: $storageLocation, ')
          ..write('days: $days, ')
          ..write('openedDays: $openedDays, ')
          ..write('refrigerateAfterOpen: $refrigerateAfterOpen')
          ..write(')'))
        .toString();
  }
}

class $NotificationSettingsTable extends NotificationSettings
    with TableInfo<$NotificationSettingsTable, NotificationSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _notifyHourMeta = const VerificationMeta(
    'notifyHour',
  );
  @override
  late final GeneratedColumn<int> notifyHour = GeneratedColumn<int>(
    'notify_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(8),
  );
  static const VerificationMeta _notifyMinuteMeta = const VerificationMeta(
    'notifyMinute',
  );
  @override
  late final GeneratedColumn<int> notifyMinute = GeneratedColumn<int>(
    'notify_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fridgeLeadDaysMeta = const VerificationMeta(
    'fridgeLeadDays',
  );
  @override
  late final GeneratedColumn<int> fridgeLeadDays = GeneratedColumn<int>(
    'fridge_lead_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _fridgeOnTheDayMeta = const VerificationMeta(
    'fridgeOnTheDay',
  );
  @override
  late final GeneratedColumn<bool> fridgeOnTheDay = GeneratedColumn<bool>(
    'fridge_on_the_day',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("fridge_on_the_day" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _freezerLeadDaysMeta = const VerificationMeta(
    'freezerLeadDays',
  );
  @override
  late final GeneratedColumn<int> freezerLeadDays = GeneratedColumn<int>(
    'freezer_lead_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _freezerOnTheDayMeta = const VerificationMeta(
    'freezerOnTheDay',
  );
  @override
  late final GeneratedColumn<bool> freezerOnTheDay = GeneratedColumn<bool>(
    'freezer_on_the_day',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("freezer_on_the_day" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _pantryEarlyDaysMeta = const VerificationMeta(
    'pantryEarlyDays',
  );
  @override
  late final GeneratedColumn<int> pantryEarlyDays = GeneratedColumn<int>(
    'pantry_early_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(14),
  );
  static const VerificationMeta _pantryLateDaysMeta = const VerificationMeta(
    'pantryLateDays',
  );
  @override
  late final GeneratedColumn<int> pantryLateDays = GeneratedColumn<int>(
    'pantry_late_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    notifyHour,
    notifyMinute,
    fridgeLeadDays,
    fridgeOnTheDay,
    freezerLeadDays,
    freezerOnTheDay,
    pantryEarlyDays,
    pantryLateDays,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('notify_hour')) {
      context.handle(
        _notifyHourMeta,
        notifyHour.isAcceptableOrUnknown(data['notify_hour']!, _notifyHourMeta),
      );
    }
    if (data.containsKey('notify_minute')) {
      context.handle(
        _notifyMinuteMeta,
        notifyMinute.isAcceptableOrUnknown(
          data['notify_minute']!,
          _notifyMinuteMeta,
        ),
      );
    }
    if (data.containsKey('fridge_lead_days')) {
      context.handle(
        _fridgeLeadDaysMeta,
        fridgeLeadDays.isAcceptableOrUnknown(
          data['fridge_lead_days']!,
          _fridgeLeadDaysMeta,
        ),
      );
    }
    if (data.containsKey('fridge_on_the_day')) {
      context.handle(
        _fridgeOnTheDayMeta,
        fridgeOnTheDay.isAcceptableOrUnknown(
          data['fridge_on_the_day']!,
          _fridgeOnTheDayMeta,
        ),
      );
    }
    if (data.containsKey('freezer_lead_days')) {
      context.handle(
        _freezerLeadDaysMeta,
        freezerLeadDays.isAcceptableOrUnknown(
          data['freezer_lead_days']!,
          _freezerLeadDaysMeta,
        ),
      );
    }
    if (data.containsKey('freezer_on_the_day')) {
      context.handle(
        _freezerOnTheDayMeta,
        freezerOnTheDay.isAcceptableOrUnknown(
          data['freezer_on_the_day']!,
          _freezerOnTheDayMeta,
        ),
      );
    }
    if (data.containsKey('pantry_early_days')) {
      context.handle(
        _pantryEarlyDaysMeta,
        pantryEarlyDays.isAcceptableOrUnknown(
          data['pantry_early_days']!,
          _pantryEarlyDaysMeta,
        ),
      );
    }
    if (data.containsKey('pantry_late_days')) {
      context.handle(
        _pantryLateDaysMeta,
        pantryLateDays.isAcceptableOrUnknown(
          data['pantry_late_days']!,
          _pantryLateDaysMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationSettingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      notifyHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notify_hour'],
      )!,
      notifyMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notify_minute'],
      )!,
      fridgeLeadDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fridge_lead_days'],
      )!,
      fridgeOnTheDay: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}fridge_on_the_day'],
      )!,
      freezerLeadDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}freezer_lead_days'],
      )!,
      freezerOnTheDay: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}freezer_on_the_day'],
      )!,
      pantryEarlyDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pantry_early_days'],
      )!,
      pantryLateDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pantry_late_days'],
      )!,
    );
  }

  @override
  $NotificationSettingsTable createAlias(String alias) {
    return $NotificationSettingsTable(attachedDatabase, alias);
  }
}

class NotificationSettingRow extends DataClass
    implements Insertable<NotificationSettingRow> {
  final int id;
  final int notifyHour;
  final int notifyMinute;
  final int fridgeLeadDays;
  final bool fridgeOnTheDay;
  final int freezerLeadDays;
  final bool freezerOnTheDay;
  final int pantryEarlyDays;
  final int pantryLateDays;
  const NotificationSettingRow({
    required this.id,
    required this.notifyHour,
    required this.notifyMinute,
    required this.fridgeLeadDays,
    required this.fridgeOnTheDay,
    required this.freezerLeadDays,
    required this.freezerOnTheDay,
    required this.pantryEarlyDays,
    required this.pantryLateDays,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['notify_hour'] = Variable<int>(notifyHour);
    map['notify_minute'] = Variable<int>(notifyMinute);
    map['fridge_lead_days'] = Variable<int>(fridgeLeadDays);
    map['fridge_on_the_day'] = Variable<bool>(fridgeOnTheDay);
    map['freezer_lead_days'] = Variable<int>(freezerLeadDays);
    map['freezer_on_the_day'] = Variable<bool>(freezerOnTheDay);
    map['pantry_early_days'] = Variable<int>(pantryEarlyDays);
    map['pantry_late_days'] = Variable<int>(pantryLateDays);
    return map;
  }

  NotificationSettingsCompanion toCompanion(bool nullToAbsent) {
    return NotificationSettingsCompanion(
      id: Value(id),
      notifyHour: Value(notifyHour),
      notifyMinute: Value(notifyMinute),
      fridgeLeadDays: Value(fridgeLeadDays),
      fridgeOnTheDay: Value(fridgeOnTheDay),
      freezerLeadDays: Value(freezerLeadDays),
      freezerOnTheDay: Value(freezerOnTheDay),
      pantryEarlyDays: Value(pantryEarlyDays),
      pantryLateDays: Value(pantryLateDays),
    );
  }

  factory NotificationSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationSettingRow(
      id: serializer.fromJson<int>(json['id']),
      notifyHour: serializer.fromJson<int>(json['notifyHour']),
      notifyMinute: serializer.fromJson<int>(json['notifyMinute']),
      fridgeLeadDays: serializer.fromJson<int>(json['fridgeLeadDays']),
      fridgeOnTheDay: serializer.fromJson<bool>(json['fridgeOnTheDay']),
      freezerLeadDays: serializer.fromJson<int>(json['freezerLeadDays']),
      freezerOnTheDay: serializer.fromJson<bool>(json['freezerOnTheDay']),
      pantryEarlyDays: serializer.fromJson<int>(json['pantryEarlyDays']),
      pantryLateDays: serializer.fromJson<int>(json['pantryLateDays']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'notifyHour': serializer.toJson<int>(notifyHour),
      'notifyMinute': serializer.toJson<int>(notifyMinute),
      'fridgeLeadDays': serializer.toJson<int>(fridgeLeadDays),
      'fridgeOnTheDay': serializer.toJson<bool>(fridgeOnTheDay),
      'freezerLeadDays': serializer.toJson<int>(freezerLeadDays),
      'freezerOnTheDay': serializer.toJson<bool>(freezerOnTheDay),
      'pantryEarlyDays': serializer.toJson<int>(pantryEarlyDays),
      'pantryLateDays': serializer.toJson<int>(pantryLateDays),
    };
  }

  NotificationSettingRow copyWith({
    int? id,
    int? notifyHour,
    int? notifyMinute,
    int? fridgeLeadDays,
    bool? fridgeOnTheDay,
    int? freezerLeadDays,
    bool? freezerOnTheDay,
    int? pantryEarlyDays,
    int? pantryLateDays,
  }) => NotificationSettingRow(
    id: id ?? this.id,
    notifyHour: notifyHour ?? this.notifyHour,
    notifyMinute: notifyMinute ?? this.notifyMinute,
    fridgeLeadDays: fridgeLeadDays ?? this.fridgeLeadDays,
    fridgeOnTheDay: fridgeOnTheDay ?? this.fridgeOnTheDay,
    freezerLeadDays: freezerLeadDays ?? this.freezerLeadDays,
    freezerOnTheDay: freezerOnTheDay ?? this.freezerOnTheDay,
    pantryEarlyDays: pantryEarlyDays ?? this.pantryEarlyDays,
    pantryLateDays: pantryLateDays ?? this.pantryLateDays,
  );
  NotificationSettingRow copyWithCompanion(NotificationSettingsCompanion data) {
    return NotificationSettingRow(
      id: data.id.present ? data.id.value : this.id,
      notifyHour: data.notifyHour.present
          ? data.notifyHour.value
          : this.notifyHour,
      notifyMinute: data.notifyMinute.present
          ? data.notifyMinute.value
          : this.notifyMinute,
      fridgeLeadDays: data.fridgeLeadDays.present
          ? data.fridgeLeadDays.value
          : this.fridgeLeadDays,
      fridgeOnTheDay: data.fridgeOnTheDay.present
          ? data.fridgeOnTheDay.value
          : this.fridgeOnTheDay,
      freezerLeadDays: data.freezerLeadDays.present
          ? data.freezerLeadDays.value
          : this.freezerLeadDays,
      freezerOnTheDay: data.freezerOnTheDay.present
          ? data.freezerOnTheDay.value
          : this.freezerOnTheDay,
      pantryEarlyDays: data.pantryEarlyDays.present
          ? data.pantryEarlyDays.value
          : this.pantryEarlyDays,
      pantryLateDays: data.pantryLateDays.present
          ? data.pantryLateDays.value
          : this.pantryLateDays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationSettingRow(')
          ..write('id: $id, ')
          ..write('notifyHour: $notifyHour, ')
          ..write('notifyMinute: $notifyMinute, ')
          ..write('fridgeLeadDays: $fridgeLeadDays, ')
          ..write('fridgeOnTheDay: $fridgeOnTheDay, ')
          ..write('freezerLeadDays: $freezerLeadDays, ')
          ..write('freezerOnTheDay: $freezerOnTheDay, ')
          ..write('pantryEarlyDays: $pantryEarlyDays, ')
          ..write('pantryLateDays: $pantryLateDays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    notifyHour,
    notifyMinute,
    fridgeLeadDays,
    fridgeOnTheDay,
    freezerLeadDays,
    freezerOnTheDay,
    pantryEarlyDays,
    pantryLateDays,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationSettingRow &&
          other.id == this.id &&
          other.notifyHour == this.notifyHour &&
          other.notifyMinute == this.notifyMinute &&
          other.fridgeLeadDays == this.fridgeLeadDays &&
          other.fridgeOnTheDay == this.fridgeOnTheDay &&
          other.freezerLeadDays == this.freezerLeadDays &&
          other.freezerOnTheDay == this.freezerOnTheDay &&
          other.pantryEarlyDays == this.pantryEarlyDays &&
          other.pantryLateDays == this.pantryLateDays);
}

class NotificationSettingsCompanion
    extends UpdateCompanion<NotificationSettingRow> {
  final Value<int> id;
  final Value<int> notifyHour;
  final Value<int> notifyMinute;
  final Value<int> fridgeLeadDays;
  final Value<bool> fridgeOnTheDay;
  final Value<int> freezerLeadDays;
  final Value<bool> freezerOnTheDay;
  final Value<int> pantryEarlyDays;
  final Value<int> pantryLateDays;
  const NotificationSettingsCompanion({
    this.id = const Value.absent(),
    this.notifyHour = const Value.absent(),
    this.notifyMinute = const Value.absent(),
    this.fridgeLeadDays = const Value.absent(),
    this.fridgeOnTheDay = const Value.absent(),
    this.freezerLeadDays = const Value.absent(),
    this.freezerOnTheDay = const Value.absent(),
    this.pantryEarlyDays = const Value.absent(),
    this.pantryLateDays = const Value.absent(),
  });
  NotificationSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.notifyHour = const Value.absent(),
    this.notifyMinute = const Value.absent(),
    this.fridgeLeadDays = const Value.absent(),
    this.fridgeOnTheDay = const Value.absent(),
    this.freezerLeadDays = const Value.absent(),
    this.freezerOnTheDay = const Value.absent(),
    this.pantryEarlyDays = const Value.absent(),
    this.pantryLateDays = const Value.absent(),
  });
  static Insertable<NotificationSettingRow> custom({
    Expression<int>? id,
    Expression<int>? notifyHour,
    Expression<int>? notifyMinute,
    Expression<int>? fridgeLeadDays,
    Expression<bool>? fridgeOnTheDay,
    Expression<int>? freezerLeadDays,
    Expression<bool>? freezerOnTheDay,
    Expression<int>? pantryEarlyDays,
    Expression<int>? pantryLateDays,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (notifyHour != null) 'notify_hour': notifyHour,
      if (notifyMinute != null) 'notify_minute': notifyMinute,
      if (fridgeLeadDays != null) 'fridge_lead_days': fridgeLeadDays,
      if (fridgeOnTheDay != null) 'fridge_on_the_day': fridgeOnTheDay,
      if (freezerLeadDays != null) 'freezer_lead_days': freezerLeadDays,
      if (freezerOnTheDay != null) 'freezer_on_the_day': freezerOnTheDay,
      if (pantryEarlyDays != null) 'pantry_early_days': pantryEarlyDays,
      if (pantryLateDays != null) 'pantry_late_days': pantryLateDays,
    });
  }

  NotificationSettingsCompanion copyWith({
    Value<int>? id,
    Value<int>? notifyHour,
    Value<int>? notifyMinute,
    Value<int>? fridgeLeadDays,
    Value<bool>? fridgeOnTheDay,
    Value<int>? freezerLeadDays,
    Value<bool>? freezerOnTheDay,
    Value<int>? pantryEarlyDays,
    Value<int>? pantryLateDays,
  }) {
    return NotificationSettingsCompanion(
      id: id ?? this.id,
      notifyHour: notifyHour ?? this.notifyHour,
      notifyMinute: notifyMinute ?? this.notifyMinute,
      fridgeLeadDays: fridgeLeadDays ?? this.fridgeLeadDays,
      fridgeOnTheDay: fridgeOnTheDay ?? this.fridgeOnTheDay,
      freezerLeadDays: freezerLeadDays ?? this.freezerLeadDays,
      freezerOnTheDay: freezerOnTheDay ?? this.freezerOnTheDay,
      pantryEarlyDays: pantryEarlyDays ?? this.pantryEarlyDays,
      pantryLateDays: pantryLateDays ?? this.pantryLateDays,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (notifyHour.present) {
      map['notify_hour'] = Variable<int>(notifyHour.value);
    }
    if (notifyMinute.present) {
      map['notify_minute'] = Variable<int>(notifyMinute.value);
    }
    if (fridgeLeadDays.present) {
      map['fridge_lead_days'] = Variable<int>(fridgeLeadDays.value);
    }
    if (fridgeOnTheDay.present) {
      map['fridge_on_the_day'] = Variable<bool>(fridgeOnTheDay.value);
    }
    if (freezerLeadDays.present) {
      map['freezer_lead_days'] = Variable<int>(freezerLeadDays.value);
    }
    if (freezerOnTheDay.present) {
      map['freezer_on_the_day'] = Variable<bool>(freezerOnTheDay.value);
    }
    if (pantryEarlyDays.present) {
      map['pantry_early_days'] = Variable<int>(pantryEarlyDays.value);
    }
    if (pantryLateDays.present) {
      map['pantry_late_days'] = Variable<int>(pantryLateDays.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationSettingsCompanion(')
          ..write('id: $id, ')
          ..write('notifyHour: $notifyHour, ')
          ..write('notifyMinute: $notifyMinute, ')
          ..write('fridgeLeadDays: $fridgeLeadDays, ')
          ..write('fridgeOnTheDay: $fridgeOnTheDay, ')
          ..write('freezerLeadDays: $freezerLeadDays, ')
          ..write('freezerOnTheDay: $freezerOnTheDay, ')
          ..write('pantryEarlyDays: $pantryEarlyDays, ')
          ..write('pantryLateDays: $pantryLateDays')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $IngredientsTable ingredients = $IngredientsTable(this);
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final $ShelfLifeDefaultsTable shelfLifeDefaults =
      $ShelfLifeDefaultsTable(this);
  late final $NotificationSettingsTable notificationSettings =
      $NotificationSettingsTable(this);
  late final IngredientDao ingredientDao = IngredientDao(this as AppDatabase);
  late final FavoriteDao favoriteDao = FavoriteDao(this as AppDatabase);
  late final ShelfLifeDao shelfLifeDao = ShelfLifeDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    ingredients,
    favorites,
    shelfLifeDefaults,
    notificationSettings,
  ];
}

typedef $$IngredientsTableCreateCompanionBuilder =
    IngredientsCompanion Function({
      Value<int> id,
      required String name,
      Value<double> quantity,
      required StorageLocation storageLocation,
      required DateTime expiryDate,
      Value<bool> isOpened,
      Value<DateTime?> openedAt,
      Value<IngredientStatus> status,
      Value<DateTime> createdAt,
    });
typedef $$IngredientsTableUpdateCompanionBuilder =
    IngredientsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> quantity,
      Value<StorageLocation> storageLocation,
      Value<DateTime> expiryDate,
      Value<bool> isOpened,
      Value<DateTime?> openedAt,
      Value<IngredientStatus> status,
      Value<DateTime> createdAt,
    });

class $$IngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<StorageLocation, StorageLocation, int>
  get storageLocation => $composableBuilder(
    column: $table.storageLocation,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOpened => $composableBuilder(
    column: $table.isOpened,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<IngredientStatus, IngredientStatus, int>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get storageLocation => $composableBuilder(
    column: $table.storageLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOpened => $composableBuilder(
    column: $table.isOpened,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumnWithTypeConverter<StorageLocation, int> get storageLocation =>
      $composableBuilder(
        column: $table.storageLocation,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isOpened =>
      $composableBuilder(column: $table.isOpened, builder: (column) => column);

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<IngredientStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$IngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IngredientsTable,
          IngredientRow,
          $$IngredientsTableFilterComposer,
          $$IngredientsTableOrderingComposer,
          $$IngredientsTableAnnotationComposer,
          $$IngredientsTableCreateCompanionBuilder,
          $$IngredientsTableUpdateCompanionBuilder,
          (
            IngredientRow,
            BaseReferences<_$AppDatabase, $IngredientsTable, IngredientRow>,
          ),
          IngredientRow,
          PrefetchHooks Function()
        > {
  $$IngredientsTableTableManager(_$AppDatabase db, $IngredientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IngredientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<StorageLocation> storageLocation = const Value.absent(),
                Value<DateTime> expiryDate = const Value.absent(),
                Value<bool> isOpened = const Value.absent(),
                Value<DateTime?> openedAt = const Value.absent(),
                Value<IngredientStatus> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => IngredientsCompanion(
                id: id,
                name: name,
                quantity: quantity,
                storageLocation: storageLocation,
                expiryDate: expiryDate,
                isOpened: isOpened,
                openedAt: openedAt,
                status: status,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<double> quantity = const Value.absent(),
                required StorageLocation storageLocation,
                required DateTime expiryDate,
                Value<bool> isOpened = const Value.absent(),
                Value<DateTime?> openedAt = const Value.absent(),
                Value<IngredientStatus> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => IngredientsCompanion.insert(
                id: id,
                name: name,
                quantity: quantity,
                storageLocation: storageLocation,
                expiryDate: expiryDate,
                isOpened: isOpened,
                openedAt: openedAt,
                status: status,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IngredientsTable, IngredientRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $IngredientsTable,
                    IngredientRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IngredientsTable,
      IngredientRow,
      $$IngredientsTableFilterComposer,
      $$IngredientsTableOrderingComposer,
      $$IngredientsTableAnnotationComposer,
      $$IngredientsTableCreateCompanionBuilder,
      $$IngredientsTableUpdateCompanionBuilder,
      (
        IngredientRow,
        BaseReferences<_$AppDatabase, $IngredientsTable, IngredientRow>,
      ),
      IngredientRow,
      PrefetchHooks Function()
    >;
typedef $$FavoritesTableCreateCompanionBuilder = FavoritesCompanion Function({
  Value<int> id,
  required String name,
  required StorageLocation defaultStorageLocation,
  Value<int?> defaultShelfDays,
});
typedef $$FavoritesTableUpdateCompanionBuilder = FavoritesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<StorageLocation> defaultStorageLocation,
  Value<int?> defaultShelfDays,
});

class $$FavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<StorageLocation, StorageLocation, int>
  get defaultStorageLocation => $composableBuilder(
    column: $table.defaultStorageLocation,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get defaultShelfDays => $composableBuilder(
    column: $table.defaultShelfDays,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultStorageLocation => $composableBuilder(
    column: $table.defaultStorageLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultShelfDays => $composableBuilder(
    column: $table.defaultShelfDays,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<StorageLocation, int>
  get defaultStorageLocation => $composableBuilder(
    column: $table.defaultStorageLocation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultShelfDays => $composableBuilder(
    column: $table.defaultShelfDays,
    builder: (column) => column,
  );
}

class $$FavoritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoritesTable,
          FavoriteRow,
          $$FavoritesTableFilterComposer,
          $$FavoritesTableOrderingComposer,
          $$FavoritesTableAnnotationComposer,
          $$FavoritesTableCreateCompanionBuilder,
          $$FavoritesTableUpdateCompanionBuilder,
          (
            FavoriteRow,
            BaseReferences<_$AppDatabase, $FavoritesTable, FavoriteRow>,
          ),
          FavoriteRow,
          PrefetchHooks Function()
        > {
  $$FavoritesTableTableManager(_$AppDatabase db, $FavoritesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<StorageLocation> defaultStorageLocation =
                    const Value.absent(),
                Value<int?> defaultShelfDays = const Value.absent(),
              }) => FavoritesCompanion(
                id: id,
                name: name,
                defaultStorageLocation: defaultStorageLocation,
                defaultShelfDays: defaultShelfDays,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required StorageLocation defaultStorageLocation,
                Value<int?> defaultShelfDays = const Value.absent(),
              }) => FavoritesCompanion.insert(
                id: id,
                name: name,
                defaultStorageLocation: defaultStorageLocation,
                defaultShelfDays: defaultShelfDays,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FavoritesTable, FavoriteRow>(table),
                  BaseReferences<_$AppDatabase, $FavoritesTable, FavoriteRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoritesTable,
      FavoriteRow,
      $$FavoritesTableFilterComposer,
      $$FavoritesTableOrderingComposer,
      $$FavoritesTableAnnotationComposer,
      $$FavoritesTableCreateCompanionBuilder,
      $$FavoritesTableUpdateCompanionBuilder,
      (
        FavoriteRow,
        BaseReferences<_$AppDatabase, $FavoritesTable, FavoriteRow>,
      ),
      FavoriteRow,
      PrefetchHooks Function()
    >;
typedef $$ShelfLifeDefaultsTableCreateCompanionBuilder =
    ShelfLifeDefaultsCompanion Function({
      Value<int> id,
      required String nameKeyword,
      Value<String?> category,
      required StorageLocation storageLocation,
      required int days,
      Value<int?> openedDays,
      Value<bool> refrigerateAfterOpen,
    });
typedef $$ShelfLifeDefaultsTableUpdateCompanionBuilder =
    ShelfLifeDefaultsCompanion Function({
      Value<int> id,
      Value<String> nameKeyword,
      Value<String?> category,
      Value<StorageLocation> storageLocation,
      Value<int> days,
      Value<int?> openedDays,
      Value<bool> refrigerateAfterOpen,
    });

class $$ShelfLifeDefaultsTableFilterComposer
    extends Composer<_$AppDatabase, $ShelfLifeDefaultsTable> {
  $$ShelfLifeDefaultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameKeyword => $composableBuilder(
    column: $table.nameKeyword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<StorageLocation, StorageLocation, int>
  get storageLocation => $composableBuilder(
    column: $table.storageLocation,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get days => $composableBuilder(
    column: $table.days,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openedDays => $composableBuilder(
    column: $table.openedDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get refrigerateAfterOpen => $composableBuilder(
    column: $table.refrigerateAfterOpen,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShelfLifeDefaultsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShelfLifeDefaultsTable> {
  $$ShelfLifeDefaultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameKeyword => $composableBuilder(
    column: $table.nameKeyword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get storageLocation => $composableBuilder(
    column: $table.storageLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get days => $composableBuilder(
    column: $table.days,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openedDays => $composableBuilder(
    column: $table.openedDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get refrigerateAfterOpen => $composableBuilder(
    column: $table.refrigerateAfterOpen,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShelfLifeDefaultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShelfLifeDefaultsTable> {
  $$ShelfLifeDefaultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameKeyword => $composableBuilder(
    column: $table.nameKeyword,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumnWithTypeConverter<StorageLocation, int> get storageLocation =>
      $composableBuilder(
        column: $table.storageLocation,
        builder: (column) => column,
      );

  GeneratedColumn<int> get days =>
      $composableBuilder(column: $table.days, builder: (column) => column);

  GeneratedColumn<int> get openedDays => $composableBuilder(
    column: $table.openedDays,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get refrigerateAfterOpen => $composableBuilder(
    column: $table.refrigerateAfterOpen,
    builder: (column) => column,
  );
}

class $$ShelfLifeDefaultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShelfLifeDefaultsTable,
          ShelfLifeRow,
          $$ShelfLifeDefaultsTableFilterComposer,
          $$ShelfLifeDefaultsTableOrderingComposer,
          $$ShelfLifeDefaultsTableAnnotationComposer,
          $$ShelfLifeDefaultsTableCreateCompanionBuilder,
          $$ShelfLifeDefaultsTableUpdateCompanionBuilder,
          (
            ShelfLifeRow,
            BaseReferences<
              _$AppDatabase,
              $ShelfLifeDefaultsTable,
              ShelfLifeRow
            >,
          ),
          ShelfLifeRow,
          PrefetchHooks Function()
        > {
  $$ShelfLifeDefaultsTableTableManager(
    _$AppDatabase db,
    $ShelfLifeDefaultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShelfLifeDefaultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShelfLifeDefaultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShelfLifeDefaultsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nameKeyword = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<StorageLocation> storageLocation = const Value.absent(),
                Value<int> days = const Value.absent(),
                Value<int?> openedDays = const Value.absent(),
                Value<bool> refrigerateAfterOpen = const Value.absent(),
              }) => ShelfLifeDefaultsCompanion(
                id: id,
                nameKeyword: nameKeyword,
                category: category,
                storageLocation: storageLocation,
                days: days,
                openedDays: openedDays,
                refrigerateAfterOpen: refrigerateAfterOpen,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nameKeyword,
                Value<String?> category = const Value.absent(),
                required StorageLocation storageLocation,
                required int days,
                Value<int?> openedDays = const Value.absent(),
                Value<bool> refrigerateAfterOpen = const Value.absent(),
              }) => ShelfLifeDefaultsCompanion.insert(
                id: id,
                nameKeyword: nameKeyword,
                category: category,
                storageLocation: storageLocation,
                days: days,
                openedDays: openedDays,
                refrigerateAfterOpen: refrigerateAfterOpen,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ShelfLifeDefaultsTable, ShelfLifeRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ShelfLifeDefaultsTable,
                    ShelfLifeRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShelfLifeDefaultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShelfLifeDefaultsTable,
      ShelfLifeRow,
      $$ShelfLifeDefaultsTableFilterComposer,
      $$ShelfLifeDefaultsTableOrderingComposer,
      $$ShelfLifeDefaultsTableAnnotationComposer,
      $$ShelfLifeDefaultsTableCreateCompanionBuilder,
      $$ShelfLifeDefaultsTableUpdateCompanionBuilder,
      (
        ShelfLifeRow,
        BaseReferences<_$AppDatabase, $ShelfLifeDefaultsTable, ShelfLifeRow>,
      ),
      ShelfLifeRow,
      PrefetchHooks Function()
    >;
typedef $$NotificationSettingsTableCreateCompanionBuilder =
    NotificationSettingsCompanion Function({
      Value<int> id,
      Value<int> notifyHour,
      Value<int> notifyMinute,
      Value<int> fridgeLeadDays,
      Value<bool> fridgeOnTheDay,
      Value<int> freezerLeadDays,
      Value<bool> freezerOnTheDay,
      Value<int> pantryEarlyDays,
      Value<int> pantryLateDays,
    });
typedef $$NotificationSettingsTableUpdateCompanionBuilder =
    NotificationSettingsCompanion Function({
      Value<int> id,
      Value<int> notifyHour,
      Value<int> notifyMinute,
      Value<int> fridgeLeadDays,
      Value<bool> fridgeOnTheDay,
      Value<int> freezerLeadDays,
      Value<bool> freezerOnTheDay,
      Value<int> pantryEarlyDays,
      Value<int> pantryLateDays,
    });

class $$NotificationSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationSettingsTable> {
  $$NotificationSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notifyHour => $composableBuilder(
    column: $table.notifyHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notifyMinute => $composableBuilder(
    column: $table.notifyMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fridgeLeadDays => $composableBuilder(
    column: $table.fridgeLeadDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get fridgeOnTheDay => $composableBuilder(
    column: $table.fridgeOnTheDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get freezerLeadDays => $composableBuilder(
    column: $table.freezerLeadDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get freezerOnTheDay => $composableBuilder(
    column: $table.freezerOnTheDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pantryEarlyDays => $composableBuilder(
    column: $table.pantryEarlyDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pantryLateDays => $composableBuilder(
    column: $table.pantryLateDays,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationSettingsTable> {
  $$NotificationSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notifyHour => $composableBuilder(
    column: $table.notifyHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notifyMinute => $composableBuilder(
    column: $table.notifyMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fridgeLeadDays => $composableBuilder(
    column: $table.fridgeLeadDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get fridgeOnTheDay => $composableBuilder(
    column: $table.fridgeOnTheDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get freezerLeadDays => $composableBuilder(
    column: $table.freezerLeadDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get freezerOnTheDay => $composableBuilder(
    column: $table.freezerOnTheDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pantryEarlyDays => $composableBuilder(
    column: $table.pantryEarlyDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pantryLateDays => $composableBuilder(
    column: $table.pantryLateDays,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationSettingsTable> {
  $$NotificationSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get notifyHour => $composableBuilder(
    column: $table.notifyHour,
    builder: (column) => column,
  );

  GeneratedColumn<int> get notifyMinute => $composableBuilder(
    column: $table.notifyMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fridgeLeadDays => $composableBuilder(
    column: $table.fridgeLeadDays,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get fridgeOnTheDay => $composableBuilder(
    column: $table.fridgeOnTheDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get freezerLeadDays => $composableBuilder(
    column: $table.freezerLeadDays,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get freezerOnTheDay => $composableBuilder(
    column: $table.freezerOnTheDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pantryEarlyDays => $composableBuilder(
    column: $table.pantryEarlyDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pantryLateDays => $composableBuilder(
    column: $table.pantryLateDays,
    builder: (column) => column,
  );
}

class $$NotificationSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationSettingsTable,
          NotificationSettingRow,
          $$NotificationSettingsTableFilterComposer,
          $$NotificationSettingsTableOrderingComposer,
          $$NotificationSettingsTableAnnotationComposer,
          $$NotificationSettingsTableCreateCompanionBuilder,
          $$NotificationSettingsTableUpdateCompanionBuilder,
          (
            NotificationSettingRow,
            BaseReferences<
              _$AppDatabase,
              $NotificationSettingsTable,
              NotificationSettingRow
            >,
          ),
          NotificationSettingRow,
          PrefetchHooks Function()
        > {
  $$NotificationSettingsTableTableManager(
    _$AppDatabase db,
    $NotificationSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationSettingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NotificationSettingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> notifyHour = const Value.absent(),
                Value<int> notifyMinute = const Value.absent(),
                Value<int> fridgeLeadDays = const Value.absent(),
                Value<bool> fridgeOnTheDay = const Value.absent(),
                Value<int> freezerLeadDays = const Value.absent(),
                Value<bool> freezerOnTheDay = const Value.absent(),
                Value<int> pantryEarlyDays = const Value.absent(),
                Value<int> pantryLateDays = const Value.absent(),
              }) => NotificationSettingsCompanion(
                id: id,
                notifyHour: notifyHour,
                notifyMinute: notifyMinute,
                fridgeLeadDays: fridgeLeadDays,
                fridgeOnTheDay: fridgeOnTheDay,
                freezerLeadDays: freezerLeadDays,
                freezerOnTheDay: freezerOnTheDay,
                pantryEarlyDays: pantryEarlyDays,
                pantryLateDays: pantryLateDays,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> notifyHour = const Value.absent(),
                Value<int> notifyMinute = const Value.absent(),
                Value<int> fridgeLeadDays = const Value.absent(),
                Value<bool> fridgeOnTheDay = const Value.absent(),
                Value<int> freezerLeadDays = const Value.absent(),
                Value<bool> freezerOnTheDay = const Value.absent(),
                Value<int> pantryEarlyDays = const Value.absent(),
                Value<int> pantryLateDays = const Value.absent(),
              }) => NotificationSettingsCompanion.insert(
                id: id,
                notifyHour: notifyHour,
                notifyMinute: notifyMinute,
                fridgeLeadDays: fridgeLeadDays,
                fridgeOnTheDay: fridgeOnTheDay,
                freezerLeadDays: freezerLeadDays,
                freezerOnTheDay: freezerOnTheDay,
                pantryEarlyDays: pantryEarlyDays,
                pantryLateDays: pantryLateDays,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $NotificationSettingsTable,
                    NotificationSettingRow
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $NotificationSettingsTable,
                    NotificationSettingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationSettingsTable,
      NotificationSettingRow,
      $$NotificationSettingsTableFilterComposer,
      $$NotificationSettingsTableOrderingComposer,
      $$NotificationSettingsTableAnnotationComposer,
      $$NotificationSettingsTableCreateCompanionBuilder,
      $$NotificationSettingsTableUpdateCompanionBuilder,
      (
        NotificationSettingRow,
        BaseReferences<
          _$AppDatabase,
          $NotificationSettingsTable,
          NotificationSettingRow
        >,
      ),
      NotificationSettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$IngredientsTableTableManager get ingredients =>
      $$IngredientsTableTableManager(_db, _db.ingredients);
  $$FavoritesTableTableManager get favorites =>
      $$FavoritesTableTableManager(_db, _db.favorites);
  $$ShelfLifeDefaultsTableTableManager get shelfLifeDefaults =>
      $$ShelfLifeDefaultsTableTableManager(_db, _db.shelfLifeDefaults);
  $$NotificationSettingsTableTableManager get notificationSettings =>
      $$NotificationSettingsTableTableManager(_db, _db.notificationSettings);
}
