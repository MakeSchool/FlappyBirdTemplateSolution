Creating an Update Loop
=============

You probably noticed that if you keep tapping your character will keep going
higher and higher without stopping. We need to fix that!

For this sort of logic, games typically use an "update loop." What happens is that some
code is run really fast - up to 60 times per second! That code usually checks things like
player health, whether enemies have died, or whether our character is jumping too high!

In order to create an update loop, you need to add a new method. Below the
closing bracket of your ```touchBegan``` method, but before the ```@end```,
add the following:

	- (void)update:(CCTime)delta
	{
		// this will be run every frame.
		// delta is the time that has elapsed since the last time it was run.
	}

Limiting the jump!
=======================

Now that we have an update loop, limiting the jump is rather easy. We just need to
clamp the vertical velocity. To do that, in your ```update``` method, add:

	character.physicsBody.velocity = ccp(0, clampf(character.physicsBody.velocity.y, -800, 200));

We are using the method ```clampf``` to ensure that the ```character.physicsBody.velocity.y```
variable stays within the range ```-800``` to ```200```.

Now run the game and see what you did!
