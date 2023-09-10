#include "HIDDeviceInterface.h"

HIDDeviceInterface::HIDDeviceInterface(unsigned short _vid, unsigned short _pid, int _dev_to_host_buff_size, int _host_to_dev_buff_size):
	vid(_vid),pid(_pid), dev_to_host_buff_size(_dev_to_host_buff_size), host_to_dev_buff_size(_host_to_dev_buff_size),
    device_handle(NULL)
{
	hid_init();
}

HIDDeviceInterface::~HIDDeviceInterface()
{
    hid_exit();
}

int HIDDeviceInterface::connect()
{
    device_handle = hid_open(vid, pid, NULL);
    if (device_handle == NULL)
        return -1;
 
    hid_set_nonblocking(device_handle, 1);
    return 0;
}

void HIDDeviceInterface::disconnect()
{
    hid_close(device_handle);
    device_handle = NULL;
}

int HIDDeviceInterface::read_device(unsigned char* buffer, int buffer_size)
{
    if (!device_handle)
        return -1;

    return hid_read(device_handle, buffer, buffer_size> dev_to_host_buff_size ? dev_to_host_buff_size : buffer_size);
}

int HIDDeviceInterface::write_device(unsigned char* buffer, int buffer_size)
{
    if (!device_handle)
        return -1;

    return hid_send_feature_report(device_handle, buffer, buffer_size > host_to_dev_buff_size ? host_to_dev_buff_size : buffer_size);
}