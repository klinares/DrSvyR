# Phase 12: motion without av

Kevin's ruling: av did not work well on the work server, so the app stops using it. Motion stays, played by the browser from the frames the app already draws. No model calls in this phase.

Conventions as before: native pipe, no for/while/repeat, no new files in `R/`, commits only under `chaRt/`, no push, do not start WSL, tests from PowerShell, look at the result in a browser before saying done.

## Part A: take av out

1. Remove every use of av from the app: `av_installed()`, `av_has_h264()`, both `av::av_encode_video()` calls, `video_available()`'s av conditions, the MP4 files in the export zip, and av from DESCRIPTION, the manifest and the README's install line.
2. Remove av, gganimate and gifski from `probe/app.R`, with their checks.
3. Keep the frame engine as it is (`spec_frames()`, `video_frame()`, `video_draw()`, `design_video()`'s compositing, scales pinned, last frame equal to the static chart). Only the encoder goes.
4. After this part, `grep -rn "av::\|\"av\"" R app.R probe` returns nothing, and the app loads on a machine where av is not installed. Prove the second by a check that hides the package, not by uninstalling it.

## Part B: the browser plays the frames

1. A chart set to motion is exported as its frames, embedded in `dashboard.html` as base64 PNG, with a player written in plain JavaScript inline in the page. No library, no CDN, no file beside the page.
2. Frames: 12 per second, not 24. Drawn at the card's size, not the download size. The hold at the end is not stored as frames: the player stops on the last frame. Identical neighbouring frames are stored once with a repeat count.
3. The player:
   - starts when the card first scrolls into view, plays once, and stops on the last frame;
   - has a Replay button, a real `<button>` with a text label, reachable by keyboard;
   - with `prefers-reduced-motion: reduce`, shows the last frame and never plays;
   - with JavaScript off, shows the static picture (`<noscript>` or an `<img>` the script replaces);
   - in print, shows the static picture. Check this in Chrome's print output: no card may print a half-drawn chart.
4. The classification bands stay outside the chart on every frame, as now.
5. In the app, the card's video preview uses the same player. The words "video" and "MP4" in the interface, the export dialog and the README become "motion" or "animated", wherever they now promise a file.
6. The zip no longer holds MP4 files. `charts/` keeps PNG at 300 dpi, SVG and CSV.
7. Weight: report the size of `dashboard.html` for the five-chart test dashboard with all five in motion, and for one chart alone. If one chart is over 2 MB, say so and say which frames cost most. Do not lower quality to hide it.
8. The export dialog shows the estimated added size beside each chart set to motion.

## Part C: checks

1. Replace the checks that encoded and read back an MP4 (9B-15 to 9B-18, the probe's 9C checks that used av, and Part C of Phase 11's video checks) with checks of the same intent on the new path: frame count, last frame identical to the static picture, scales the same on every frame, bands on every frame.
2. In headless Chrome, on the exported page: the player reaches the last frame; Replay plays again; reduced motion shows the last frame at once; the printed page shows the static picture; nothing is requested from the network.
3. A mutation for each new check.
4. Both smoke runs pass. Report the two count lines.

## Not in this phase

- No animated GIF and no animated PNG file. If Kevin later needs a file for slides, the `apng` package (pure R, no compiled code) is the candidate, and it goes into the probe before it goes into the app.
- `www/methodology.md`, the reflex files and the skill files are the manager's. If any of them says "video" or "MP4", list the lines in the report and do not edit them.

## Report

Write `manager/done-12.md`: what was removed, the page weights, what was seen in the browser and by whom, what was not seen, and the two count lines.
