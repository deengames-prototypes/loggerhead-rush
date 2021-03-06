package deengames.loggerheadrush.entities;

import deengames.loggerheadrush.data.PlayerData;

import helix.GameTime;
import helix.core.HelixSprite;
using helix.core.HelixSpriteFluentApi;
import helix.data.Config;
 
// The player
class Player extends HelixSprite
{
    // Required because prey/predators require this as a constructor parameter,
    // except that we use FlxGroup.recycle, which demands parameterless constructors.
    public static var instance(default, null):Player;

    public var dead(get, null):Bool;
    public var currentHealth(default, null):Int = 0;
    public var totalHealth(default, null):Int = 0;
    public var foodPoints(default, default):Int = 0;
    public var smellProbability(default, null):Int = 0;
    
    private var lastHurtTime:Float = 0;
    
    public function new(playerData:PlayerData)
    {
        super("assets/images/entities/turtle.png");

        Player.instance = this;

        this.currentHealth = this.totalHealth = playerData.startingHealth;
        this.smellProbability = playerData.smellUpgrades * Config.getInt("smellPercentPerUpgradeLevel");

        this.moveWithKeyboard(Config.getInt("playerKeyboardMoveVelocity"))
            .setComponentVelocity("AutoMove", Config.getInt("playerAutoMoveVelocity"), 0)            
            .trackWithCamera();

        if (Config.get("buoyancy").enabled == true)
        {
            this.setComponentVelocity("Buoyancy", 0, Config.get("buoyancy").velocity);
        }
    }

    public function transform(stage:Int):Void
    {
        this.loadGraphic('assets/images/entities/turtle-stage${stage + 1}.png');        
    }

    public function getHurt():Void
    {
        var invincibleDuration:Int = Config.getInt("gotHurtInvincibleSeconds");
        if (GameTime.totalElapsedSeconds - lastHurtTime >= invincibleDuration)
        {            
            lastHurtTime = GameTime.totalElapsedSeconds;
            this.currentHealth -= 1;
            this.flicker(invincibleDuration);

            if (this.currentHealth <= 0)
            {
                this.setComponentVelocity("AutoMove", 0, 0);
            }
        }
    }

    public function get_dead():Bool
    {
        return this.currentHealth <= 0;
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);

        if (this.currentHealth > 0)
        {
            var baseVelocity:Int = Config.getInt("playerAutoMoveVelocity");
            var elapsedTimeVelocity = GameTime.totalElapsedSeconds * Config.getInt("autoMoveVelocityIncreasePerSecond");
            var totalVelocity = Math.min(baseVelocity + elapsedTimeVelocity, Config.getInt("maxVelocity"));
            
            totalVelocity = Std.int(Math.floor(totalVelocity));
            this.setComponentVelocity("AutoMove", totalVelocity, 0);
        }
    }
}