import 'package:Staffield/core/entities/employee.dart';
import 'package:Staffield/core/entities/entry.dart';

abstract class EntriesRepositoryInterface {
  Future<List<Entry>> fetch({int greaterThan, int lessThan, List<Employee> employees, int limit});
  Future<bool> addOrUpdate(List<Entry> entry);
  void remove(String uid);
}
