#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
#include <DNSServer.h>
#include <ESP8266mDNS.h>
#include <EEPROM.h>

/*
   This example serves a "hello world" on a WLAN and a SoftAP at the same time.
   The SoftAP allow you to configure WLAN parameters at run time. They are not setup in the sketch but saved on EEPROM.

   Connect your computer or cell phone to wifi network ESP_ap with password 12345678. A popup may appear and it allow you to go to WLAN config. If it does not then navigate to http://192.168.4.1/wifi and config it there.
   Then wait for the module to connect to your wifi and take note of the WLAN IP it got. Then you can disconnect from ESP_ap and return to your regular WLAN.

   Now the ESP8266 is in your network. You can reach it through http://192.168.x.x/ (the IP you took note of) or maybe at http://esp8266.local too.

   This is a captive portal because through the softAP it will redirect any http request to http://192.168.4.1/
*/

/* Set these to your desired softAP credentials. They are not configurable at runtime */
#ifndef APSSID
#define APSSID "NightLighter"
#define APPSK "12341234"
#endif

const char *softAP_ssid = APSSID;
const char *softAP_password = APPSK;

/* hostname for mDNS. Should work at least on windows. Try http://esp8266.local */
const char *myHostname = "esp8266";

/* Don't set this wifi credentials. They are configurated at runtime and stored on EEPROM */
char ssid[32] = "";
char password[32] = "";

// DNS server
const byte DNS_PORT = 53;
DNSServer dnsServer;

// Web server
ESP8266WebServer server(80);

/* Soft AP network parameters */
IPAddress apIP(172, 217, 28, 1);
IPAddress netMsk(255, 255, 255, 0);

/** Should I connect to WLAN asap? */
boolean connect;

/** Last time I tried to connect to WLAN */
unsigned long lastConnectTry = 0;

/** Current WLAN status */
unsigned int status = WL_IDLE_STATUS;

/** Is this an IP? */
boolean isIp(String str) {
  for (size_t i = 0; i < str.length(); i++) {
    int c = str.charAt(i);
    if (c != '.' && (c < '0' || c > '9')) {
      return false;
    }
  }
  return true;
}

/** IP to String? */
String toStringIp(IPAddress ip) {
  String res = "";
  for (int i = 0; i < 3; i++) {
    res += String((ip >> (8 * i)) & 0xFF) + ".";
  }
  res += String(((ip >> 8 * 3)) & 0xFF);
  return res;
}

/** Load WLAN credentials from EEPROM */
void loadCredentials()
{
    EEPROM.begin(512);
    EEPROM.get(0, ssid);
    EEPROM.get(0 + sizeof(ssid), password);
    char ok[2 + 1];
    EEPROM.get(0 + sizeof(ssid) + sizeof(password), ok);
    EEPROM.end();
    if (String(ok) != String("OK"))
    {
        ssid[0] = 0;
        password[0] = 0;
    }
    Serial.println("Recovered credentials:");
    Serial.println(ssid);
    Serial.println(strlen(password) > 0 ? "********" : "<no password>");
}

/** Store WLAN credentials to EEPROM */
void saveCredentials()
{
    EEPROM.begin(512);
    EEPROM.put(0, ssid);
    EEPROM.put(0 + sizeof(ssid), password);
    char ok[2 + 1] = "OK";
    EEPROM.put(0 + sizeof(ssid) + sizeof(password), ok);
    EEPROM.commit();
    EEPROM.end();
}


/** Handle root or redirect to captive portal */
void handleRoot()
{
    if (captivePortal())
    { // If caprive portal redirect instead of displaying the page.
        return;
    }
    server.sendHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    server.sendHeader("Pragma", "no-cache");
    server.sendHeader("Expires", "-1");

    String Page;
    Page += F(
        "<html>"
        "<title>NightLighter</title>"
        "<meta charset=\"UTF-8\" />"
		"<meta name=\"viewport\" content=\"width=device-width, user-scalable=no\">"
		"<style>*{box-sizing:border-box}body{font-family:sans-serif,arial;color:lightgray;background-size:cover;height:100vh;font-size:16px;background:#2f414d;height:100vh;font-size:16px;display:flex;align-items:center;justify-content:center}h1{text-align:center}p{text-align:center;padding:15px 0}a{text-decoration:none;color:lightgray}.button{display:inline-block;padding:15px;border:1px solid #fff;text-align:center;background:#006400}"
		"</style><body><main><h1>NightLighter</h1>"
        );
    if (server.client().localIP() == apIP)
    {
        Page += String(F("<p>You are not connected to the internet</p>"));
        Page += F("<p><a class=\"button\" href=\"/wifi\">Connect to your WIFI</a></p>");
    }
    else
    {
        Page += String(F("<p>You are connected through the wifi network: ")) + ssid + F("</p>");
        Page += F("<p><a class=\"button\" href=\"/wifi\">Change your WIFI connection</a></p>");
    }
        Page += F("</body></html>");

    server.send(200, "text/html", Page);
}

