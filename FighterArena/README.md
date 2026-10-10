# Fighter Arena (Prototype)

A landscape, offline-first 3D arena fighting prototype for Android, built with Godot 4 and GDScript.

## Current prototype
- Runtime-generated 3D arena and two stylized fighter models (no external model downloads).
- Player controls: move left/right, block, punch, kick.
- Rival AI approaches the player and attacks on a timer.
- Health bars, hit feedback, victory/defeat and restart.
- GL Compatibility renderer selected for broad mobile support.

## Build APK
GitHub Actions workflow: **Build Fighter Arena APK**. Pushes to this branch or manual dispatch start a build. Download the artifact named **FighterArena-debug-apk** from the completed run's Artifacts section.

## Size target
About 50 MB is a target, not a guarantee. Actual APK size depends on Godot export templates and architecture. This prototype uses primitive meshes and no bundled high-resolution textures/audio to keep assets small.

## Important
This is a playable prototype, not a finished commercial fighting game. It does not yet contain imported rigged character models, motion-captured animation, campaign progression, save slots, sound, or online multiplayer. Replace generated fighters with licensed rigged GLB assets as the next art milestone.

## Phone/iPad workflow
Edit files in GitHub from the mobile app/browser. Use GitHub Actions to produce the APK in the cloud; no laptop is required. Render is not needed to serve the offline game itself.
