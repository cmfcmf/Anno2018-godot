# Anno 2018

This is a rewrite of twenty-year-old Anno 1602 using a modern game engine (Godot).
My goal is to bring the complete Anno 1602 experience to modern devices.
It uses grahics and configuration of the original game. Due to copyright law,
I cannot include the Anno 1602 graphics with Anno 2018. You need to have a copy of
Anno 1602 installed on your computer to import them into this game.

## Thanks

This would have never been possible without the work of countless Anno enthusiasts:
- [Sir Henry](https://github.com/wzurborg) for their work on different tools around
  the Anno1602 file formats.
- [Benedikt Freisen](https://github.com/roybaer) for their work on _mdcii-engine_
  and decoding further Anno1602 file formats.
- The countless forum posts and websites who worked on Anno1602 mods.

## Getting Started

### I just want to play

1. Go to this repository's releases page.
2. Download the latest release for your platform.
3. Extract and start the game.
4. Click _Load Anno 1602 files_.
5. Navigate to your Anno 1602 installation folder and click _Select current folder_.
6. Grab a coffee. This step takes several minutes. The game will appear to be frozen.
7. After the import has finished, click _Start Game_.

### I also want to contribute

1. Download Godot 3.0.2 https://godotengine.org/.
2. Clone this repository to your local machine.
3. Start Godot, click _Import_ and navigate to the location you cloned this repository at.
4. Open the imported project.
5. Click the _AssetLib_ button at the top of the screen.
6. Search for _Gut_ and click it.
7. Press _Install_, then press _Install_ again, leave everything selected,
   and press _Install_ one last time.
8. Hit `F5` to run the game.
9. Click _Run Tests_ (they should pass).
10. Re-open the game.
11. Follow the instructions in the _I just want to play section_ (after step 3).

## Roadmap

- [x] Load Anno 1602 savegames
- [x] Render Anno 1602 savegames
- [x] Render static animations (flags, smoke)
- [ ] Render tile animations (water, rivers, mill, canon foundry)
- [ ] Render ships
- [ ] Building logic
  - [ ] Render radius
  - [ ] Calculate running cost
  - [ ] Market logic
    - [ ] Calculate storage capactiy
    - [ ] Fetch produced goods
  - [ ] Production building logic
    - [ ] Render worker animations
    - [ ] Fetch raw goods
    - [ ] Produce goods
    - [ ] Pause if on fire or manually paused
  - [ ] Public building logic
  - [ ] House logic
    - [ ] Tax
    - [ ] Consumption of goods
    - [ ] Level advancement
- [ ] Building things
  - [ ] Draggable streets, walls
  - [ ] Rotateable buildings
- [ ] Shipyard
- [ ] Firefighters, Doctor
- [ ] Ship logic
  - [ ] Movement
  - [ ] Trade Routes
- [ ] Save savegame
- [ ] Start randomly generated endless game
- [ ] Play Anno 1602 scenarios
- [ ] Trader
- [ ] Pirate
- [ ] Natives
- [ ] Sound
  - [ ] Background music
  - [ ] Building sounds
- [ ] Misc
  - [ ] Triumphal arch
  - [ ] Golden monument
  - [ ] Palace
- [ ] Random events
  - [ ] Vulcano
  - [ ] Fire
  - [ ] Plague
  - [ ] Drought
- [ ] Military
  - [ ] Soldiers
  - [ ] Towers
  - [ ] Ship cannons
- [ ] AI
- [ ] Multiplayer
- [ ] Random island generation
- [ ] Increase island and map size
- [ ] Running on Android and iOS

## License

This project is licensed under GPLv2 or (at your option) any later version.
See the LICENSE file for further information.
