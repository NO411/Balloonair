# Balloonair
## by NO11

A hot air balloon game for Minetest.

![screenshot](https://github.com/NO411/Balloonair/blob/main/screenshot.png)

This game was created in 21 days for the 2021 Minetest GAME JAM.
Everything (sounds, textures, models, code) was created by NO11 in these 21 days and is under the GPL 3.0 license.

The goal of the game is to get the highest score. The score is made up of the position of your balloon and the coins you have collected.
Try not to sink down!
You can play this game on a server with other players. You can see the scores of all online players by running `/scores`. 

##### Gameplay

Control a balloon and fly as far towards the sun as you can.

There are 3 items that you can collect:

* Gas bottle: drive forward faster
* Sandbag: you can activate a total of 4, the balloon rises because it is losing weight
* Shield: protects you from hills or birds, collect shield coins (green coins) to get it

Left click with the item to activate the boost. After 10 seconds the effect is removed.
Do not try to hit birds, you will kill them and you will sink! If you hit the ground you lose. Be careful: you only come up with sand and otherwise the balloon will keep sinking.
Collect coins to get more points!

While trying not to sink, enjoy the beautiful randomly generated landscape!

##### Controls

Where you move the mouse doesn't affect where you fly, you always fly in the direction of the sun and can only steer right, left, up and down!

* Down: lower the balloon
* Left: move the balloon to the left
* Right: move the balloon to the rigth
* Jump: start game
* Aux1: abort game
* Dig: use the selected item
* Escape: pause game

At the moment there are no global variables/functions, it is standalone.
If it gets enough positive feedback, maybe I'll create a modding API.
