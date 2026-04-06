# Lulu's Big Walk

## 1. Game Overview

**Title:** Lulu's Big Walk
**Genre:** 2D Endless Runner / Platformer
**Platform:** PC / Mobile (iOS & Android)
**Engine:** Godot 4
**Graphics Style:** Pixel Art
**Developed by:** [alelorenzo085](http://github.com/alelorenzo085)

**Description:**
Lulu's Big Walk is a 2D endless runner where the player controls Lulu, an adorable pixel art dog who has escaped through an open door. The goal is to run as far as possible across different environments, dodging obstacles, collecting bones, and pulling off dog-like mischief. The further Lulu runs, the faster and more chaotic the world becomes.

---

## 2. Gameplay

### 2.1 Player
- **Controls:** Auto-run to the right. `Space` / Tap to jump. `Z` / Swipe Up to bark. `S` / Swipe Down to sit/duck. `P` to activate pee shield.
- **Abilities:**
  - **Double Jump:** A second jump can be performed while airborne.
  - **Bark:** Stuns nearby dogs and scares cats, opening a passage window. Short cooldown.
  - **Poo Shield:** Marks territory creating a temporary protective area. Long cooldown.
- **Actions:**
  - Run and survive as long as possible.
  - Dodge obstacles and collect bones and treats.
  - Fill the Mischief Meter to activate Dog Frenzy mode.

### 2.2 Collectibles
- **Bones:** Primary currency. Found on the ground or floating. Used in the shop.
- **Treats:** Rare currency. Grants x2 score multiplier for 10 seconds.
- **Balls:** Power-up. Lulu runs x1.5 faster for 8 seconds.
- **Sniff Trail:** All collectibles glow for 5 seconds, making them easier to spot.

### 2.3 Obstacles
- **Street Cats:** Static blockers. Lulu freezes briefly on contact. Bark to scare them.
- **Bicycles:** Move diagonally across the path. Require jump timing.
- **Puddles:** Lulu hesitates near water. Player must trigger a jump to pass.
- **Mail Carrier:** Throws packages. Bark to scare, jump to dodge.
- **Fences & Walls:** Require double jump or finding a gap.
- **Parked Cars:** Reduce the lane; jump on top or duck underneath.

### 2.4 Mischief Meter
Performing dog-like actions fills the Mischief Meter:
- Barking at someone: +1
- Peeing on a lamp post: +2
- Stealing a sandwich: +3
- Chasing a cat while shielded: +5

When full, **Dog Frenzy** activates: x2 speed, invulnerability, x3 score multiplier for 8 seconds.

### 2.5 Levels / Progression
- The game consists of three biomes that unlock based on total distance run.
- **Neighborhood Park** (0m): Wide sidewalks, trees, benches. Cats and cyclists.
- **City Downtown** (1,500m): Traffic, scaffolding, café terraces. Higher speed.
- **Forest** (3,000m): Uneven terrain, fallen logs, squirrels. Trampoline platforms.
- After 6,000m the game enters **Infinite Mode**, where speed increases continuously.

---

## 3. Game Mechanics

- **Movement:** Lulu runs automatically to the right. The player controls jumps, barks, and ducks.
- **Procedural Generation:** The level is built from pre-designed chunks assembled by a `ChunkManager`. Difficulty increases every 500m.
- **Mischief Combo:** Chaining dog-like actions fills the Mischief Meter and triggers Dog Frenzy mode.
- **Collectibles:** Bones and treats are picked up by running over them.
- **Hint / Shield:** The pee ability creates a temporary area shield. The bark stuns or scares enemies.
- **Win Condition:** There is no end — the goal is to beat your personal best distance and score.
- **Fail Condition:** Lulu hits a lethal obstacle and the run ends.

---

## 4. Character Animations

All sprite sheets plug directly into Godot's `AnimatedSprite2D`:

| Sprite Sheet | State | Trigger |
|---|---|---|
| `idlesprite.png` | `idle` | Lulu standing still |
| `walksprite.png` | `walk` | Low speed |
| `runsprite.png` | `run` | Normal speed |
| `jumpsprite.png` | `jump` | In the air |
| `sitsprite.png` | `sit` | Duck input held |
| `barksprite.png` | `bark` | Bark input (one-shot) |
| `poopsprite.png` | `poop` | Pee ability activated (one-shot) |

---

## 5. Technical Details

- **Engine:** Godot 4
- **Resolution:** 480×270 (pixel art, scaled up)
- **Physics:** 2D collisions and movement via `CharacterBody2D`
- **Level Generation:** Chunk-based procedural system with Object Pooling
- **Animations:** `AnimatedSprite2D` with `AnimationTree` state machine
- **Save System:** High score, collected bones, and unlocked cosmetics saved via `FileAccess`
