#pragma once
#include "hidapi.h"

class HIDDeviceInterface
{	private:
		unsigned short vid;
		unsigned short pid;
		int dev_to_host_buff_size;
		int host_to_dev_buff_size;
		hid_device* device_handle;
	public:
		HIDDeviceInterface(unsigned short _vid, unsigned short _pid, int _dev_to_host_buff_size=64, int _host_to_dev_buff_size=64);
		~HIDDeviceInterface();
		int connect();
		void disconnect();
		int read_device(unsigned char* buffer, int buffer_size);
		int write_device(unsigned char* buffer, int buffer_size);
};

