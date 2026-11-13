# Gold test: the Evaluate review against the known problems

Test items: Sturgis, P., Roberts, C. and Robinson, T. (2026), LLMs for survey pretesting: How well can large language models identify flaws in survey questions? Survey Futures Working Paper 15, Appendix B, as transcribed by the Claude project into `tests/gold_items.csv` (20 flawed questions with 48 known problems; 7 European Social Survey core items as controls). Run on 2026-11-12.

**The matching of findings to known problems was done by the builder (Claude, in Claude Code), by reading, after all 27 reviews were saved. It is a judgement and is to be checked.** Every match is in `tests/gold_matches.csv` with a note where it was a close call; the borderline ones are listed below. Nothing in the app, a skill, a prompt, a threshold or a test was changed after seeing the results.

## How it was run

- Each of the 27 items was reviewed alone through `run_review()`, as a one-question questionnaire (`Q1. <question>` and a `Response options:` line), by the project manager model (claude-sonnet-5-5) with the app's own evaluation ceiling of 43,000 tokens, which was not raised. Form: research question "Evaluate this survey question", population "Adults in the general population", web, no country, English.
- The model was shown only the question and its options. Where the paper prints only the two end options (`scale_complete` FALSE, 19 of the 27 items in the file) the line reads `a scale running from <first> to <last> (the options in between are not shown in this test)`. The runner asserts before every call that the prompt holds no id, topic, set, problem id or problem text.
- All 27 calls finished (27 ok, 0 cut off, 0 other failures), each on the first attempt. Raw replies are in `tests/gold_runs/<id>.json`.
- Matching: only findings rated 5 or above were matched. Exact means the same problem with the same framing; approximate means the same underlying issue with a different emphasis. One finding matches at most one known problem and the reverse. Findings about the instrument (routing across questions) were matched like the others; there were none at 5 or above on a control item.

## Share of known problems found

- **Of all 48: 36 found, 75.0%** (33 exact, 3 approximate). Target 65%.
- **Of the 45 that can be judged from the end options alone: 36 found, 80.0%.** The 3 problems that need the full scale (F2-P2, F12-P3, F19-P2) were all not found.

Approximate matches, and the close calls among the exact ones, are the least certain: F6-P2, F12-P2 and F16-P3 (approximate), F14-P2 (exact, borderline), and F1-P2, where one finding states the content of two known problems and only one can be credited.

### Detection by problem type

| Problem type | Known | Found | Share | Judgeable | Found of judgeable |
|---|---|---|---|---|---|
| presupposition | 9 | 7 | 77.8% | 9 | 9 |
| vague/ambiguous | 9 | 8 | 88.9% | 9 | 9 |
| response-mapping | 7 | 3 | 42.9% | 4 | 4 |
| double-barrelled | 6 | 6 | 100.0% | 6 | 6 |
| leading/loaded | 5 | 4 | 80.0% | 5 | 5 |
| retrieval/recall | 5 | 5 | 100.0% | 5 | 5 |
| sensitivity | 4 | 1 | 25.0% | 4 | 4 |
| complex-syntax | 3 | 2 | 66.7% | 3 | 3 |

### Known problems not found

