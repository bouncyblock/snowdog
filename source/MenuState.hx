package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.ui.FlxButton;

class MenuState extends FlxState
{
    var playButton:FlxButton;
    override public function create()
	{
		
        playButton = new FlxButton(0, 0, "Play", clickPlay);
        add(playButton);
        playButton.screenCenter();
		super.create();
	}
    
}

function clickPlay()
{
    FlxG.switchState(PlayState.new);
}