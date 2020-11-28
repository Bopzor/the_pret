abstract class Repository {
  void saveObject(List<dynamic> object);

  Future<List<dynamic>> getObject();

  Future<void> removeObject();
}