| Problem | Type | Known problem | Closest finding below severity 5 (builder's reading) |
|---|---|---|---|
| F1-P3 | presupposition | assumes respondent has experience of services | none separate; the severity 5 presupposition finding that matched F1-P2 also says respondents may have no experience of the services |
| F2-P2 | response-mapping | categories use inconsistent linguistic constructions | finding 7 (severity 4, response_scale): the two end labels are not parallel and the verb phrases differ |
| F6-P1 | sensitivity | precise income is a highly sensitive question | none |
| F9-P1 | leading/loaded | frames punishment as deserved | finding 37 (severity 4, neutral_wording): 'deserve' asserts a moral claim as fact |
| F9-P2 | sensitivity | social desirability around criminal justice attitudes | none |
| F12-P3 | response-mapping | no neutral midpoint | none |
| F13-P1 | vague/ambiguous | "the way things are going" conflates trajectory with current state | finding 49 (severity 4, plain_words): 'the way things are going' read as state or as direction |
| F13-P2 | response-mapping | only endpoints labelled on 0 to 10 scale | finding 50 (severity 4, response_scale): only the endpoints carry words |
| F15-P2 | complex-syntax | long sentence with conditional premise, domain specification, purpose clause, and time reference | finding 60 (severity 4, simple_syntax): one sentence stacking two premises, a purpose clause and a time frame |
| F17-P1 | presupposition | assumes respondent has a fixed home | finding 69 (severity 3, no_presupposition): assumes one home and one clear household |
| F18-P2 | sensitivity | reporting arguments is sensitive | none |
| F19-P2 | response-mapping | asymmetric scale interacts with leading preamble | none |

Findings are shown to the analyst only at severity 5 or above, so the ones in the last column would not have been seen. Six of the twelve (F2-P2, F9-P1, F13-P1, F13-P2, F15-P2, F17-P1) have a finding of that kind that matches them on the builder's reading; counting them would give 42 of 48. That is context, not the result: the threshold was not changed.

## Control items (7 ESS core items)

- **Findings rated 5 or above per control item: 0.43** (3 findings over 7 items; 2 of the 7 items have any). Target at most 1.0.
- **After setting aside findings that are only about the in-between options not being shown: 0.43** (3 findings). None of the control findings at 5 or above was only about that, so the two counts are the same. Instrument-level findings at 5 or above on a control item: 0.

| Control item | Findings at 5 or above (question) | (instrument) | After setting aside unshown-options findings |
|---|---|---|---|
| C1 | 0 | 0 | 0 |
| C3 | 0 | 0 | 0 |
| C4 | 0 | 0 | 0 |
| C5 | 0 | 0 | 0 |
| C6 | 0 | 0 | 0 |
| C7 | 2 | 0 | 2 |
| C8 | 1 | 0 | 1 |

The control findings at 5 or above:

- C7, plain_words, severity 5, on fruit, excluding drinking juice: 'Fruit' is read differently by different people: fresh only, or also dried, tinned or frozen fruit, fruit in a smoothie, or fruit cooked into a dish. The exclusion names only juice, so the other forms are left to each respondent. Which forms count is the analyst's decision, and the brief does not say.
- C7, specific_concrete, severity 5, on 'How often do you eat fruit' with the top option 'Three times or more a day': The stem gives no time frame, so each respondent picks their own period, such as last week, a typical week or the current season. Fruit eating can vary by season and by week. The unit 'times' is also undefined: it could mean separate eating occasions or pieces of fruit, so someone who eats two apples at once could answer either way. Which period fits depends on what the estimate is for, and the brief does not say.
- C8, specific_concrete, severity 5, on 'over your life in general nowadays': The item does not say which parts of life to consider (for example work, money, health, family), so respondents could each pick different parts or average over them. 'Nowadays' gives no clear time frame, so it is unclear whether the answer is about this week, this year or recent years. The brief names no construct or reference period, so the analyst must decide how narrow the item should be.

## Seconds and output tokens per item

| | Seconds | Output tokens |
|---|---|---|
| All 27 | mean 31.0, range 17.6 to 47.6 | mean 3940, range 2179 to 6521 |
| 20 flawed | mean 33.5, range 22.0 to 47.6 | mean 4301, range 2698 to 6521 |
| 7 control | mean 23.9, range 17.6 to 40.9 | mean 2907, range 2179 to 5278 |

Input tokens were 4135 to 4215 per item. In total 838 seconds, 112,254 tokens in and 106,374 out. Per-item figures are in `tests/gold_runs/_calls.csv`.

## Findings below severity 5

- On the 20 flawed items: 23 (1.1 per item), against 64 at 5 or above.
- On the 7 control items: 12 (1.7 per item), against 3 at 5 or above.

## Findings at 5 or above on flawed items that matched nothing (28), in full

For the Claude project to judge: some are real faults the authors did not list, some are the same issue as a matched finding, and some may be over-flagging. The builder has not ruled on which.

- **F3** (question), `plain_words`, severity 6. Evidence: 'vigorous physical activity and moderate physical activity'. The stem gives no definition of 'vigorous' or 'moderate', so respondents may draw the line between them in different places, and some may treat the two as the same thing. On the web the definition has to be on screen with the question, and the stem has none.
- **F3** (question), `specific_concrete`, severity 5. Evidence: 'physical activity' (no setting named) and 'In a typical week'. The stem does not say whether activity at paid work, housework, getting around or in free time counts. Respondents who have physically active jobs or do heavy housework could include it or leave it out, and the estimate would shift accordingly.
- **F4** (question), `one_thing`, severity 7. Evidence: 'reduce the number of immigrants coming to this country, particularly those who may not contribute to the economy'. The item asks about reducing immigration in general and about reducing it for one subgroup. A respondent who wants fewer non-contributing immigrants but not fewer immigrants overall, or the reverse, has no accurate answer. 'Do more' and 'reduce the number' also add a policy-effort judgment to a judgment about the level.
- **F4** (question), `plain_words`, severity 6. Evidence: 'those who may not contribute to the economy'. 'Contribute to the economy' can mean paid work, paying tax, running a business, unpaid care or spending. 'May not' also leaves open whether it means now or in future. Respondents will read the group differently. 'Immigrants' may likewise be read as including or excluding refugees, students or long-settled residents.
- **F4** (question), `specific_concrete`, severity 5. Evidence: 'the government should do more to reduce the number of immigrants'. 'Do more' compares against current government action that many respondents may not know, and no policy, group or time frame is named. Respondents may answer about the current level of immigration, about government effort, or about a general feeling. These are different things.
- **F4** (question), `agree_disagree_and_grids`, severity 5. Evidence: Strongly agree to Strongly disagree, attached to a single statement worded in one direction. A one-sided statement is open to acquiescence, and the leading wording adds to the pull toward agreeing. A direct question about the preferred level of immigration would ask for the same judgment without requiring respondents to convert it into agreement.
- **F5** (instrument), `filters_and_routing`, severity 7. Evidence: Q1 is the only item, with no screening question before it and no routing for people who are not employees. Every adult respondent reaches Q1, so the question reaches people it does not apply to, and no route leads non-employees to a suitable next question. A screening question and a skip are needed before Q1 in the full instrument.
- **F6** (question), `specific_concrete`, severity 6. Evidence: 'household's' and 'monthly'. The item does not say who counts as part of the household (for example adult children, lodgers, or relatives who share only some costs). It also does not say which month is meant (last month, a usual month, or an average), which matters when income varies. On the web there is no interviewer to explain, so any definition must be in the visible question text. The household definition should match the benchmark source the analyst will compare against, which the brief does not name.
- **F6** (question), `plain_words`, severity 5. Evidence: 'from all sources' and 'before tax and deductions'. 'All sources' does not tell the respondent whether benefits, pensions, gifts from family, savings withdrawals, loans or one-off payments count. 'Deductions' is a payroll term whose scope (pension contributions, loan repayments, other items) is not clear to everyone. Respondents may therefore include different things.
- **F7** (question), `plain_words`, severity 5. Evidence: 'access essential services such as healthcare'. 'Essential services' has no fixed meaning, and one example does not say which others count. 'Access' can mean physically travelling there, getting an appointment, affording it or being eligible. Respondents may therefore answer about different things.
- **F7** (question), `specific_concrete`, severity 5. Evidence: 'How easy or difficult is it' with no time frame, no way of travelling and no dimension of difficulty. The stem does not say whether difficulty means distance, travel time, cost, lack of transport or something else. It does not say which way of travelling to think of, or whether to think of a usual trip or the worst one. Respondents will fill these gaps differently. The analyst must decide which dimension and reference period the study needs.
- **F9** (question), `one_thing`, severity 7. Evidence: 'deserve to be punished severely, even if this means longer prison sentences'. The statement joins a view about how severe punishment should be with a view about longer prison sentences. A respondent who wants severe punishment but through other means, or who does not accept longer sentences, has no true answer on one agree-disagree scale. The 'even if' clause also assumes that severe punishment means longer prison terms.
- **F9** (question), `specific_concrete`, severity 5. Evidence: 'serious crimes' and 'punished severely'. Respondents may picture very different crimes (for example violent crime, fraud, drug offences) and different meanings of 'severely'. The answers then reflect different private reference points rather than one common object. Choosing which crimes to name, or whether to leave the term broad, narrows or changes the construct and is the analyst's decision.
- **F9** (question), `agree_disagree_and_grids`, severity 5. Evidence: 'To what extent do you agree or disagree?' after a single one-directional statement. Only the punitive side is stated and there is no item keyed the other way, so acquiescence would inflate agreement and cannot be separated from the attitude. A construct-specific question about how severe punishment should be could do the same job without a statement to accept or reject.
- **F12** (question), `specific_concrete`, severity 5. Evidence: 'stay at home to look after their children'. The phrase does not say whether it means full time, or whether a mother who works part time or from home counts. Respondents may read it differently and answer different questions. The analyst must decide which meaning is intended.
- **F13** (question), `specific_concrete`, severity 5. Evidence: 'Taking everything into account' together with 'at this moment'. The first phrase asks for an overall view of life. The second narrows it to the present moment. Respondents may answer from today's mood or from a longer stretch of their life, and the brief does not say which time frame the analyst intends.
- **F14** (question), `plain_words`, severity 5. Evidence: 'childcare services'. The term can be read as formal paid provision, such as nurseries or paid carers. It can also be read to include care by grandparents or other relatives, or after-school care. Which meaning a respondent picks changes what they judge. The analyst must decide which kinds of care the item is meant to cover.
- **F14** (question), `specific_concrete`, severity 5. Evidence: 'in your area'. 'Area' has no fixed size. Respondents may think of their street, their town or a wider region, and may judge different sets of providers. Where it is meant to apply, such as near home or near work, is also left open.
- **F15** (question), `plain_words`, severity 6. Evidence: 'personal carbon footprint'. This is a technical or metaphorical term, and the item gives no definition. Some respondents may read it as energy use only, others as all environmental harm, and others may not know it. The web mode allows the definition to sit in the question text.
- **F15** (question), `one_thing`, severity 6. Evidence: 'changes to your daily habits'. 'Daily habits' covers many different behaviours, such as travel, food, home energy and shopping. A respondent who changed one area but not another has no clear answer. To pick one position on the scale, the respondent must recall changes across all areas, add them up, and decide which count as done 'specifically' for this reason. The brief names no construct, so the domains that matter are for the analyst to choose.
- **F15** (question), `options_fit`, severity 5. Evidence: Response options 'A great deal' to 'Not at all'. The question asks about change over the past year. Someone who already lived in a low-carbon way before that year, and so made no recent change, has no true option: 'Not at all' would suggest they do nothing. The in-between options were not shown, so they could not be checked.
- **F17** (question), `specific_concrete`, severity 5. Evidence: 'the amount of space in the home' and 'the needs of your household'. The question does not say which space counts: rooms inside, storage, a garden, balcony or other outdoor areas. It does not say which needs count: sleeping, privacy, working or studying at home, hosting, storage. Respondents may fill these gaps differently, so the same housing situation could get different answers. The analyst must decide what the space construct covers, and this review cannot decide it.
- **F18** (question), `specific_concrete`, severity 6. Evidence: 'How often do you...' with no time frame. The stem gives no reference period, so each respondent picks their own: the past week, the past year, or the whole relationship. Answers are then not comparable. The brief gives no reference period, so its length is the analyst's choice.
- **F18** (question), `options_fit`, severity 5. Evidence: 'a scale running from Very often to Never'. No option is offered for people with no partner or no children. They must choose 'Never', which is untrue for them and mixes them with partnered respondents who do not argue. This overlaps with the presupposition finding: a filter question or a 'does not apply' option would each solve it, and the analyst decides which.
- **F18** (instrument), `filters_and_routing`, severity 6. Evidence: Q1 is the only item pasted and no screening question comes before it. Nothing sends people without a partner, or without children, past Q1. Every adult in the general population would reach an item that applies only to some of them. In web mode no interviewer can skip or clarify it.
- **F19** (question), `no_presupposition`, severity 6. Evidence: the recent scandals in government. The question assumes every respondent knows of these scandals and accepts that they happened. Respondents who know of none, or who dispute the label 'scandals', cannot answer on the terms given. The brief does not say which events are meant.
- **F19** (question), `specific_concrete`, severity 5. Evidence: politicians. It is not clear whose trust is being asked about: national, regional or local politicians, the governing party, or all of them. Respondents must choose their own referent and may differ, and they must average across many people to answer. The analyst should choose the level that matches the research aim, which the brief does not state.
- **F20** (question), `plain_words`, severity 5. Evidence: domestic tasks, caring responsibilities, or personal grooming. These are formal terms and may not be read the same way by everyone. 'Caring responsibilities' may be taken to mean only care for someone ill or dependent, so playing with one's own child could be counted as leisure by some and as care by others. 'Domestic tasks' may or may not include cooking, gardening or shopping.

