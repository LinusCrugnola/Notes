---
title: " GTKmm Overview"
author: "Linus Crugnola"
institution: "EPFL"
date: "04.04.2022"
---

# Introduction 
GTKmm is a C++ wrapper for the GTK+ library, it wraps functionality of GTK+ into a class structure to provide better usability inside a C++ Project.

## Installation:
On Linux GTKmm is installed per default but we have to get the developers package in order to being able to compile code including GTKmm:
```bash
$ sudo apt install libgtkmm-3.0-dev
```

## Include GTKmm in C++ code:
To include the GTKmm API we have to use the following directive:
```cpp
#include <gtkmm.h>
```

## Compile the code
To compile code including the GTKmm library with g++ we have to use the following flags:
```bash
$ g++ myfile.cc -std=c++11 -Wall -o a.out `pkg-config gtkmm-3.0 --cflags --libs`
```
This shows the compiler that we use GTKmm. **Note:** we must use backquotes!

# Intro: Basic GUI Elements

## Create a window:

To create a window we first have to create an application pointer:
```cpp
auto app = Gtk::Application::create(); // app becomes a pointer
```
After this we can create the actual window and set its default size:
```cpp
Gtk::Window window;
window.set_default_size(200,200); // set size to 200x200 px
window.set_title("window"); // set window title
```
To display the window we then have to run the app:
```cpp
return app->run(window); // instead of return 0 in main
```
This opens a window on the computer and keeps the program running until the window is closed.

## Widgets
GTKmm is organized in widgets, we add them by appending them to other items e.g. adding a button to a box:
```cpp
m_box.append(m_Button);
```

## Example Create a button:
We have to include the application API:
```cpp
#include <gtkmm/application.h>
```
Then we create an app and we create a class that inherits from GTK window in which we can define our button Object:
```cpp
class MyClass : public Gtk::window{
// constructor, destructor
protected:
// signal handler:
void on_button_clicked();
// Button
Gtk::Button m_button;
};
```
In the constructor of the Button class we define the hello world button:
```cpp
MyButton::MyButton()
    : m_button("Text") // button text
{
    set_border_width(10);
    
    m_button.signal_clicked().connect(sigc::mem_fun(*this,
        &MyButton::on_button_clicked)); // connect user-defined method

    add(m_button); // add button to window
    m_button.show(); // display button
}

// in main we return:
return app->run(myclass); // with the object we created
```
In the scope in which the app is defined we can now construct an Object of MyClass and a button with *Text* written on it appears

# Draw with Cairomm

## Drawing Area:
To draw things, we use the widget DrawingArea, thus we have to create an object that inherits from DrawingArea and that **overrides the method on_draw()**. 
```cpp
class MyArea : public Gtk::DrawingArea{
protected:
    bool on_draw(const Cairo::RefPtr<Cairo::Context>& cr) override;
};

// on_draw():
bool MyArea::on_draw(...){
    // Get window parameters
    Gtk::Allocation allocation = get_allocation();
    const int width = allocation.get_width(); //same for height
    // draw stuff with cr->...
    return true;
}
```
In the scope of the application we have to create MyArea and add it to the window like the button in the example above and return the window in the main. The current parameters of a drawing can be stored in the Cairo::Context object so the drawing functions don't need to recreate those parameters with each call. 

## Basic Cairomm commands:
Note cr is the cairo reference pointer that must be passed to a on_draw() function.
```cpp
// set background colour (memorised in cairo object)
cr->set_source_rgb(r, g, b); 
// paint the background
cr->paint();
// create a line
cr->set_line_width(double);
cr->set_source_rgb(r, g, b);
cr->move_to(x, y); // (0,0) is the top left corner
cr->line_to(xn, yn); // creates the line
cr->stroke(); // draws the line
```

## Coordinate transforms:
Cairo proides methods to change the origin of the drawing to the bottom left corner:
```cpp
cr->translate(width/2, height/2); // moves to (x,y)
cr->scale(width/x_step, height/y_step); // scales to x, y
cr->translate(-xm, -ym); // middle point is (xm, ym)
```

# Keyboard inputs



# Buttons:
There are three main types of buttons:

## 1. Push Button:
As in the example above we derive our button from GTK::Button class. A Button is also a container, so we can put other widgets into it. <br>
To bind the Button to a keyboard key we define it like this:
```cpp
Gtk::Button* pButton = new Gtk::Button("_Something", true);

## 2. Toggle Buttons

## 3. Check Buttons