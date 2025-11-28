package;

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
import haxe.macro.Expr.EFieldKind;
import lime.media.FlashAudioContext;

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
		screen.drawFrame();
		var screenPixels = screen.framePixels;

		if (FlxG.renderBlit)
			screenPixels.copyPixels(FlxG.camera.buffer, FlxG.camera.buffer.rect, new Point());
		else
			screenPixels.draw(FlxG.camera.canvas, new Matrix(1, 0, 0, 1, 0, 0));

		var rc:Float = 1 / 3;
		var gc:Float = 1 / 2;
		var bc:Float = 1 / 6;
		screenPixels.applyFilter(screenPixels, screenPixels.rect, new Point(), new ColorMatrixFilter([
			rc, gc, bc, 0, 0,
			rc, gc, bc, 0, 0,
			rc, gc, bc, 0, 0,
			 0,  0,  0, 1, 0
		]));

		combatSound.play();
		this.playerHealth = playerHealth;
		this.enemy = enemy;

		updatePlayerHealth();

		// setup enemy sprite
		enemyMaxHealth = enemyHealth = if (enemy.type == REGULAR) 2 else 4; // health
		enemyHealthBar.value = 100; // full bar

		// init so nothing looks weird
		wait = true;
		results.text = "";
		pointer.visible = false;
		results.visible = false;
		outcome = NONE;
		selected = FIGHT;
		movePointer();

		visible = true;

		// fade in combat
		FlxTween.num(0, 1, .66, {ease: FlxEase.circOut, onComplete: finishFadeIn}, updateAlpha);
	}

	// called by tween, fade in all hud elements (or out i guess)
	function updateAlpha(alpha:Float)
	{
		this.alpha = alpha;
		forEach(function(sprite) sprite.alpha = alpha);
	}

	// set hud to active

	function finishFadeIn(_)
	{
		active = true;
		wait = false;
		pointer.visible = true;
		selectSound.play();
	}

	// set hud to hidden!
	function finishFadeOut(_)
	{
		active = false;
		visible = false;
	}

	// change player health text on screen

	function updatePlayerHealth()
	{
		playerHealthCounter.text = playerHealth + " / 3";
		playerHealthCounter.x = playerSprite.x + 4 - (playerHealthCounter.width / 2);
	}

	override public function update(elapsed:Float)
	{
		if (!wait) // if waiting, dont do this
		{
			updateKeyboardInput();
			updateTouchInput();
		}
		super.update(elapsed);
	}

	function updateKeyboardInput()
	{
		#if FLX_KEYBOARD
		var up:Bool = false;
		var down:Bool = false;
		var fire:Bool = false; // fire?

		if (FlxG.keys.anyJustReleased([SPACE, X, ENTER]))
		{
			fire = true;
		}
		else if (FlxG.keys.anyJustReleased([W, UP]))
		{
			up = true;
		}
		else if (FlxG.keys.anyJustReleased([S, DOWN]))
		{
			down = true;
		}

		if (fire)
		{
			selectSound.play();
			makeChoice(); // process choice
		}
		else if (up || down)
		{
			// move cursor up or down
			selected = if (selected == FIGHT) FLEE else FIGHT;
			selectSound.play();
			movePointer();
		}
		#end
	}

	function updateTouchInput()
	{
		#if FLX_TOUCH
		for (touch in FlxG.touches.justReleased())
		{
			for (choice in choices.keys())
			{
				var text = choices[choice];
				if (touch.overlaps(text))
				{
					selectSound.play();
					selected = choice;
					movePointer();
					makeChoice();
					return;
				}
			}
		}
		#end
	}

	// moves pointer to current choice

	function movePointer()
	{
		pointer.y = choices[selected].y + (choices[selected].height / 2) - 8;
	}

	function makeChoice()
	{
		pointer.visible = false;
		switch (selected)
		{
			case FIGHT:
				// if fight was picked
				// playersprite attacks first
				// 85% chance of hitting
				if (FlxG.random.bool(85))
				{
					damages[1].text = "1";
					FlxTween.tween(enemySprite, {x: enemySprite.x + 4}, 0.1, {
						onComplete: function(_)
						{
							FlxTween.tween(enemySprite, {x: enemySprite.x - 4}, 0.1);
						}
					});
					hurtSound.play();
					enemyHealth--;
					enemyHealthBar.value = enemyHealth / enemyMaxHealth * 100; // change health bar
				}
				else
				{
					// change our damage text, we missed!
					damages[1].text = "MISS!";
					missSound.play();
				}

				// damage text over enemy sprite
				damages[1].x = enemySprite.x + 2 - (damages[1].width / 2);
				damages[1].y = enemySprite.y + 4 - (damages[1].height / 2);

				// if still alive, attack back (enemy)

				if (enemyHealth > 0)
				{
					enemyAttack();
				}

				// fade in and float up
				FlxTween.num(damages[0].y, damages[0].y - 12, 1, {ease: FlxEase.circOut}, updateDamageY);
				FlxTween.num(0, 1, .2, {ease: FlxEase.circInOut, onComplete: doneDamageIn}, updateDamageAlpha);

			case FLEE:
				// 50/50 to escape
				if (FlxG.random.bool(50))
				{
					// success
					outcome = ESCAPE;
					results.text = "ESCAPED!";
					fledSound.play();
					results.visible = true;
					results.alpha = 0;
					FlxTween.tween(results, {alpha: 1}, .66, {ease: FlxEase.circOut, onComplete: doneResultsIn});
				}
                else
                {
                    enemyAttack();
                    FlxTween.num(damages[0].y, damages[0].y -12, 1, {ease: FlxEase.circOut}, updateDamageY);
                    FlxTween.num(0, 1, .2, {ease: FlxEase.circInOut, onComplete: doneDamageIn}, updateDamageAlpha);
                }
		}

        wait = true;
    }

    function enemyAttack()
    {
        // 30% chance to hit
        if (FlxG.random.bool(30))
        {
            // if we hit
            FlxG.camera.flash(FlxColor.WHITE, .2);
            FlxG.camera.shake(0.01, 0.2);
            hurtSound.play();
            damages[0].text = "1";
            playerHealth--;
            updatePlayerHealth();
        }
        else
        {
            // if miss
            damages[0].text = "MISS!";
            missSound.play();
        }

        // setup combat text to show on player sprite

        damages[0].x = playerSprite.x + 2 - (damages[0].width / 2);
        damages[0].y = playerSprite.y + 4 - (damages[0].height / 2);
        damages[0].alpha = 0;
        damages[0].visible = true;
    }

    // move damage displays

    function updateDamageY(damageY:Float)
    {
        damages[0].y = damages[1].y = damageY;
    }

    // fade in out

    function updateDamageAlpha(damageAlpha:Float)
    {
        damages[0].alpha = damages[1].alpha = damageAlpha;
    }

    // finish fading in

    function doneDamageIn(_)
    {
        FlxTween.num(1, 0, .66, {ease: FlxEase.circInOut, startDelay: 1, onComplete: doneDamageOut}, updateDamageAlpha);
    }

    // done results in
    function doneResultsIn(_)
    {
        FlxTween.num(1, 0, .66, {ease: FlxEase.circOut, onComplete: finishFadeOut, startDelay: 1}, updateAlpha);
    }

    // DONE DAMAGE OUT
    // when damage texts finish fading out, check what do next....

    function doneDamageOut(_)
    {
        damages[0].visible = false;
        damages[1].visible = false;
        damages[0].text = "";
        damages[1].text = "";

        if (playerHealth <= 0)
        {
            outcome = DEFEAT;
            loseSound.play();
            results.text = "DEFEAT";
            results.visible = true;
            results.alpha = 0;
            FlxTween.tween(results, {alpha: 1}, .66, {ease: FlxEase.circInOut, onComplete: doneResultsIn});
        }
        else if (enemyHealth <= 0)
        {
            outcome = VICTORY;
            winSound.play();
            results.text = "VICTORY!";
            results.visible = true;
            results.alpha = 0;
            FlxTween.tween(results, {alpha: 1}, .66, {ease: FlxEase.circInOut, onComplete: doneResultsIn});
        }
        else
        {
            // next round
            wait = false;
            pointer.visible = true;
        }
    }
}
