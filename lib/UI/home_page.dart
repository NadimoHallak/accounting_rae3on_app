import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:mathmatic_app/model/database.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
//varibles

  final ctrlPrice = TextEditingController();
  final addCtrl = TextEditingController();
  final percentCtrl = TextEditingController();
  final ctrlD = TextEditingController();
  final Database db = Database();
  final GlobalKey formKey = GlobalKey<FormState>();
  bool colorAndIcon = false;
  final _mybox = Hive.box('mybox');
  double totalDianr = 0.0;
  double totalLira = 0.0;
  double totalLiraPer = 0.0;

  @override
  void initState() {
    if (_mybox.get("teachers") == null) {
      db.creatInitData();
    } else {
      db.loadData();
    }
    super.initState();
  }

  onLongPressFlaotButton() {
    setState(() {
      colorAndIcon = true;
      ctrlPrice.clear();
      addCtrl.clear();
      percentCtrl.clear();
      for (var i = 0; i < db.teacherList.length; i++) {
        db.teacherList[i]["salaryD"] = 0.0;
        db.teacherList[i]["salaryL"] = 0.0;
      }
      totalDianr = 0.0;
      totalLiraPer = 0.0;
      totalLira = 0.0;
      db.updateData();
    });
  }

  onLongPressFlaotButtonCancle() {
    setState(() {
      colorAndIcon = false;
    });
  }

  calcTotal() {
    setState(() {
      if (totalDianr != 0 && totalLiraPer != 0 && totalLira != 0) {
        totalDianr = 0;
        totalLiraPer = 0;
        totalLira = 0;
        for (int i = 0; i < db.teacherList.length; i++) {
          totalDianr += db.teacherList[i]["salaryD"];
          totalLiraPer += db.teacherList[i]["salaryL"];
        }
        double liraPrice = double.parse(ctrlPrice.text);
        totalLira = totalDianr * liraPrice;
      } else {
        for (int i = 0; i < db.teacherList.length; i++) {
          totalDianr += db.teacherList[i]["salaryD"];
          totalLiraPer += db.teacherList[i]["salaryL"];
        }
        double liraPrice = double.parse(ctrlPrice.text);
        totalLira = totalDianr * liraPrice;
      }
    });
  }

  // Function to calc salary in lira
  calcSalary(int index, BuildContext context) async {
    setState(() {
      if (ctrlPrice.text.trim().isEmpty ||
          ctrlD.text.trim().isEmpty ||
          percentCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لك ماما عبي المعلومات المطلوبة',
              textAlign: TextAlign.end,
              style: GoogleFonts.notoSansArabic(
                fontSize: 20,
              ),
            ),
          ),
        );
      } else {
        double liraPrice = double.parse(ctrlPrice.text);
        double dinarSalary = double.parse(ctrlD.text);
        double percent = double.parse(percentCtrl.text);

        if (liraPrice > 0 && dinarSalary > 0 && percent >= 0) {
          db.teacherList[index]['salaryD'] = dinarSalary;
          //salary without percent
          var salaryL = liraPrice * dinarSalary;

          //calc percent in lira
          double percentLira = salaryL - ((salaryL * percent) / 100);

          //put the final salary in a list
          db.teacherList[index]['salaryL'] = percentLira;

          ctrlD.clear();
          totalDianr = 0.0;
          totalLiraPer = 0.0;
          totalLira = 0.0;
        } else if (liraPrice > 0 && dinarSalary > 0 && percent == 0) {
          //if percent = 0
          var salaryL = liraPrice * dinarSalary;
          db.teacherList[index]['salaryL'] = salaryL;
          totalDianr = 0.0;
          totalLiraPer = 0.0;
          totalLira = 0.0;
        }
        db.updateData();
      }
    });
  }

  //Function to create a new teacher
  createNewTeacher() {
    //this variable for check the list
    var list = db.teacherList;
    setState(() {
      if (list.any((element) => element["name"] == addCtrl.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ماما.. هاد كاتبتيه',
              textAlign: TextAlign.end,
              style: GoogleFonts.notoSansArabic(fontSize: 20, letterSpacing: 2),
            ),
          ),
        );
      } else if (addCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ' :(  ماما كتبي اسم المدرس  ',
              textAlign: TextAlign.end,
              style: GoogleFonts.notoSansArabic(fontSize: 20, letterSpacing: 2),
            ),
          ),
        );
        // Navigator.of(context).pop();
      } else {
        db.teacherList.add({
          "name": addCtrl.text,
          "salaryD": 0,
          "salaryL": 0,
          // "controller": TextEditingController(),
        });
        db.updateData();
        addCtrl.clear();
        Navigator.of(context).pop();
      }
    });
  }

  //Function to delete a teacher
  deleteTeacher(int index) {
    setState(() {
      db.teacherList.removeAt(index);
      db.updateData();
      totalDianr = 0.0;
      totalLiraPer = 0.0;
      totalLira = 0.0;
    });
  }

  //Function to show dialog who add a teacher
  showAddDialog() {
    setState(() {
      showDialog(
        useSafeArea: true,
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'أضيفي مدرس',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansArabic(fontSize: 20, color: Colors.red),
          ),
          content: Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            width: 200,
            height: 130,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextFormField(
                  controller: addCtrl,
                  keyboardType: TextInputType.name,
                  textAlign: TextAlign.end,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    hintText: 'اسم  ا لمدرس',
                    hintStyle: GoogleFonts.notoSansArabic(),
                  ),
                ),
                ElevatedButton(
                  onPressed: createNewTeacher,
                  child: Text(
                    'إضافة',
                    style: GoogleFonts.notoSansArabic(
                        fontSize: 18, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }

///////////////////////////////////////////////////////////////////////////////////
////////////////////////////////    End      /////////////////////////////////////
///////////////////////////////  Function   /////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          "حسابات الشهر",
          style: GoogleFonts.notoSansArabic(
              color: Colors.black,
              textStyle: const TextStyle(
                fontSize: 35.0,
              )),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              /////////////////////////////////////////////////////////////////
              //////////////////////  TextFormFields  ////////////////////////
              ///////////////////////////////////////////////////////////////
              Padding(
                padding: const EdgeInsets.only(
                    top: 0, bottom: 15, left: 10, right: 10),
                //enter the price bank
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: width / 2.2,
                      height: 50,
                      child: TextFormField(
                        onTapOutside: (event) {},
                        controller: percentCtrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          prefixIcon: IconButton(
                              onPressed: () {
                                percentCtrl.clear();
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: width * 6 / 100,
                              )),
                          hintText: "النسبة الإدارية",
                          hintStyle: GoogleFonts.notoSansArabic(
                            color: Colors.grey,
                            textStyle: const TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.2,
                      height: 50,
                      child: TextFormField(
                        controller: ctrlPrice,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          prefixIcon: IconButton(
                              onPressed: () {
                                ctrlPrice.clear();
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: width * 6 / 100,
                              )),
                          hintText: "سعر صرف",
                          hintStyle: GoogleFonts.notoSansArabic(
                            color: Colors.grey,
                            textStyle: const TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              /////////////////////////////////////////////////////////////////
              //////////////////////  Total Calc  ////////////////////////
              ///////////////////////////////////////////////////////////////
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 5,
                      color: Colors.green,
                    ),
                    color: Colors.transparent,
                  ),
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  height: width * 44 / 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$totalDianr : الدينار",
                        style: GoogleFonts.notoSansArabic(fontSize: 20),
                      ),
                      Text(
                        '$totalLira : بالليرة بدون خصم',
                        style: GoogleFonts.notoSansArabic(fontSize: 20),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => calcTotal(),
                            child: Text(
                              'حساب',
                              style: GoogleFonts.notoSansArabic(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            '$totalLiraPer : بالليرة مع خصم',
                            style: GoogleFonts.notoSansArabic(fontSize: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              ///////////////////////////////////////////////////////////////////
              //////////////////// ListView.builder ////////////////////////////
              /////////////////////////////////////////////////////////////////
              Expanded(
                child: ListView.builder(
                  itemCount: db.teacherList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          top: 6, left: 10, right: 10, bottom: 12),

                      //Start container
                      child: Slidable(
                        useTextDirection: false,
                        startActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              borderRadius: BorderRadius.circular(10),
                              onPressed: (context) => deleteTeacher(index),
                              icon: Icons.delete,
                              backgroundColor: Colors.red,
                            )
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromARGB(255, 177, 177, 177),
                                  offset: Offset(1, 1),
                                  blurRadius: 5.0,
                                  spreadRadius: 0,
                                )
                              ]),
                          height: 180.0,
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            //////////  Column to display list element from data  //////////////////
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'الاسم :   ${db.teacherList[index]['name']}',
                                  style: GoogleFonts.notoSansArabic(
                                    color: Colors.black,
                                    textStyle: const TextStyle(
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 8.0,
                                ),
                                //row for 2th row in card///////////////////////////////////
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${db.teacherList[index]['salaryD']}  -  ${percentCtrl.text}%",
                                      style: GoogleFonts.notoSansArabic(
                                        color: Colors.black,
                                        textStyle: const TextStyle(
                                          fontSize: 20.0,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 40,
                                          width: 50.0,
                                          child: TextFormField(
                                            autofocus: false,
                                            controller: ctrlD,
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Text(
                                          ": الراتب بالدينار",
                                          style: GoogleFonts.notoSansArabic(
                                            color: Colors.black,
                                            textStyle: const TextStyle(
                                              fontSize: 20.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8.0,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () =>
                                          calcSalary(index, context),
                                      child: Text(
                                        'حساب',
                                        style: GoogleFonts.notoSansArabic(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "الراتب بالليرة : ${db.teacherList[index]['salaryL'] ?? 0}",
                                      style: GoogleFonts.notoSansArabic(
                                        color: Colors.black,
                                        textStyle: const TextStyle(
                                          fontSize: 20.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
      //////////////////////// Flaoting Action Bottun //////////////////////////////////////////////////////
      floatingActionButton: GestureDetector(
        onLongPress: () => onLongPressFlaotButton(),
        onLongPressEnd: (ditales) => onLongPressFlaotButtonCancle(),
        child: FloatingActionButton(
          backgroundColor: colorAndIcon ? Colors.red : Colors.green,
          onPressed: () => showAddDialog(),
          child: Icon(
            colorAndIcon ? Icons.delete : Icons.add,
            size: 30,
          ),
        ),
      ),
    );
  }
}
