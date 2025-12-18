package;

import haxe.display.Display.DisplayItemKind;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxState;
import flixel.ui.FlxButton;

class MenuState extends FlxState
{
    var playButton:FlxButton;
    var exitButton:FlxButton;
    var titleText:FlxText;
    var optionsButton:FlxButton;


    override public function create() // creating the play button!
	{
		titleText = new FlxText(20, 0, 0, "snowdog", 22);
        titleText.alignment = CENTER;
        titleText.screenCenter(X);
        add(titleText);

        playButton = new FlxButton(0, 0, "Start...", clickPlay);
        add(playButton);
        playButton.screenCenter();

        optionsButton = new FlxButton(0, 0, "Minimal Choice", clickOptions);
        //optionsButton.x = (FlxG.width / 2) + 10;
        //optionsButton.y = playButton.y + 40;
        optionsButton.screenCenter(X);
        optionsButton.y = playButton.y + 40;
        add(optionsButton);

        exitButton = new FlxButton(0, 0, "Leave", clickExit);
        add(exitButton);
        exitButton.screenCenter(X);
        exitButton.y = playButton.y + 80;
        
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

function clickOptions()
{
    FlxG.switchState(new OptionsState());
}