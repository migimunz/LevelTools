#About  

LevelTools is a haxe/flixel library that makes loading and manipulating flixel tilemaps easy (or at least easier). This library is written to work with [Beeblerox' HaxeFlixel port](https://github.com/Beeblerox/HaxeFlixel). It provides utility classes for loading level data from [DAME](http://dambots.com/dame-editor/) and [Tiled Map Editor](http://www.mapeditor.org/), as well as extension methods for iterating tiles in tilemaps.

#Targets  

So far, the library has been tested with neko, native linux and windows and flash targets. However, it should support all platforms supported by HaxeFlixel.  

#How to build/install  

With haxelib:  
`haxelib install LevelTools`  

Building documentation, requires chxdoc:  
`make docs`  

Installing with haxelib locally:  
`make lib testlib`  

Otherwise, there is nothing to build, just include the library sources in your classpath.  

#Demos  

Coming soon.  

#Features  

* Loading levels exported from DAME. Supports:
    * Tilemap layers  
    * Sprite layers  
    * Path layers (at this point, one path per layer, due to a problem with naming individual tiles)  
    * Links between sprites  
    * Properties for all objects except individual tiles  
* Loading levels exported from Tiled Map Editor, experimental, wouldn't recommend using it at this point.  
* Tilemap iterators  
* Convenience extension methods for iterating, filtering and replacing tiles  

#Examples  

Loading a DAME level and retrieving individual layers:  
<pre><code>
level = DameLevel.loadLevel(
	Assets.getText("assets/DameProject/Level_DemoLevel1.xml"), //XML file exported from DAME
	"assets/", //Assets directory
	true //Add the level to the state when loaded
	);
var mainTilemap = level.getTilemap("MainTilemap");
var spriteLayer = level.getLayer("SpriteLayer");
</code></pre>  

Iterating a tilemap with a for loop:  
<pre><code>
using org.ivar.leveltools.LevelTools; //imports the extension methods
/* ... */

for(tileId in mainTilemap.iterAll())
{
	trace(tileId);
}
</code></pre>  

Alternatively, using `each*` methods provides more information and easier modification of the tilemap:  
<pre><code>
private var flowerId = 5;
/* ... */
//Adds variation by randomly changing the first flower tile to different flowers.
mainTilemap.eachWithId(flowerId, function(data:TileData) {
	data.tilemap.setTile(data.x, data.y, FlowerId + Std.random(3));
});
</code></pre>  