/** Redirect to captive portal if we got a request for another domain. Return true in that case so the page handler do not try to handle the request again. */
boolean captivePortal()
{
    if (!isIp(server.hostHeader()) && server.hostHeader() != (String(myHostname) + ".local"))
    {
        Serial.println("Request redirected to captive portal");
        server.sendHeader("Location", String("http://") + toStringIp(server.client().localIP()), true);
        server.send(302, "text/plain", ""); // Empty content inhibits Content-length header so we have to close the socket ourselves.
        server.client().stop();             // Stop is needed because we sent no content length
        return true;
    }
    return false;
}

/** Wifi config page handler */
void handleWifi()
{
    server.sendHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    server.sendHeader("Pragma", "no-cache");
    server.sendHeader("Expires", "-1");

    String Page;
    Page += F(
        "<html><head><title>NightLighter</title>"
    "<meta charset=\"UTF-8\" />"
    "<meta name=\"viewport\" content=\"width=device-width, user-scalable=no\" />"
    "<style>*{box-sizing:border-box}body{font-family:sans-serif,arial;color:lightgray;background-size:cover;height:100vh;font-size:16px;background:#2f414d;height:100vh;font-size:16px;display:flex;align-items:center;justify-content:center}h1{text-align:center}p{text-align:center;padding:15px 0}a{text-decoration:none;color:lightgray}.button{display:inline-block;padding:15px;border:1px solid #fff;border-radius:0;text-align:center;background:#006400;min-width:120px;color:lightgray;font-size:16px;-webkit-appearance:none;-webkit-border-radius:0}select{min-width:120px;min-height:25px;outline:none;-webkit-appearance:none;-webkit-border-radius:0;color:gray;font-size:16px;padding-left:7px;width:120px;background:#fff}.p{padding:15px 0}.form-group{position:relative;margin:0 auto;width:120px}.form-group input{min-width:120px;min-height:25px;outline:none;width:120px;color:gray;-webkit-appearance:none;-webkit-border-radius:0}.form-control-placeholder{position:absolute;top:0;padding:7px 0 3px 7px;transition:all 200ms;left:0;color:gray}.form-control:focus + .form-control-placeholder,.form-control:valid + .form-control-placeholder{font-size:75%;transform:translate3d(0,-100%,0)}</style>"
    "</head><body><main><h1>Wifi config</h1>");
    // if (server.client().localIP() == apIP)
    // {
    //     Page += String(F("<p>You are connected through the soft AP: ")) + softAP_ssid + F("</p>");
    // }
    // else
    // {
    //     Page += String(F("<p>You are connected through the wifi network: ")) + ssid + F("</p>");
    // }
    Serial.println("scan start");
    int n = WiFi.scanNetworks();
    Serial.println("scan done");
    
    Page += F("<form method='POST' action='wifisave'>");
    if (n > 0)
    {
        Page += F("<p><select name=\"n\"><option disabled>Choose your WIFI</option>");
        for (int i = 0; i < n; i++)
        {
            Page += String(F("<option value=")) + WiFi.SSID(i) + F("\" ") + (WiFi.SSID(i) == ssid ? F("selected>") : F(">")) + WiFi.SSID(i) + F("</option>");
        }
        Page += F("</select></p>");
    }
    else
    {
        Page += F("<p>No WIFI found</p>");
    }
    Page += F(
        "<div class=\"p\"><div class=\"form-group\">"
		"<input type=\"password\" name=\"p\" id=\"password\" class=\"form-control\" required>"
		"<label class=\"form-control-placeholder\" for=\"password\">Password</label>"
		"</div></div>"
        "<p><input class=\"button\" type=\"submit\" value=\"Connect\" /></p>"
        "</form></main></body></html>");
    server.send(200, "text/html", Page);
    server.client().stop(); // Stop is needed because we sent no content length
}

