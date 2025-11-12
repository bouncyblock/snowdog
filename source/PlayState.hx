// main file for running the "scene"

package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.tile.FlxTilemap;

class PlayState extends FlxState
{
	var player:Player;
	var map:FlxOgmo3Loader;
	var walls:FlxTilemap;

	function placeEntities(entitie:EntityData) // spawning entities on the map where it was defined in Ogmo Editor
	{
		if (entitie.name == "player")
		{
			player.setPosition(entitie.x, entitie.y);
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

		player = new Player();
		map.loadEntities(placeEntities, "entities");
		add(player);

		FlxG.camera.follow(player, TOPDOWN, 1);

		super.create();
	}

	override public function update(elapsed:Float) // the main loop of this scene (not the game, thats handeled in main.hx?)
	{
		super.update(elapsed);
		FlxG.collide(player, walls);
	}
}
