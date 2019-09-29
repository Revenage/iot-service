#include <ESP8266WiFi.h>
#include <DNSServer.h>
#include <ESP8266WebServer.h>
#include <ESP8266HTTPClient.h>
#include <ArduinoJson.h>

#include "EEPROM.h"

// #define pin_SW_SDA 5 // Назначаем вывод D3 Arduino для работы в качестве линии SDA программной шины I2C.
// #define pin_SW_SCL 4

#include <Wire.h>
#include <iarduino_RTC.h>

uint8_t wire1 = D8;
uint8_t wire2 = D7;
uint8_t wire3 = D6;
uint8_t wire4 = D5;

iarduino_RTC timeRTC(RTC_DS1307);

const byte DNS_PORT = 53;
IPAddress apIP(172, 217, 28, 1);
DNSServer dnsServer;
ESP8266WebServer server(80);

const char *ssid = "CatsFeeder"; //ENTER YOUR WIFI SETTINGS
const char *password = "12341234";

boolean LEDstate = LOW;
uint8_t LEDpin = 2;

String wifiSSID = "";
String wifiPASSWORD = "";
String wifiMAC = "";
String wifiTOKEN = "";

void writeString(char add, String data);
String read_String(char add);

const String host = "http://192.168.0.104:3000";
//const String host = "http://iot-smart-house.herokuapp.com";

String Page(String title, String content)
{
  String ptr = "<!DOCTYPE html> <html>\n";
  ptr += "<head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, user-scalable=no\">\n";
  ptr += "<title>" + title + "</title>\n";
  ptr += "<style>html { font-family: Helvetica; display: inline-block; margin: 0px auto; text-align: center;}\n";
  ptr += "body{margin-top: 50px;} h1 {color: #444444;margin: 50px auto 30px;} h3 {color: #444444;margin-bottom: 50px;}\n";
  ptr += ".button {display: block;width: 80px;background-color: #1abc9c;border: none;color: white;padding: 13px 30px;text-decoration: none;font-size: 25px;margin: 0px auto 35px;cursor: pointer;border-radius: 4px;}\n";
  ptr += ".button-on {background-color: #1abc9c;}\n";
  ptr += ".button-on:active {background-color: #16a085;}\n";
  ptr += ".button-off {background-color: #34495e;}\n";
  ptr += ".button-off:active {background-color: #2c3e50;}\n";
  ptr += "p {font-size: 14px;color: #888;margin-bottom: 10px;}\n";
  ptr += "</style>\n";
  ptr += "</head>\n";
  ptr += "<body>\n";
  ptr += content;
  ptr += "</body>\n";
  ptr += "</html>\n";
  return ptr;
}

String ConnectionListWiFiPage()
{
  String ptr = "";
  int n = WiFi.scanNetworks();
  Serial.println("scan done");
  if (n == 0)
    Serial.println("no networks found");
  else
  {
    Serial.print(n);
    Serial.println(" networks found");
    for (int i = 0; i < n; ++i)
    {
      String name = WiFi.SSID(i);
      ptr += "<p><a class=\"\" href=\"/connection?ssid=" + name + "\">" + name + "</a></p>";
    }
  }
  return Page("Choose you WiFi", ptr);
}

String ConnectionToWiFiPage()
{
  String ptr = "";

  String name = server.arg("ssid");
  wifiSSID = name;
  Serial.print("Connect you WiFi: ");
  Serial.println(name);

  ptr += "<form method=\"post\" action=\"/connect_to_wifi\">";
  ptr += "Password:<br>";
  ptr += "<input type=\"password\" name=\"password\" value=\"\">";
  ptr += "<br><input type=\"submit\" value=\"Connect\">";
  ptr += "</form>";

  ptr += "</body>\n";
  ptr += "</html>\n";
  return Page("Connect you WiFi", ptr);
}

