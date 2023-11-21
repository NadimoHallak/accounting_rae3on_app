import 'package:hive/hive.dart';

class Database {
  final mybox = Hive.box("mybox");
  List teacherList = [];

  //creat a new teacher

  void loadData() {
    teacherList = mybox.get('teachers');
  }

  //update salary

  void updateData() {
    mybox.put('teachers', teacherList);
  }

  void creatInitData() {
    teacherList.add({
      "name": "هدودة الحلوة",
      "salaryD": 0,
      "salaryL": 0,
    });
  }
}
