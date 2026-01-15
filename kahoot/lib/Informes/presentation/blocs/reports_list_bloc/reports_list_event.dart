abstract class ReportsListEvent {}

// Se llama al iniciar la pantalla o al hacer "pull-to-refresh"
class LoadMyResults extends ReportsListEvent {
  final int limit;
  
  // Mantenemos el default de 20 según la documentación 
  LoadMyResults({this.limit = 20});
}

// Se llama cuando el scroll llega al final
class LoadMoreResults extends ReportsListEvent {}