String ConnectionToYouAccount()
{
  String ptr = "";
  ptr += "<h1>Connection To You Account</h1>\n";
  ptr += "<form method=\"post\" action=\"/connect_to_account\">";
  ptr += "Account Email:<br>";
  ptr += "<input type=\"email\" name=\"email\" value=\"\">";
  ptr += "Account Password:<br>";
  ptr += "<input type=\"password\" name=\"password\" value=\"\">";
  ptr += "<br><input type=\"submit\" value=\"Connect\">";
  ptr += "</form>";
  return Page("Connection To You Account", ptr);
}

String FailConnection()
{
  String ptr = "";
  ptr += "<h1>Fail Connection to WIFI</h1>\n";
  ptr += "<a href=\"/\">Try another connection</a>";
  return Page("Fail Connection to WIFI", ptr);
}

void setup()
{
  delay(1000);

  pinMode(wire1, OUTPUT);
  pinMode(wire2, OUTPUT);
  pinMode(wire3, OUTPUT);
  pinMode(wire4, OUTPUT);

  Serial.begin(115200);
  Wire.begin(4, 5);
  timeRTC.begin();
  EEPROM.begin(256);

  WiFi.mode(WIFI_OFF);
  pinMode(LEDpin, OUTPUT);

  Serial.setDebugOutput(true);

  WiFi.mode(WIFI_AP_STA);
  WiFi.softAPConfig(apIP, apIP, IPAddress(255, 255, 255, 0));
  WiFi.softAP(ssid, password);

  wifiMAC = WiFi.macAddress();

  Serial.print("MAC: ");
  Serial.println(wifiMAC);

  dnsServer.start(DNS_PORT, "*", apIP);

  Serial.println("USP Server started");

  server.on("/", handle_root);
  server.on("/connection", handle_conection);
  server.on("/connect_to_wifi", handle_conection_to_wifi);
  server.on("/connect_to_account", handle_connection_to_account);

  server.on("/generate_204", handle_root);        //Android captive portal
  server.on("/hotspot-detect.html", handle_root); //Iphone captive portal
  server.onNotFound(handleNotFound);
  server.begin();

  Serial.println("HTTP server started");
}

// STEPPER
void sequence(bool a, bool b, bool c, bool d)
{ /* four step sequence to stepper motor */
  digitalWrite(wire1, a);
  digitalWrite(wire2, b);
  digitalWrite(wire3, c);
  digitalWrite(wire4, d);
  delay(1);
  // delayMicroseconds(50);
}

void rotate(int percent)
{
  for (int i = 0; i < (524 * percent / 100); i++)
  {
    sequence(HIGH, LOW, LOW, LOW);
    sequence(HIGH, HIGH, LOW, LOW);
    sequence(LOW, HIGH, LOW, LOW);
    sequence(LOW, HIGH, HIGH, LOW);
    sequence(LOW, LOW, HIGH, LOW);
    sequence(LOW, LOW, HIGH, HIGH);
    sequence(LOW, LOW, LOW, HIGH);
    sequence(HIGH, LOW, LOW, HIGH);
  }
  sequence(LOW, LOW, LOW, LOW);
}

void rotateBack(int percent)
{
  for (int i = 0; i < (524 * percent / 100); i++)
  {
    sequence(LOW, LOW, LOW, HIGH);
    sequence(LOW, LOW, HIGH, HIGH);
    sequence(LOW, LOW, HIGH, LOW);
    sequence(LOW, HIGH, HIGH, LOW);
    sequence(LOW, HIGH, LOW, LOW);
    sequence(HIGH, HIGH, LOW, LOW);
    sequence(HIGH, LOW, LOW, LOW);
    sequence(HIGH, LOW, LOW, HIGH);
  }
  sequence(LOW, LOW, LOW, LOW);
}

//SERVER

void handleNotFound()
{
  Serial.print("URI Not Found: ");
  Serial.println(server.uri());
  server.send(404, "text/html", "Page not found");
}

void handle_root()
{
  Serial.print("Page served: ");
  Serial.println(server.uri());
  server.send(200, "text/html", ConnectionListWiFiPage());
}

void handle_conection()
{
  server.send(200, "text/html", ConnectionToWiFiPage());
}

void handle_conection_to_wifi()
{
  wifiPASSWORD = server.arg("password");
  wifi_connection();

  server.send(200, "text/html", ConnectionToYouAccount());
}

