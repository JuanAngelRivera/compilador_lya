import 'dart:io';
import 'dart:convert';
import 'package:compilador_lya/classes/lexer.dart';

class SymbolEntry {
  final int id;
  final String lexeme;
  final String type;
  final int position;
  final int line;
  final int column;
  dynamic value;
  String? scope;
  String? dataType;
  int? memoryAddress;

  SymbolEntry({
    required this.id,
    required this.lexeme,
    required this.type,
    required this.position,
    required this.line,
    required this.column,
    this.value,
    this.scope,
    this.dataType,
    this.memoryAddress,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'lexeme': lexeme,
    'type': type,
    'position': position,
    'line': line,
    'column': column,
    'value': value?.toString(),
    'scope': scope,
    'dataType': dataType,
    'memoryAddress': memoryAddress,
  };

  factory SymbolEntry.fromJson(Map<String, dynamic> json) => SymbolEntry(
    id: json['id'],
    lexeme: json['lexeme'],
    type: json['type'],
    position: json['position'],
    line: json['line'],
    column: json['column'],
    value: json['value'],
    scope: json['scope'],
    dataType: json['dataType'],
    memoryAddress: json['memoryAddress'],
  );

  @override
  String toString() {
    return '[$id] "$lexeme" ($type) at line $line:$column';
  }
}

class SymbolTableHash {
  late String _filePath;
  final int _tableSize;
  int _lastId = 0;

  late List<SymbolEntry?> _hashTable;

  int _totalCollisions = 0;
  int _maxProbe = 0;

  double get _loadFactor => _insertedElements / _tableSize;
  int _insertedElements = 0;

  final Map<int, int> _idToOffset = {};

  String get filePath => _filePath;

  SymbolTableHash([int initialSize = 1009])
    : _tableSize = initialSize,
      _hashTable = List<SymbolEntry?>.filled(initialSize, null);

  static Future<SymbolTableHash> create([int initialSize = 1009]) async {
    final table = SymbolTableHash(initialSize);
    await table._initialize();
    return table;
  }

  Future<void> _initialize() async {
    final dir = Directory.current.path;
    _filePath = '$dir/symbol_table.json';

    print('Tabla de símbolos en: $_filePath');

    final file = File(_filePath);
    if (!file.existsSync()) {
      await file.create();
      await file.writeAsString('');
      await _loadReservedWords();
      print('Archivo creado con palabras reservadas');
    } else {
      _recoverFile();
      print('Archivo recuperado con ${_insertedElements} entradas');
    }
  }

  Future<void> _loadReservedWords() async {
    int line = 0;

    for (final word in Lexer.reserved_words) {
      await registerToken(
        lexeme: word,
        type: 'reservada',
        position: 0,
        line: line++,
        column: 0,
      );
    }

    print('${Lexer.reserved_words.length} palabras reservadas registradas');
  }

  void _recoverFile() {
    final file = File(_filePath);
    final lines = file.readAsLinesSync();

    int currentOffset = 0;

    for (final line in lines) {
      if (line.trim().isEmpty) {
        currentOffset += line.length + 1;
        continue;
      }

      try {
        final json = jsonDecode(line);
        final entry = SymbolEntry.fromJson(json);

        if (entry.id > _lastId) _lastId = entry.id;

        _idToOffset[entry.id] = currentOffset;

        _insert(entry);
        _insertedElements++;

        currentOffset += line.length + 1;
      } catch (e) {
        currentOffset += line.length + 1;
      }
    }
  }

  // Función HASH

  int _hashFunction(String lexeme, {int attempt = 0}) {
    int hash = 5381;
    for (int i = 0; i < lexeme.length; i++) {
      hash = ((hash << 5) + hash) + lexeme.codeUnitAt(i);
    }

    return (hash.abs() + attempt) % _tableSize;
    // .abs (absolute)
  }

  // Inserción

  int _insert(SymbolEntry entry) {
    int attempt = 0;
    int localCollisions = 0;

    while (attempt < _tableSize) {
      int index = _hashFunction(entry.lexeme, attempt: attempt);

      if (_hashTable[index] == null) {
        _hashTable[index] = entry;

        if (localCollisions > 0) {
          _totalCollisions++;
          if (localCollisions > _maxProbe) {
            _maxProbe = localCollisions;
          }
        }

        return index;
      } else {
        attempt++;
        localCollisions++;
      }
    }

    throw Exception('La tabla de símbolos está llena.');
  }

