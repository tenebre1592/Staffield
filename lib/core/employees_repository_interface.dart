import 'package:Staffield/core/entities/employee.dart';

abstract class EmployeesRepositoryInterface {
  Future<List<Employee>> fetch();
  Future<bool> addOrUpdate(Employee entry);
  Future<int> remove(String uid);
  Future<Employee> getEmployee(String uid);
}
