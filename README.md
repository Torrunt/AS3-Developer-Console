## Torrunt's AS3 Developer Console

An AS3 class that let's you access every public variable/function (that can be accessed from your main class) in your project while it's running using a very simple console user interface.

<img src="http://i.imgur.com/Dv2AwZC.png" height="200px" /> <img src="http://i.imgur.com/DrraFtq.png" height="200px" /> 
<img src="http://i.imgur.com/8evr8gL.png" height="200px" /> <img src="http://i.imgur.com/JYTymGT.png" height="200px" />

[Download the latest version](https://github.com/Torrunt/AS3-Developer-Console/archive/master.zip)

[Update Notes](https://github.com/Torrunt/AS3-Developer-Console/commits/master)

### Created by
Corey Zeke Womack (Torrunt) - [me@torrunt.net](mailto:me@torrunt.net) - [torrunt.net](http://torrunt.net)

### Features
- The ability to access/use any public function or variable in your project
- The ability to access/use imported classes and their static functions and variables
- Auto-complete/ Suggestions (use up/down keys to cycle through them)
- Used commands History (use up/down to cycle through them when the auto-complete box is NOT showing)
- Calculations (+,-,/,*,%)
- Shorthand calculations (+=, -=, /=, *=, %=)
- Echo function with custom colours as well as error and warn functions
- Ability to enter multiple commands at once (eg: function(); something += 2; function2();)
- Multiplying Commands: Put an x and a number after a command to repeat it that many times (eg: spawnEnemy();x5)
- Tracer: Trace things easily with the Tracer table and/or the built in trace()
- FPS Counter: See what your current FPS is using the Tracer (trace:fps)
- Temporary Variables: Create and use temporary variables through the console (eg: blah = new flash.geom.Point(5,2); blah.x *= 2;)

### Install
Simply create an instance of the DeveloperConsole, add it and call console.toggle() to open/close it (or console.open() and console.close()).

[Full instructions + example](https://github.com/Torrunt/AS3-Developer-Console/wiki/Install-Instructions)