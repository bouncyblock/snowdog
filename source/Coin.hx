package;

import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class Coin extends FlxSprite
{
    public function new(x:Float, y:Float) { // i guess to have things in function, localvarname:type
        super(x, y); // makes flx sprite at location
        loadGraphic(AssetPaths.coin__png, false, 8, 8);
    }

    override function kill() {
        alive = false;
        FlxTween.tween(this, {alpha: 0, y: y - 16}, 0.33, {ease: FlxEase.circOut, onComplete: finishKill});
    }

    function finishKill(_) {
        exists = false;
    }
}