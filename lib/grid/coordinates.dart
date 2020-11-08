class Coordinates {
  Coordinates.cube(this.x, this.y, this.z)
      : assert(x != null),
        assert(y != null),
        assert(z != null);

  Coordinates.axial(int q, int r)
      : assert(q != null),
        assert(r != null),
        this.x = q,
        this.y = -q - r,
        this.z = r;

  final int x, y, z;

  int get q => x;

  int get r => z;

  @override
  bool operator ==(Object other) =>
      other is Coordinates && other.x == x && other.y == y && other.z == z;

  @override
  int get hashCode => x ^ y ^ z;
}

class Tile<T> {
  final Coordinates coordinates;
  final T item;

  Tile(this.coordinates, this.item);
}
