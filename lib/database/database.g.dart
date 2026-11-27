// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SentencesTable extends Sentences
    with TableInfo<$SentencesTable, Sentence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SentencesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sentenceMeta = const VerificationMeta(
    'sentence',
  );
  @override
  late final GeneratedColumn<String> sentence = GeneratedColumn<String>(
    'sentence',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 1000,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _translationMeta = const VerificationMeta(
    'translation',
  );
  @override
  late final GeneratedColumn<String> translation = GeneratedColumn<String>(
    'translation',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 4000,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinyinMeta = const VerificationMeta('pinyin');
  @override
  late final GeneratedColumn<String> pinyin = GeneratedColumn<String>(
    'pinyin',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 8000,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
    sentence,
    translation,
    pinyin,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sentences';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sentence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sentence')) {
      context.handle(
        _sentenceMeta,
        sentence.isAcceptableOrUnknown(data['sentence']!, _sentenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sentenceMeta);
    }
    if (data.containsKey('translation')) {
      context.handle(
        _translationMeta,
        translation.isAcceptableOrUnknown(
          data['translation']!,
          _translationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationMeta);
    }
    if (data.containsKey('pinyin')) {
      context.handle(
        _pinyinMeta,
        pinyin.isAcceptableOrUnknown(data['pinyin']!, _pinyinMeta),
      );
    } else if (isInserting) {
      context.missing(_pinyinMeta);
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
  Sentence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sentence(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sentence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sentence'],
      )!,
      translation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation'],
      )!,
      pinyin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pinyin'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SentencesTable createAlias(String alias) {
    return $SentencesTable(attachedDatabase, alias);
  }
}

class Sentence extends DataClass implements Insertable<Sentence> {
  final int id;
  final String sentence;
  final String translation;
  final String pinyin;
  final DateTime createdAt;
  const Sentence({
    required this.id,
    required this.sentence,
    required this.translation,
    required this.pinyin,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sentence'] = Variable<String>(sentence);
    map['translation'] = Variable<String>(translation);
    map['pinyin'] = Variable<String>(pinyin);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SentencesCompanion toCompanion(bool nullToAbsent) {
    return SentencesCompanion(
      id: Value(id),
      sentence: Value(sentence),
      translation: Value(translation),
      pinyin: Value(pinyin),
      createdAt: Value(createdAt),
    );
  }

  factory Sentence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sentence(
      id: serializer.fromJson<int>(json['id']),
      sentence: serializer.fromJson<String>(json['sentence']),
      translation: serializer.fromJson<String>(json['translation']),
      pinyin: serializer.fromJson<String>(json['pinyin']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sentence': serializer.toJson<String>(sentence),
      'translation': serializer.toJson<String>(translation),
      'pinyin': serializer.toJson<String>(pinyin),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Sentence copyWith({
    int? id,
    String? sentence,
    String? translation,
    String? pinyin,
    DateTime? createdAt,
  }) => Sentence(
    id: id ?? this.id,
    sentence: sentence ?? this.sentence,
    translation: translation ?? this.translation,
    pinyin: pinyin ?? this.pinyin,
    createdAt: createdAt ?? this.createdAt,
  );
  Sentence copyWithCompanion(SentencesCompanion data) {
    return Sentence(
      id: data.id.present ? data.id.value : this.id,
      sentence: data.sentence.present ? data.sentence.value : this.sentence,
      translation: data.translation.present
          ? data.translation.value
          : this.translation,
      pinyin: data.pinyin.present ? data.pinyin.value : this.pinyin,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sentence(')
          ..write('id: $id, ')
          ..write('sentence: $sentence, ')
          ..write('translation: $translation, ')
          ..write('pinyin: $pinyin, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sentence, translation, pinyin, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sentence &&
          other.id == this.id &&
          other.sentence == this.sentence &&
          other.translation == this.translation &&
          other.pinyin == this.pinyin &&
          other.createdAt == this.createdAt);
}

class SentencesCompanion extends UpdateCompanion<Sentence> {
  final Value<int> id;
  final Value<String> sentence;
  final Value<String> translation;
  final Value<String> pinyin;
  final Value<DateTime> createdAt;
  const SentencesCompanion({
    this.id = const Value.absent(),
    this.sentence = const Value.absent(),
    this.translation = const Value.absent(),
    this.pinyin = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SentencesCompanion.insert({
    this.id = const Value.absent(),
    required String sentence,
    required String translation,
    required String pinyin,
    this.createdAt = const Value.absent(),
  }) : sentence = Value(sentence),
       translation = Value(translation),
       pinyin = Value(pinyin);
  static Insertable<Sentence> custom({
    Expression<int>? id,
    Expression<String>? sentence,
    Expression<String>? translation,
    Expression<String>? pinyin,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sentence != null) 'sentence': sentence,
      if (translation != null) 'translation': translation,
      if (pinyin != null) 'pinyin': pinyin,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SentencesCompanion copyWith({
    Value<int>? id,
    Value<String>? sentence,
    Value<String>? translation,
    Value<String>? pinyin,
    Value<DateTime>? createdAt,
  }) {
    return SentencesCompanion(
      id: id ?? this.id,
      sentence: sentence ?? this.sentence,
      translation: translation ?? this.translation,
      pinyin: pinyin ?? this.pinyin,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sentence.present) {
      map['sentence'] = Variable<String>(sentence.value);
    }
    if (translation.present) {
      map['translation'] = Variable<String>(translation.value);
    }
    if (pinyin.present) {
      map['pinyin'] = Variable<String>(pinyin.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SentencesCompanion(')
          ..write('id: $id, ')
          ..write('sentence: $sentence, ')
          ..write('translation: $translation, ')
          ..write('pinyin: $pinyin, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WordsTable extends Words with TableInfo<$WordsTable, Word> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _translationMeta = const VerificationMeta(
    'translation',
  );
  @override
  late final GeneratedColumn<String> translation = GeneratedColumn<String>(
    'translation',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinyinMeta = const VerificationMeta('pinyin');
  @override
  late final GeneratedColumn<String> pinyin = GeneratedColumn<String>(
    'pinyin',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _posMeta = const VerificationMeta('pos');
  @override
  late final GeneratedColumn<String> pos = GeneratedColumn<String>(
    'pos',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<Syllable>, String>
  syllables = GeneratedColumn<String>(
    'syllables',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<Syllable>>($WordsTable.$convertersyllables);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    word,
    translation,
    pinyin,
    pos,
    syllables,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'words';
  @override
  VerificationContext validateIntegrity(
    Insertable<Word> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('translation')) {
      context.handle(
        _translationMeta,
        translation.isAcceptableOrUnknown(
          data['translation']!,
          _translationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationMeta);
    }
    if (data.containsKey('pinyin')) {
      context.handle(
        _pinyinMeta,
        pinyin.isAcceptableOrUnknown(data['pinyin']!, _pinyinMeta),
      );
    } else if (isInserting) {
      context.missing(_pinyinMeta);
    }
    if (data.containsKey('pos')) {
      context.handle(
        _posMeta,
        pos.isAcceptableOrUnknown(data['pos']!, _posMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {word, pinyin, translation},
  ];
  @override
  Word map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Word(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      translation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation'],
      )!,
      pinyin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pinyin'],
      )!,
      pos: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pos'],
      ),
      syllables: $WordsTable.$convertersyllables.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}syllables'],
        )!,
      ),
    );
  }

  @override
  $WordsTable createAlias(String alias) {
    return $WordsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<Syllable>, String> $convertersyllables =
      const SyllablesConverter();
}

class Word extends DataClass implements Insertable<Word> {
  final int id;
  final String word;
  final String translation;
  final String pinyin;
  final String? pos;

  /// SQL에서는 JSON TEXT, Dart에서는 `List<Syllable>`.
  final List<Syllable> syllables;
  const Word({
    required this.id,
    required this.word,
    required this.translation,
    required this.pinyin,
    this.pos,
    required this.syllables,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word'] = Variable<String>(word);
    map['translation'] = Variable<String>(translation);
    map['pinyin'] = Variable<String>(pinyin);
    if (!nullToAbsent || pos != null) {
      map['pos'] = Variable<String>(pos);
    }
    {
      map['syllables'] = Variable<String>(
        $WordsTable.$convertersyllables.toSql(syllables),
      );
    }
    return map;
  }

  WordsCompanion toCompanion(bool nullToAbsent) {
    return WordsCompanion(
      id: Value(id),
      word: Value(word),
      translation: Value(translation),
      pinyin: Value(pinyin),
      pos: pos == null && nullToAbsent ? const Value.absent() : Value(pos),
      syllables: Value(syllables),
    );
  }

  factory Word.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Word(
      id: serializer.fromJson<int>(json['id']),
      word: serializer.fromJson<String>(json['word']),
      translation: serializer.fromJson<String>(json['translation']),
      pinyin: serializer.fromJson<String>(json['pinyin']),
      pos: serializer.fromJson<String?>(json['pos']),
      syllables: serializer.fromJson<List<Syllable>>(json['syllables']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'word': serializer.toJson<String>(word),
      'translation': serializer.toJson<String>(translation),
      'pinyin': serializer.toJson<String>(pinyin),
      'pos': serializer.toJson<String?>(pos),
      'syllables': serializer.toJson<List<Syllable>>(syllables),
    };
  }

  Word copyWith({
    int? id,
    String? word,
    String? translation,
    String? pinyin,
    Value<String?> pos = const Value.absent(),
    List<Syllable>? syllables,
  }) => Word(
    id: id ?? this.id,
    word: word ?? this.word,
    translation: translation ?? this.translation,
    pinyin: pinyin ?? this.pinyin,
    pos: pos.present ? pos.value : this.pos,
    syllables: syllables ?? this.syllables,
  );
  Word copyWithCompanion(WordsCompanion data) {
    return Word(
      id: data.id.present ? data.id.value : this.id,
      word: data.word.present ? data.word.value : this.word,
      translation: data.translation.present
          ? data.translation.value
          : this.translation,
      pinyin: data.pinyin.present ? data.pinyin.value : this.pinyin,
      pos: data.pos.present ? data.pos.value : this.pos,
      syllables: data.syllables.present ? data.syllables.value : this.syllables,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Word(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('translation: $translation, ')
          ..write('pinyin: $pinyin, ')
          ..write('pos: $pos, ')
          ..write('syllables: $syllables')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, word, translation, pinyin, pos, syllables);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Word &&
          other.id == this.id &&
          other.word == this.word &&
          other.translation == this.translation &&
          other.pinyin == this.pinyin &&
          other.pos == this.pos &&
          other.syllables == this.syllables);
}

class WordsCompanion extends UpdateCompanion<Word> {
  final Value<int> id;
  final Value<String> word;
  final Value<String> translation;
  final Value<String> pinyin;
  final Value<String?> pos;
  final Value<List<Syllable>> syllables;
  const WordsCompanion({
    this.id = const Value.absent(),
    this.word = const Value.absent(),
    this.translation = const Value.absent(),
    this.pinyin = const Value.absent(),
    this.pos = const Value.absent(),
    this.syllables = const Value.absent(),
  });
  WordsCompanion.insert({
    this.id = const Value.absent(),
    required String word,
    required String translation,
    required String pinyin,
    this.pos = const Value.absent(),
    this.syllables = const Value.absent(),
  }) : word = Value(word),
       translation = Value(translation),
       pinyin = Value(pinyin);
  static Insertable<Word> custom({
    Expression<int>? id,
    Expression<String>? word,
    Expression<String>? translation,
    Expression<String>? pinyin,
    Expression<String>? pos,
    Expression<String>? syllables,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (word != null) 'word': word,
      if (translation != null) 'translation': translation,
      if (pinyin != null) 'pinyin': pinyin,
      if (pos != null) 'pos': pos,
      if (syllables != null) 'syllables': syllables,
    });
  }

  WordsCompanion copyWith({
    Value<int>? id,
    Value<String>? word,
    Value<String>? translation,
    Value<String>? pinyin,
    Value<String?>? pos,
    Value<List<Syllable>>? syllables,
  }) {
    return WordsCompanion(
      id: id ?? this.id,
      word: word ?? this.word,
      translation: translation ?? this.translation,
      pinyin: pinyin ?? this.pinyin,
      pos: pos ?? this.pos,
      syllables: syllables ?? this.syllables,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (translation.present) {
      map['translation'] = Variable<String>(translation.value);
    }
    if (pinyin.present) {
      map['pinyin'] = Variable<String>(pinyin.value);
    }
    if (pos.present) {
      map['pos'] = Variable<String>(pos.value);
    }
    if (syllables.present) {
      map['syllables'] = Variable<String>(
        $WordsTable.$convertersyllables.toSql(syllables.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordsCompanion(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('translation: $translation, ')
          ..write('pinyin: $pinyin, ')
          ..write('pos: $pos, ')
          ..write('syllables: $syllables')
          ..write(')'))
        .toString();
  }
}

class $SentenceWordsTable extends SentenceWords
    with TableInfo<$SentenceWordsTable, SentenceWord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SentenceWordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sentenceIdMeta = const VerificationMeta(
    'sentenceId',
  );
  @override
  late final GeneratedColumn<int> sentenceId = GeneratedColumn<int>(
    'sentence_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sentences (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id)',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [sentenceId, wordId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sentence_words';
  @override
  VerificationContext validateIntegrity(
    Insertable<SentenceWord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sentence_id')) {
      context.handle(
        _sentenceIdMeta,
        sentenceId.isAcceptableOrUnknown(data['sentence_id']!, _sentenceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sentenceIdMeta);
    }
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sentenceId, position};
  @override
  SentenceWord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SentenceWord(
      sentenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sentence_id'],
      )!,
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $SentenceWordsTable createAlias(String alias) {
    return $SentenceWordsTable(attachedDatabase, alias);
  }
}

class SentenceWord extends DataClass implements Insertable<SentenceWord> {
  final int sentenceId;
  final int wordId;

  /// 문장 안에서 단어의 위치(0부터).
  final int position;
  const SentenceWord({
    required this.sentenceId,
    required this.wordId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sentence_id'] = Variable<int>(sentenceId);
    map['word_id'] = Variable<int>(wordId);
    map['position'] = Variable<int>(position);
    return map;
  }

  SentenceWordsCompanion toCompanion(bool nullToAbsent) {
    return SentenceWordsCompanion(
      sentenceId: Value(sentenceId),
      wordId: Value(wordId),
      position: Value(position),
    );
  }

  factory SentenceWord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SentenceWord(
      sentenceId: serializer.fromJson<int>(json['sentenceId']),
      wordId: serializer.fromJson<int>(json['wordId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sentenceId': serializer.toJson<int>(sentenceId),
      'wordId': serializer.toJson<int>(wordId),
      'position': serializer.toJson<int>(position),
    };
  }

  SentenceWord copyWith({int? sentenceId, int? wordId, int? position}) =>
      SentenceWord(
        sentenceId: sentenceId ?? this.sentenceId,
        wordId: wordId ?? this.wordId,
        position: position ?? this.position,
      );
  SentenceWord copyWithCompanion(SentenceWordsCompanion data) {
    return SentenceWord(
      sentenceId: data.sentenceId.present
          ? data.sentenceId.value
          : this.sentenceId,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SentenceWord(')
          ..write('sentenceId: $sentenceId, ')
          ..write('wordId: $wordId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sentenceId, wordId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SentenceWord &&
          other.sentenceId == this.sentenceId &&
          other.wordId == this.wordId &&
          other.position == this.position);
}

class SentenceWordsCompanion extends UpdateCompanion<SentenceWord> {
  final Value<int> sentenceId;
  final Value<int> wordId;
  final Value<int> position;
  final Value<int> rowid;
  const SentenceWordsCompanion({
    this.sentenceId = const Value.absent(),
    this.wordId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SentenceWordsCompanion.insert({
    required int sentenceId,
    required int wordId,
    required int position,
    this.rowid = const Value.absent(),
  }) : sentenceId = Value(sentenceId),
       wordId = Value(wordId),
       position = Value(position);
  static Insertable<SentenceWord> custom({
    Expression<int>? sentenceId,
    Expression<int>? wordId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sentenceId != null) 'sentence_id': sentenceId,
      if (wordId != null) 'word_id': wordId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SentenceWordsCompanion copyWith({
    Value<int>? sentenceId,
    Value<int>? wordId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return SentenceWordsCompanion(
      sentenceId: sentenceId ?? this.sentenceId,
      wordId: wordId ?? this.wordId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sentenceId.present) {
      map['sentence_id'] = Variable<int>(sentenceId.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SentenceWordsCompanion(')
          ..write('sentenceId: $sentenceId, ')
          ..write('wordId: $wordId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedWordsTable extends SavedWords
    with TableInfo<$SavedWordsTable, SavedWord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedWordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id)',
    ),
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _srsLevelMeta = const VerificationMeta(
    'srsLevel',
  );
  @override
  late final GeneratedColumn<int> srsLevel = GeneratedColumn<int>(
    'srs_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextReviewAtMeta = const VerificationMeta(
    'nextReviewAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextReviewAt = GeneratedColumn<DateTime>(
    'next_review_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastReviewedAtMeta = const VerificationMeta(
    'lastReviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReviewedAt =
      GeneratedColumn<DateTime>(
        'last_reviewed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    wordId,
    savedAt,
    srsLevel,
    nextReviewAt,
    lastReviewedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_words';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedWord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    }
    if (data.containsKey('srs_level')) {
      context.handle(
        _srsLevelMeta,
        srsLevel.isAcceptableOrUnknown(data['srs_level']!, _srsLevelMeta),
      );
    }
    if (data.containsKey('next_review_at')) {
      context.handle(
        _nextReviewAtMeta,
        nextReviewAt.isAcceptableOrUnknown(
          data['next_review_at']!,
          _nextReviewAtMeta,
        ),
      );
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
        _lastReviewedAtMeta,
        lastReviewedAt.isAcceptableOrUnknown(
          data['last_reviewed_at']!,
          _lastReviewedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {wordId};
  @override
  SavedWord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedWord(
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_id'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
      srsLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}srs_level'],
      )!,
      nextReviewAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_review_at'],
      ),
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed_at'],
      ),
    );
  }

  @override
  $SavedWordsTable createAlias(String alias) {
    return $SavedWordsTable(attachedDatabase, alias);
  }
}

class SavedWord extends DataClass implements Insertable<SavedWord> {
  final int wordId;
  final DateTime savedAt;
  final int srsLevel;
  final DateTime? nextReviewAt;
  final DateTime? lastReviewedAt;
  const SavedWord({
    required this.wordId,
    required this.savedAt,
    required this.srsLevel,
    this.nextReviewAt,
    this.lastReviewedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['word_id'] = Variable<int>(wordId);
    map['saved_at'] = Variable<DateTime>(savedAt);
    map['srs_level'] = Variable<int>(srsLevel);
    if (!nullToAbsent || nextReviewAt != null) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt);
    }
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    return map;
  }

  SavedWordsCompanion toCompanion(bool nullToAbsent) {
    return SavedWordsCompanion(
      wordId: Value(wordId),
      savedAt: Value(savedAt),
      srsLevel: Value(srsLevel),
      nextReviewAt: nextReviewAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextReviewAt),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
    );
  }

  factory SavedWord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedWord(
      wordId: serializer.fromJson<int>(json['wordId']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
      srsLevel: serializer.fromJson<int>(json['srsLevel']),
      nextReviewAt: serializer.fromJson<DateTime?>(json['nextReviewAt']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'wordId': serializer.toJson<int>(wordId),
      'savedAt': serializer.toJson<DateTime>(savedAt),
      'srsLevel': serializer.toJson<int>(srsLevel),
      'nextReviewAt': serializer.toJson<DateTime?>(nextReviewAt),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
    };
  }

  SavedWord copyWith({
    int? wordId,
    DateTime? savedAt,
    int? srsLevel,
    Value<DateTime?> nextReviewAt = const Value.absent(),
    Value<DateTime?> lastReviewedAt = const Value.absent(),
  }) => SavedWord(
    wordId: wordId ?? this.wordId,
    savedAt: savedAt ?? this.savedAt,
    srsLevel: srsLevel ?? this.srsLevel,
    nextReviewAt: nextReviewAt.present ? nextReviewAt.value : this.nextReviewAt,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
  );
  SavedWord copyWithCompanion(SavedWordsCompanion data) {
    return SavedWord(
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
      srsLevel: data.srsLevel.present ? data.srsLevel.value : this.srsLevel,
      nextReviewAt: data.nextReviewAt.present
          ? data.nextReviewAt.value
          : this.nextReviewAt,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedWord(')
          ..write('wordId: $wordId, ')
          ..write('savedAt: $savedAt, ')
          ..write('srsLevel: $srsLevel, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('lastReviewedAt: $lastReviewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(wordId, savedAt, srsLevel, nextReviewAt, lastReviewedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedWord &&
          other.wordId == this.wordId &&
          other.savedAt == this.savedAt &&
          other.srsLevel == this.srsLevel &&
          other.nextReviewAt == this.nextReviewAt &&
          other.lastReviewedAt == this.lastReviewedAt);
}

class SavedWordsCompanion extends UpdateCompanion<SavedWord> {
  final Value<int> wordId;
  final Value<DateTime> savedAt;
  final Value<int> srsLevel;
  final Value<DateTime?> nextReviewAt;
  final Value<DateTime?> lastReviewedAt;
  const SavedWordsCompanion({
    this.wordId = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.srsLevel = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
  });
  SavedWordsCompanion.insert({
    this.wordId = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.srsLevel = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
  });
  static Insertable<SavedWord> custom({
    Expression<int>? wordId,
    Expression<DateTime>? savedAt,
    Expression<int>? srsLevel,
    Expression<DateTime>? nextReviewAt,
    Expression<DateTime>? lastReviewedAt,
  }) {
    return RawValuesInsertable({
      if (wordId != null) 'word_id': wordId,
      if (savedAt != null) 'saved_at': savedAt,
      if (srsLevel != null) 'srs_level': srsLevel,
      if (nextReviewAt != null) 'next_review_at': nextReviewAt,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
    });
  }

  SavedWordsCompanion copyWith({
    Value<int>? wordId,
    Value<DateTime>? savedAt,
    Value<int>? srsLevel,
    Value<DateTime?>? nextReviewAt,
    Value<DateTime?>? lastReviewedAt,
  }) {
    return SavedWordsCompanion(
      wordId: wordId ?? this.wordId,
      savedAt: savedAt ?? this.savedAt,
      srsLevel: srsLevel ?? this.srsLevel,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    if (srsLevel.present) {
      map['srs_level'] = Variable<int>(srsLevel.value);
    }
    if (nextReviewAt.present) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedWordsCompanion(')
          ..write('wordId: $wordId, ')
          ..write('savedAt: $savedAt, ')
          ..write('srsLevel: $srsLevel, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('lastReviewedAt: $lastReviewedAt')
          ..write(')'))
        .toString();
  }
}

class $SavedSentencesTable extends SavedSentences
    with TableInfo<$SavedSentencesTable, SavedSentence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedSentencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sentenceIdMeta = const VerificationMeta(
    'sentenceId',
  );
  @override
  late final GeneratedColumn<int> sentenceId = GeneratedColumn<int>(
    'sentence_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sentences (id)',
    ),
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [sentenceId, savedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_sentences';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedSentence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sentence_id')) {
      context.handle(
        _sentenceIdMeta,
        sentenceId.isAcceptableOrUnknown(data['sentence_id']!, _sentenceIdMeta),
      );
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sentenceId};
  @override
  SavedSentence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedSentence(
      sentenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sentence_id'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
    );
  }

  @override
  $SavedSentencesTable createAlias(String alias) {
    return $SavedSentencesTable(attachedDatabase, alias);
  }
}

class SavedSentence extends DataClass implements Insertable<SavedSentence> {
  final int sentenceId;
  final DateTime savedAt;
  const SavedSentence({required this.sentenceId, required this.savedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sentence_id'] = Variable<int>(sentenceId);
    map['saved_at'] = Variable<DateTime>(savedAt);
    return map;
  }

  SavedSentencesCompanion toCompanion(bool nullToAbsent) {
    return SavedSentencesCompanion(
      sentenceId: Value(sentenceId),
      savedAt: Value(savedAt),
    );
  }

  factory SavedSentence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedSentence(
      sentenceId: serializer.fromJson<int>(json['sentenceId']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sentenceId': serializer.toJson<int>(sentenceId),
      'savedAt': serializer.toJson<DateTime>(savedAt),
    };
  }

  SavedSentence copyWith({int? sentenceId, DateTime? savedAt}) => SavedSentence(
    sentenceId: sentenceId ?? this.sentenceId,
    savedAt: savedAt ?? this.savedAt,
  );
  SavedSentence copyWithCompanion(SavedSentencesCompanion data) {
    return SavedSentence(
      sentenceId: data.sentenceId.present
          ? data.sentenceId.value
          : this.sentenceId,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedSentence(')
          ..write('sentenceId: $sentenceId, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sentenceId, savedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedSentence &&
          other.sentenceId == this.sentenceId &&
          other.savedAt == this.savedAt);
}

class SavedSentencesCompanion extends UpdateCompanion<SavedSentence> {
  final Value<int> sentenceId;
  final Value<DateTime> savedAt;
  const SavedSentencesCompanion({
    this.sentenceId = const Value.absent(),
    this.savedAt = const Value.absent(),
  });
  SavedSentencesCompanion.insert({
    this.sentenceId = const Value.absent(),
    this.savedAt = const Value.absent(),
  });
  static Insertable<SavedSentence> custom({
    Expression<int>? sentenceId,
    Expression<DateTime>? savedAt,
  }) {
    return RawValuesInsertable({
      if (sentenceId != null) 'sentence_id': sentenceId,
      if (savedAt != null) 'saved_at': savedAt,
    });
  }

  SavedSentencesCompanion copyWith({
    Value<int>? sentenceId,
    Value<DateTime>? savedAt,
  }) {
    return SavedSentencesCompanion(
      sentenceId: sentenceId ?? this.sentenceId,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sentenceId.present) {
      map['sentence_id'] = Variable<int>(sentenceId.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedSentencesCompanion(')
          ..write('sentenceId: $sentenceId, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SentencesTable sentences = $SentencesTable(this);
  late final $WordsTable words = $WordsTable(this);
  late final $SentenceWordsTable sentenceWords = $SentenceWordsTable(this);
  late final $SavedWordsTable savedWords = $SavedWordsTable(this);
  late final $SavedSentencesTable savedSentences = $SavedSentencesTable(this);
  late final Index sentencesSentenceUnique = Index(
    'sentences_sentence_unique',
    'CREATE UNIQUE INDEX sentences_sentence_unique ON sentences (sentence)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sentences,
    words,
    sentenceWords,
    savedWords,
    savedSentences,
    sentencesSentenceUnique,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sentences',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sentence_words', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SentencesTableCreateCompanionBuilder =
    SentencesCompanion Function({
      Value<int> id,
      required String sentence,
      required String translation,
      required String pinyin,
      Value<DateTime> createdAt,
    });
typedef $$SentencesTableUpdateCompanionBuilder =
    SentencesCompanion Function({
      Value<int> id,
      Value<String> sentence,
      Value<String> translation,
      Value<String> pinyin,
      Value<DateTime> createdAt,
    });

final class $$SentencesTableReferences
    extends BaseReferences<_$AppDatabase, $SentencesTable, Sentence> {
  $$SentencesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SentenceWordsTable, List<SentenceWord>>
  _sentenceWordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sentenceWords,
    aliasName: $_aliasNameGenerator(
      db.sentences.id,
      db.sentenceWords.sentenceId,
    ),
  );

  $$SentenceWordsTableProcessedTableManager get sentenceWordsRefs {
    final manager = $$SentenceWordsTableTableManager(
      $_db,
      $_db.sentenceWords,
    ).filter((f) => f.sentenceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sentenceWordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SavedSentencesTable, List<SavedSentence>>
  _savedSentencesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.savedSentences,
    aliasName: $_aliasNameGenerator(
      db.sentences.id,
      db.savedSentences.sentenceId,
    ),
  );

  $$SavedSentencesTableProcessedTableManager get savedSentencesRefs {
    final manager = $$SavedSentencesTableTableManager(
      $_db,
      $_db.savedSentences,
    ).filter((f) => f.sentenceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_savedSentencesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SentencesTableFilterComposer
    extends Composer<_$AppDatabase, $SentencesTable> {
  $$SentencesTableFilterComposer({
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

  ColumnFilters<String> get sentence => $composableBuilder(
    column: $table.sentence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinyin => $composableBuilder(
    column: $table.pinyin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sentenceWordsRefs(
    Expression<bool> Function($$SentenceWordsTableFilterComposer f) f,
  ) {
    final $$SentenceWordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sentenceWords,
      getReferencedColumn: (t) => t.sentenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentenceWordsTableFilterComposer(
            $db: $db,
            $table: $db.sentenceWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> savedSentencesRefs(
    Expression<bool> Function($$SavedSentencesTableFilterComposer f) f,
  ) {
    final $$SavedSentencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savedSentences,
      getReferencedColumn: (t) => t.sentenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedSentencesTableFilterComposer(
            $db: $db,
            $table: $db.savedSentences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SentencesTableOrderingComposer
    extends Composer<_$AppDatabase, $SentencesTable> {
  $$SentencesTableOrderingComposer({
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

  ColumnOrderings<String> get sentence => $composableBuilder(
    column: $table.sentence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinyin => $composableBuilder(
    column: $table.pinyin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SentencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SentencesTable> {
  $$SentencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sentence =>
      $composableBuilder(column: $table.sentence, builder: (column) => column);

  GeneratedColumn<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pinyin =>
      $composableBuilder(column: $table.pinyin, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> sentenceWordsRefs<T extends Object>(
    Expression<T> Function($$SentenceWordsTableAnnotationComposer a) f,
  ) {
    final $$SentenceWordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sentenceWords,
      getReferencedColumn: (t) => t.sentenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentenceWordsTableAnnotationComposer(
            $db: $db,
            $table: $db.sentenceWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> savedSentencesRefs<T extends Object>(
    Expression<T> Function($$SavedSentencesTableAnnotationComposer a) f,
  ) {
    final $$SavedSentencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savedSentences,
      getReferencedColumn: (t) => t.sentenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedSentencesTableAnnotationComposer(
            $db: $db,
            $table: $db.savedSentences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SentencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SentencesTable,
          Sentence,
          $$SentencesTableFilterComposer,
          $$SentencesTableOrderingComposer,
          $$SentencesTableAnnotationComposer,
          $$SentencesTableCreateCompanionBuilder,
          $$SentencesTableUpdateCompanionBuilder,
          (Sentence, $$SentencesTableReferences),
          Sentence,
          PrefetchHooks Function({
            bool sentenceWordsRefs,
            bool savedSentencesRefs,
          })
        > {
  $$SentencesTableTableManager(_$AppDatabase db, $SentencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SentencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SentencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SentencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sentence = const Value.absent(),
                Value<String> translation = const Value.absent(),
                Value<String> pinyin = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SentencesCompanion(
                id: id,
                sentence: sentence,
                translation: translation,
                pinyin: pinyin,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sentence,
                required String translation,
                required String pinyin,
                Value<DateTime> createdAt = const Value.absent(),
              }) => SentencesCompanion.insert(
                id: id,
                sentence: sentence,
                translation: translation,
                pinyin: pinyin,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SentencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sentenceWordsRefs = false, savedSentencesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sentenceWordsRefs) db.sentenceWords,
                    if (savedSentencesRefs) db.savedSentences,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sentenceWordsRefs)
                        await $_getPrefetchedData<
                          Sentence,
                          $SentencesTable,
                          SentenceWord
                        >(
                          currentTable: table,
                          referencedTable: $$SentencesTableReferences
                              ._sentenceWordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SentencesTableReferences(
                                db,
                                table,
                                p0,
                              ).sentenceWordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sentenceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (savedSentencesRefs)
                        await $_getPrefetchedData<
                          Sentence,
                          $SentencesTable,
                          SavedSentence
                        >(
                          currentTable: table,
                          referencedTable: $$SentencesTableReferences
                              ._savedSentencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SentencesTableReferences(
                                db,
                                table,
                                p0,
                              ).savedSentencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sentenceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SentencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SentencesTable,
      Sentence,
      $$SentencesTableFilterComposer,
      $$SentencesTableOrderingComposer,
      $$SentencesTableAnnotationComposer,
      $$SentencesTableCreateCompanionBuilder,
      $$SentencesTableUpdateCompanionBuilder,
      (Sentence, $$SentencesTableReferences),
      Sentence,
      PrefetchHooks Function({bool sentenceWordsRefs, bool savedSentencesRefs})
    >;
typedef $$WordsTableCreateCompanionBuilder =
    WordsCompanion Function({
      Value<int> id,
      required String word,
      required String translation,
      required String pinyin,
      Value<String?> pos,
      Value<List<Syllable>> syllables,
    });
typedef $$WordsTableUpdateCompanionBuilder =
    WordsCompanion Function({
      Value<int> id,
      Value<String> word,
      Value<String> translation,
      Value<String> pinyin,
      Value<String?> pos,
      Value<List<Syllable>> syllables,
    });

final class $$WordsTableReferences
    extends BaseReferences<_$AppDatabase, $WordsTable, Word> {
  $$WordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SentenceWordsTable, List<SentenceWord>>
  _sentenceWordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sentenceWords,
    aliasName: $_aliasNameGenerator(db.words.id, db.sentenceWords.wordId),
  );

  $$SentenceWordsTableProcessedTableManager get sentenceWordsRefs {
    final manager = $$SentenceWordsTableTableManager(
      $_db,
      $_db.sentenceWords,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sentenceWordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SavedWordsTable, List<SavedWord>>
  _savedWordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.savedWords,
    aliasName: $_aliasNameGenerator(db.words.id, db.savedWords.wordId),
  );

  $$SavedWordsTableProcessedTableManager get savedWordsRefs {
    final manager = $$SavedWordsTableTableManager(
      $_db,
      $_db.savedWords,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_savedWordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WordsTableFilterComposer extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableFilterComposer({
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

  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinyin => $composableBuilder(
    column: $table.pinyin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pos => $composableBuilder(
    column: $table.pos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<Syllable>, List<Syllable>, String>
  get syllables => $composableBuilder(
    column: $table.syllables,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> sentenceWordsRefs(
    Expression<bool> Function($$SentenceWordsTableFilterComposer f) f,
  ) {
    final $$SentenceWordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sentenceWords,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentenceWordsTableFilterComposer(
            $db: $db,
            $table: $db.sentenceWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> savedWordsRefs(
    Expression<bool> Function($$SavedWordsTableFilterComposer f) f,
  ) {
    final $$SavedWordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savedWords,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedWordsTableFilterComposer(
            $db: $db,
            $table: $db.savedWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableOrderingComposer({
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

  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinyin => $composableBuilder(
    column: $table.pinyin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pos => $composableBuilder(
    column: $table.pos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syllables => $composableBuilder(
    column: $table.syllables,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pinyin =>
      $composableBuilder(column: $table.pinyin, builder: (column) => column);

  GeneratedColumn<String> get pos =>
      $composableBuilder(column: $table.pos, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<Syllable>, String> get syllables =>
      $composableBuilder(column: $table.syllables, builder: (column) => column);

  Expression<T> sentenceWordsRefs<T extends Object>(
    Expression<T> Function($$SentenceWordsTableAnnotationComposer a) f,
  ) {
    final $$SentenceWordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sentenceWords,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentenceWordsTableAnnotationComposer(
            $db: $db,
            $table: $db.sentenceWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> savedWordsRefs<T extends Object>(
    Expression<T> Function($$SavedWordsTableAnnotationComposer a) f,
  ) {
    final $$SavedWordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savedWords,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedWordsTableAnnotationComposer(
            $db: $db,
            $table: $db.savedWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordsTable,
          Word,
          $$WordsTableFilterComposer,
          $$WordsTableOrderingComposer,
          $$WordsTableAnnotationComposer,
          $$WordsTableCreateCompanionBuilder,
          $$WordsTableUpdateCompanionBuilder,
          (Word, $$WordsTableReferences),
          Word,
          PrefetchHooks Function({bool sentenceWordsRefs, bool savedWordsRefs})
        > {
  $$WordsTableTableManager(_$AppDatabase db, $WordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> word = const Value.absent(),
                Value<String> translation = const Value.absent(),
                Value<String> pinyin = const Value.absent(),
                Value<String?> pos = const Value.absent(),
                Value<List<Syllable>> syllables = const Value.absent(),
              }) => WordsCompanion(
                id: id,
                word: word,
                translation: translation,
                pinyin: pinyin,
                pos: pos,
                syllables: syllables,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String word,
                required String translation,
                required String pinyin,
                Value<String?> pos = const Value.absent(),
                Value<List<Syllable>> syllables = const Value.absent(),
              }) => WordsCompanion.insert(
                id: id,
                word: word,
                translation: translation,
                pinyin: pinyin,
                pos: pos,
                syllables: syllables,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$WordsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({sentenceWordsRefs = false, savedWordsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sentenceWordsRefs) db.sentenceWords,
                    if (savedWordsRefs) db.savedWords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sentenceWordsRefs)
                        await $_getPrefetchedData<
                          Word,
                          $WordsTable,
                          SentenceWord
                        >(
                          currentTable: table,
                          referencedTable: $$WordsTableReferences
                              ._sentenceWordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordsTableReferences(
                                db,
                                table,
                                p0,
                              ).sentenceWordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (savedWordsRefs)
                        await $_getPrefetchedData<Word, $WordsTable, SavedWord>(
                          currentTable: table,
                          referencedTable: $$WordsTableReferences
                              ._savedWordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordsTableReferences(
                                db,
                                table,
                                p0,
                              ).savedWordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordsTable,
      Word,
      $$WordsTableFilterComposer,
      $$WordsTableOrderingComposer,
      $$WordsTableAnnotationComposer,
      $$WordsTableCreateCompanionBuilder,
      $$WordsTableUpdateCompanionBuilder,
      (Word, $$WordsTableReferences),
      Word,
      PrefetchHooks Function({bool sentenceWordsRefs, bool savedWordsRefs})
    >;
typedef $$SentenceWordsTableCreateCompanionBuilder =
    SentenceWordsCompanion Function({
      required int sentenceId,
      required int wordId,
      required int position,
      Value<int> rowid,
    });
typedef $$SentenceWordsTableUpdateCompanionBuilder =
    SentenceWordsCompanion Function({
      Value<int> sentenceId,
      Value<int> wordId,
      Value<int> position,
      Value<int> rowid,
    });

final class $$SentenceWordsTableReferences
    extends BaseReferences<_$AppDatabase, $SentenceWordsTable, SentenceWord> {
  $$SentenceWordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SentencesTable _sentenceIdTable(_$AppDatabase db) =>
      db.sentences.createAlias(
        $_aliasNameGenerator(db.sentenceWords.sentenceId, db.sentences.id),
      );

  $$SentencesTableProcessedTableManager get sentenceId {
    final $_column = $_itemColumn<int>('sentence_id')!;

    final manager = $$SentencesTableTableManager(
      $_db,
      $_db.sentences,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sentenceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WordsTable _wordIdTable(_$AppDatabase db) => db.words.createAlias(
    $_aliasNameGenerator(db.sentenceWords.wordId, db.words.id),
  );

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<int>('word_id')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SentenceWordsTableFilterComposer
    extends Composer<_$AppDatabase, $SentenceWordsTable> {
  $$SentenceWordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$SentencesTableFilterComposer get sentenceId {
    final $$SentencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sentenceId,
      referencedTable: $db.sentences,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentencesTableFilterComposer(
            $db: $db,
            $table: $db.sentences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SentenceWordsTableOrderingComposer
    extends Composer<_$AppDatabase, $SentenceWordsTable> {
  $$SentenceWordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$SentencesTableOrderingComposer get sentenceId {
    final $$SentencesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sentenceId,
      referencedTable: $db.sentences,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentencesTableOrderingComposer(
            $db: $db,
            $table: $db.sentences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SentenceWordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SentenceWordsTable> {
  $$SentenceWordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$SentencesTableAnnotationComposer get sentenceId {
    final $$SentencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sentenceId,
      referencedTable: $db.sentences,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentencesTableAnnotationComposer(
            $db: $db,
            $table: $db.sentences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SentenceWordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SentenceWordsTable,
          SentenceWord,
          $$SentenceWordsTableFilterComposer,
          $$SentenceWordsTableOrderingComposer,
          $$SentenceWordsTableAnnotationComposer,
          $$SentenceWordsTableCreateCompanionBuilder,
          $$SentenceWordsTableUpdateCompanionBuilder,
          (SentenceWord, $$SentenceWordsTableReferences),
          SentenceWord,
          PrefetchHooks Function({bool sentenceId, bool wordId})
        > {
  $$SentenceWordsTableTableManager(_$AppDatabase db, $SentenceWordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SentenceWordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SentenceWordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SentenceWordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> sentenceId = const Value.absent(),
                Value<int> wordId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SentenceWordsCompanion(
                sentenceId: sentenceId,
                wordId: wordId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int sentenceId,
                required int wordId,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => SentenceWordsCompanion.insert(
                sentenceId: sentenceId,
                wordId: wordId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SentenceWordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sentenceId = false, wordId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sentenceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sentenceId,
                                referencedTable: $$SentenceWordsTableReferences
                                    ._sentenceIdTable(db),
                                referencedColumn: $$SentenceWordsTableReferences
                                    ._sentenceIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (wordId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.wordId,
                                referencedTable: $$SentenceWordsTableReferences
                                    ._wordIdTable(db),
                                referencedColumn: $$SentenceWordsTableReferences
                                    ._wordIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SentenceWordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SentenceWordsTable,
      SentenceWord,
      $$SentenceWordsTableFilterComposer,
      $$SentenceWordsTableOrderingComposer,
      $$SentenceWordsTableAnnotationComposer,
      $$SentenceWordsTableCreateCompanionBuilder,
      $$SentenceWordsTableUpdateCompanionBuilder,
      (SentenceWord, $$SentenceWordsTableReferences),
      SentenceWord,
      PrefetchHooks Function({bool sentenceId, bool wordId})
    >;
typedef $$SavedWordsTableCreateCompanionBuilder =
    SavedWordsCompanion Function({
      Value<int> wordId,
      Value<DateTime> savedAt,
      Value<int> srsLevel,
      Value<DateTime?> nextReviewAt,
      Value<DateTime?> lastReviewedAt,
    });
typedef $$SavedWordsTableUpdateCompanionBuilder =
    SavedWordsCompanion Function({
      Value<int> wordId,
      Value<DateTime> savedAt,
      Value<int> srsLevel,
      Value<DateTime?> nextReviewAt,
      Value<DateTime?> lastReviewedAt,
    });

final class $$SavedWordsTableReferences
    extends BaseReferences<_$AppDatabase, $SavedWordsTable, SavedWord> {
  $$SavedWordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WordsTable _wordIdTable(_$AppDatabase db) => db.words.createAlias(
    $_aliasNameGenerator(db.savedWords.wordId, db.words.id),
  );

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<int>('word_id')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SavedWordsTableFilterComposer
    extends Composer<_$AppDatabase, $SavedWordsTable> {
  $$SavedWordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get srsLevel => $composableBuilder(
    column: $table.srsLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedWordsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedWordsTable> {
  $$SavedWordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get srsLevel => $composableBuilder(
    column: $table.srsLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedWordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedWordsTable> {
  $$SavedWordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);

  GeneratedColumn<int> get srsLevel =>
      $composableBuilder(column: $table.srsLevel, builder: (column) => column);

  GeneratedColumn<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedWordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedWordsTable,
          SavedWord,
          $$SavedWordsTableFilterComposer,
          $$SavedWordsTableOrderingComposer,
          $$SavedWordsTableAnnotationComposer,
          $$SavedWordsTableCreateCompanionBuilder,
          $$SavedWordsTableUpdateCompanionBuilder,
          (SavedWord, $$SavedWordsTableReferences),
          SavedWord,
          PrefetchHooks Function({bool wordId})
        > {
  $$SavedWordsTableTableManager(_$AppDatabase db, $SavedWordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedWordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedWordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedWordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> wordId = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
                Value<int> srsLevel = const Value.absent(),
                Value<DateTime?> nextReviewAt = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
              }) => SavedWordsCompanion(
                wordId: wordId,
                savedAt: savedAt,
                srsLevel: srsLevel,
                nextReviewAt: nextReviewAt,
                lastReviewedAt: lastReviewedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> wordId = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
                Value<int> srsLevel = const Value.absent(),
                Value<DateTime?> nextReviewAt = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
              }) => SavedWordsCompanion.insert(
                wordId: wordId,
                savedAt: savedAt,
                srsLevel: srsLevel,
                nextReviewAt: nextReviewAt,
                lastReviewedAt: lastReviewedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SavedWordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (wordId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.wordId,
                                referencedTable: $$SavedWordsTableReferences
                                    ._wordIdTable(db),
                                referencedColumn: $$SavedWordsTableReferences
                                    ._wordIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SavedWordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedWordsTable,
      SavedWord,
      $$SavedWordsTableFilterComposer,
      $$SavedWordsTableOrderingComposer,
      $$SavedWordsTableAnnotationComposer,
      $$SavedWordsTableCreateCompanionBuilder,
      $$SavedWordsTableUpdateCompanionBuilder,
      (SavedWord, $$SavedWordsTableReferences),
      SavedWord,
      PrefetchHooks Function({bool wordId})
    >;
typedef $$SavedSentencesTableCreateCompanionBuilder =
    SavedSentencesCompanion Function({
      Value<int> sentenceId,
      Value<DateTime> savedAt,
    });
typedef $$SavedSentencesTableUpdateCompanionBuilder =
    SavedSentencesCompanion Function({
      Value<int> sentenceId,
      Value<DateTime> savedAt,
    });

final class $$SavedSentencesTableReferences
    extends BaseReferences<_$AppDatabase, $SavedSentencesTable, SavedSentence> {
  $$SavedSentencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SentencesTable _sentenceIdTable(_$AppDatabase db) =>
      db.sentences.createAlias(
        $_aliasNameGenerator(db.savedSentences.sentenceId, db.sentences.id),
      );

  $$SentencesTableProcessedTableManager get sentenceId {
    final $_column = $_itemColumn<int>('sentence_id')!;

    final manager = $$SentencesTableTableManager(
      $_db,
      $_db.sentences,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sentenceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SavedSentencesTableFilterComposer
    extends Composer<_$AppDatabase, $SavedSentencesTable> {
  $$SavedSentencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SentencesTableFilterComposer get sentenceId {
    final $$SentencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sentenceId,
      referencedTable: $db.sentences,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentencesTableFilterComposer(
            $db: $db,
            $table: $db.sentences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedSentencesTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedSentencesTable> {
  $$SavedSentencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SentencesTableOrderingComposer get sentenceId {
    final $$SentencesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sentenceId,
      referencedTable: $db.sentences,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentencesTableOrderingComposer(
            $db: $db,
            $table: $db.sentences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedSentencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedSentencesTable> {
  $$SavedSentencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);

  $$SentencesTableAnnotationComposer get sentenceId {
    final $$SentencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sentenceId,
      referencedTable: $db.sentences,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentencesTableAnnotationComposer(
            $db: $db,
            $table: $db.sentences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedSentencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedSentencesTable,
          SavedSentence,
          $$SavedSentencesTableFilterComposer,
          $$SavedSentencesTableOrderingComposer,
          $$SavedSentencesTableAnnotationComposer,
          $$SavedSentencesTableCreateCompanionBuilder,
          $$SavedSentencesTableUpdateCompanionBuilder,
          (SavedSentence, $$SavedSentencesTableReferences),
          SavedSentence,
          PrefetchHooks Function({bool sentenceId})
        > {
  $$SavedSentencesTableTableManager(
    _$AppDatabase db,
    $SavedSentencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedSentencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedSentencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedSentencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> sentenceId = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
              }) => SavedSentencesCompanion(
                sentenceId: sentenceId,
                savedAt: savedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> sentenceId = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
              }) => SavedSentencesCompanion.insert(
                sentenceId: sentenceId,
                savedAt: savedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SavedSentencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sentenceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sentenceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sentenceId,
                                referencedTable: $$SavedSentencesTableReferences
                                    ._sentenceIdTable(db),
                                referencedColumn:
                                    $$SavedSentencesTableReferences
                                        ._sentenceIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SavedSentencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedSentencesTable,
      SavedSentence,
      $$SavedSentencesTableFilterComposer,
      $$SavedSentencesTableOrderingComposer,
      $$SavedSentencesTableAnnotationComposer,
      $$SavedSentencesTableCreateCompanionBuilder,
      $$SavedSentencesTableUpdateCompanionBuilder,
      (SavedSentence, $$SavedSentencesTableReferences),
      SavedSentence,
      PrefetchHooks Function({bool sentenceId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SentencesTableTableManager get sentences =>
      $$SentencesTableTableManager(_db, _db.sentences);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db, _db.words);
  $$SentenceWordsTableTableManager get sentenceWords =>
      $$SentenceWordsTableTableManager(_db, _db.sentenceWords);
  $$SavedWordsTableTableManager get savedWords =>
      $$SavedWordsTableTableManager(_db, _db.savedWords);
  $$SavedSentencesTableTableManager get savedSentences =>
      $$SavedSentencesTableTableManager(_db, _db.savedSentences);
}
