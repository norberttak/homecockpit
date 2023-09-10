#include "HID-Project.h"

const int BUFFER_SIZE = 64;
uint8_t data_device_to_host[BUFFER_SIZE]; //feature report's 0 byte is reserved for report id!
uint8_t data_host_to_device[BUFFER_SIZE]; 

const uint8_t PIN_RESET = 8;
const uint8_t PIN_IRQ = 9;
const uint8_t PIN_N_CS = 10;
const uint8_t PIN_MOSI = 11;
const uint8_t PIN_MISO = 12;
const uint8_t PIN_SCK  = 13;

const uint8_t FPGA_CMD_SET_ADDRESS = 0x00;
const uint8_t FPGA_CMD_WRITE_DATA = 0x10;
const uint8_t FPGA_CMD_READ_DATA = 0x20;
const uint8_t FPGA_CMD_BURST_WRITE = 0x30;
const uint8_t FPGA_CMD_BURST_READ = 0x40;

bool buffer_changed = false;
bool first_loop = false;

void setup() {
  pinMode(PIN_RESET, OUTPUT);
  pinMode(PIN_IRQ, INPUT_PULLUP);
  pinMode(PIN_N_CS, OUTPUT);
  pinMode(PIN_MOSI, OUTPUT);
  pinMode(PIN_MISO, INPUT_PULLUP);
  pinMode(PIN_SCK, OUTPUT);

  digitalWrite(PIN_N_CS, HIGH);
  digitalWrite(PIN_MOSI, LOW);
  digitalWrite(PIN_SCK, LOW);

  //reset FPGA
  digitalWrite(PIN_RESET, LOW);
  delay(100);
  digitalWrite(PIN_RESET, HIGH);
  delay(20);

  // setup USB HID interface
  RawHID.begin(data_device_to_host, sizeof(data_device_to_host));
  RawHID.setFeatureReport(data_host_to_device, sizeof(data_host_to_device));
  RawHID.enable();
  RawHID.enableFeatureReport();

  Serial.begin(9600);
  while (!Serial);
  Serial.print("Homecockpit started");

  first_loop = true;
}

uint8_t read_spi_one_byte()
{
  uint8_t ret_val = 0x00;
  uint8_t mask = 0x80;

  for (int i=0; i<8; i++)
  {
    digitalWrite(PIN_SCK,HIGH);

    if (digitalRead(PIN_MISO) == HIGH)
      ret_val += mask;

    digitalWrite(PIN_SCK,LOW);
    mask = mask >> 1;
  }
  
  return ret_val;
}

uint8_t read_fpga_reg(uint8_t address)
{
  digitalWrite(PIN_N_CS,LOW);
  write_spi_one_byte(FPGA_CMD_SET_ADDRESS);
  write_spi_one_byte(address);
  digitalWrite(PIN_N_CS,HIGH);

  digitalWrite(PIN_N_CS,LOW);
  write_spi_one_byte(FPGA_CMD_READ_DATA);  
  uint8_t ret_val = read_spi_one_byte();
  digitalWrite(PIN_N_CS,HIGH);  

  return ret_val;
}

void read_fpga_all_reg(uint8_t address, uint8_t* buffer, unsigned int count)
{
  for (uint8_t i=address; i<count; i++)
    buffer[i] = read_fpga_reg(address+i);
}

void write_spi_one_byte(uint8_t data)
{
  uint8_t mask = 0x80;
  for (int i=0; i<8; i++)
  {    
    if ((data & mask) == mask)
      digitalWrite(PIN_MOSI,HIGH);
    else
      digitalWrite(PIN_MOSI,LOW);

    digitalWrite(PIN_SCK,HIGH);
    digitalWrite(PIN_SCK,LOW);

    mask = mask >> 1;
  }
}

void write_fpga_reg(uint8_t address, uint8_t data)
{
  digitalWrite(PIN_N_CS,LOW);
  write_spi_one_byte(FPGA_CMD_SET_ADDRESS);
  write_spi_one_byte(address);
  
  write_spi_one_byte(FPGA_CMD_WRITE_DATA);
  write_spi_one_byte(data);
  digitalWrite(PIN_N_CS,HIGH);
}

void write_fpga_all_reg(uint8_t address, uint8_t* buffer, unsigned int count)
{
  for (uint8_t i = address; i < count; i++)
    write_fpga_reg(address + i, buffer[i]);
}

void loop() {
  buffer_changed = false;

  // Check if there is new data from the RawHID device
  if (RawHID.availableFeatureReport()) {
    // byte 0 in feature report is reserved for report id
    buffer_changed = true;
    data_host_to_device[2] |= 0x80; // turn on IRQ pin handling
    write_fpga_all_reg(1, &data_host_to_device[1], sizeof(data_host_to_device)-1);    
    RawHID.enableFeatureReport();
  }

  //if any input is changed on the device, it raises the IRQ pin.
  //the read of status register clears the IRQ bit.
  //we need to read all registers in case of previous write happend
  if (digitalRead(PIN_IRQ) == HIGH || buffer_changed == true || first_loop == true) {
    // we don't use the byte 0. set it to 0 as a report id    
    read_fpga_all_reg(0, &data_device_to_host[1], sizeof(data_device_to_host)-1);
    data_device_to_host[0] = 0;
    buffer_changed = true;
  }

  if (buffer_changed)
    RawHID.write(&data_device_to_host[0], sizeof(data_device_to_host));

  first_loop = false;
  delay(20);
}