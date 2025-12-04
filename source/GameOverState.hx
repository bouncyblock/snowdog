package;

import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;

class GameOverState extends FlxState
{
    var titleText:FlxText;
    var messageText:FlxText;
    var scoreIcon:FlxSprite;
    var scoreText:FlxText;
    var highscoreText:FlxText;
    var mainMenuButton:FlxButton;

    public function new(win:Bool, score:Int)
    {
        super();
        #if FLX_MOUSE
        FlxG.mouse.visible = true;
        #end

        // create our items:

        
    }
}