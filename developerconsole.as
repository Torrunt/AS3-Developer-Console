// What		: AS3 Developer Console	(v1.06) - http://code.google.com/p/as3developerconsole/
// Author	: Corey Zeke Womack (Torrunt)
// Contact	: torrunt56@gmail.com | torrunt.newgrounds.com | torrunt.tumblr.com/games

// Notes:
// - Type 'help' in console for help.
// - If your testing your project in the Flash IDE make sure 'Disable Keyboard Shortcuts' is ticked.
// - When testing your project in the Flash IDE you have to click the swf at least once to be able to see the text cursor.

package classes {
	import flash.display.Sprite;
	import flash.text.*;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.events.Event;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;
	
	public class developerconsole extends Sprite {
		
		// Customisation
		public var consoleheight:Number				= 125;		// height of the console
		public var maxSuggestions:int				= 14;		// max suggestions that can be shown at once
		public var showTypes:Boolean 				= true;		// show data/return types of vars and functions
		public var returnFunctions:Boolean 			= true;		// echo function return values
		
		public var tracerView:Boolean 				= true;		// show the tracer table when using the tracer
		public var tracerActualTrace:Boolean 		= true;		// actually use as3's trace() function when using the tracer
		public var tracerActualTraceFPS:Boolean 	= false;	// actually use as3's trace() function when using the tracer for fps
		public var tracerActualTraceLayout:String 	= "name : value";
		public var tracerOneCiclePerLine:Boolean 	= false;	// makes everything traced in one cicle only apear on one line
		public var tracerOneCiclePerLine_seperator:String = " ";
		
		
		private static var versionName:String = "Torrunt's AS3 Developer Console (v1.06)"
		private static var help:String = " - Type 'clear' to clear the console.\n - Type 'author' to get info on the author of this console.\n - Use the Up/Down arrow keys to go through your previous used commands or suggestions\n - Use Quotations when you want enter string literal with spaces (\")\n - Use Square Brackets when you want to use an arral literal (e.g:[0,1]).\n - You can do multiple commands at once by seperating them with ';'s.\n - You can also put x# after a ';' to do that command # many times.\n - Calculations are allowed when assigning or in parameters (+,-,*,/,%). BIMDAS is not supported.\n - Type 'trace:something' to start tracing something or 'stoptrace:something' to stop tracing it.\n - You can also use 'trace:fps' to check your fps.\n - Use pgUp and pgDown on your keyboard to scroll up and down";
		private static var author:String = versionName + " was programmed by Corey Zeke Womack (Torrunt)\ntorrunt56@gmail.com\ntorrunt.newgrounds.com\ntorrunt.tumblr.com/games";
		
		// Creating / Defaults
		private var main:*;
		public var opened:Boolean = false;
		
		private var suggesttext:TextField;
		private var consoleTextFormat:TextFormat;
		private var historytext:TextField;
		private var inputtext:TextField;
		
		private var cmdsuggest:Array = new Array();
		private var cmdhistory:Array = new Array();
		private var cicle:Array;
		private var hpos:int = -1;
		
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
		public function developerconsole(_main:*){
			main = _main;	// Start off point for seeing/using variables and functions (main class or frame/stage)
			
			// Customise Look
				// Text Format
			consoleTextFormat = new TextFormat();
			consoleTextFormat.size = 14;
			consoleTextFormat.font = "Arial";
			consoleTextFormat.color = 0xFFFFFF;
			
				// History Textbox
			historytext = new TextField();
			addChild(historytext);
			
			historytext.width = main.stage.stageWidth;
			historytext.height = consoleheight;
			historytext.alpha = 0.9;
			historytext.selectable = false;
			historytext.multiline = true;
			historytext.wordWrap = true;
			historytext.defaultTextFormat = consoleTextFormat;
			historytext.background = true;
			historytext.backgroundColor = 0x000000;
			
				// Input Textbox
			inputtext = new TextField();
			inputtext.type = TextFieldType.INPUT;
			addChild(inputtext);
			
			inputtext.width = main.stage.stageWidth;
			inputtext.height = 20;
			inputtext.y = historytext.height;
			inputtext.x = 0;
			inputtext.alpha = 0.9;
			inputtext.defaultTextFormat = consoleTextFormat;
			inputtext.background = true;
			inputtext.backgroundColor = 0x4B4B4B;
			
				// Suggest/auto-complete Textbox
			suggesttext = new TextField();
			addChild(suggesttext);
			
			suggesttext.width = 150;
			suggesttext.height = 20;
			suggesttext.y = inputtext.y + inputtext.height;
			suggesttext.alpha = 0.85;
			suggesttext.selectable = false;
			suggesttext.defaultTextFormat = consoleTextFormat;
			suggesttext.background = true;
			suggesttext.backgroundColor = 0x000000;
			suggesttext.autoSize = TextFieldAutoSize.LEFT;
			suggesttext.visible = false;
			
				// Tracer
			tracerAlignX = main.stage.stageWidth - 10;
			tracerAlignY = 10;
			
			consoleTextFormat.bold = true;
	
			tracer = new TextField();
			main.stage.addChild(tracer);
			
			tracer.alpha = 0.75;
			tracer.selectable = false;
			consoleTextFormat.align = "right";
			tracer.defaultTextFormat = consoleTextFormat;
			tracer.background = true;
			tracer.backgroundColor = 0x666666;
			tracer.autoSize = TextFieldAutoSize.LEFT;
			tracer.visible = false;
			
			
			tracerNames = new TextField();
			main.stage.addChild(tracerNames);
			
			tracerNames.alpha = 0.75;
			tracerNames.selectable = false;
			consoleTextFormat.align = "left";
			tracerNames.defaultTextFormat = consoleTextFormat;
			tracerNames.background = true;
			tracerNames.backgroundColor = 0x666666;
			tracerNames.autoSize = TextFieldAutoSize.LEFT;
			tracerNames.visible = false;
			
			// Startup Message
			echo(versionName);
			
			// Hide self
			visible = false;
        }
		
		//////////////////////////
		//		Open/Close		//
		/////////////////////////
		
		public function open():void {
			if (!opened){
				visible = true;
				opened = true;
				main.stage.focus = inputtext;
				
				main.stage.addEventListener(KeyboardEvent.KEY_UP, keyup);
				main.stage.addEventListener(KeyboardEvent.KEY_DOWN, keydown);
				inputtext.addEventListener(TextEvent.TEXT_INPUT,typed);
			}
		}
		
		public function close():void {
			if (opened){
				visible = false;
				opened = false;
				inputtext.text = "";
				hpos = -1;
				
				main.stage.removeEventListener(KeyboardEvent.KEY_UP, keyup);
				main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keydown);
				inputtext.removeEventListener(TextEvent.TEXT_INPUT,typed);
			}
		}
		
		public function toggle():void {
			if (opened){
				close();
			} else {
				open();
			}
		}
		
		//////////////////////////
		//		Controls		//
		/////////////////////////
		
		private var pressedUp:Boolean = false;
		
		private function keydown(e:KeyboardEvent):void {
			// Enter
			if (e.keyCode == 13 && inputtext.text != ""){
				echo(inputtext.text);
				
				if (cmdhistory[cmdhistory.length-1] != inputtext.text){
					cmdhistory.push(inputtext.text);
					hpos = -1;
				}
				
				interpret(inputtext.text);
				
				inputtext.text = "";
				hidesuggestions();
			}
			
			// Backspace
			if (e.keyCode == 8){
				if(inputtext.length-1 <= 0){
					hidesuggestions();
				} else {
					showsuggestions(inputtext.text.substr(0,inputtext.length-1));
				}
			}
			
			// Up and Down
				// Pick array to go through
			if (suggesttext.visible){
				cicle = cmdsuggest;
			} else {
				cicle = cmdhistory;
			}
				// Up
			if (e.keyCode == 38 && cicle[cicle.length-1-(hpos+1)] != null){
				hpos++;
				changeInputbox();
				pressedUp = true;
			}
				// Down
			if (e.keyCode == 40){
				if (cicle[cicle.length-1-(hpos-1)] != null){
					hpos--;
					changeInputbox();
				} else if (cicle == cmdhistory) {
					inputtext.text = "";
					hpos = -1;
				}
			}
			
			// Scrolling Up and Down
				// Page Up
			if (e.keyCode == 33){
				historytext.scrollV--;
			}
				// Page Down
			if (e.keyCode == 34){
				historytext.scrollV++;
			}
		}
		
			// Fix cursor position if you press up when moving through history or suggestions
		private function keyup(e:KeyboardEvent):void {
			if (pressedUp){
				inputtext.setSelection(inputtext.length,inputtext.length);
				pressedUp = false;
			}
		}
		
		// Change inputbox contents to the next/previous history or suggestion item
		private function changeInputbox():void {
			// If going through suggestions: just replace the thing you're currently writing
			if (cicle == cmdsuggest){
				// if last suggestion added a '();' at the end - remove it
				if (inputtext.text.lastIndexOf("();")+3 == inputtext.length){
					inputtext.text = inputtext.text.substr(0,inputtext.length-3);
				}
				
				// Remove text after last symbol or space
					// get indexs of symbols
				var symbols:Array = fillArrayWithIndexsOf(symbols,inputtext.text,["."," ","(",",","-","+","/","*","%",";",":","["]);
					// get highest index (last used symbol)
				var ls:int = symbols[0]; // (last symbol)
				for (var i:int = 1; i < symbols.length; i++){
					if (symbols[i] > ls) ls = symbols[i];
				}
				
				// if the last symbol is a bracket and is the last thing in the inputbox: make it the second last symbol
				if (inputtext.text.charAt(ls) == "(" && (ls == inputtext.length-1)){
					inputtext.text = inputtext.text.substr(0,ls);
					changeInputbox();
					return;
				}
				
				// Remove what you're currently writing
				inputtext.text = inputtext.text.substr(0,ls+1);
				// Appened suggestion
				inputtext.appendText(cicle[cicle.length-1-hpos]);
			} else {
			// Otherwise replace the whole inputtext
				inputtext.text = cicle[cicle.length-1-hpos]; // Replace text
			}
			
			inputtext.setSelection(inputtext.length,inputtext.length);
		}
		
		//////////////////////////
		//		Suggesting		//
		/////////////////////////
		
		// Defaulting
		private var areSuggestions:Boolean = false;
		private var hitMax:Boolean = false;
		
		// Update while typing
		private function typed(e:TextEvent):void {
			showsuggestions(inputtext.text+e.text);
		}
		
		private function showsuggestions(str:String):void {
			// reset to defaults
			hidesuggestions();	// hide previous
			areSuggestions = false;
			hitMax = false;
			
			// check for ';'s (end of commands)
			if (str.indexOf(";") > 1){
				str = str.slice(str.lastIndexOf(";")+1,str.length);
			}
			
			// change str to latest var user is writing
			str = stringReplaceAll(str," ");
			
			var symbols:Array = fillArrayWithIndexsOf(symbols,str,["(","=",",","-","+","/","*","%",":","["]);
			var startFrom:int = symbols[0];
			
			if (characterCount(str,"]") == characterCount(str,"[")) symbols.pop(); // Don't look for '[' if last one was closed
			
			for (var s:int = 1; s < symbols.length; s++){
				if (symbols[s] > startFrom) startFrom = symbols[s];
			}
			str = str.substring(startFrom+1,str.length);
			
			// Get all public Vars and Functions
			if (str != ""){
				try {
					// FIND ME
					var ob = stringToVar(str, true);
					var stre:String = str.substring(str.lastIndexOf(".")+1,str.length);
					
					var description:XML = describeType(ob);
					
					var type:String = "";
					
					if (description.*.length() > 3){ // if 3 (or less?) that means ob doesn't exist
						// Vars
						for each (var v:XML in description.variable){
							if (suggesttext.numLines < maxSuggestions){
								if(v.@name.indexOf(stre) == 0){
									if (showTypes) type = ":" + v.@type;
									
									cmdsuggest.push(v.@name);
									suggesttext.appendText(v.@name + type + "\n");
									areSuggestions = true;
								}
							} else {
								hitMax = true;
								break;
							}
						}
						// Accessors
						for each (var a:XML in description.accessor){
							if (suggesttext.numLines < maxSuggestions){
								if(a.@name.indexOf(stre) == 0){
									if (showTypes) type = ":" + a.@type;
									
									cmdsuggest.push(a.@name);
									suggesttext.appendText(a.@name + type + " (accessor)\n");
									areSuggestions = true;
								}
							} else {
								hitMax = true;
								break;
							}
						}
						// Methods / Functions
						for each (var m:XML in description.method){
							if (suggesttext.numLines < maxSuggestions){
								if(m.@name.indexOf(stre) == 0){
									if (showTypes) type = ":" + m.@returnType;
									
									suggesttext.appendText(m.@name + "(");
									areSuggestions = true;
									// Parameters
									if (m.parameter != undefined) {
										for each (var p:XML in m.parameter){
											suggesttext.appendText(p.@type+",");
										}
										suggesttext.text = suggesttext.text.slice(0,suggesttext.text.length-1);
										cmdsuggest.push(m.@name+"(");
									} else {
										cmdsuggest.push(m.@name+"();");
									}
									suggesttext.appendText(")" + type +"\n");
								}
							} else {
								hitMax = true;
								break;
							}
						}
					}
					
					// If there are suggestions
					if (areSuggestions){
						// if there were more then what can be displayed; add a last item called "..."
						if (hitMax){
							suggesttext.appendText("...");
						}
						suggesttext.visible = true;
						hpos = cmdsuggest.length;
					}
				}
				catch(er:Error){
					// do nothing
				}
			}
		}
		
		private function hidesuggestions():void {
			suggesttext.visible = false;
			suggesttext.text = "";
			suggesttext.height = 20;
			cmdsuggest = new Array();
			hpos = -1;
		}
		
		//////////////////////////
		//		Interpreting	//
		/////////////////////////
		
		// Seperate commands (by ;) and interpet them
		private function interpret(str:String):void {
			if (str.indexOf(";") > 1){
				var c:Array = str.split(";");
				for (var i:int = 0; i < c.length; i++){
					
					// if there's an x then look for x# and repeat for that #
					if (c[i].indexOf("x") == 0){
						c[i] = Number(c[i].slice(1,c[i].length));
						for (var r:int = 1; r < c[i]; r++){
							interpretString(c[i-1]);
						}
					} else {
						if (c[i] != "") interpretString(c[i]);
					}
				}
			} else {
				interpretString(str);
			}
		}
		
		// Interpret String/Command
		private function interpretString(str:String):void {
			// Remove ';'s and spaces outside of quotes
			str = stringReplaceAll(str, ";");
			str = stringReplaceButExclude(str," ","\"","",false);
			
			// Assigning
			if (str.indexOf("=") > 0){
				var ar = str.split("=");
				ar = checkShorthandCalculations(ar);
				ar[1] = stringToVarWithCalculation(ar[1]);
				changeVar(ar[0],ar[1]);
			} else 
			// Calling functions
			if (str.indexOf("(") > 0 && str.indexOf(")") > str.indexOf("(")){
				if (returnFunctions){
					var rtrn:String = stringToFunc(str);
					if (rtrn != null) warn("returned: "+rtrn);
				} else {
					stringToFunc(str);
				}
			} else {
				// Console-only Commands and getVar
				if (str.indexOf("trace:") == 0){
					setTrace(str);
				} else
				if (str.indexOf("stoptrace:") == 0){
					stopTrace(str);
				} else {
					switch(str){
						case "clear": historytext.text = ""; break;
						case "help": echo(help,"0099CC"); break;
						case "author": echo(author,"0099CC"); break;
						default: getVar(str); break;
					}
				}
			}
		}
		
		// Echo var value / calculation
		private function getVar(varname):void {
			var rstring:String = varname + " is ";

			try {
				rstring += stringToVarWithCalculation(varname);
				echo(rstring);
			}
			catch(er:Error){
				error(er.message);
			}
		}
		
		// Assign a value to a variable
		private function changeVar(varname:String,vset):void {
			try {
				// check if vset is an array
				try {
					vset = stringToArray(vset);
				}
				catch(er:Error){
					// do nothing
				}
				
				// check if vset is a boolean
				if (vset == "true") vset = true;
				if (vset == "false") vset = false;
				
				// assign
				var v:Array = varname.split(".");
				
				var ob = main;
				var tempAry; // for array items if needed
				
				for (var i:int = 0; i < v.length-1; i++){
					if (v[i].indexOf("[") > -1){
						// if an Array Item
						tempAry = stringToArrayItem(v[i]);
						ob = ob[tempAry[0]][tempAry[1]];
					} else {
						ob = ob[v[i]];
					}
				}
				
				if (v[v.length-1].indexOf("[") > -1){
					// if an Array Item
					tempAry = stringToArrayItem(v[v.length-1]);
					ob[tempAry[0]][tempAry[1]] = vset;
				} else {
					ob[v[v.length-1]] = vset;
				}
			}
			catch(er:Error){
				error(er.message);
			}
		}
		
		// Covert a string to useable variable
		private function stringToVar(str:String, leaveOutLast:Boolean = false):* {
			var ob = str;
			
			var lo:int = 0;
			if (leaveOutLast) lo = 1; 
			
			if (str.indexOf("\"") == -1 && isNaN(Number(str))){
				var v:Array = str.split(".");
				
				try {
					ob = main;
					for (var i:int = 0; i < v.length-lo; i++){
						if (v[i].indexOf("[") > -1){
							// if an Array Item
							var tempAry = stringToArrayItem(v[i]);
							ob = ob[tempAry[0]][tempAry[1]];
						} else {
							ob = ob[v[i]];
						}
					}
				}
				catch (e:Error){
					// failed? is it a class?
					var cl = v[0];
					for (i = 0; i < v.length; i++){
						try {
							ob = getDefinitionByName(cl) as Class;
							break; // break out if it get's this far (if it's a class)
						}
						catch (e:Error) {
							cl = cl + "." + v[i+1];
						}
					}
					if (ob is Class){
						// member of class?
						for (i++; i < v.length-lo; i++){
							ob = ob[v[i]];
						}
					} else {
						ob = str;
					}
				}
			}
			
			return ob;
		}
		
		// Convert a string to a callable function
		private function stringToFunc(str:String, setval:Boolean = false){
			str = stringReplaceAll(str, ")");
			var ar = str.split("(");
			var pars;
			
			if (ar[1] == ""){
				pars = new Array();
			} else {
				pars = stringToPars(ar[1]);
			}
			
			if (!setval){
				return stringToVar(ar[0]).apply(null,pars);
			} else {
				return stringToVar(ar[0]).apply(null,pars);
			}
		}
		
		// Convert a string into an array of parameters/arguments
		private function stringToPars(str:String):Array {
			// change commas but leave commas inside array literals
			str = str.replace("[","|");
			str = str.replace("]","|");
			str = stringReplaceButExclude(str,",","|","`");
			// split the parameters
			var pars = str.split("`");
			
			// Convert pars to vals/funcs if they are
			for (var i:int = 0; i < pars.length; i++){
				try {
					pars[i] = stringToVarWithCalculation(pars[i]);
					
					// convert to array if nessesary
					if (pars[i].indexOf(",") > -1){
						pars[i] = stringToArray(pars[i],false);
					}
				}
				catch (er:Error){
					// do nothing
				}
			}
			return pars;
		}
		
		// Convert a string into an array
		private function stringToArray(str,needSquareBrackets:Boolean = true):* {
			var res;
			
			// if there's square brackets - remove them and convert
			if (str.indexOf("[") == 0 && str.lastIndexOf("]") == str.length-1 || !needSquareBrackets){
				if (needSquareBrackets) str = str.substr(1,str.length-2); // remove brackets
				res = str.split(",");
				
				for (var i:int = 0; i < res.length; i++){
					try {
						res[i] = stringToVarWithCalculation(res[i]);
					}
					catch (er:Error){
						// do nothing
					}
				}
				
			} else {
				// if there was no square brackets and they were needed - just convert it to a var
				res = stringToVarWithCalculation(res);
			}
			
			return res;
		}
		
		// Conver a string into an array item
		private function stringToArrayItem(str):* {
			var res = str;
			
			// if there's square brackets - convert to array item
			if (str.indexOf("[") > -1 && str.lastIndexOf("]") == str.length-1){
				str = str.substr(0,str.length-1); // remove last bracket
				res = str.split("[");
				res[1] = Number(res[1]); // convert given index to number
			}
			
			return res;
		}
		
		// Convert to vars/func returns and do calucations with them
		private function stringToVarWithCalculation(str):* {
			if (str == "this"){
				return main;
			} else
			if (str == "true"){
				return true;
			} else
			if (str == "false"){
				return false;
			} else
			if (containsOperators(str)){
				var operatorOrder:Array = new Array();
				var n:int = 0;
				
				var temp:String = "";
				var inExl:Boolean = false;
				var foundOperator:Boolean;
				var operators:Array = new Array("-","+","/","*","%");
				
				for (var i:int = 0; i < str.length; i++){
					foundOperator = false;
					
					if (str.charAt(i) == "\""){ // doesn't do calculations in quotations
						inExl = !inExl;
					} else {
						if (!inExl){
							var op:int = 0;
							
							while (!foundOperator && op < operators.length){
								if (str.charAt(i) == operators[op]){
									foundOperator = true;
									
									operatorOrder[n] = op;
									n++;
								}
								op++;
							}
						}
						
						if (foundOperator){
							temp += "`"; // replace operator with ` for spliting
						} else {
							temp += str.charAt(i);
						}
					}
				}
				str = temp;
				
				// split by operators
				var t:Array = str.split("`");
				
				// Convert to vars/functions if they are
				for (var c:int = 0; c < t.length; c++){
					if (!isNaN(t[c])){
						t[c] = Number(t[c]);
					} else
					if (t[c].indexOf("(") > 0 && t[c].indexOf(")") > 0){
						t[c] = stringToFunc(t[c],true);
					} else {
						try {
							t[c] = stringToVar(t[c]);
						}
						catch (e:Error){
							
						}
					}
				}
				
				// Calculate
				str = t[0];
				n = 0;
				for (var o:int = 1; o < t.length; o++){
					switch (operatorOrder[n]){
						case 0: str -= t[o]; break;
						case 1: str += t[o]; break;
						case 2: str /= t[o]; break;
						case 3: str *= t[o]; break;
						case 4: str %= t[o]; break;
					}
					n++;
				}
			} else {
				// If no operators - just convert to var or func
				str = stringReplaceAll(str,"\"");
				try {
					if (str.indexOf("(") > 0 && str.indexOf(")") > str.indexOf("(")){
						str = stringToFunc(str,true);
					} else {
						str = stringToVar(str);
					}
				}
				catch (er:Error){
					// do nothing
				}
			}
			
			return str;
		}
		
		
		private function checkShorthandCalculations(ar:Array):Array {
			if (ar[0].indexOf("+") == ar[0].length-1 || ar[0].indexOf("-") == ar[0].length-1 ||
				ar[0].indexOf("/") == ar[0].length-1 || ar[0].indexOf("*") == ar[0].length-1 ||
				ar[0].indexOf("%") == ar[0].length-1){
				ar[1] = ar[0] + ar[1];
				ar[0] = ar[0].substr(0,ar[0].length-1);
			}
			return ar;
		}
		
		private function containsOperators(str):Boolean {
			return str.indexOf("+") > -1 || str.indexOf("-") > -1 || str.indexOf("/") > -1 || str.indexOf("*") > -1 || str.indexOf("%") > -1;
		}
		
		//////////////////////////
		//	  Misc Functions	//
		/////////////////////////
		
			// Messages
		public function echo(str, colour:String = "FFFFFF"):void {
			historytext.htmlText = historytext.htmlText + "<font color=\"#"+ colour +"\">" + str + "</font>\n";
			historytext.scrollV = historytext.maxScrollV;
		}
		public function error(str):void {
			echo(str,"FF0000");
		}
		public function warn(str):void {
			echo(str,"0000FF");
		}
		
			// Common String related functions
		private function stringReplaceAll(str:String, r:String, rw:String = ""):String {
			do {
				str = str.replace(r,rw);
			}
			while(str.indexOf(r) > - 1);
			
			return str;
		}
		
		private function stringReplaceButExclude(str:String, r:String, exl:String, rw:String = "", removeExls:Boolean = true):String {
			// Replaces all 'r's in a string with 'rw' excluding 'r's inside 'exl's
			var temp:String = "";
			
			if (str.indexOf(exl) > -1){
				var inExl:Boolean = false;
				
				for (var i:int = 0; i < str.length; i++){
					if (str.charAt(i) == exl){
						inExl = !inExl;
						if (!removeExls) temp += exl;
					} else
					if (str.charAt(i) == r && !inExl){
						temp += rw;
					} else {
						temp += str.charAt(i);
					}
				}
			} else {
				temp = stringReplaceAll(str, r, rw);
			}
			return temp;
		}
		
		private function fillArrayWithIndexsOf(ar:Array, str:String, ar2:Array, startIndex:int = -1):Array {
			if (ar == null) ar = new Array();
			if (startIndex == -1) startIndex = str.length-1;
			
			for (var i:int = 0; i < ar2.length; i++){
				ar[i] = str.lastIndexOf(ar2[i],startIndex);
			}
			
			return ar;
		}
		
		private function characterCount(str:String, char:String):int {
			var count:int = 0;
			for (var i:int = 0; i < str.length; i++){
				if (str.charAt(i) == char) count++;
			}
			return count;
		}
		
		//////////////////////////
		//		  Tracer		//
		/////////////////////////
		
		private function setTrace(str:String){
			var originalLength:int = traceVars.length;
			
			str = str.replace("trace:","");
			
			if (str == "fps"){
				addEventListener(Event.ENTER_FRAME, tick);
				str = "console.fps";
			}
			
			var v:Array = str.split(",");
			for (var n:int = 0; n < v.length; n++){
				if (traceVars.indexOf(v[n]) == -1)
					traceVars.push(v[n]);
			}
			
			if (originalLength == 0 && traceVars.length != 0)
				tracer.addEventListener(Event.ENTER_FRAME, traceUpdate);
		}
		
		private function stopTrace(str:String){
			str = str.replace("stoptrace:","");
			
			if (str == "fps"){
				removeEventListener(Event.ENTER_FRAME, tick);
			} else
			if (str == "all"){
				traceVars = new Array();
			} else {
				var v:Array = str.split(",");
				for (var n:int = 0; n < v.length; n++){
					for (var i:int = 0; i < traceVars.length; i++){
						if (traceVars[i] == v[n]) traceVars.splice(i,1);
					}
				}
			}
			
			if (traceVars.length == 0){
				tracer.removeEventListener(Event.ENTER_FRAME, traceUpdate);
				tracer.visible = false;
				tracerNames.visible = false;
			}
		}
		
		private function traceUpdate(e:Event){
			var na:String;
			
			// actual trace
			if (tracerActualTrace){
				if (tracerOneCiclePerLine) var completeOutput:String = "";
				
				for (var t:int = 0; t < traceVars.length; t++){
					if (traceVars[t] != "console.fps" || tracerActualTraceFPS){
						
						var output:String = tracerActualTraceLayout;
						
						na = traceVars[i];
						if (na == "console.fps") na = "fps";
						
						output = output.replace("name",na);
						output = output.replace("value",stringToVarWithCalculation(traceVars[t]));
						
						if (!tracerOneCiclePerLine){
							trace(output);
						} else {
							completeOutput += output + tracerOneCiclePerLine_seperator;
						}
						
					}
				}
				
				if (tracerOneCiclePerLine) trace(completeOutput);
			}
			
			// tracer table
			if (tracerView){
				tracer.visible = true;
				tracerNames.visible = true;
				tracer.text = "";
				tracerNames.text = "";
				
				for (var i:int = 0; i < traceVars.length; i++){
					na = traceVars[i];
					
					if (na == "console.fps") na = "fps";
					
					tracerNames.appendText(na + "\n");
					tracer.appendText(stringToVarWithCalculation(traceVars[i]) + "\n");
				}
				
				// position				
				tracerNames.x = tracerAlignX - tracerNames.width;
				tracer.x = tracerNames.x - tracer.width - 10;
				if (visible && tracerAlignY < consoleheight+inputtext.height){
					tracer.y = 10 + inputtext.y + inputtext.height;
					tracerNames.y = 10 +inputtext.y + inputtext.height;
				} else {
					tracer.y = tracerAlignY;
					tracerNames.y = tracerAlignY;
				}
			} else {
				tracer.visible = false;
				tracerNames.visible = false;
			}
		}
		
		// FPS Counter
		private function tick(e:Event):void {
            ticks++;
            var now:uint = getTimer();
            var delta:uint = now - last;
            if (delta >= 1000) {
                var f:Number = ticks / delta * 1000;
				fps = f.toFixed(1);
                ticks = 0;
                last = now;
            }
        }
		
	}
}