  // Búsqueda secuencial

  SymbolEntry? _searchWithProbing(String lexeme) {
    int attempt = 0;

    while (attempt < _tableSize) {
      int index = _hashFunction(lexeme, attempt: attempt);
      SymbolEntry? entry = _hashTable[index];

      if (entry == null) {
        return null;
      }

      if (entry.lexeme == lexeme) {
        return entry;
      }

      attempt++;
    }

    return null;
  }

  void _resizeTable() {
    int newSize = _nextPrime(_tableSize * 2);
    print('Cambio de tamaño de $_tableSize a $newSize');

    List<SymbolEntry> currentEntries = [];
    for (var entry in _hashTable) {
      if (entry != null) {
        currentEntries.add(entry);
      }
    }

    // reconstrucción de la tabla con el nuevo tamaño
    _hashTable = List<SymbolEntry?>.filled(newSize, null);
    _insertedElements = 0;
    _totalCollisions = 0;
    _maxProbe = 0;

    for (var entry in currentEntries) {
      _insert(entry);
      _insertedElements++;
    }
  }

  // obtención del siguiente número primo.

  int _nextPrime(int n) {
    if (n <= 1) return 2;
    int prime = n;
    while (true) {
      prime++;
      bool isPrime = true;
      for (int i = 2; i * i <= prime; i++) {
        if (prime % i == 0) {
          isPrime = false;
          break;
        }
      }
      if (isPrime) return prime;
    }
  }

  // escritura secuencial

  Future<void> _appendToFile(SymbolEntry entry) async {
    final file = File(_filePath);
    final currentSize = await file.length();

    _idToOffset[entry.id] = currentSize;

    await file.writeAsString(
      jsonEncode(entry.toJson()) + '\n',
      mode: FileMode.append,
    );
  }

  // regstro de tokens

  Future<SymbolEntry> registerToken({
    required String lexeme,
    required String type,
    required int position,
    required int line,
    required int column,
    dynamic value,
    String? scope,
    String? dataType,
    int? memoryAddress,
  }) async {
    _lastId++;

    if (_loadFactor > 0.75) {
      _resizeTable();
    }

    final entry = SymbolEntry(
      id: _lastId,
      lexeme: lexeme,
      type: type,
      position: position,
      line: line,
      column: column,
      value: value,
      scope: scope,
      dataType: dataType,
    );

    int index = _insert(entry);

    entry.memoryAddress = index;
    _insertedElements++;

    await _appendToFile(entry);

    print('Token "$lexeme" insertado con el indice: $index (ID: ${_lastId})');

    return entry;
  }

  // Búsqueda por lexema
  SymbolEntry? findByLexeme(String lexeme) {
    return _searchWithProbing(lexeme);
  }

  // Acceso aleatorio

  Future<SymbolEntry?> findById(int id) async {
    final offset = _idToOffset[id];
    if (offset == null) return null;

    final file = File(_filePath);
    final raf = await file.open(mode: FileMode.read);

    try {
      await raf.setPosition(offset);

      List<int> bytes = [];
      int byte;
      while (true) {
        byte = await raf.readByte();
        if (byte == 10 || byte == 13) {
          break;
        }
        bytes.add(byte);
      }

      String line = utf8.decode(bytes);
      if (line.isNotEmpty) {
        return SymbolEntry.fromJson(jsonDecode(line));
      }
    } catch (e) {
      print('Error al leer en el offset $offset: $e');
    } finally {
      await raf.close();
    }

    return null;
  }

  // Búsqueda secuencial

