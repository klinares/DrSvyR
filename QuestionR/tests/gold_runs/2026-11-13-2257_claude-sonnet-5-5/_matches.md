# Gold run 2026-11-13-2257, claude-sonnet-5-5: flags matched to the 48 known problems

Matched by the Claude project (an AI model) by reading `_flags.csv` against `tests/gold_items.csv`. One flag matches at most one known problem. A judgement, not checked by a second person.

**Found at either level: 41 of 48 (85.4%).** At fix level: 33 (68.8%). Of the 45 that can be judged from the end options alone: 40 (88.9%). Phase 4 baseline, old prompt, severity 5 or above: 36 of 48 (75.0%).

Controls (7 ESS items): 2 fix flags in all (C7, C8; 0.29 per item), 11 consider flags on 6 items. C4 has none.

| Problem | Type | Result | Flag (check, level) |
|---|---|---|---|
| F1-P1 | double-barrelled | found | one_thing, fix |
| F1-P2 | presupposition | found | no_presupposition, consider |
| F1-P3 | presupposition | found | non_attitudes, consider |
| F2-P1 | vague/ambiguous | found | ambiguous_words, fix |
| F2-P2 | response-mapping | found, approximate | response_scale, fix (end labels not parallel) |
| F3-P1 | double-barrelled | found | one_thing, fix |
| F3-P2 | retrieval/recall | found, approximate | reference_period, fix (averaging over weeks; the adding-up is inside the one_thing flag) |
| F4-P1 | leading/loaded | found | neutral_wording, fix |
| F4-P2 | complex-syntax | found, approximate | no_negation, fix (the negative interrogative only) |
| F5-P1 | vague/ambiguous | found | ambiguous_words, fix |
| F5-P2 | response-mapping | found | response_scale, fix |
| F5-P3 | presupposition | found | no_presupposition, fix |
| F6-P1 | sensitivity | missed | |
| F6-P2 | presupposition | found | ambiguous_words on "household's", fix |
| F7-P1 | double-barrelled | found | one_thing, fix |
| F7-P2 | response-mapping | found | response_scale, consider |
| F7-P3 | presupposition | found | no_presupposition, fix |
| F8-P1 | vague/ambiguous | found | ambiguous_words, fix |
| F8-P2 | retrieval/recall | found | retrieval_and_judgment, fix |
| F9-P1 | leading/loaded | found | balanced_stem, fix ("deserve" adds moral push) |
| F9-P2 | sensitivity | missed | |
| F10-P1 | double-barrelled | found | one_thing, fix |
| F10-P2 | vague/ambiguous | found | ambiguous_words, consider |
| F11-P1 | vague/ambiguous | found | ambiguous_words, fix |
| F11-P2 | retrieval/recall | found | reference_period, consider |
| F11-P3 | presupposition | found | no_presupposition, fix |
| F12-P1 | leading/loaded | found | neutral_wording, fix |
| F12-P2 | sensitivity | found, approximate | attitude_object, consider (the parent to mothers shift, not framed as sensitivity) |
| F12-P3 | response-mapping | missed (needs the full scale) | |
| F13-P1 | vague/ambiguous | found | ambiguous_words, consider |
| F13-P2 | response-mapping | found | response_scale, consider |
| F14-P1 | double-barrelled | found | one_thing, fix |
| F14-P2 | presupposition | found | no_presupposition, fix |
| F15-P1 | leading/loaded | found | neutral_wording, fix |
| F15-P2 | complex-syntax | missed | |
| F16-P1 | vague/ambiguous | found | ambiguous_words, fix |
| F16-P2 | retrieval/recall | found | how_many_or_how_often, fix |
| F16-P3 | vague/ambiguous | found | reference_period, fix |
| F17-P1 | presupposition | missed | |
| F17-P2 | response-mapping | found | response_scale, fix |
| F18-P1 | double-barrelled | found | one_thing, fix |
| F18-P2 | sensitivity | missed | |
| F18-P3 | presupposition | found | no_presupposition, fix (two flags) |
| F19-P1 | leading/loaded | found | neutral_wording, fix |
| F19-P2 | response-mapping | missed (needs the full scale) | |
| F20-P1 | complex-syntax | found | simple_syntax, fix |
| F20-P2 | vague/ambiguous | found | ambiguous_words, fix |
| F20-P3 | retrieval/recall | found | retrieval_and_judgment, fix |

By type (found of known): double-barrelled 6 of 6; vague/ambiguous 9 of 9; retrieval/recall 5 of 5; leading/loaded 5 of 5; presupposition 8 of 9; response-mapping 5 of 7; complex-syntax 2 of 3; sensitivity 1 of 4.
