package;

import haxe.macro.Expr.EFieldKind;
import flash.filters.ColorMatrixFilter;
import flash.geom.Matrix;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

enum Outcome
{
    NONE;
    ESCAPE;
    VICTORY;
    DEFEAT;
}

enum Choice
{
    FIGHT;
    FLEE;
}

class CombatHUD extends FlxTypedGroup<FlxSprite>
{
    public var enemy:Enemy;
    public var playerHealth(default, null):Int;
    public var outcome(default, null):Outcome;


    var background:FlxSprite;
    var playerSprite:Player;
    var enemySprite:Enemy;

    var enemyHealth:Int;
    var enemyMaxHealth:Int;
    var enemyHealthBar:FlxBar;

    var playerHealthCounter:FlxText;

    var damages:Array<FlxText>;

    var pointer:FlxSprite;
    var selected:Choice;
    var choices:Map<Choice, FlxText>;

    var results:FlxText;

    var alpha:Float = 0;
    var wait:Bool = true;

    var fledSound:FlxSound;
    var hurtSound:FlxSound;
    var loseSound:FlxSound;
    var missSound:FlxSound;
    var selectSound:FlxSound;
    var winSound:FlxSound;
    var combatSound:FlxSound;

    var screen:FlxSprite;

    public function new()
    {
        super();

        screen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
        var waveEffect = new FlxWaveEffect(FlxWaveMode.ALL, 4, -1, 4);
        var waveSprite = new FlxEffectSprite(screen, [waveEffect]);

        // bacjground
        background = new FlxSprite().makeGraphic(120, 120, FlxColor.WHITE);
        background.drawRect(1, 1, 118, 44, FlxColor.BLACK);
        background.drawRect(1, 46, 118, 73, FlxColor.BLACK);
        background.screenCenter(); // pesky american spelling taking over my code....
        add(background);

        // dummy player sprite that cannot move
        playerSprite = new Player(background.x + 36, background.y + 16);
        playerSprite.animation.frameIndex = 3;
        playerSprite.active = false;
        playerSprite.facing = RIGHT;
        add(playerSprite);

        // SAME THING AGAIN FOR ENEMY
        enemySprite = new Enemy(background.x + 76, background.y + 16, REGULAR);
        enemySprite.animation.frameIndex = 3;
        enemySprite.active = false;
        enemySprite.facing = RIGHT;
        add(enemySprite);

        // setup health display and add to group
        playerHealthCounter = new FlxText(0, playerSprite.y + playerSprite.height + 2, 0, "3 / 3", 8);
        playerHealthCounter.alignment = CENTER;
        playerHealthCounter.x = playerSprite.x + 4 - (playerHealthCounter.width / 2);
        add(playerHealthCounter);

        // enemy health bar
        enemyHealthBar = new FlxBar(enemySprite.x - 6, playerHealthCounter.y, LEFT_TO_RIGHT, 20, 10);
        enemyHealthBar.createFilledBar(0xffdc143c , FlxColor.YELLOW, true, FlxColor.YELLOW);
        add(enemyHealthBar);

        // create + add choices
        choices = new Map();
        choices[FIGHT] = new FlxText(background.x + 30, background.y + 48, 85, "FIGHT", 22);
        choices[FLEE] = new FlxText(background.x + 30, choices[FIGHT].y + choices[FIGHT].height + 8, 85, "FLEE", 22);
        add(choices[FIGHT]);
        add(choices[FLEE]);

        pointer = new FlxSprite(background.x + 10, choices[FIGHT].y + (choices[FIGHT].height / 2) - 8, AssetPaths.pointer__png);
        pointer.visible = false;
        add(pointer);

        // damage texts
        damages = new Array<FlxText>();
        damages.push(new FlxText(0, 0, 40));
        damages.push(new FlxText(0, 0, 40));
        for (d in damages)
        {
            d.color = FlxColor.WHITE;
            d.setBorderStyle(SHADOW, FlxColor.RED);
            d.alignment = CENTER;
            d.visible = false;
            add(d);
        }

        // results!
        results = new FlxText(background.x + 2, background.y + 9, 116, "", 18);
        results.alignment = CENTER;
        results.color = FlxColor.YELLOW;
        results.setBorderStyle(SHADOW, FlxColor.GRAY);
        results.visible = false;
        add(results);

        // like we did in hud

        forEach(function(sprite:FlxSprite)
        {
            sprite.scrollFactor.set();
            sprite.alpha = 0;
        });
        
        // dont see until called
        active = false;
        visible = false;

        fledSound = FlxG.sound.load(AssetPaths.fled__wav);
		hurtSound = FlxG.sound.load(AssetPaths.hurt__wav);
		loseSound = FlxG.sound.load(AssetPaths.lose__wav);
		missSound = FlxG.sound.load(AssetPaths.miss__wav);
		selectSound = FlxG.sound.load(AssetPaths.select__wav);
		winSound = FlxG.sound.load(AssetPaths.win__wav);
		combatSound = FlxG.sound.load(AssetPaths.combat__wav);

    }

    public function initCombat(playerHealth:Int, enemy:Enemy)
    {
        // some code should go here!!!!!
    }
}