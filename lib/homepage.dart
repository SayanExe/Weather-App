import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'components/weather_item.dart';
import 'constants.dart';
import 'detailpage.dart';

class homepage extends StatefulWidget { // StatefulWidget for the homepage
  const homepage({super.key}); // Constructor for homepage widget

  @override
  State<homepage> createState() => _homepageState();
} // Creating state for homepage


class _homepageState extends State<homepage> {
  TextEditingController _cityController = TextEditingController();
  final Constants _constants = Constants(); // Instance of Constants clas

  static String API_KEY = "6e925e1d461e42f6809102649240306"; // OpenWeatherMap API key


  String location = 'Berlin'; //Default location
  String weatherIcon = 'heavycloud.png';
  int temparature = 0;
  int windspeed = 0;
  int humidity = 0;
  int cloud = 0;
  String currentDate = '';

  List hourlyWeatherForecast = [];
  List dailyWeatherForecast = [];

  String currentWeatherStatus = '';

  //API call
  String searchWeatherAPI = "https://api.weatherapi.com/v1/forecast.json?key=" +
      API_KEY +
      "&days=7&q=";

  void fetchWeatherData(String searchText) async {
    try {
      var searchResult = await http.get(Uri.parse(searchWeatherAPI + searchText));

      final weatherData = Map<String, dynamic>.from(
          json.decode(searchResult.body) ?? 'No data');

      var locationData = weatherData["location"];
      var currentWeather = weatherData["current"];

      setState(() {
        location = getShortLocationName(locationData["name"]);
        var parsedDate = DateTime.parse(locationData["localtime"].substring(0, 10));
        print(parsedDate);
        var newDate = DateFormat('MMMMEEEEd').format(parsedDate);
        currentDate = newDate;

        //UpdateWeather
        currentWeatherStatus = currentWeather["condition"]["text"];
        weatherIcon = currentWeatherStatus.replaceAll(' ','').toLowerCase() + ".png";
        temparature = currentWeather["temp_c"].toInt();
        windspeed = currentWeather["wind_kph"].toInt();
        humidity = currentWeather["humidity"].toInt();
        cloud = currentWeather["cloud"].toInt();

        //Forecast data
        dailyWeatherForecast = weatherData["forecast"]["forecastday"];
        hourlyWeatherForecast = dailyWeatherForecast[0]["hour"];
        print(dailyWeatherForecast);
      });
    } catch (e) {
      //debug print e
    }
  }

  //FUnction to return the first two names of the string
  static String getShortLocationName(String s) {
    List<String> wordList = s.split(" ");

    if (wordList.isNotEmpty) {
      if (wordList.length > 1) {
        return wordList[0] + " " + wordList[1];
      } else {
        return wordList[0];
      }
    } else {
      return " ";
    }
  }

  @override
  void initState() {
    fetchWeatherData(location);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);

