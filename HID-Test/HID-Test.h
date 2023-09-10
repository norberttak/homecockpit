#pragma once

#include <stdlib.h>
#include <chrono>
#include <thread>
#include <utility>
#include <list>

#define ARDUINO_VID 0x2341
#define ARDUINO_PID 0x8036

#define SAITEK_VID  0x06A3
#define SAITEK_RADIO_PID 0x0D05
#define SAITEK_MULTI_PID 0x0D06
#define SAITEK_SWITCH_PID 0x0D67

#define ARDUINO_DEV_TO_HOST_BUFF_SIZE (64)
#define ARDUINO_HOST_TO_DEV_BUFF_SIZE (64)

#define SAITEK_RADIO_DEV_TO_HOST_BUFF_SIZE (5)
#define SAITEK_RADIO_HOST_TO_DEV_BUFF_SIZE (23)





