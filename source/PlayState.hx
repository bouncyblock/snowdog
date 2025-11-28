// main file for running the "scene"

package; // must have?

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;

using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState
{
	var player:Player;
	var map:FlxOgmo3Loader;
	var walls:FlxTilemap;
	var coins:FlxTypedGroup<Coin>;
	var enemies:FlxTypedGroup<Enemy>;
	var hud:HUD;
	var money:Int = 0;
	var health:Int = 3;
	var inCombat:Bool = false;
	var combatHud:CombatHUD;

	function placeEntities(entity:EntityData) // spawning entities on the map where it was defined in Ogmo Editor
	{
		var x = entity.x;
		var y = entity.y;

		switch (entity.name)
		{
			case "player":
				player.setPosition(x, y);
			case "coin":
				coins.add(new Coin(x + 4, y + 4));
			case "enemy":
				enemies.add(new Enemy(x + 4, y, REGULAR));
			case "boss":
				enemies.add(new Enemy(x + 4, y, BOSS));
		}
	}

	function playerTouchCoin(player:Player, coin:Coin) // WHY IS THIS HERE AND NOT THE PLAYER CLASS?
	{
		if (player.alive && player.exists && coin.alive && coin.exists)
		{
			money++;
			hud.updateHUD(health, money);
			coin.kill();
		}
	}

	override public function create() // basically _init()
	{
		map = new FlxOgmo3Loader(AssetPaths.turnBasedRPG__ogmo, AssetPaths.room_001__json);
		walls = map.loadTilemap(AssetPaths.tiles__png, "walls");
		walls.follow();
		walls.setTileProperties(1, NONE);
		walls.setTileProperties(2, ANY);
		add(walls);

		// gotta have coins!
		coins = new FlxTypedGroup<Coin>();
		add(coins);

		// grrrrr
		enemies = new FlxTypedGroup<Enemy>();
		add(enemies);

		// hud
		hud = new HUD();
		add(hud);

		// combat hud
		combatHud = new CombatHUD();
		add(combatHud);

		player = new Player();
		map.loadEntities(placeEntities, "entities");
		add(player);

		FlxG.camera.follow(player, TOPDOWN, 1);

		super.create();
	}

	override public function update(elapsed:Float) // the main loop of this scene (not the game, thats handeled in main.hx?)
	{
		super.update(elapsed);
		if (inCombat)
		{
			if (!combatHud.visible)
			{
				health = combatHud.playerHealth;
				hud.updateHUD(health, money);
				if (combatHud.outcome == VICTORY)
				{
					combatHud.enemy.kill();
				}
				else
				{
					combatHud.enemy.flicker();
				}
				inCombat = false;
				player.active = true;
				enemies.active = true;
			}
		}
		else
		{
			FlxG.collide(player, walls);
			FlxG.overlap(player, coins, playerTouchCoin);
			FlxG.collide(enemies, walls);
			enemies.forEachAlive(checkEnemyVision);
			FlxG.overlap(player, enemies, playerTouchEnemy);
		}
		
	}

	function checkEnemyVision(enemy:Enemy) // basically jsut an enemy function hiding in playstate
	{
		if (walls.ray(enemy.getMidpoint(), player.getMidpoint()))
		{
			enemy.seesPlayer = true;
			enemy.playerPosition = player.getMidpoint();
		}
		else
		{
			enemy.seesPlayer = false;
		}
	}
	function playerTouchEnemy(player:Player, enemy:Enemy)
	{
		if (player.alive && player.exists && enemy.alive && enemy.exists && !enemy.isFlickering())
		{
			startCombat(enemy);
		}
	}

	function startCombat(enemy:Enemy)
	{
		inCombat = true;
		player.active = false;
		enemies.active = false;
		combatHud.initCombat(health, enemy);
	}
}
