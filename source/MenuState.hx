package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.ui.FlxButton;

class MenuState extends FlxState
{
    var playButton:FlxButton;
    var exitButton:FlxButton;
    override public function create() // creating the play button!
	{
		
        playButton = new FlxButton(0, 0, "Play", clickPlay);
        add(playButton);
        playButton.screenCenter();

        exitButton = new FlxButton(0, 0, "exit", clickExit);
        add(exitButton);
        exitButton.screenCenter(X);
        exitButton.y = playButton.y + 40;
        
		super.create();
	}
    
}

function clickPlay()
{
    FlxG.switchState(PlayState.new);
}

function clickExit()
{
    Sys.exit(0);
}