#include "ConsoleUI.h"
#include <iostream>
#include <conio.h>
#include <stdio.h>
#include <windows.h>

TextField::TextField(int _x, int _y, int _width, int _height)
{
    x = _x;
    y = _y;
    width = _width;
    height = _height;
}

void TextField::console_gotoxy(int x, int y)
{
    COORD c;
    c.X = x;
    c.Y = y;

    SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), c);
}

int TextField::get_width()
{
    return width;
}

int TextField::get_height()
{
    return height;
}

void TextField::render()
{
    int row_offset = 0;
    for (const auto& line : lines)
    {
        console_gotoxy(x, y+row_offset);
        printf("%s", line.c_str());
        row_offset++;

        if (row_offset > height)
            break;
    }
}

void TextField::clear_text()
{
    lines.clear();
}

bool TextField::add_line(std::string line, bool roll_up)
{
    if (lines.size() >= height)
    {
        if (roll_up)
            lines.pop_front();
        else
            return false;
    }

    lines.push_back(line);
    return true;
}

//------------

ConsoleUI::ConsoleUI(std::string _title)
{
    title = _title;
    std_out_handle = GetStdHandle(STD_OUTPUT_HANDLE);


    CONSOLE_SCREEN_BUFFER_INFO csbi;

    GetConsoleScreenBufferInfo(std_out_handle, &csbi);
    old_color_attr = csbi.wAttributes;
    SetConsoleTextAttribute(std_out_handle, FOREGROUND_GREEN | BACKGROUND_BLUE | FOREGROUND_INTENSITY );
}

ConsoleUI::~ConsoleUI()
{
    SetConsoleTextAttribute(std_out_handle, old_color_attr);
}

void ConsoleUI::query_console_size()
{
    CONSOLE_SCREEN_BUFFER_INFO csbi;

    GetConsoleScreenBufferInfo(std_out_handle, &csbi);
    console_width = csbi.srWindow.Right - csbi.srWindow.Left + 1;
    console_height = csbi.srWindow.Bottom - csbi.srWindow.Top + 1;
}

std::tuple<int, int> ConsoleUI::get_screen_size()
{
    query_console_size();
    return {console_width ,console_height};
}

void ConsoleUI::render_screen()
{
    system("cls");

    COORD c;
    c.X = 0;
    c.Y = 0;
    SetConsoleCursorPosition(std_out_handle, c);
    printf("%s", title.c_str());

    for (auto& text_field : text_fields)
    {
        text_field.render();
    }
}

void ConsoleUI::clear_all()
{
    for (auto& text_field : text_fields)
    {
        text_field.clear_text();
    }
}

TextField& ConsoleUI::create_text_field(int x, int y, int width, int height)
{
    text_fields.emplace_back(x, y, width, height);
    return text_fields.back();
}

int ConsoleUI::read_hex_integer(int x, int y, const std::string& caption_text)
{
    COORD c;
    c.X = x;
    c.Y = y;
    SetConsoleCursorPosition(std_out_handle, c);

    printf("%s ", caption_text.c_str());
    int ret_val = 0;
    std::cin >> std::hex >> ret_val;
    return ret_val;
}