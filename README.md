# TF2: Gold Rush photo mode

A free camera for taking screenshots in TF2: Gold Rush on a local server: noclip flying with
adjustable speed, FOV 10–120, camera tilt and a HUD toggle, entered and left with one command each.

Downloads, setup and controls: **https://theothertored.github.io/tf2gr-photo-mode/**

## Files

| Path | Goes to |
| --- | --- |
| `tf_goldrush/cfg/photomode.cfg` | `tf_goldrush\cfg\` |
| `tf_goldrush/cfg/photomode_off.cfg` | `tf_goldrush\cfg\` |
| `tf_goldrush/scripts/vscripts/photomode.nut` | `tf_goldrush\scripts\vscripts\` |
| `tf_goldrush/addons/SourceRes.dll`, `SourceRes.vdf` | `tf_goldrush\addons\` (optional) |
| `tf_goldrush/screenshots/tga-to-png.bat` | `tf_goldrush\screenshots\` (optional, needs ImageMagick) |

`SourceRes.dll` is a 64-bit build of [SourceRes](https://github.com/jooonior/SourceRes) by jooonior,
for rendering at resolutions larger than your monitor.

## Releasing

Push a tag (`git tag v1.0 && git push origin v1.0`). The workflow in `.github/workflows/release.yml`
publishes a release with the ZIPs and single files that the page's download buttons point to.
