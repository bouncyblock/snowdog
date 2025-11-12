package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new() // ITS THE MAIN LOOP WOOOOO
	{
		super();
		addChild(new FlxGame(320, 240, MenuState));
	}
}
