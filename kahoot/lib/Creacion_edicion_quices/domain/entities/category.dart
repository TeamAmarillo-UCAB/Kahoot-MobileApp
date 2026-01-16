class Category {
  final String nombre;

  Category({required this.nombre});

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    final name = (json['nombre'] as String?) ?? (json['name'] as String?) ?? '';
    return Category(nombre: name);
  }
}
