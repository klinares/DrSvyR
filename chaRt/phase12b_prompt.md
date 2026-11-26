# Phase 12b: the player's first second, its memory, and a page the manager can open

Phase 12 is accepted. Three follow-ups from the manager's reading of `MOTION_JS`. No model calls. Conventions as before.

## 1. The first card's first second

Suspected, not seen: on page load the finished chart is painted first (it is the `<img>` in the HTML), then `play()` starts before the frame images have loaded, so `show()` skips the first frames (`im.complete` is false) and the finished chart stays up until a later frame replaces it. A reader would see: finished chart, then a jump to a part-drawn chart, then the motion.

- First find out whether it happens. Open the five-chart page in a headed Chrome with real time (not virtual time) and take screenshots every 50 ms for the first 800 ms. Record `data-frame` at each. Report what was seen before changing anything.
- If it happens, fix it so that a card that is going to play never shows the finished chart first, and never skips its opening frames: start only when the frames are decoded, and keep the still hidden for such a card until then. Without script, under reduced motion and in print, the finished chart must still show at once. A card that fails to load its frames must fall back to the finished chart, not stay blank.
- A check in Chrome with real time: the first frame drawn is frame 0, and no screenshot before it shows the finished chart on a card that then plays.

## 2. Memory

`ready()` makes an `Image` for every frame of every card when the page loads, whether or not the card is ever seen.

- Make the images when a card is about to play, and let them go when it stops. Replay makes them again.
- Report Chrome's memory for the five-chart page at rest, before and after this change (`performance.memory` or the task manager's figure; say which).
- Build a dashboard of twelve animated charts and report its size and its memory at rest and while one card plays. If it is not usable on an ordinary laptop, say so.

## 3. A page for the manager

- Write the five-chart animated dashboard to `tests/dashboard_motion/dashboard.html` (git-ignored like the other test dashboards), in the Clean style and in Briefing, marking UNCLASSIFIED.
- Rebuild `tests/dashboard_designed/` with `LIVE11_REPLAY=1`, so its two designed cards are animated cards. No model call.

## Not in this phase

- Storing only the changed rectangle of each frame. The manager's ruling: not now. Animation is chosen chart by chart and the dialog states the cost.

## Report

Add a section to `manager/done-12.md`: what was seen in item 1 before and after, the memory figures, the twelve-chart result, and the two count lines.
