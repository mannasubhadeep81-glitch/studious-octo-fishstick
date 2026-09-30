# LUMIRA Racing

A standalone mobile-friendly 2D arcade racing prototype.

## V2 build
- Canvas-based 2D rendering
- Parallax city/highway scenery
- Player car + moving traffic opponents
- Three selectable cars with different speed/nitro profiles
- Nitro boost and particle effects
- Touch + keyboard controls
- Garage UI
- Score, best score and race progress HUD
- Local persistence for selected car and best score
- Responsive mobile/landscape layout
- No external game assets or dependencies required

## Play
Open `racing/index.html` through GitHub Pages or another static web host.

## Backend / AI plan
The browser game should not contain private AI API keys. A future Render service can expose a small `/api/ai` or `/api/race` endpoint, and the game can call that endpoint for AI-powered race features.

## Next phases
1. Authored SVG/PNG sprite sheets and richer environment art.
2. Multiple tracks, laps, checkpoints, garage upgrades and progression.
3. Audio, engine sound, collision sound and richer VFX.
4. Smarter opponent racing behaviour.
5. Render backend/API integration and optional AI features.