  Future<SymbolEntry?> findBySequential(int id) async {
    final file = File(_filePath);
    final lines = await file.readAsLines();

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      try {
        final json = jsonDecode(line);
        if (json['id'] == id) {
          return SymbolEntry.fromJson(json);
        }
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  // Verificación de existencia

  bool existsLexeme(String lexeme) {
    return _searchWithProbing(lexeme) != null;
  }

  // Obtener todos los símbolos

  List<SymbolEntry> getAll() {
    List<SymbolEntry> result = [];
    for (var entry in _hashTable) {
      if (entry != null) {
        result.add(entry);
      }
    }
    return result;
  }

  Future<List<SymbolEntry>> getAllFromFile() async {
    final file = File(_filePath);
    final lines = await file.readAsLines();
    final List<SymbolEntry> entries = [];

    for (final line in lines) {
      if (line.trim().isNotEmpty) {
        try {
          entries.add(SymbolEntry.fromJson(jsonDecode(line)));
        } catch (e) {}
      }
    }
    return entries;
  }

  //
  Map<String, dynamic> getHashStats() {
    int occupiedSlots = 0;
    int freeSlots = 0;

    for (var entry in _hashTable) {
      if (entry != null) {
        occupiedSlots++;
      } else {
        freeSlots++;
      }
    }

    return {
      'table_size': _tableSize,
      'inserted_elements': _insertedElements,
      'load_factor': _loadFactor.toStringAsFixed(4),
      'occupied_slots': occupiedSlots,
      'free_slots': freeSlots,
      'total_collisions': _totalCollisions,
      'max_probe': _maxProbe,
      'collision_rate': _insertedElements > 0
          ? (_totalCollisions / _insertedElements).toStringAsFixed(4)
          : '0',
      'last_id': _lastId,
      'indexed_offsets': _idToOffset.length,
    };
  }

  // Imprimir tabla HASH

  void printHashTable() {
    print('\n========== HASH TABLE (Linear Probing) ==========');
    print('Size: $_tableSize | Elements: $_insertedElements');
    print('Total collisions: $_totalCollisions | Max probe: $_maxProbe');
    print('Load factor: ${_loadFactor.toStringAsFixed(4)}');
    print('File: $_filePath');
    print('Indexed offsets: ${_idToOffset.length}');
    print('------------------------------------------------');

    for (int i = 0; i < _tableSize; i++) {
      if (_hashTable[i] != null) {
        print('[$i] → ${_hashTable[i]}');
      } else if (i < 20 || i > _tableSize - 5) {
        print('[$i] → [empty]');
      } else if (i == 20) {
        print('...');
      }
    }
    print('================================================\n');
  }

  // Actualizar existencia

  Future<void> updateEntry(
    String lexeme, {
    dynamic value,
    String? scope,
    String? dataType,
    int? memoryAddress,
  }) async {
    SymbolEntry? entry = _searchWithProbing(lexeme);

    if (entry == null) {
      throw Exception('Símbolo "$lexeme" no encontrado.');
    }

    if (value != null) entry.value = value;
    if (scope != null) entry.scope = scope;
    if (dataType != null) entry.dataType = dataType;
    if (memoryAddress != null) entry.memoryAddress = memoryAddress;

    final allEntries = await getAllFromFile();
    final file = File(_filePath);
    await file.writeAsString('');

    _idToOffset.clear();
    int currentOffset = 0;

    for (final e in allEntries) {
      final line = jsonEncode(e.toJson()) + '\n';

      if (e.lexeme == lexeme) {
        final newLine = jsonEncode(entry.toJson()) + '\n';
        _idToOffset[entry.id] = currentOffset;
        await file.writeAsString(newLine, mode: FileMode.append);
        currentOffset += newLine.length;
      } else {
        _idToOffset[e.id] = currentOffset;
        await file.writeAsString(line, mode: FileMode.append);
        currentOffset += line.length;
      }
    }
  }

  // Despejar tabla de símbolos (POR SI ACASO)

  Future<void> clear() async {
    final file = File(_filePath);
    await file.writeAsString('');

    _hashTable = List<SymbolEntry?>.filled(_tableSize, null);
    _lastId = 0;
    _insertedElements = 0;
    _totalCollisions = 0;
    _maxProbe = 0;
    _idToOffset.clear();
  }

  // Información del archivo
  Future<FileStat> getFileInfo() async {
    final file = File(_filePath);
    return await file.stat();
  }

  Future<void> rebuildOffsetIndex() async {
    _idToOffset.clear();
    final file = File(_filePath);
    final lines = await file.readAsLines();
    int currentOffset = 0;

    for (final line in lines) {
      if (line.trim().isNotEmpty) {
        try {
          final json = jsonDecode(line);
          final id = json['id'] as int;
          _idToOffset[id] = currentOffset;
        } catch (e) {
          // Ignore
        }
      }
      currentOffset += line.length + 1;
    }
  }
}
