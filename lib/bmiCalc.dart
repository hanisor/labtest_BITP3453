import 'dart:math';

import 'package:flutter/material.dart';

import 'controller/sqlite_db.dart';

class BmiCalc extends StatefulWidget {
  const BmiCalc({super.key});

  @override
  State<BmiCalc> createState() => _BmiCalcState();
}

class _BmiCalcState extends State<BmiCalc> {
  // global variable (anything with _ )
  var _bmi = 0;
  var category = "";
  var _weight = 0;
  var _height = 0;
  var _gender = "";
  var maleCount = 0;
  var femaleCount = 0;
  var totalMaleBMI = 0;
  var totalFemaleBMI = 0;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }


  Future<void> init() async {
    SQLiteDB db = SQLiteDB();
    List<Map<String, dynamic>> previousData = await db.retrievePreviousData();

    if (previousData.isNotEmpty) {
      setState(() {
        nameController.text = previousData[0]['username'];
        heightController.text = previousData[0]['height'].toString();
        weightController.text = previousData[0]['weight'].toString();
        _gender = previousData[0]['gender'];
        //_bmi = previousData[0]['status'];
        category = previousData[0]['status'];

      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BMI Calculator"),),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Your Full Name',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: heightController,
                decoration: InputDecoration(
                  labelText: 'height in cm; 170',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: weightController,
                decoration: InputDecoration(
                  labelText: 'Weight in KG',
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(child: Text("BMI Value"),
                alignment: Alignment.topLeft,),
            ),

            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Male'),
                    leading: Radio(
                      value: 'Male',
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = (value as String?)!;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Female'),
                    leading: Radio(
                      value: 'Female',
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = (value as String?)!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),

            TextButton( onPressed: () async {
              double _weight = double.parse(weightController.text);
              double _height = double.parse(heightController.text) / 100;
              double bmiTemp = _weight / (_height * _height);
              print(bmiTemp);

              if (_gender == 'Male') {
                maleCount++;
                totalMaleBMI += _bmi!;
              } else {
                femaleCount++;
                totalFemaleBMI += _bmi!;
              }


              setState(() {
                if (_gender == 'Male'){
                  if (bmiTemp < 18.5) {
                    category = 'Underweight. Careful during strong wind!';
                  }
                  else if (bmiTemp > 18.5 && bmiTemp < 24.9) {
                    category = 'That is ideal! Please maintain';
                  }
                  else if (bmiTemp > 25 && bmiTemp < 30) {
                    category = 'Overweight! Work out please';
                  }
                  else
                    category = 'Whoa obese! Dangerous mate!';
                }
                else if (_gender == 'Female'){
                  if (bmiTemp < 16) {
                    category = 'Underweight. Careful during strong wind!';
                  }
                  else if (bmiTemp > 16 && bmiTemp < 22) {
                    category = 'That is ideal! Please maintain';
                  }
                  else if (bmiTemp > 22 && bmiTemp < 27) {
                    category = 'Overweight! Work out please';
                  }
                  else
                    category = 'Whoa obese! Dangerous mate!';
                }
              });

              setState(() {
                _bmi = bmiTemp.round();
              });

              print('Before BMI calculation');
              // Save BMI data to the database
              final String username = nameController.text;
              final double weight = double.parse(weightController.text);
              final double height = double.parse(heightController.text) /100;
              final String gender = _gender;
              final String status = category;

              print('Before saving to database');
              try {
                Map<String, dynamic> bmiData = {
                  'username': username,
                  'weight': weight,
                  'height': height,
                  'gender': gender,
                  'bmi_status': status,
                };

                await SQLiteDB().insertBMIRecord(bmiData);
                print('BMI data saved to database');
              } catch (e) {
                print('Error saving BMI data: $e');
              }
            },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white),
                backgroundColor: MaterialStateProperty.all(Colors.blue),
              ), child: Text("Calculate BMI and save"),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                  "BMI Value: $_bmi"
              ),
            ),

            Text ("$_gender"),
            Text(
              "$category",
            ),


            SizedBox(height: 16),
            Center(
              child: Text(
                'Total BMI for Male: $maleCount, Total BMI for Female: $femaleCount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Inside your Column widget
            SizedBox(height: 8),
            Center(
              child: Text(
                'Average Male BMI: ${maleCount == 0 ? 0 : (totalMaleBMI / maleCount).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                'Average Female BMI: ${femaleCount == 0 ? 0 : (totalFemaleBMI / femaleCount).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
