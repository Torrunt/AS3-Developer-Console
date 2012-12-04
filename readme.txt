Torrunt's AS3 Developer Console
===============================

An AS3 class that let's you access every public variable/function (that can be accessed from your main class) in your project while it's running using a very simple console user interface.

For the latest update notes go to:
https://github.com/Torrunt/AS3-Developer-Console/wiki/Update-Notes

Author
-------
Corey Zeke Womack (Torrunt) - me@torrunt.net

http://torrunt.net

Features
--------
- The ability to access/use any public function or variable in your project!
- The ability to access/use imported classes and their static functions and variables!
- Auto-complete/ Suggestions (use up/down keys to cycle through them)
- Used commands History (use up/down to cycle through them when the auto-complete box is NOT showing)
- Calculations (+,-,/,*,%)
- Shorthand calculations (+=,-=,/=,etc)
- Echo function with multiple colours!
- Ability to do multiple commands at once (e.g: function(); something += 2; function2();)
- Multiplying Commands: Put an x plus a number after a command to repeat it that many times (e.g: spawnEnemy();x5)
- Tracer: Tracer things easily with the Tracer table and/or the built in trace().
- FPS Counter: See what your current FPS is using the Tracer.
- Temporary Variables: Create and use variables through the console

Install
--------
Simply create an instance of the developerconsole, add it and call console.toggle() to open/close it (or console.open() and console.close()).

For full instructions (including an example) for those who need it can be read over at:
https://github.com/Torrunt/AS3-Developer-Console/wiki/Install-Instructions