    Size size = MediaQuery.of(context).size;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          width: size.width,
          height: size.height,
          padding: const EdgeInsets.only(top: 50, left: 10, right: 10),
          color: _constants.primaryColor.withOpacity(.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  height: size.height * .7,
                  decoration: BoxDecoration(
                    gradient: _constants.linearGradientBlue,
                    boxShadow: [
                      BoxShadow(
                        color: _constants.primaryColor.withOpacity(.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(20),

                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/menu.png",
                            width: 40,
                            height: 40,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset("assets/pin.png", width: 20,),
                              const SizedBox(width: 2,),
                              Text(location, style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),),
                              IconButton(
                                onPressed: () {
                                  _cityController.clear();
                                  showMaterialModalBottomSheet(
                                    context: context,
                                    builder: (context) => SingleChildScrollView(
                                      controller: ModalScrollController.of(context),
                                      child: Container(
                                        height: size.height * 2,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10,
                                        ),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: 70,
                                              child: Divider(
                                                thickness: 3.5,
                                                color: _constants.primaryColor,
                                              ),
                                            ),
                                            const SizedBox(height: 10,),
                                            TextField(
                                              onSubmitted: (searchText) {
                                                fetchWeatherData(searchText);
                                                Navigator.pop(context);
                                              },
                                              controller: _cityController,
                                              autofocus: true,
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(Icons.search,
                                                  color: _constants.primaryColor,),
                                                suffixIcon: GestureDetector(
                                                  onTap: () => _cityController.clear(),
                                                  child: Icon(Icons.close,
                                                    color: _constants.primaryColor,),
                                                ),
                                                hintText: 'Search city e.g. London',
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: _constants.primaryColor,
                                                  ),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.search_outlined,
                                  color: Colors.white,),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 160,
                        child: Image.asset("assets/" + weatherIcon),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              temparature.toString(),
                              style: TextStyle(
                                fontSize: 80,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..shader = _constants.shader,
                              ),
                            ),
                          ),
                          Text(
                            'o',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..shader = _constants.shader,
                            ),
                          ),
                        ],
                      ),
                      Text(currentWeatherStatus, style: TextStyle(
                        color: Colors.white70,
                        fontSize: 20.0,
                      ),),
                      Text(currentDate, style: const TextStyle(
                        color: Colors.white70,
                      ),),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Divider(
                          color: Colors.white70,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            WeatherItem(
                              value: windspeed.toInt(),
                              unit: 'km/h',
                              imageUrl: 'assets/windspeed.png',
                            ),
                            WeatherItem(
                              value: humidity.toInt(),
                              unit: '%',
                              imageUrl: 'assets/humidity.png',
                            ),
                            WeatherItem(
                              value: cloud.toInt(),
                              unit: '%',
                              imageUrl: 'assets/cloud.png',
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 10),
                height: size.height * .20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Today', style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),),
                        GestureDetector(
                          onTap: () =>
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_)=> DetailPage(dailyForecastWeather: dailyWeatherForecast ,))),
                          child: Text('Forecasts', style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _constants.primaryColor,

                          ),),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8,),
                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: hourlyWeatherForecast.length,
                          itemBuilder: (BuildContext context, int index){

                            if (index >= hourlyWeatherForecast.length) {
                              return SizedBox(); // Return an empty widget if index is out of bounds
                            }
                            String currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
                            String currentHour = currentTime.substring(0,2);


                            String forecastTime = hourlyWeatherForecast[index]["time"].substring(11,16);
                            String forecastHour = hourlyWeatherForecast[index]["time"].substring(11,13);

                            String forecastWeatherName = hourlyWeatherForecast[index]["condition"]["text"];
                            String forecastWeatherIcon = forecastWeatherName.replaceAll(' ', '').toLowerCase() + ".png";

                            String forecastTemparature = hourlyWeatherForecast[index]["temp_c"].round().toString();
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              margin: const EdgeInsets.only(right: 20),
                              width: 65,
                              decoration: BoxDecoration(
                                color: currentHour == forecastHour ? Colors.white : _constants.primaryColor,
                                borderRadius: BorderRadius.all(Radius.circular(50)),
                                boxShadow: [
                                  BoxShadow(
                                    offset: const Offset(0, 1),
                                    blurRadius: 5,
                                    color: _constants.primaryColor.withOpacity(.2)
                                  )
                                ]
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(forecastTime, style: TextStyle(
                                    fontSize: 17,
                                    color: _constants.greyColor,
                                    fontWeight: FontWeight.w500,
                                  ),),
                                  Image.asset('assets/' + forecastWeatherIcon, width: 20,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(forecastTemparature, style: TextStyle(
                                        color: _constants.greyColor,
                                        fontWeight: FontWeight.bold,
                                      ),),
                                      Text('°', style: TextStyle(
                                        color: _constants.greyColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20,
                                        fontFeatures: const[
                                          FontFeature.enable('sups'),
                                        ],
                                      ),)
                                    ],
                                  )
                                ],

                              ),
                            );


                          },

                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

