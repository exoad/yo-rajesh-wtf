import 'package:project_yellow_cake/engine/engine.dart';
import 'package:project_yellow_cake/game/game.dart';

class ReactorSlot {
  final Map<Class, int> _Class;

  ReactorSlot([Map<Class, int>? initial])
      : _Class = Map<Class, int>.fromIterables(
            Class.values, List<int>.filled(Class.values.length, 0, growable: false));

  int at(Class layer) {
    return _Class[
        layer]!; // non nullable enum type assures us that the result will at least produce a numerical typing
  }

  int operator [](Class layer) {
    return at(layer);
  }

  void setAt(Class layer, int value) {
    _Class[layer] = value;
  }

  void operator []=(Class layer, int value) {
    _Class[layer] = value;
  }
}

class ReactorEntity {
  final List<List<ReactorSlot>> _grid;

  ReactorEntity(
      {required int rows,
      required int columns,
      ReactorSlot Function(int row, int column)? generator})
      : _grid = List<List<ReactorSlot>>.generate(
            rows,
            (int i) => List<ReactorSlot>.generate(
                columns, (int j) => generator != null ? generator(i, j) : ReactorSlot()));

  /// Returns an item definition ID that can be looked up in [ItemsRegistry]
  ReactorSlot at(int row, int column) {
    if (row < 0 || row >= _grid.length || column < 0 || column >= _grid[row].length) {
      panicNow(
          "Invalid indices: row=$row, column=$column. Grid size is ${_grid.length}x${_grid.isNotEmpty ? _grid[0].length : 0}.");
    }
    return _grid[row][column];
  }

  List<ReactorSlot> allOnLayer(Class layer) {
    return _grid[layer.index];
  }

  int operator [](CellLocation location) {
    if (location.row < 0 ||
        location.row >= _grid.length ||
        location.column < 0 ||
        location.row >= _grid[location.row].length) {
      panicNow(
          "Invalid indices: row=${location.row}, column=${location.row}, layer=${location.layer}. Grid size is ${_grid.length}x${_grid.isNotEmpty ? _grid[0].length : 0}.");
    }
    return _grid[location.row][location.column][location.layer];
  }

  void operator []=(CellLocation location, int value) {
    if (location.row < 0 ||
        location.row >= _grid.length ||
        location.column < 0 ||
        location.row >= _grid[location.row].length) {
      panicNow(
          "Invalid indices: row=${location.row}, column=${location.row}. Grid size is ${_grid.length}x${_grid.isNotEmpty ? _grid[0].length : 0}.");
    }
    _grid[location.row][location.column][location.layer] = value;
    Shared.logger.fine(
        "Reactor set ${location.row},${location.column},${location.layer} to $value (${value.findItemDefinition(location.layer).identifier})");
  }

  void setAt(int value, {required int row, required int column, required Class layer}) {
    if (row < 0 || row >= _grid.length || column < 0 || column >= _grid[row].length) {
      panicNow(
          "Invalid indices: row=$row, column=$column,layer=$layer. Grid size is ${_grid.length}x${_grid.isNotEmpty ? _grid[0].length : 0}.");
    }
    _grid[row][column][layer] = value;
  }

  int get size => _grid.length * _grid[0].length;

  int get rows => _grid.length;

  int get columns => _grid[0].length;
}

class CellLocation {
  final int row;
  final int column;
  final Class layer;

  CellLocation(this.row, this.column, this.layer)
      : assert(row >= 0, "Reactor Cell of Row=$row is not possible!"),
        assert(column >= 0, "Reactor Cell of Column=$column is not possible!");

  int findInRector([ReactorEntity? instance]) {
    return (instance ?? GameRoot.I.reactor).at(row, column)[layer];
  }
}
