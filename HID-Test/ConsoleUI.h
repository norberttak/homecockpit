#pragma once
#include <list>
#include <string>

class TextField
{
private:
	int x;
	int y;
	int width;
	int height;
	std::list<std::string> lines;
	void console_gotoxy(int x, int y);
public:
	TextField(int x, int y, int width, int height);
	void clear_text();
	void render();
	int get_width();
	int get_height();
	bool add_line(std::string line, bool roll_up=true);
};

class ConsoleUI
{
private:
	int console_width;
	int console_height;
	std::string title;
	std::list<TextField> text_fields;
	void* std_out_handle;
	unsigned short old_color_attr;
	void query_console_size();
public:
	ConsoleUI(std::string _title);
	~ConsoleUI();
	std::tuple<int, int> get_screen_size();
	void render_screen();
	void clear_all();
	TextField& create_text_field(int x, int y, int width, int height);
	int read_hex_integer(int x, int y, const std::string& caption_text);
};