void wifi_connection()
{
  Serial.print("Wifi ssid: ");
  Serial.println(wifiSSID);
  Serial.print("Wifi password: ");
  Serial.println(wifiPASSWORD);

  delay(500);

  WiFi.begin(wifiSSID, wifiPASSWORD); //Connect to your WiFi router
  Serial.println("");

  Serial.print("Connecting");
  // Wait for connection
  int count = 10;
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    Serial.print(".");
    count--;
    if (count == 0)
    {
      Serial.println("");
      Serial.print("Fail Connected ");
      server.send(200, "text/html", FailConnection());
    }
  }

  blink();
  blink();

  //If connection successful show IP address in serial monitor
  Serial.println("");
  Serial.print("Connected to ");
  Serial.println(wifiSSID);
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

void handle_connection_to_account()
{
  HTTPClient http;

  String emailArg = server.arg("email");
  String passwordArg = server.arg("password");

  Serial.print("postData email: ");
  Serial.println(emailArg);
  Serial.print("postData password: ");
  Serial.println(passwordArg);
  Serial.print("postData wifiMAC: ");
  Serial.println(wifiMAC);

  // const int capacity = JSON_OBJECT_SIZE(3);
  String postData = "";
  StaticJsonDocument<200> postDataDoc;
  postDataDoc["email"] = emailArg;
  postDataDoc["password"] = passwordArg;
  postDataDoc["uid"] = wifiMAC;

  serializeJson(postDataDoc, postData);

  //  String postData = "{\"email\":\"" + email + "\",\"password\":\"" + password + "\",\"uid\":\"" + uid + "\"}";
  Serial.print("postData: ");
  Serial.println(postData);

  http.begin(host + "/api/devices/auth/register");    //Specify request destination
  http.addHeader("Content-Type", "application/json"); //Specify content-type header

  int httpCode = http.POST(postData); //Send the request
  String respond = http.getString();  //Get the response payload

  Serial.println(httpCode); //Print HTTP return code
  Serial.println(respond);  //Print request response payload
  http.end();

  // const int cap = JSON_OBJECT_SIZE(3) + 2 * JSON_OBJECT_SIZE(1);
  StaticJsonDocument<400> respondDoc;

  DeserializationError err = deserializeJson(respondDoc, respond);
  if (err)
  {
    Serial.print(F("deserializeJson() failed with code "));
    Serial.println(err.c_str());
  }

  auto resStatus = respondDoc["status"].as<String>();
  auto resMessage = respondDoc["message"].as<String>();
  auto token = respondDoc["token"].as<String>();

  Serial.print("write token:");
  Serial.println(token);

  if (token)
  {
    saveCredentials();
    writeString(64, token);
  }

  if (httpCode >= 200 && httpCode < 300)
  {
    server.send(200, "text/html", resMessage + " " + "Please connect to you local WiFi");
  }
  else
  {
    server.send(httpCode, "text/html", "Connection failed: " + resMessage);
  }
}

void writeString(char add, String data)
{
  int _size = data.length();
  int i;
  for (i = 0; i < _size; i++)
  {
    EEPROM.write(add + i, data[i]);
  }
  EEPROM.write(add + _size, '\0'); //Add termination null character for String Data
  EEPROM.commit();
}

String read_String(char add)
{
  int i;
  char data[200]; //Max 100 Bytes
  int len = 0;
  unsigned char k;
  k = EEPROM.read(add);
  while (k != '\0' && len < 500) //Read until null character
  {
    k = EEPROM.read(add + len);
    data[len] = k;
    len++;
  }
  data[len] = '\0';
  return String(data);
}

/** Store WLAN credentials to EEPROM */
void saveCredentials()
{
  Serial.print("Save Credentials:");
  Serial.println(wifiSSID);
  Serial.println(wifiPASSWORD);

  writeString(0, wifiSSID);
  writeString(32, wifiPASSWORD);
}

/** Load WLAN credentials from EEPROM */
String loadSSID()
{
  String SSID = read_String(0);
  Serial.print('loadSSID: ');
  Serial.println(SSID);
  return SSID;
}

