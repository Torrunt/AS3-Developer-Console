// What		: AS3 Developer Console - https://github.com/Torrunt/AS3-Developer-Console
// Author	: Corey Zeke Womack (Torrunt)
// Contact	: me@torrunt.net
// Website	: torrunt.net

// Notes:
// - Type 'help' in console for help.
// - If you're testing your project in the Adobe Flash IDE make sure 'Disable Keyboard Shortcuts' is ticked.
// - When testing your project in an Adobe Flash IDE you have to click the swf at least once to be able to see the text cursor.

package 
{
	import flash.display.Sprite;
	import flash.text.*;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.events.Event;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;
	
	public class DeveloperConsole extends Sprite
	{
		
		// Customisation (to customise look go to the constructor)
		
		/** Height (in pixels) of the developer console. */
		public var consoleHeight:Number				= 145;
		/** The max amount of suggestions that can be shown in the suggestion drop-down. */
		public var maxSuggestions:int				= 14;
		/** If true, The data/return types of variables and functions are shown in the suggestion drop-down. */
		public var showTypes:Boolean 				= true;		// show data/return types of vars and functions
		
		/** If true, when assigning variables that don't exist, they will be created as a temporary variable (can't be a member var). */
		public var createVarsThatDontExist:Boolean	= true;
		
		/** If true, when the console is opened/closed a sliding animation is played. */
		public var slideAnimation:Boolean			= true;
		/** The speed of the sliding open/close animation, if slideAnimation is true. */
		public var slideAnimation_speed:Number 		= 15;
		
		/** If true, the tracer table is shown while tracing. */
		public var tracerView:Boolean 				= true;
		/** If true, as3's trace() function is called when using the tracer	(IDE Output). */
		public var tracerActualTrace:Boolean 		= false;
		/** If true, as3's trace() function is called when the tracer is tracing the fps */
		public var tracerActualTraceFPS:Boolean 	= false;
		/** 
		 * The layout of a trace when it is in the IDE Output. 
		 * Default: "name : value"
		 */
		public var tracerActualTraceLayout:String 	= "name : value";
		/** If true, everything traced by the tracer into the IDE Output is placed on a single line. */
		public var tracerOneCiclePerLine:Boolean 	= true;
		/**
		 * If tracerOneCiclePerLine is true, this string is placed inbetween each traced item. 
		 * Default: "   "
		 */
		public var tracerOneCiclePerLine_seperator:String = "   ";
		
		private const colour_type:String = "06C1FF";
		private const colour_param_type:String = "B5B5B5";
		
		private const VERSION_NAME:String = "Torrunt's AS3 Developer Console"
		private const HELP:String = " - Type 'clear' to clear the console\n" + 
									" - Type 'author' to get info on the author of this console\n" + 
									" - Use Quotations when you want enter string literal with spaces (\"\")\n" + 
									" - Use Square Brackets when you want to use an arral literal (e.g:[0][1])\n" +
									" - You can do multiple commands at once by seperating them with ';'s\n" +
									" - You can also put x# after a ';' to do that command # many times\n" +
									" - Calculations are allowed when assigning or in parameters (+,-,*,/,%). BIMDAS is not supported\n" +
									" - Type 'trace:something' to start tracing something or 'stoptrace:something' to stop tracing it\n" +
									" - You can also use 'trace:fps' to check your fps\n" +
									" - Toggle Fullscreen console with the F7 key\n" +
									" - Use the Up/Down arrow keys to go through your previous used commands or suggestions\n" +
									" - Use PAGE UP/DOWN and HOME/END on your keyboard to scroll up and down";
		private const AUTHOR:String = VERSION_NAME + " was programmed by Corey Zeke Womack (Torrunt)\nme@torrunt.net\nhttp://torrunt.net";
		
		// Creating / Defaults
		private var main:*;
		private var opened:Boolean = false;
	
		private var container:Sprite = new Sprite();
		private var suggestText:TextField;
		private var consoleTextFormat:TextFormat;
		private var historyText:TextField;
		private var inputText:TextField;
		
		private var cmdSuggest:Array = new Array();
		private var cmdhistory:Array = new Array();
		private var cicle:Array;
		private var hpos:int = -1;
		
		private const consoleHeight_default:Number = consoleHeight;		
		
		// temp variables
		private var tempVarNames:Array = new Array();
		private var tempVars:Array = new Array();
		
			// slide animation
		private var slideAnimation_animating:Boolean = false;
		private var slideAnimation_target:Number = 0;
		
			// tracer
		private var tracer:TextField;
		private var tracerNames:TextField;
		private var traceVars:Array = new Array();
		private var tracerAlignX:Number;
		private var tracerAlignY:Number;
		
			// fps counter
		public var fps:String;
		private var last:uint = getTimer();
        private var ticks:uint = 0;
		
		// Constructor
		public function DeveloperConsole(_main:*)
		{
			main = _main;	// Start off point for seeing/using variables and functions (main class or frame/stage)
			
			addChild(container);
			
			// Customise Look
				// Text Format
			consoleTextFormat = new TextFormat();
			consoleTextFormat.size = 14;
			consoleTextFormat.font = "Courier New";
			consoleTextFormat.color = 0xFFFFFF;
			
				// History Textbox
			historyText = new TextField();
			container.addChild(historyText);
			
			historyText.width = main.stage.stageWidth;
			historyText.height = consoleHeight - 20;
			historyText.alpha = 0.85;
			historyText.selectable = false;
			historyText.multiline = true;
			historyText.wordWrap = true;
			historyText.defaultTextFormat = consoleTextFormat;
			historyText.background = true;
			historyText.backgroundColor = 0x000000;
			
				// Input Textbox
			inputText = new TextField();
			inputText.type = TextFieldType.INPUT;
			container.addChild(inputText);
			
			inputText.width = main.stage.stageWidth;
			inputText.height = 21;
			inputText.y = historyText.height;
			inputText.x = 0;
			inputText.alpha = 0.85;
			inputText.defaultTextFormat = consoleTextFormat;
			inputText.background = true;
			inputText.backgroundColor = 0x4B4B4B;
			
				// Suggest/auto-complete Textbox
			suggestText = new TextField();
			container.addChild(suggestText);
			
			suggestText.width = 150;
			suggestText.height = 20;
			suggestText.y = inputText.y + inputText.height;
			suggestText.alpha = 0.85;
			suggestText.selectable = false;
			suggestText.defaultTextFormat = consoleTextFormat;
			suggestText.background = true;
			suggestText.backgroundColor = 0x000000;
			suggestText.autoSize = TextFieldAutoSize.LEFT;
			suggestText.visible = false;
			suggestText.multiline = true;
			
				// Tracer
			tracerAlignX = main.stage.stageWidth - 5;
			tracerAlignY = 5;
			
			consoleTextFormat.bold = true;
	
			tracer = new TextField();
			addChild(tracer);
			
			tracer.alpha = 0.75;
			tracer.selectable = false;
			consoleTextFormat.align = "right";
			tracer.defaultTextFormat = consoleTextFormat;
			tracer.background = true;
			tracer.backgroundColor = 0x666666;
			tracer.autoSize = TextFieldAutoSize.LEFT;
			tracer.visible = false;
			
			
			tracerNames = new TextField();
			addChild(tracerNames);
			
			tracerNames.alpha = 0.75;
			tracerNames.selectable = false;
			consoleTextFormat.align = "left";
			tracerNames.defaultTextFormat = consoleTextFormat;
			tracerNames.background = true;
			tracerNames.backgroundColor = 0x666666;
			tracerNames.autoSize = TextFieldAutoSize.LEFT;
			tracerNames.visible = false;
			
			// Startup Message
			echo(VERSION_NAME, "-", "torrunt.net");
			
			// Animation start position
			if (slideAnimation)
				container.y = -historyText.height - inputText.height;
			
			// Hide self
			container.visible = false;
        }
		
		//////////////////////////
		//		Open/Close		//
		/////////////////////////
		
		public function open():void
		{
			if (opened)
				return;
			
			container.visible = true;
			opened = true;
			main.stage.focus = inputText;
			
			main.stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			main.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			inputText.addEventListener(TextEvent.TEXT_INPUT, onTextInput);
			
			
			// animation
			if (slideAnimation)
				startSlideAnimation(true);
		}
		
		public function close():void
		{
			if (!opened)
				return;
				
			container.visible = false;
			opened = false;
			inputText.text = "";
			hpos = -1;
			
			main.stage.removeEventListener(KeyboardEvent.KEY_UP, keyUp);
			main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			inputText.removeEventListener(TextEvent.TEXT_INPUT, onTextInput);
			
			
			// animation
			if (slideAnimation)
				startSlideAnimation(false);
		}
		
		/** Open/Close the developer console. */
		public function toggle():void
		{
			if (opened)
				close();
			else
				open();
		}
		
		public function isOpen():Boolean { return opened; }
		
		//////////////////////////
		//		Controls		//
		/////////////////////////
		
		private var pressedUp:Boolean = false;
		
		private function keyDown(e:KeyboardEvent):void
		{
			// Enter
			if (e.keyCode == 13 && inputText.text != "")
			{
				echo(inputText.text, "#999999");
				
				if (cmdhistory[cmdhistory.length - 1] != inputText.text)
				{
					cmdhistory.push(inputText.text);
					hpos = -1;
				}
				
				eval(inputText.text);
				
				inputText.text = "";
				hideSuggestions();
			}
			
			// Backspace
			if (e.keyCode == 8)
			{
				if (inputText.length-1 <= 0)
					hideSuggestions();
				else
					showSuggestions(inputText.text.substr(0,inputText.length-1));
			}
			
			// Up and Down
				// Pick array to go through
			if (suggestText.visible)
				cicle = cmdSuggest;
			else
				cicle = cmdhistory;
			
				// Up
			if (e.keyCode == 38 && cicle[cicle.length-1-(hpos+1)] != null)
			{
				hpos++;
				changeInputbox();
				pressedUp = true;
			}
				// Down
			if (e.keyCode == 40)
			{
				if (cicle[cicle.length-1-(hpos-1)] != null)
				{
					hpos--;
					changeInputbox();
				}
				else if (cicle == cmdhistory)
				{
					inputText.text = "";
					hpos = -1;
				}
			}
			
			// Scrolling Up and Down
				// Page Up
			if (e.keyCode == 33)
				historyText.scrollV--;
			
				// Page Down
			if (e.keyCode == 34)
				historyText.scrollV++;
				
				// Home
			if (e.keyCode == 36)
				historyText.scrollV = 0;
				
				// End
			if (e.keyCode == 35)
				historyText.scrollV = historyText.maxScrollV;
			
			// Toggle Fullscreen (F7)
			if (e.keyCode == 118)
				toggleFullscreen();
		}
		
			// Fix cursor position if you press up when moving through history or suggestions
		private function keyUp(e:KeyboardEvent):void
		{
			if (pressedUp)
			{
				inputText.setSelection(inputText.length,inputText.length);
				pressedUp = false;
			}
		}
		
		// Change inputbox contents to the next/previous history or suggestion item
		private function changeInputbox():void
		{
			// If going through suggestions: just replace the thing you're currently writing
			if (cicle == cmdSuggest)
			{
				// if last suggestion added a '();' at the end - remove it
				if (inputText.text.lastIndexOf("();")+3 == inputText.length)
					inputText.text = inputText.text.substr(0,inputText.length-3);
				
				// Remove text after last symbol or space
					// get indexs of symbols
				var symbols:Array = fillArrayWithIndexsOf(symbols,inputText.text,["."," ","(",",","-","+","/","*","%",";",":","["]);
					// get highest index (last used symbol)
				var ls:int = symbols[0]; // (last symbol)
				for (var i:int = 1; i < symbols.length; i++)
				{
					if (symbols[i] > ls)
						ls = symbols[i];
				}
				
				// if the last symbol is a bracket and is the last thing in the inputbox: make it the second last symbol
				if (inputText.text.charAt(ls) == "(" && (ls == inputText.length-1))
				{
					inputText.text = inputText.text.substr(0,ls);
					changeInputbox();
					return;
				}
				
				// Remove what you're currently writing
				inputText.text = inputText.text.substr(0,ls+1);
				// Appened suggestion
				inputText.appendText(cicle[cicle.length-1-hpos]);
			}
			else
			{
				// Otherwise replace the whole inputText
				inputText.text = cicle[cicle.length-1-hpos]; // Replace text
			}
			
			inputText.setSelection(inputText.length,inputText.length);
		}
		
		//////////////////////////
		//		Suggesting		//
		/////////////////////////
		
		// Defaulting
		private var areSuggestions:Boolean = false;
		private var hitMax:Boolean = false;
		
		// Update while typing
		private function onTextInput(e:TextEvent):void
		{
			if (e.text == "`" || inputText.text == "`")
				inputText.text = inputText.text.slice(0, -1);
			
			showSuggestions(inputText.text + e.text);
		}
		
		private function showSuggestions(str:String):void
		{
			// reset to defaults
			hideSuggestions();	// hide previous
			areSuggestions = false;
			hitMax = false;
			
			if (str.length == 0)
				return;
			
			// check for ';'s (end of commands)
			if (str.indexOf(";") > 1)
				str = str.slice(str.lastIndexOf(";")+1,str.length);
			
			// change str to latest var user is writing
			str = stringReplaceAll(str," ");
			
			var symbols:Array = fillArrayWithIndexsOf(symbols,str,["(","=",",","-","+","/","*","%",":","["]);
			
				// Don't look for '[' or '(' if last one was closed
			if (characterCount(str,"]") == characterCount(str,"["))
				symbols.pop();
			if (characterCount(str, ")") == characterCount(str, "("))
				symbols.shift();
			
			var startFrom:int = symbols[0];
			
			for (var s:int = 1; s < symbols.length; s++)
				if (symbols[s] > startFrom) startFrom = symbols[s];
			str = str.substring(startFrom+1,str.length);
			
			// Get all public Vars and Functions
			if (str != "")
			{
				try
				{
					// FIND ME
					var ob:* = stringToVarWithCalculation(str, main, true);
					var stre:String = str.substring(str.lastIndexOf(".")+1,str.length);
					
					var description:XML = describeType(ob);
					
					var type:String = "";
					
					if (description.*.length() > 3) // if 3 (or less) that means ob doesn't exist
					{
						// Vars
						for each (var v:XML in description.variable)
						{
							if (suggestText.numLines < maxSuggestions)
							{
								if(v.@name.indexOf(stre) == 0)
								{
									if (showTypes)
										type = ":" + "<font color=\"#" + colour_type + "\">" + v.@type + "</font>";
									
									cmdSuggest.push(v.@name);
									suggestText.htmlText += v.@name + type + "<br>";
									areSuggestions = true;
								}
							}
							else
							{
								hitMax = true;
								break;
							}
						}
						// Accessors
						for each (var a:XML in description.accessor)
						{
							if (suggestText.numLines < maxSuggestions)
							{
								if(a.@name.indexOf(stre) == 0)
								{
									if (showTypes)
										type = ":" + "<font color=\"#" + colour_type + "\">" + a.@type + "</font>";
									
									cmdSuggest.push(a.@name);
									suggestText.htmlText += a.@name + type + " <font color=\"#818181\">(accessor)</font><br>";
									areSuggestions = true;
								}
							}
							else
							{
								hitMax = true;
								break;
							}
						}
						// Methods / Functions
						for each (var m:XML in description.method)
						{
							if (suggestText.numLines < maxSuggestions)
							{
								if(m.@name.indexOf(stre) == 0)
								{
									var text:String;
									
									if (showTypes)
										type = ":" + "<font color=\"#" + colour_type + "\">" + m.@returnType + "</font>";
									
									text = m.@name + "(";
									areSuggestions = true;
									// Parameters
									if (m.parameter != undefined)
									{
										var first:Boolean = true;
										for each (var p:XML in m.parameter)
										{
											if (!first)
												text += ", ";
											else
												first = false;
												
											text += "<font color=\"#" + colour_param_type + "\">" + p.@type + "</font>";
										}
										cmdSuggest.push(m.@name+"(");
									}
									else
									{
										cmdSuggest.push(m.@name+"();");
									}
									suggestText.htmlText += text + ")" + type + "<br>";
								}
							}
							else
							{
								hitMax = true;
								break;
							}
						}
					}
					
					// If there are suggestions
					if (areSuggestions)
					{
						// if there were more then what can be displayed; add a last item called "..."
						if (hitMax)
							suggestText.htmlText += "...";
						
						// Position (show above inputTest if console is fullscreen)
						if (consoleHeight == main.stage.stageHeight)
							suggestText.y = inputText.y - suggestText.height;
						else
							suggestText.y = inputText.y + inputText.height;
						
						suggestText.visible = true;
						hpos = cmdSuggest.length;
					}
				}
				catch (er:Error)
				{
					// do nothing
				}
			}
		}
		
		private function hideSuggestions():void
		{
			suggestText.visible = false;
			suggestText.htmlText = "";
			suggestText.height = 20;
			cmdSuggest = new Array();
			hpos = -1;
		}
		
		//////////////////////////
		//		Interpreting	//
		/////////////////////////
		
		/** Seperate commands (by ;) and evaluates them. */
		public function eval(str:String):void
		{
			if (str.indexOf(";") > 1)
			{
				var c:Array = str.split(";");
				for (var i:int = 0; i < c.length; i++)
				{
					// if there's an x then look for x# and repeat for that #
					if (c[i].indexOf("x") == 0)
					{
						c[i] = Number(c[i].slice(1,c[i].length));
						for (var r:int = 1; r < c[i]; r++)
							interpretString(c[i-1]);
					}
					else if (c[i] != "")
					{
						 interpretString(c[i]);
					}
				}
			}
			else 
			{
				interpretString(str);
			}
		}
		
		// Interpret String/Command
		private function interpretString(str:String):void
		{
			// Remove ';'s and spaces outside of quotes
			str = stringReplaceAll(str, ";");
			str = stringReplaceButExclude(str, " ", ["\""], "", [false]);
			
			
			if (str.indexOf("=") > 0)
			{
				// Assigning
				var ar:Array = str.split("=");
				ar = checkShorthandCalculations(ar);
				ar[1] = stringToVarWithCalculation(ar[1]);
				changeVar(ar[0], ar[1]);
			}
			else
			{
				// Console-only Commands and getVar
				if (str.indexOf("trace:") == 0)
					setTrace(str);
				else if (str.indexOf("stoptrace:") == 0)
					stopTrace(str);
				else
				{
					switch (str)
					{
						case "clear"	: historyText.text = ""; 	break;
						case "help"		: echo(HELP, "#0099CC"); 	break;
						case "author"	: echo(AUTHOR, "#0099CC");	break;
						default			: getVar(str); 				break;
					}
				}
			}
		}
		
		// Echo var value / calculation
		private function getVar(varname:String):void
		{
			var rstring:String = varname + " returned ";

			try 
			{
				var value:* = stringToVarWithCalculation(varname);
				
				if (value == undefined)
					return;
				
				rstring += value;
				echo(rstring);
			}
			catch (er:Error)
			{
				error(er.message);
			}
		}
		
		// Assign a value to a variable
		private function changeVar(varname:String, vset:*):void
		{
			try
			{
				// check if vset is an array
				try
				{
					if (vset is String)
						vset = stringToArray(vset);
				}
				catch (er:Error)
				{
					// do nothing
				}
				
				// check if vset is a boolean
				if (vset == "true")
					vset = true;
				else if (vset == "false")
					vset = false;
					
				// check if vset is Number
				if (!isNaN(vset))
					vset = Number(vset);
					
				// Assign
				
					// change dots but leave dots inside array literals
				var str:String = stringReplaceButExclude(varname,".",["[","]","(",")"],"`",[false,false,false,false]);
				var v:Array = str.split("`");
				
				if (!assignVar(varname, vset, v, main))
					throw new Error();
			}
			catch (er:Error)
			{
				// Variable Does not exist / Invalid Type
				var index:int = tempVarNames.indexOf(v[0]);
				if (index == -1 && stringToVar(varname) != varname)
				{
					// Invalid Type
					error("Invalid type");
				}
				else if (createVarsThatDontExist && v.length == 1)
				{
					// Create Temporary Variable
					tempVarNames.push(v[0]);
					tempVars.push(vset);
					
					warn("Temporary variable called \"" + v[0] + "\" created with the value " + vset);
				}
				else
					error(er.message);
			}
		}
		private function assignVar(varname:String, vset:*, v:Array, ob:*, skipFirstIndex:Boolean = false):Boolean
		{
			try
			{
				var tempAry:Array; // for array items if needed
				
				for (var i:int = skipFirstIndex ? 1 : 0; i < v.length-1; i++)
				{
					if (v[i].indexOf("[") > -1)
					{
						// if an Array Item
						tempAry = stringToArrayItem(v[i]);
						
						switch (tempAry.length)
						{
							case 4:  ob = ob[tempAry[0]][tempAry[1]][tempAry[2]][tempAry[3]]; break;
							case 3:  ob = ob[tempAry[0]][tempAry[1]][tempAry[2]]; break;
							default: ob = ob[tempAry[0]][tempAry[1]]; break;
						}
					}
					else
						ob = ob[v[i]];
				}
				
				if (v[v.length-1].indexOf("[") == -1)
				{
					ob[v[v.length-1]] = vset;
					
					echo(varname + " is now " + ob[v[v.length-1]]);
				}
				else
				{
					// if an Array Item
					tempAry = stringToArrayItem(v[v.length - 1]);
					
					switch (tempAry.length)
					{
						case 4:  ob[tempAry[0]][tempAry[1]][tempAry[2]][tempAry[3]] = vset; break;
						case 3:  ob[tempAry[0]][tempAry[1]][tempAry[2]] = vset; break;
						default: ob[tempAry[0]][tempAry[1]] = vset; break;
					}
				}
				
				return true;
			}
			catch (e:Error)
			{
				// failed? is it a class?
				var cl:* = v[0];
				for (i = 0; i < v.length; i++)
				{
					try
					{
						ob = getDefinitionByName(cl) as Class;
						break; // break out if it get's this far (if it's a class)
					}
					catch (e:Error)
					{
						cl = cl + "." + v[i+1];
					}
				}
				
				if (ob is Class)
				{
					// member of class?
					for (i++; i < v.length; i++)
					{
						ob[v[v.length-1]] = vset;
						
						echo(varname + " is now " + ob[v[v.length-1]]);
					}
				}
				else
				{
					// temporary variable?
					var index:int = tempVarNames.indexOf( v[0].indexOf("[") == -1 ? v[0] : v[0].substring(0, v[0].indexOf("[")) );
					if (index != -1)
					{
						if (v.length > 1 || v[0].indexOf("[") != -1)
						{
							ob = tempVars[index];
							for (i = (v[0].indexOf("[") != -1 ? 0 : 1); i < v.length; i++)
							{
								if (v[i].indexOf("[") != -1)
								{
									// if an Array Item
									tempAry = stringToArrayItem(v[i]);
									if (i == 0)
										tempAry.shift();
									
									switch (tempAry.length)
									{
										case 4:  ob[tempAry[0]][tempAry[1]][tempAry[2]][tempAry[3]] = vset; break;
										case 3: ob[tempAry[0]][tempAry[1]][tempAry[2]] = vset; break;
										case 2: ob[tempAry[0]][tempAry[1]] = vset; break;
										default: ob[tempAry[0]] = vset; break;
									}
								}
								else
								{
									ob[v[i]] = vset;
									
									echo(varname + " is now " + ob[v[i]]);
								}
							}
						}
						else
						{
							tempVars[index] = vset;
							
							echo(varname + " is now " + tempVars[index]);
						}
							
						return true;
					}
					else
						return false;
				}
				
				return v.length > 1;
			}
			
			return false;
		}
		
		// Covert a string to useable variable
		private function stringToVar(str:String, base:* = null, leaveOutLast:Boolean = false):*
		{
			if (base == null)
				base = main;
				
			var ob:* = str;
			
			var lo:int = 0;
			if (leaveOutLast)
				lo = 1; 
			
			if (str.indexOf("\"") == -1 && isNaN(Number(str)))
			{
				// change dots but leave dots inside array literals
				var splitString:String = stringReplaceButExclude(str, ".", ["[","]","(",")"], "`", [false,false,false,false]);
			
				var v:Array = splitString.split("`");
				
				try
				{
					ob = base;
					for (var i:int = 0; i < v.length-lo; i++)
					{
						if (v[i].indexOf("[") != -1)
						{
							// if an Array Item
							var tempAry:Array = stringToArrayItem(v[i]);
							
							switch (tempAry.length)
							{
								case 4: ob = ob[tempAry[0]][tempAry[1]][tempAry[2]][tempAry[3]]; break;
								case 3: ob = ob[tempAry[0]][tempAry[1]][tempAry[2]]; break;
								default: ob = ob[tempAry[0]][tempAry[1]]; break;
							}
						}
						else
							ob = ob[v[i]];
					}
					
					if (ob == undefined)
						throw new Error();
				}
				catch (e:Error)
				{
					// failed? is it a class?
					var cl:* = v[0];
					for (i = 0; i < v.length; i++)
					{
						try
						{
							ob = getDefinitionByName(cl) as Class;
							break; // break out if it get's this far (if it's a class)
						}
						catch (e:Error)
						{
							cl = cl + "." + v[i+1];
						}
					}
					
					if (ob is Class)
					{
						// member of class?
						for (i++; i < v.length-lo; i++)
						{
							if (v[i].indexOf("[") != -1)
							{
								// if an Array Item
								tempAry = stringToArrayItem(v[i]);
								
								switch (tempAry.length)
								{
									case 4: ob = ob[tempAry[0]][tempAry[1]][tempAry[2]][tempAry[3]]; break;
									case 3: ob = ob[tempAry[0]][tempAry[1]][tempAry[2]]; break;
									default: ob = ob[tempAry[0]][tempAry[1]]; break;
								}
							}
							else
								ob = ob[v[i]];
						}
					}
					else
					{
						// temporary variable?
						var index:int = tempVarNames.indexOf( v[0].indexOf("[") == -1 ? v[0] : v[0].substring(0, v[0].indexOf("[")) );
						if (index != -1)
						{
							ob = tempVars[index];
							for (i = (v[0].indexOf("[") != -1 ? 0 : 1); i < v.length; i++)
							{
								if (v[i].indexOf("[") != -1)
								{
									// if an Array Item
									tempAry = stringToArrayItem(v[i]);
									if (i == 0)
										tempAry.shift();
									
									switch (tempAry.length)
									{
										case 4: ob = ob[tempAry[0]][tempAry[1]][tempAry[2]][tempAry[3]]; break;
										case 3: ob = ob[tempAry[0]][tempAry[1]][tempAry[2]]; break;
										case 2: ob = ob[tempAry[0]][tempAry[1]]; break;
										default: ob = ob[tempAry[0]]; break;
									}
								}
								else
									ob = ob[v[i]];
							}
						}
						else
							ob = str;
					}
				}
			}
			
			return ob;
		}
		
		// Convert a string to a callable function
		private function stringToFunc(str:String, base:* = null, leaveOutLast:Boolean = false):*
		{
			var member:String = str.substring(str.indexOf(")") + 2);
			str = str.substring(0, str.indexOf(")"));
			
			var fn:String = str.substring(0, str.indexOf("("));
			var p:String = str.substring(str.indexOf("(") + 1);
			
			// get parameters
			var pars:Array;
			if (p == "")
				pars = new Array();
			else
				pars = stringToPars(p);
				
			if (member == "")
				return stringToVar(fn, base, leaveOutLast).apply(null,pars);
			else
				return stringToVarWithCalculation(member, stringToVar(fn).apply(null, pars), leaveOutLast);
		}
		
		// Convert a string to a new instance
		private function stringToNewInstance(str:String, allowError:Boolean = true):*
		{
			str = str.replace("new", "");
			
			str = stringReplaceAll(str, ")");
			var cl:* = str;
			var p:String = "";
			if (str.indexOf("(") != -1)
			{
				cl = str.substring(0, str.indexOf("("));
				p = str.substring(str.indexOf("(") + 1);
			}
			
			// get parameters
			var pars:Array;
			if (p == "")
				pars = new Array();
			else
				pars = stringToPars(p);
			
			// get class
			cl = stringToVar(cl);
			
			
			var obj:*;
			// If you want support for classes with constructors that have more than 10 parameters; just add more cases.
			try
			{
				switch (pars.length)
				{
					default: obj = new cl(); break;
					case 1 : obj = new cl(pars[0]); break;
					case 2 : obj = new cl(pars[0],pars[1]); break;
					case 3 : obj = new cl(pars[0],pars[1],pars[2]); break;
					case 4 : obj = new cl(pars[0],pars[1],pars[2],pars[3]); break;
					case 5 : obj = new cl(pars[0],pars[1],pars[2],pars[3],pars[4]); break;
					case 6 : obj = new cl(pars[0],pars[1],pars[2],pars[3],pars[4],pars[5]); break;
					case 7 : obj = new cl(pars[0],pars[1],pars[2],pars[3],pars[4],pars[5],pars[6]); break;
					case 8 : obj = new cl(pars[0],pars[1],pars[2],pars[3],pars[4],pars[5],pars[6],pars[7]); break;
					case 9 : obj = new cl(pars[0],pars[1],pars[2],pars[3],pars[4],pars[5],pars[6],pars[7],pars[8]); break;
					case 10: obj = new cl(pars[0],pars[1],pars[2],pars[3],pars[4],pars[5],pars[6],pars[7],pars[8],pars[9]); break;
					case 11: obj = new cl(pars[0],pars[1],pars[2],pars[3],pars[4],pars[5],pars[6],pars[7],pars[8],pars[9],pars[10]); break;
				}
			}
			catch(e:Error)
			{
				if (!allowError)
					error(e.message);
			}
			
			return obj;
		}
		
		// Convert a string into an array of parameters/arguments
		private function stringToPars(str:String):Array
		{
			// change commas but leave commas inside array literals
			str = str.replace("[","|");
			str = str.replace("]","|");
			str = stringReplaceButExclude(str,",",["|","(",")"],"`",[true,false,false]);
			// split the parameters
			var pars:Array = str.split("`");
			
			// Convert pars to vals/funcs if they are
			for (var i:int = 0; i < pars.length; i++)
			{
				try
				{
					pars[i] = stringToVarWithCalculation(pars[i]);
					
					// convert to array if nessesary
					if (pars[i].indexOf(",") > -1)
						pars[i] = stringToArray(pars[i],false);
				}
				catch (er:Error)
				{
					// do nothing
				}
			}
			
			return pars;
		}
		
		// Convert a string into an array
		private function stringToArray(str:String, needSquareBrackets:Boolean = true):*
		{
			var res:Array;
			
			// if there's square brackets - remove them and convert
			if (str.indexOf("[") == 0 && str.lastIndexOf("]") == str.length-1 || !needSquareBrackets)
			{
				// remove brackets
				if (needSquareBrackets)
					str = str.substr(1,str.length-2);
				res = str.split(",");
				
				for (var i:int = 0; i < res.length; i++)
				{
					try
					{
						res[i] = stringToVarWithCalculation(res[i]);
					}
					catch (er:Error)
					{
						// do nothing
					}
				}
				
			}
			else
			{
				// if there was no square brackets and they were needed - just convert it to a var
				res = stringToVarWithCalculation(res);
			}
			
			return res;
		}
		
		// Conver a string into an array item
		private function stringToArrayItem(str:String):*
		{
			var res:* = str;
			
			// if there's square brackets - convert to array item
			if (str.indexOf("[") > -1 && str.lastIndexOf("]") == str.length-1)
			{
				str = stringReplaceAll(str, "]"); // remove close square brackets
				res = str.split("[");
				
				for (var i:uint = 1; i < res.length; i++)
					res[i] = stringToVarWithCalculation(res[i]);
			}
			
			return res;
		}
		
		// Convert to vars/func returns and do calucations with them
		private function stringToVarWithCalculation(str:*, base:* = null, leaveOutLast:Boolean = false):*
		{
			if (str == "this")
				return main;
			else if (str == "true")
				return true;
			else if (str == "false")
				return false;
			else if (containsOperators(str,"[","]") && containsOperators(str,"(",")"))
			{
				// Contains Math Operators that are not inside "[]"
				var operatorOrder:Array = new Array();
				var n:int = 0;
				
				var temp:String = "";
				var inExl:Boolean = false;
				var currExlList:Array = new Array();
				var foundOperator:Boolean;
				var foundExl:uint = 0;
				var operators:Array = ["-", "+", "/", "*", "%"];
				var exls:Array = [["\"", "\""], ["[", "]"], ["(", ")"]]; // Don't do calculations inside these (for now)
				
				for (var i:uint = 0; i < str.length; i++)
				{
					foundOperator = false;
					foundExl = 0;
					
					// Check for exclusions
					for (var e:uint = 0; e < exls.length; e++)
					{
						if (str.charAt(i) == exls[e][0])
						{
							foundExl = 1;
							break;
						}
						else if (str.charAt(i) == exls[e][1])
						{
							foundExl = 2;
							break;
						}
					}
					
					if (foundExl != 0)
					{
						if (currExlList.length == 0 || foundExl == 1)
							inExl = true;
						else if (currExlList[currExlList.length-1] == exls[e][0])
						{
							// close if foundExl is 2 (exl close) and the last exl was the open one
							inExl = false;
							currExlList.pop();
						}
						
						currExlList.push( str.charAt(i) );
					}
					else
					{
						if (!inExl)
						{
							var op:int = 0;
							
							while (!foundOperator && op < operators.length)
							{
								if (str.charAt(i) == operators[op])
								{
									foundOperator = true;
									
									operatorOrder[n] = op;
									n++;
								}
								op++;
							}
						}
						
						if (foundOperator)
							temp += "`"; // replace operator with ` for spliting
						else
							temp += str.charAt(i);
					}
				}
				str = temp;
				
				// split by operators
				var t:Array = str.split("`");
				
				// Convert to vars/functions if they are
				for (var c:int = 0; c < t.length; c++)
				{
					if (!isNaN(t[c]))
						t[c] = Number(t[c]);
					else if (t[c].indexOf("(") > 0)
						t[c] = stringToFunc(t[c], base, leaveOutLast);
					else
						t[c] = stringToVar(t[c], base, leaveOutLast);
				}
				
				// Calculate
				str = t[0];
				n = 0;
				for (var o:int = 1; o < t.length; o++)
				{
					switch (operatorOrder[n])
					{
						case 0: str -= t[o]; break;
						case 1: str += t[o]; break;
						case 2: str /= t[o]; break;
						case 3: str *= t[o]; break;
						case 4: str %= t[o]; break;
					}
					n++;
				}
			}
			else
			{
				// If no operators - just convert to var or func
				str = stringReplaceAll(str,"\"");
				try
				{
					if (str.indexOf("new") == 0)
						str = stringToNewInstance(str, leaveOutLast);
					else if (str.indexOf("(") > 0)
						str = stringToFunc(str, base, leaveOutLast);
					else
						str = stringToVar(str, base, leaveOutLast);
				}
				catch (er:Error)
				{
					// do nothing
				}
			}
			
			return str;
		}
		
		
		private function checkShorthandCalculations(ar:Array):Array
		{
			if (ar[0].indexOf("+") == ar[0].length-1 || ar[0].indexOf("-") == ar[0].length-1 ||
				ar[0].indexOf("/") == ar[0].length-1 || ar[0].indexOf("*") == ar[0].length-1 ||
				ar[0].indexOf("%") == ar[0].length-1)
			{
				ar[1] = ar[0] + ar[1];
				ar[0] = ar[0].substr(0,ar[0].length-1);
			}
			
			return ar;
		}
		
		private function containsOperators(str:String, before:String = "", after:String = ""):Boolean
		{
			var operators:Array = new Array("+","-","/","*","%");
			
			for (var i:int = 0; i < operators.length; i++)
			{
				var index:int = str.indexOf(operators[i]);
				
				if (index != -1 && (before == "" || index < str.indexOf(before) || str.indexOf(before) == -1) && (after == "" || index > str.indexOf(after)) )
					return true;
			}
			
			return false;
		}
		
		//////////////////////////
		//	  Misc Functions	//
		/////////////////////////
		
		// Messages
		
		/** 
		 * Echos parameters to the developer console. 
		 * If last parameter is a string with it's first character being a '#' (eg: string is "#FFFF00") it will echo the previous parameters in that colour.
		 * */
		public function echo(... args):void
		{
			// Check for Colour
			var colour:String;
			if (args[args.length - 1] is String && args[args.length - 1].charAt(0) == "#")
			{
				colour = args[args.length - 1];
				args.pop();
			}
			else
				colour = "#FFFFFF";
			
			// Seperate arguments with ", "
			var str:String = "";
			for (var i:uint = 0; i < args.length; i++)
			{
				str += args[i];
				if (i < args.length - 1)
					str += " ";
			}
				
			historyText.htmlText += "<font color=\"" + colour +"\">" + str + "</font>\n";
			historyText.scrollV = historyText.maxScrollV;
		}
		/** Echos parameters to the developer console in red (#FF0000). */
		public function error(... args):void
		{
			args.push( "#FF0000" );
			echo.apply(null, args);
		}
		/** Echos parameters to the developer console in blue (#00CCFF). */
		public function warn(... args):void
		{
			args.push( "#00CCFF" );
			echo.apply(null, args);
		}
		
		// Common String related functions
		private function stringReplaceAll(str:String, r:String, rw:String = ""):String
		{
			do
			{
				str = str.replace(r,rw);
			}
			while (str.indexOf(r) > - 1);
			
			return str;
		}
		
		private function stringReplaceButExclude(str:String, r:String, exclude:Array, rw:String, removeExls:Array):String
		{
			// Replaces all 'r's in a string with 'rw' excluding 'r's inside 'exclude's
			var temp:String = "";
			
			if (stringContains(str,exclude))
			{
				var inExl:Boolean = false;
				
				for (var i:int = 0; i < str.length; i++)
				{
					if (charIsAnyOf(str.charAt(i),exclude))
					{
						inExl = !inExl;
						if ( !removeExls[ exclude.indexOf(str.charAt(i)) ] ) temp += str.charAt(i);
					}
					else if (str.charAt(i) == r && !inExl)
					{
						temp += rw;
					}
					else
					{
						temp += str.charAt(i);
					}
				}
			}
			else
				temp = stringReplaceAll(str, r, rw);
			
			return temp;
		}
		
		private function stringContains(str:String, what:Array):Boolean
		{
			for (var i:int = 0; i < what.length; i++)
			{
				if (str.indexOf(what[i]) > -1)
					return true;
			}
			return false;
		}
		
		private function charIsAnyOf(char:String, what:Array):Boolean
		{
			for (var i:int = 0; i < what.length; i++)
			{
				if (char == what[i])
					return true;
			}
			return false;
		}
		
		private function fillArrayWithIndexsOf(ar:Array, str:String, ar2:Array, startIndex:int = -1):Array
		{
			if (ar == null)
				ar = new Array();
			if (startIndex == -1)
				startIndex = str.length-1;
			
			for (var i:int = 0; i < ar2.length; i++)
			{
				ar[i] = str.lastIndexOf(ar2[i],startIndex);
			}
			
			return ar;
		}
		
		private function characterCount(str:String, char:String):int
		{
			var count:int = 0;
			for (var i:int = 0; i < str.length; i++)
			{
				if (str.charAt(i) == char)
					count++;
			}
			return count;
		}
		
		//////////////////////////
		//	  Slide Animation	//
		/////////////////////////
		
		private function startSlideAnimation(open:Boolean):void
		{
			main.addEventListener(Event.ENTER_FRAME, slide);
			slideAnimation_animating = true;
			
			if (open)
			{
				slideAnimation_target = 0;
			}
			else
			{
				container.visible = true;
			
				slideAnimation_target = -historyText.height - inputText.height;
			}
		}
		private function stopSlideAnimation():void
		{
			container.y = slideAnimation_target;
			
			main.removeEventListener(Event.ENTER_FRAME, slide);
			slideAnimation_animating = false;
		}
		
		private function slide(e:Event):void
		{
			if (container.y <= slideAnimation_target)
			{
				container.y += slideAnimation_speed;
				
				// Stop
				if (container.y >= slideAnimation_target)
					stopSlideAnimation();
			}
			else if (container.y >= slideAnimation_target)
			{
				container.y -= slideAnimation_speed;
				
				// Stop
				if (container.y <= slideAnimation_target)
				{
					stopSlideAnimation();
					container.visible = false;
				}
			}
		}
		
		//////////////////////////
		//	 Fullscreen Toggle	//
		/////////////////////////
		
		private function toggleFullscreen():void
		{
			if (consoleHeight != main.stage.stageHeight)
				consoleHeight = main.stage.stageHeight; // Extend
			else
				consoleHeight = consoleHeight_default;  // Retract
			
			
			if (slideAnimation)
			{
				main.addEventListener(Event.ENTER_FRAME, fullscreenSlide);
				slideAnimation_animating = true;
				slideAnimation_target = consoleHeight - 20;
				suggestText.visible = false;
			}
			else
			{
				historyText.height = consoleHeight - 20;
				inputText.y = historyText.height;
			}
		}
		private function stopFullscreenSlideAnimation():void
		{
			historyText.height = consoleHeight - 20;
			inputText.y = historyText.height;
			suggestText.y = inputText.y + inputText.height;
			historyText.scrollV = historyText.maxScrollV;
			
			main.removeEventListener(Event.ENTER_FRAME, fullscreenSlide);
			slideAnimation_animating = false;
		}
		
		private function fullscreenSlide(e:Event):void
		{
			if (historyText.height <= slideAnimation_target)
			{
				historyText.height += slideAnimation_speed;
				inputText.y = historyText.height;
				
				// Stop
				if (historyText.height >= slideAnimation_target)
					stopFullscreenSlideAnimation();
			}
			else if (historyText.height >= slideAnimation_target)
			{
				historyText.height -= slideAnimation_speed;
				inputText.y = historyText.height;
				historyText.scrollV = historyText.maxScrollV;
				
				// Stop
				if (historyText.height <= slideAnimation_target)
					stopFullscreenSlideAnimation();
			}
		}
		
		//////////////////////////
		//		  Tracer		//
		/////////////////////////
		
		public function setTrace(str:String):void
		{
			var originalLength:int = traceVars.length;
			
			str = str.replace("trace:","");
			
			if (str == "fps")
				addEventListener(Event.ENTER_FRAME, tick);
			
			var v:Array = str.split(",");
			for (var n:int = 0; n < v.length; n++)
			{
				if (traceVars.indexOf(v[n]) == -1)
					traceVars.push(v[n]);
			}
			
			if (originalLength == 0 && traceVars.length != 0)
				tracer.addEventListener(Event.ENTER_FRAME, traceUpdate);
		}
		
		public function stopTrace(str:String):void
		{
			str = str.replace("stoptrace:","");
			
			// remove event listener for fps
			removeEventListener(Event.ENTER_FRAME, tick);
			
			if (str == "all")
			{
				traceVars = new Array();
			}
			else
			{
				var v:Array = str.split(",");
				for (var n:int = 0; n < v.length; n++)
				{
					for (var i:int = 0; i < traceVars.length; i++)
					{
						if (traceVars[i] == v[n]) traceVars.splice(i,1);
					}
				}
			}
			
			if (traceVars.length == 0)
			{
				tracer.removeEventListener(Event.ENTER_FRAME, traceUpdate);
				tracer.visible = false;
				tracerNames.visible = false;
			}
		}
		
		private function traceUpdate(e:Event):void
		{
			var na:String;
			
			// actual trace
			if (tracerActualTrace)
			{
				if (tracerOneCiclePerLine)
					var completeOutput:String = "";
				
				for (var i:uint = 0; i < traceVars.length; i++)
				{
					if (traceVars[i] != "fps" || tracerActualTraceFPS)
					{	
						var output:String = tracerActualTraceLayout;
						
						na = traceVars[i];
						
						output = output.replace("name", na);
						
						if (na == "fps")
							output = output.replace("value", fps);
						else
							output = output.replace("value", stringToVarWithCalculation(traceVars[i]));
						
						if (!tracerOneCiclePerLine)
							trace(output);
						else
							completeOutput += output + tracerOneCiclePerLine_seperator;
					}
				}
				
				if (tracerOneCiclePerLine)
					trace(completeOutput);
			}
			
			// tracer table
			if (tracerView)
			{
				tracer.visible = true;
				tracerNames.visible = true;
				tracer.text = "";
				tracerNames.text = "";
				
				for (i = 0; i < traceVars.length; i++)
				{
					na = traceVars[i];
					
					tracerNames.appendText(na + "\n");
					
					if (na == "fps")
						tracer.appendText(fps + "\n");
					else
						tracer.appendText(stringToVarWithCalculation(traceVars[i]) + "\n");
				}
				
				// position				
				tracerNames.x = tracerAlignX - tracerNames.width;
				tracer.x = tracerNames.x - tracer.width - 10;
				if (tracerAlignY < historyText.height + inputText.height)
				{
					tracer.y 	  = container.y + inputText.y + inputText.height + tracerAlignY;
					tracerNames.y = container.y + inputText.y + inputText.height + tracerAlignY;
				}
				else
				{
					tracer.y = tracerAlignY;
					tracerNames.y = tracerAlignY;
				}
			}
			else
			{
				tracer.visible = false;
				tracerNames.visible = false;
			}
		}
		
		// FPS Counter
		private function tick(e:Event):void
		{
            ticks++;
            var now:uint = getTimer();
            var delta:uint = now - last;
            if (delta >= 1000)
			{
                var f:Number = ticks / delta * 1000;
				fps = f.toFixed(1);
                ticks = 0;
                last = now;
            }
        }
		
	}
}