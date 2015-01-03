Hello everyone! This is my first API post so go easy on me. =P

This is an OpenComputers gui framework, its currrent features are:
Movable Windows
Buttons
Textboxes
Text inputs

----------------
Points
----------------
Points are just a component I used for declaring positions, not much use in other code, created like so:

p = point( x, y )
term.write( p.x )
term.write( p.y )

points can also be added together:
p1 + p2

----------------
Windows
----------------
Windows create an area on the screen where components can be added, they are constructed like so

window1 = window( point, width, height, title, foreground colour, background colour )

Note that point must be a point object such as point( 5, 5 )

Foreground and background colours are hex values like ( 0xFF0000 )

----------------
Buttons
----------------

Buttons create a labelled area on the screen that can be clicked

exitButton = button( window, point, width, height, label, foreground colour, background colour, clickedMethod )

Window is the window that the button is contained in

Remember that when putting in the clickedMethod it should be for example foo, not foo()

----------------
TextBox
----------------

Textboxes are areas on the screen that contain text

textBox1 = textBox( window, point, width, height, text, foreground colour, background colour )

Note that the text automatically wraps inside the text box

----------------
TextInput
----------------

A textinput is an area on the screen that can be clicked and typed in

textInput1 = textInput( window, point, width, foreground colour, background colour )

Its text can be retrieved like so:

someText = textBox1.text

----------------
GUILoop
----------------

The GUI loop runs the main loop of the program, it's called like so:

GUILoop( background colour )