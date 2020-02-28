
#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <Ultrasonic.h>

/*
   TRIGGER DEFINITIONS
*/

#define TRIGGER_S1 D1
#define TRIGGER_S2 D2
#define TRIGGER_S3 D3
#define TRIGGER_S4 D4
#define AUTO D0
/*
   ECHO DEFINITIONS
*/
#define ECHO_S1 D5
#define ECHO_S2 D6
#define ECHO_S3 D7
#define ECHO_S4 D8

/*
   MQTT CLIENT CONSTANTS DECLARATIONS
*/

const char* ssid = "Dr.Ghonzo";
const char* password = "Indestructible";
const char* mqttServer = "192.168.2.2";
const int mqttPort = 1883;
const char* mqttUser = "YourMQTTUsername";
const char* mqttPassword = "YourMQTTPassword";

WiFiClient espClient;
PubSubClient client(espClient);

class Sensor {
  private:
    Ultrasonic *sensor;
    PubSubClient *_client;
    int trigger, echo, maxDistance;
    char gap = 100;

  public:
    char *topic, *message;
    int inGap;
    /*
       CONSTRUCTOR METHOD
    */
    Sensor(PubSubClient *_client, int trigger, int echo, int maxDistance, char* topic, char* message) {
      this->trigger = trigger;
      this->echo = echo;
      this->maxDistance = maxDistance;
      this->topic = topic;
      this->message = message;
      this->_client = _client;

      sensor = new Ultrasonic(trigger, echo);
    }
    /*
       EVENT GENERATOR METHOD
    */
    boolean event() {
      volatile int distance = sensor->read();
      if (distance > maxDistance - (gap / 2) && distance < maxDistance + (gap / 2)) {
        return true;
      } else {
        inGap = 0;
        return false;
      }
    }
    /*
       EVENT HANDLER WITH PUBLISHER METHOD
    */
    void eventHandler() {
      while (event()) {
        inGap++;
        if (inGap == 10) {
          Serial.println(" >> event true << ");
          Serial.print(topic);
          Serial.print("\t");
          Serial.println(message);
          _client->publish(topic, message);
          inGap = 0;
        }
        delay(50);
      }
    }

    /*
       EVENT SUPERVISOR METHOD
    */
    void checkEvents() {
      eventHandler();
    }
};

void wifi_connect() {
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    digitalWrite(LED_BUILTIN, HIGH);
    Serial.println("Connecting to WiFi..");
    delay(500);
  }
  Serial.println("Connected to the WiFi network");
}

void callback(char* topic, byte* payload, unsigned int length) {
  byte* p = (byte*)malloc(length);
  memcpy(p, payload, length);
  char s[6];
  snprintf(s, 6, "%s", p);
  if (s == "reset") {
    Serial.println("control reset");
    client.publish("control", p, length);
  }
  if (s == "on") {
    Serial.println("automata on");
    digitalWrite(AUTO, false);
    client.publish("automata", p, length);
  }
  if (s == "off") {
    Serial.println("automata off");
    digitalWrite(AUTO, true);
    client.publish("automata", p, length);
  }
  free(p);
}

void mqtt_connect() {
  if (WiFi.status() != WL_CONNECTED) {
    wifi_connect();
  }
  client.setServer(mqttServer, mqttPort);
  client.setCallback(callback);
  while (!client.connected()) {
    Serial.println("Connecting to MQTT...");
    digitalWrite(LED_BUILTIN, HIGH);
    if (client.connect("ESP8266", mqttUser, mqttPassword ))
    {
      Serial.println("MQTT connected");
      digitalWrite(LED_BUILTIN, LOW);
    } else {
      Serial.print("failed with state ");
      Serial.println(client.state());
      digitalWrite(LED_BUILTIN, HIGH);
      delay(500);
    }
  }
  client.publish("sala_1", "ESP Connected");
  client.subscribe("control");
  client.subscribe("automata");
}

Sensor S1(&client, TRIGGER_S1, ECHO_S1, 150, "sala_1", "sensor_1");
Sensor S2(&client, TRIGGER_S2, ECHO_S2, 100, "sala_1", "sensor_2");
Sensor S3(&client, TRIGGER_S3, ECHO_S3, 100, "sala_2", "sensor_1");
Sensor S4(&client, TRIGGER_S4, ECHO_S4, 100, "sala_2", "sensor_2");

void setup()
{
  pinMode(AUTO, OUTPUT);
  digitalWrite(AUTO, false);
  pinMode(LED_BUILTIN, OUTPUT);
  Serial.begin(115200);
  client.setServer(mqttServer, mqttPort);
  client.setCallback(callback);
}

void loop() {
  if (WiFi.status() != WL_CONNECTED) {
    wifi_connect();
  }
  if (!client.connected()) {
    mqtt_connect();
  }

  S1.checkEvents();
  S2.checkEvents();
  S3.checkEvents();
  S4.checkEvents();

  client.loop();

}
