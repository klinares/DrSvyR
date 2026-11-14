# Gold run 2026-11-14-0816, claude-sonnet-5-5: flags matched to the 48 known problems

Matched by the Claude project (an AI model) by reading `_flags.csv` against `tests/gold_items.csv`. One flag matches at most one known problem. A judgement, not checked by a second person. Reflexes in force: evaluate.md 0.8 (fix only for a fault in the question as written), sensitive.md 0.6, behavioral.md 0.6.

**Found at either level: 41 of 48 (85.4%).** At fix level: 33 (68.8%). Two matches are approximate (F2-P2, F12-P2).

Controls (7 ESS items): 2 fix flags, both on C7; 14 consider flags, on all 7 items. `likely_edited` was not cited on any item.

| Problem | Type | Result | Flag (check, level) |
|---|---|---|---|
| F1-P1 | double-barrelled | found | one_thing, fix |
| F1-P2 | presupposition | missed | |
| F1-P3 | presupposition | found | non_attitudes, consider |
| F2-P1 | vague/ambiguous | found | specific_concrete, fix |
| F2-P2 | response-mapping | found, approximate | response_scale, consider |
| F3-P1 | double-barrelled | found | one_thing, fix |
| F3-P2 | retrieval/recall | found | no_adding_up, fix |
| F4-P1 | leading/loaded | found | neutral_wording, fix |
| F4-P2 | complex-syntax | found | simple_syntax, fix |
| F5-P1 | vague/ambiguous | found | ambiguous_words, fix |
| F5-P2 | response-mapping | found | response_scale, fix |
| F5-P3 | presupposition | found | no_presupposition, fix |
| F6-P1 | sensitivity | missed | |
| F6-P2 | presupposition | found | ambiguous_words on "household", fix |
| F7-P1 | double-barrelled | found | one_thing, fix |
| F7-P2 | response-mapping | found | response_scale, consider |
| F7-P3 | presupposition | found | no_presupposition, fix |
| F8-P1 | vague/ambiguous | found | ambiguous_words, fix |
| F8-P2 | retrieval/recall | found | no_adding_up, fix |
| F9-P1 | leading/loaded | found | neutral_wording, fix |
| F9-P2 | sensitivity | missed | |
| F10-P1 | double-barrelled | found | one_thing, fix |
| F10-P2 | vague/ambiguous | found | ambiguous_words, consider |
| F11-P1 | vague/ambiguous | found | ambiguous_words, fix |
| F11-P2 | retrieval/recall | found | retrieval_and_judgment, consider |
| F11-P3 | presupposition | found | no_presupposition, fix |
| F12-P1 | leading/loaded | found | neutral_wording, fix |
| F12-P2 | sensitivity | found, approximate | attitude_object, consider (the parent to mothers shift, not framed as sensitivity) |
| F12-P3 | response-mapping | missed (needs the full scale) | |
| F13-P1 | vague/ambiguous | found | ambiguous_words, consider |
| F13-P2 | response-mapping | found | response_scale, consider |
| F14-P1 | double-barrelled | found | one_thing, fix |
| F14-P2 | presupposition | found | no_presupposition, fix |
| F15-P1 | leading/loaded | found | neutral_wording, fix |
| F15-P2 | complex-syntax | found | simple_syntax, fix |
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

By type (found of known): double-barrelled 6 of 6; vague/ambiguous 9 of 9; retrieval/recall 5 of 5; leading/loaded 5 of 5; complex-syntax 3 of 3; presupposition 7 of 9; response-mapping 5 of 7; sensitivity 1 of 4.
