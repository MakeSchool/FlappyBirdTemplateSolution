Making the Character Move
=============

So far we have only made the character move vertically. Now we want to make him
move to the right, so he can progress through the level. You may have already realized
how to do that: we just need to add velocity!

To do that, change the line

      character.physicsBody.velocity = ccp(0, clampf(character.physicsBody.velocity.y, -800, 200));

to

      character.physicsBody.velocity = ccp(80, clampf(character.physicsBody.velocity.y, -800, 200));

Now run the game again. You should see the character moving now!