/** Handle the WLAN save form and redirect to WLAN config page again */
void handleWifiSave()
{
    Serial.println("wifi save");
    server.arg("n").toCharArray(ssid, sizeof(ssid) - 1);
    server.arg("p").toCharArray(password, sizeof(password) - 1);
    server.sendHeader("Location", "wifi", true);
    server.sendHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    server.sendHeader("Pragma", "no-cache");
    server.sendHeader("Expires", "-1");
    server.send(302, "text/plain", ""); // Empty content inhibits Content-length header so we have to close the socket ourselves.
    server.client().stop();             // Stop is needed because we sent no content length
    saveCredentials();
    connect = strlen(ssid) > 0; // Request WLAN connect with new credentials if there is a SSID
}

void handleNotFound()
{
    if (captivePortal())
    { // If caprive portal redirect instead of displaying the error page.
        return;
    }
    String message = F("File Not Found\n\n");
    message += F("URI: ");
    message += server.uri();
    message += F("\nMethod: ");
    message += (server.method() == HTTP_GET) ? "GET" : "POST";
    message += F("\nArguments: ");
    message += server.args();
    message += F("\n");

    for (uint8_t i = 0; i < server.args(); i++)
    {
        message += String(F(" ")) + server.argName(i) + F(": ") + server.arg(i) + F("\n");
    }
    server.sendHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    server.sendHeader("Pragma", "no-cache");
    server.sendHeader("Expires", "-1");
    server.send(404, "text/plain", message);
}



void setup()
{
    delay(1000);
    Serial.begin(9600);
    Serial.println();
    Serial.println("Configuring access point...");
    /* You can remove the password parameter if you want the AP to be open. */
    WiFi.softAPConfig(apIP, apIP, netMsk);
    WiFi.softAP(softAP_ssid, softAP_password);
    delay(500); // Without delay I've seen the IP address blank
    Serial.print("AP IP address: ");
    Serial.println(WiFi.softAPIP());

    /* Setup the DNS server redirecting all the domains to the apIP */
    dnsServer.setErrorReplyCode(DNSReplyCode::NoError);
    dnsServer.start(DNS_PORT, "*", apIP);

    /* Setup web pages: root, wifi config pages, SO captive portal detectors and not found. */
    server.on("/", handleRoot);
    server.on("/wifi", handleWifi);
    server.on("/wifisave", handleWifiSave);
    server.on("/generate_204", handleRoot); //Android captive portal. Maybe not needed. Might be handled by notFound handler.
    server.on("/fwlink", handleRoot);       //Microsoft captive portal. Maybe not needed. Might be handled by notFound handler.
    server.onNotFound(handleNotFound);
    server.begin(); // Web server start
    Serial.println("HTTP server started");
    loadCredentials();          // Load WLAN credentials from network
    connect = strlen(ssid) > 0; // Request WLAN connect if there is a SSID
}

void connectWifi()
{
    Serial.println("Connecting as wifi client...");
    WiFi.disconnect();
    WiFi.begin(ssid, password);
    int connRes = WiFi.waitForConnectResult();
    Serial.print("connRes: ");
    Serial.println(connRes);
}

void loop()
{
    if (connect)
    {
        Serial.println("Connect requested");
        connect = false;
        connectWifi();
        lastConnectTry = millis();
    }
    {
        unsigned int s = WiFi.status();
        if (s == 0 && millis() > (lastConnectTry + 60000))
        {
            /* If WLAN disconnected and idle try to connect */
            /* Don't set retry time too low as retry interfere the softAP operation */
            connect = true;
        }
        if (status != s)
        { // WLAN status change
            Serial.print("Status: ");
            Serial.println(s);
            status = s;
            if (s == WL_CONNECTED)
            {
                /* Just connected to WLAN */
                Serial.println("");
                Serial.print("Connected to ");
                Serial.println(ssid);
                Serial.print("IP address: ");
                Serial.println(WiFi.localIP());

                // Setup MDNS responder
                if (!MDNS.begin(myHostname))
                {
                    Serial.println("Error setting up MDNS responder!");
                }
                else
                {
                    Serial.println("mDNS responder started");
                    // Add service to MDNS-SD
                    MDNS.addService("http", "tcp", 80);
                }
            }
            else if (s == WL_NO_SSID_AVAIL)
            {
                WiFi.disconnect();
            }
        }
        if (s == WL_CONNECTED)
        {
            MDNS.update();
        }
    }
    // Do work:
    //DNS
    dnsServer.processNextRequest();
    //HTTP
    server.handleClient();
}