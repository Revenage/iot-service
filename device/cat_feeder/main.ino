#include <ESP8266WiFi.h>
#include <DNSServer.h>
#include <ESP8266WebServer.h>
#include <ESP8266HTTPClient.h>
#include <ArduinoJson.h>

const byte DNS_PORT = 53;
IPAddress apIP(172, 217, 28, 1);
DNSServer dnsServer;
ESP8266WebServer server(80);

const char *ssid = "CatsFeeder"; //ENTER YOUR WIFI SETTINGS
const char *password = "12341234";

//boolean LEDstate = LOW;
//uint8_t LEDpin = 2;

String wifiSSID = "";
String wifiPASSWORD = "";
String wifiMAC = "";

const String host = "http://192.168.0.104:3000";

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

void setup()
{
  delay(1000);
  Serial.begin(115200);
  WiFi.mode(WIFI_OFF);
  //  pinMode(LEDpin, OUTPUT);

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
  //  server.on("/ledoff", handle_ledoff);

  server.on("/generate_204", handle_root);        //Android captive portal
  server.on("/hotspot-detect.html", handle_root); //Iphone captive portal
  server.onNotFound(handleNotFound);
  server.begin();
  //  Serial.println(LEDstate ? "HIGH" : "LOW");
  Serial.println("HTTP server started");
}

void handleNotFound()
{
  Serial.print("URI Not Found: ");
  Serial.println(server.uri());
  server.send(404, "text/html", "Page not found");
}

void handle_root()
{
  unsigned int len = wifiSSID.length();
  if (len == 0)
  {
    Serial.print("Page served: ");
    Serial.println(server.uri());
    server.send(200, "text/html", ConnectionListWiFiPage());
  }
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

  delay(1000);

  WiFi.begin(wifiSSID, wifiPASSWORD); //Connect to your WiFi router
  Serial.println("");

  Serial.print("Connecting");
  // Wait for connection
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    Serial.print(".");
  }

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

  String email = server.arg("email");
  String password = server.arg("password");

  Serial.print("postData password: ");
  Serial.println(password);

  const int capacity = JSON_OBJECT_SIZE(3);
  String postData = "";
  StaticJsonDocument<capacity> postDataDoc;
  postDataDoc["email"] = email;
  postDataDoc["password"] = password;
  postDataDoc["uid"] = wifiMAC;

  serializeJson(postDataDoc, postData);

  //  String postData = "{\"email\":\"" + email + "\",\"password\":\"" + password + "\",\"uid\":\"" + uid + "\"}";
  Serial.print("postData: ");
  Serial.println(postData);

  http.begin(host + "/connect-device");               //Specify request destination
  http.addHeader("Content-Type", "application/json"); //Specify content-type header

  int httpCode = http.POST(postData); //Send the request
  String respond = http.getString();  //Get the response payload

  Serial.println(httpCode); //Print HTTP return code
  Serial.println(respond);  //Print request response payload
  http.end();

  const int cap = JSON_OBJECT_SIZE(3) + 2 * JSON_OBJECT_SIZE(1);
  StaticJsonDocument<cap> respondDoc;

  DeserializationError err = deserializeJson(respondDoc, respond);
  if (err)
  {
    Serial.print(F("deserializeJson() failed with code "));
    Serial.println(err.c_str());
  }

  auto resStatus = respondDoc["status"].as<String>();
  auto resMessage = respondDoc["message"].as<String>();

  if (httpCode >= 200 && httpCode < 300)
  {
    server.send(200, "text/html", resMessage + " " + "Please connect to you local WiFi");
  }
  else
  {
    server.send(httpCode, "text/html", "Connection failed: " + resMessage);
  }
}

void loop()
{
  dnsServer.processNextRequest();
  server.handleClient();
}