import 'coordinates.dart';

extension HexagonTileMapExtension<T> on Map<Coordinates, T> {
  int get minX {
    int min;
    keys.forEach((coordinate) {
      if (min == null || coordinate.x < min) {
        min = coordinate.x;
      }
    });
    return min;
  }

  int get maxX {
    int max;
    keys.forEach((coordinate) {
      if (max == null || coordinate.x > max) {
        max = coordinate.x;
      }
    });
    return max;
  }

  int get minY {
    int min;
    keys.forEach((coordinate) {
      if (min == null || coordinate.y < min) {
        min = coordinate.y;
      }
    });
    return min;
  }

  int get maxY {
    int max;
    keys.forEach((coordinate) {
      if (max == null || coordinate.y > max) {
        max = coordinate.y;
      }
    });
    return max;
  }

  int get minZ {
    int min;
    keys.forEach((coordinate) {
      if (min == null || coordinate.z < min) {
        min = coordinate.z;
      }
    });
    return min;
  }

  int get maxZ {
    int max;
    keys.forEach((coordinate) {
      if (max == null || coordinate.z > max) {
        max = coordinate.z;
      }
    });
    return max;
  }

  int get columnCount {
    return maxX - minX;
  }
}
