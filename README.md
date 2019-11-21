# RTL433 to mqtt gateway

[![Build Status](https://travis-ci.org/kpucynski/RTL433-to-mqtt.svg?branch=master)](https://travis-ci.org/kpucynski/RTL433-to-mqtt)
![Style Check Status](https://github.com/kpucynski/RTL433-to-mqtt/workflows/Python%20Style%20Checker/badge.svg)
![Docker CI Status](https://github.com/kpucynski/RTL433-to-mqtt/workflows/Docker%20Image%20CI/badge.svg)


This small script is a cheap and easy way to start with IoT projects.
By using the great rtl_433 software and a cheap RTL-SDR receiver it will listen to all kinds of devices transmitting at the 433,92 Mhz frequency.

Quite likely it will receive information from weatherstations in your area,
if you don't own one, your neighbours might!
It will also receive signals from remote controls that are popular to use to
control the lights.

It's one way. You can receive a lot of information, but you can not send any!

## MQTT Topics
The gateway will receive information from the SDR receiver and publish them in JSON format to the topic `sensors/rtl_433`. (Without the slash!)

Subtopics are created from this JSON line allowing to easily subscribe to specific sensors.

Testing can be done with the following command:
```bash
mosquitto_sub -h mqtt.example.com -p 1883 -v -t "sensors/#"
```

This will generate output like this:

```
rtl433-mqtt-gateway    | RTL: {"time" : "2019-10-13 20:16:54", "brand" : "LaCrosse", "model" : "LaCrosse-TX29IT", "id" : 10, "battery_ok" : 1, "newbattery" : 0, "temperature_C" : 17.100, "humidity" : 68, "mic" : "CRC"}
rtl433-mqtt-gateway    | 
rtl433-mqtt-gateway    | Sending PUBLISH (d0, q0, r1, m42), 'b'sensors/rtl_433/LaCrosse-TX29IT/10'', ... (189 bytes)
rtl433-mqtt-gateway    | Pub: 42
```

## Configuration
Setup env variables for your docker. For example in docker-compose:

```
version: '3.6'
services:
  rtl433-mqtt-gateway:
    container_name: rtl433-mqtt-gateway
    image: rtl433-mqtt-gateway:latest
    restart: always
    environment:
      MQTT_USER: "homeassistant"
      MQTT_PASS: "password"
      MQTT_HOST: "localhost"
      MQTT_PORT: 1883
      MQTT_TOPIC: "sensors/rtl_433"
      MQTT_QOS: 0
      RTL_OPTS: "-d 1 -f 868200000 -M newmodel"
      DEBUG: "False"
    devices:
      - /dev/bus/usb
    privileged: true
    network_mode: host
```

Once you're done you can connect the RTL-SDR to a USB port and start using the
python script.

## Docker build
A `Dockerfile` is included as well. Use it if you want to run this software in a Docker container.

Navigate to the `src` directory of this project and enter the following command:

```bash
docker build -t rtl433-mqtt-gateway .
```

This will build the image needed to start a container. When the build process is completed start the container:

```bash
docker run --name rtl_433 -d --rm --privileged -v /dev/bus/usb:/dev/bus/usb  rtl433-mqtt-gateway
```
