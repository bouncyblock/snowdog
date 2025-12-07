package;

import flixel.addons.transition.FlxTransitionableState;
import openfl.net.dns.AAAARecord;
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
        titleText = new FlxText(0, 20, 0, if (win) "You Win!" else "Game Over", 22);
        titleText.alignment = CENTER;
        titleText.screenCenter(FlxAxes.X);
        add(titleText);

        messageText = new FlxText(0, (FlxG.height / 2) - 18, 0, "Final Score:", 8);
        messageText.alignment = CENTER;
        messageText.screenCenter(FlxAxes.X);
        add(messageText);

        scoreIcon = new FlxSprite((FlxG.width / 2) - 8, 0, AssetPaths.coin__png);
        scoreIcon.screenCenter(FlxAxes.Y);
        add(scoreIcon);

        scoreText = new FlxText((FlxG.width / 2), 0, 0, Std.string(score), 8);
        scoreText.screenCenter(FlxAxes.Y);
        add(scoreText);

        // highscore would me nice
        var highscore = checkHighscore(score);

        highscoreText = new FlxText(0, (FlxG.height / 2) + 10, 0, "Highscore: " + highscore, 8);
        highscoreText.alignment = CENTER;
        highscoreText.screenCenter(FlxAxes.Y);
        add(highscoreText);

        mainMenuButton = new FlxButton(0, FlxG.height - 32, "Main Menu", switchToMainMenu);
        mainMenuButton.screenCenter(FlxAxes.X);
        mainMenuButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
        add(mainMenuButton);

        FlxG.camera.fade(FlxColor.BLACK, 0.33, true);

        
    }


    function checkHighscore(score:Int):Int
    {
        var highscore:Int = score;
        if (FlxG.save.data.highscore != null && FlxG.save.data.highscore > highscore)
        {
            highscore = FlxG.save.data.highscore;
        }
        else
        {
            FlxG.save.data.highscore = score;
        }
        return highscore;
    }

    function switchToMainMenu():Void
    {
        FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
            {
                FlxG.switchState(MenuState.new);
            });
    }
}