#include <conio.h>
#include <thread>
#include <chrono>

#include "HID-Test.h"
#include "HIDDeviceInterface.h"
#include "ConsoleUI.h"
#include <iostream>

int getch_noblock() {
	if (_kbhit())
		return _getch();
	else
		return -1;
}

void print_buffer(TextField& tf, unsigned char* buffer, int buffer_size, int start_index, int count)
{
	int current_index = start_index;
	const int numbers_per_line = (int)(tf.get_width() / 3); //1 buffer value: 2 hex characters + 1 space
	while (current_index < start_index + count)
	{
		std::string line = "";
		for (int i = current_index; i < current_index + numbers_per_line; i++)
		{
			if (i >= buffer_size)
				break;

			line = line + std::format("{:02x}", buffer[i]) + " ";
		}
		tf.add_line(line);
		current_index += numbers_per_line;
	}
}

int main(int argc, char* argv[])
{
	unsigned short vid = 0;
	unsigned short pid = 0;
	if (argc >= 3)
	{
		vid = atoi(argv[1]);
		pid = atoi(argv[2]);
	}
	else
	{
		vid = ARDUINO_VID;
		pid = ARDUINO_PID;
	}

	const int device_to_host_buffer_size = 64;
	const int host_to_device_buffer_size = 64;

	unsigned char device_to_host_buffer[device_to_host_buffer_size];
	unsigned char host_to_device_buffer[host_to_device_buffer_size];

	memset(device_to_host_buffer, 0, sizeof(device_to_host_buffer));
	memset(host_to_device_buffer, 0, sizeof(host_to_device_buffer));

	HIDDeviceInterface hid_device(vid, pid, device_to_host_buffer_size, host_to_device_buffer_size);
	if (hid_device.connect() < 0)
	{
		std::cout << "Error opening HID device. vid=0x" << std::format("{:02x}", vid) << " pid=0x" << std::format("{:02x}", pid) << std::endl;
		return 1;
	}

	ConsoleUI console("USB HID test application. vid=0x" + std::format("{:02x}", vid) + " pid=0x" + std::format("{:02x}", pid));

	auto [screen_width, screen_height] = console.get_screen_size();

	TextField& tf_read = console.create_text_field(0, 5, 48, 4);
	TextField& tf_write = console.create_text_field(0, 16, 48, 4);

	TextField& tf_help = console.create_text_field(0, screen_height - 2, screen_width, 1);
	tf_help.add_line("r: read, w: write, v: write address, b: write data, p: reconnect, q: exit");

	console.render_screen();
	int write_address = 0;
	int write_data = 0;

	bool run = true;
	while (run)
	{
		char ch = getch_noblock();
		switch (ch)
		{
		case 'q':
			run = false;
			break;

		case 'r':
			if (hid_device.read_device(device_to_host_buffer, device_to_host_buffer_size) < 0)
				tf_read.add_line("error reading device");
			else
				print_buffer(tf_read, device_to_host_buffer, device_to_host_buffer_size-1, 1, device_to_host_buffer_size-1);

			console.render_screen();
			break;

		case 'w':
			host_to_device_buffer[0] = 0; //reserved for report id
			if (hid_device.write_device(host_to_device_buffer, host_to_device_buffer_size) < 0)
				tf_write.add_line("error writing device");
			else
				print_buffer(tf_write, host_to_device_buffer, host_to_device_buffer_size-1, 1, host_to_device_buffer_size-1);

			console.render_screen();
			break;

		case 'v':
			write_address = console.read_hex_integer(0, screen_height - 1, std::string("Enter write address in hex: ")) + 1;
			if (write_address < 0)
				write_address = 0;
			if (write_address >= host_to_device_buffer_size)
				write_address = host_to_device_buffer_size - 1;
			console.render_screen();
			break;

		case 'b':
			write_data = console.read_hex_integer(0, screen_height - 1, std::string("Enter write data in hex: "));
			host_to_device_buffer[write_address] = write_data;
			print_buffer(tf_write, host_to_device_buffer, host_to_device_buffer_size, 0, host_to_device_buffer_size);
			console.render_screen();
			break;

		case 'p':
			hid_device.disconnect();
			if (hid_device.connect() < 0)
				std::cout << "Error opening HID device. vid=0x" << std::format("{:02x}", vid) << " pid=0x" << std::format("{:02x}", pid) << std::endl;
			break;

		default:
			break;
		}

		std::this_thread::sleep_for(std::chrono::milliseconds(100));
	}

	hid_device.disconnect();

	return 0;
}