String loadPASSWORD()
{
  String PASSWORD = read_String(32);
  Serial.print('loadPASSWORD: ');
  Serial.println(PASSWORD);
  return PASSWORD;
}

String loadTOKEN()
{
  String token = read_String(64);

  Serial.print('loadTOKEN: ');
  Serial.println(token);
  return token;
}

void ledProcess()
{
  if (LEDstate)
  {
    digitalWrite(LEDpin, LOW);
  }
  else
  {
    digitalWrite(LEDpin, HIGH);
  }
}

void blink()
{
  delay(500);
  digitalWrite(LEDpin, LOW);
  delay(500);
  digitalWrite(LEDpin, HIGH);
}

void respondProcess(JsonDocument doc)
{
  auto action = doc["action"].as<String>();

  if (action == "led")
  {
    bool value = doc["value"];
    LEDstate = value;
    return;
  }

  if (action == "rotate")
  {
    int value = doc["value"];
    if (value > 0)
    {
      blink();
      rotate(value);
    }
    else
    {
      blink();
      blink();
      rotateBack(abs(value));
    }
    return;
  }

  if (action == "setTime")
  {
    JsonArray value = doc["value"];
    int sec = value[0];
    int min = value[1];
    int hour = value[2];
    int day = value[3];
    int month = value[4];
    int year = value[5];
    int dayNum = value[6]; // 2 - tuesday
    timeRTC.settime(sec, min, hour, day, month, year, dayNum);

    return;
  }

  Serial.print('Unknown action: ');
  Serial.println(action);
}

void mainProcess()
{

  if (WiFi.status() == WL_CONNECTED)
  {
    HTTPClient http;
    http.setTimeout(30000);
    http.begin(host + "/poll/subscribe/" + wifiMAC); //Specify request destination

    String token = loadTOKEN();

    if (token.length() <= 64 || token == "null")
    {
      delay(1000);
      return;
    }

    http.addHeader("Authorization", "Bearer " + token);
    int httpCode = http.GET(); //Send the request

    Serial.print("httpCode: ");
    Serial.println(httpCode);

    Serial.print("token: ");
    Serial.println(token);
    if (httpCode > 0)
    { //Check the returning code

      if (httpCode > 400)
      { // Unathorized
        delay(1000);
        blink();
        return;
      }

      String payload = http.getString(); //Get the request response payload
      Serial.print("poll payload: ");
      Serial.println(payload); //Print the response payload

      // PROCESS ACTIONS
      const int cap = JSON_ARRAY_SIZE(7) + JSON_OBJECT_SIZE(3) + 400;
      StaticJsonDocument<cap> respondDoc;

      DeserializationError err = deserializeJson(respondDoc, payload);
      if (err)
      {
        Serial.print(F("deserializeJson() failed with code "));
        Serial.println(err.c_str());
      }

      auto status = respondDoc["status"].as<String>();

      Serial.print("poll status: ");
      Serial.println(status); //Print the response payload

      if (status == "ok")
      {
        respondProcess(respondDoc);
      }
    }
    else
    {
      if (httpCode == -1)
      {
        delay(1000);
      }
    }

    http.end(); //Close connection
  }
  else
  {
    String ssid = loadSSID();
    String password = loadPASSWORD();

    if (ssid && password)
    {
      WiFi.begin(ssid, password); //Connect to your WiFi router
      Serial.println("Connecting");
      int count = 10;
      while (WiFi.status() != WL_CONNECTED)
      {
        delay(500);
        Serial.print(".");
        count--;
        if (count == 0)
        {
          Serial.println("");
          Serial.print("Fail Connected ");
        }
      }

      blink();
      blink();
      Serial.println("");
      Serial.print("Connected to: ");
      Serial.print(ssid);
      Serial.print(", password: ");
      Serial.println(password);
      Serial.print("IP address: ");
      Serial.println(WiFi.localIP());
    }
  }
}

void loop()
{
  dnsServer.processNextRequest();
  server.handleClient();

  mainProcess();

  Serial.println(timeRTC.gettime("H:i:s"));
  delay(1000);

  ledProcess();
}