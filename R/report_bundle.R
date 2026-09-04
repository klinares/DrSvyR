# The delivered report. One self-contained HTML file: no server, no CDN, no
#   htmlwidgets. It opens from a file:// URL, survives being emailed, and the
#   tables in it can be downloaded as CSV without anything installed.

# Why not a .docx as well. An analyst can select and copy out of a browser, so
#   a second static rendering bought nothing and cost a second thing to keep in
#   step with the first. The Word writer is gone, and with it officer and
#   flextable -- the two dependencies that needed Rtools, which is what an
#   analyst on a locked-down desktop cannot install.

# Why the tables are embedded as data rather than only as markup. The analyst
#   writing for a policymaker needs the numbers in a spreadsheet, and the
#   analyst reading the report needs them on screen. One JSON payload serves
#   both, and it cannot disagree with itself the way a table rendered twice can.

# What is NOT in this file, deliberately: any respondent record. This is the
#   artefact that gets forwarded. Segment prevalences, response probabilities,
#   domain estimates and counts are aggregates; the scored data ships as the
#   .sav beside it, which is a file people think twice about attaching.


# ---- 1. the tables ----------------------------------------------------------

# Everything the HTML can show or hand back as CSV, in one place, so a tab, a
#   download button and the long-format export cannot drift apart.

# theta_k is "segment prevalence" throughout. Not "inclusion probability":
#   in survey sampling that is pi_i, the probability a unit enters the sample,
#   and this audience will read it that way.
report_tables <- function(state) {
  labs = state$labels$Label
  seg  = function(k) labs[k] %||% paste("Segment", k)

  out = list()

  out$segments = tibble::tibble(
    segment = seq_along(labs),
    label = labs,
    description = state$labels$Description,
    prevalence = if (!is.null(state$measure))
      state$measure$shares$share else state$model$fit$pi,
    lo = if (!is.null(state$measure)) state$measure$shares$lo else NA_real_,
    hi = if (!is.null(state$measure)) state$measure$shares$hi else NA_real_,
    boundary = if (!is.null(state$measure))
      state$measure$shares$boundary else NA)

  if (!is.null(state$measure))
    out$response_probabilities = state$measure$probs |>
      dplyr::transmute(item, response, segment = group,
                       label = seg(group), probability = prob, se, lo, hi,
                       boundary)

  if (!is.null(state$measure))
    out$segment_profiles = state$measure$profile |>
      dplyr::transmute(item, segment = group, label = seg(group),
                       position = value, se, lo, hi)

  if (!is.null(state$domains)) {
    out$domain_estimates = state$domains$dom |>
      dplyr::mutate(label = seg(segment)) |>
      dplyr::relocate(label, .after = segment)
    out$population_shares = state$domains$marg
  }

  out$item_dictionary = dictionary_table(state)
  out$what_was_tested = status_table(state)
  out$coverage = state$coverage

  # These four used to be written as CSVs beside the report and nowhere else.
  #   With the CSV dump gone they have to live here or they are lost, and each
  #   is something a reviewer asks for rather than something an analyst reads.
  # The assigned-share table is deliberately NOT here. The size of a segment,
  #   for reporting, is the model prevalence in out$segments: pi_k from the
  #   design-weighted pseudo-likelihood, with an interval from refitting in
  #   every replicate. The share of respondents assigned to a segment is a
  #   scoring check, it treats the segment boundaries as known, and it would be
  #   quoted the moment it appeared in a report next to something that looked
  #   like it. It stays on the Scoring screen, where it is labelled as a check
  #   and shown beside the prevalence it should not be confused with.
  out$assignment_quality = state$quality
  out$design_checks = state$design_checks
  out$recode_audit = state$recode_audit

  purrr::compact(out)
}



# ---- 2. rendering helpers ---------------------------------------------------

# Escaping for text shown verbatim: the decision logs and the specification.
#   htmltools would do this, and taking it as a dependency for four characters
#   is not worth it.
html_escape <- function(x) {
  x = gsub("&", "&amp;", x, fixed = TRUE)
  x = gsub("<", "&lt;",  x, fixed = TRUE)
  gsub(">", "&gt;", x, fixed = TRUE)
}

# JSON escaped so it cannot terminate the script element it sits in. </script>
#   inside a string literal ends the block in every browser regardless of the
#   quoting, which is the one way an embedded payload breaks a page.

REPORT_TAB_CSS <- "
:root{--ink:#1a1a1a;--mute:#5c5c5c;--rule:#d8d8d8;--bg:#fff;--accent:#21918C;
      --wash:#f6f6f4;}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--ink);
     font:15px/1.55 -apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;}
.wrap{max-width:1080px;margin:0 auto;padding:0 24px 96px;}
header{border-bottom:2px solid var(--ink);padding:28px 0 14px;margin-bottom:0;}
header h1{font-size:25px;margin:0 0 4px;letter-spacing:-.01em;}
header .meta{color:var(--mute);font-size:13px;}
nav{position:sticky;top:0;background:var(--bg);z-index:5;
    border-bottom:1px solid var(--rule);padding:8px 0;margin-bottom:26px;
    display:flex;flex-wrap:wrap;gap:2px;}
nav button{border:0;background:none;font:inherit;font-size:13.5px;
           color:var(--mute);padding:6px 11px;border-radius:4px;cursor:pointer;}
nav button:hover{background:var(--wash);color:var(--ink);}
nav button[aria-selected=true]{background:var(--ink);color:#fff;}
section[hidden]{display:none}
h2{font-size:19px;margin:1.9em 0 .5em;padding-bottom:5px;
   border-bottom:1px solid var(--rule);}
h3{font-size:16px;margin:1.5em 0 .35em;}
h4,h5{font-size:15px;margin:1.2em 0 .3em;}
p{margin:.55em 0;white-space:pre-line;}
img{max-width:100%;margin:.7em 0;}
table.dt{border-collapse:collapse;width:100%;font-size:13px;margin:.5em 0 1em;}
table.dt th{text-align:left;border-bottom:1.5px solid var(--ink);
            padding:6px 9px;font-weight:600;white-space:nowrap;}
table.dt td{border-bottom:1px solid var(--rule);padding:5px 9px;
            vertical-align:top;}
table.dt tbody tr:hover{background:var(--wash);}
.box{background:var(--wash);border-left:3px solid var(--accent);
     padding:9px 13px;margin:1.1em 0;font-size:13.5px;color:var(--mute);}
.bar{display:flex;flex-wrap:wrap;gap:8px;align-items:center;
     margin:.4em 0 1em;padding:9px 0;border-bottom:1px solid var(--rule);}
.bar label{font-size:13px;color:var(--mute);}
select,.dl{font:inherit;font-size:13px;padding:5px 10px;border-radius:4px;
           border:1px solid var(--rule);background:#fff;color:var(--ink);
           cursor:pointer;}
.dl:hover{border-color:var(--ink);}
.seg{display:inline-block;border:1px solid var(--rule);border-radius:4px;
     overflow:hidden;}
.seg button{border:0;background:#fff;font:inherit;font-size:13px;
            padding:5px 11px;cursor:pointer;color:var(--mute);}
.seg button[aria-pressed=true]{background:var(--accent);color:#fff;}
.note{font-size:12.5px;color:var(--mute);margin:.3em 0 1.2em;}
pre{background:var(--wash);border:1px solid var(--rule);border-radius:4px;
    padding:12px;overflow:auto;font-size:12.5px;line-height:1.45;}
@media print{nav{display:none}section[hidden]{display:block !important}}
"

# Tab switching, table rendering from the payload, the estimator toggle and
#   CSV download. Vanilla, because DT and plotly self-contained are megabytes
#   and three dependencies for a table and a button.

# Nothing here computes an estimate. The moment this file derives a number it
#   can disagree with the report above it, and there would be no way to tell
#   which was wrong. It formats and it filters.
REPORT_JS <- "
const DATA = JSON.parse(document.getElementById('drsvyr-data').textContent);

function toCSV(rows){
  if(!rows || !rows.length) return '';
  const cols = Object.keys(rows[0]);
  const q = v => {
    if(v === null || v === undefined) return '';
    const s = String(v);
    return /[\",\\n]/.test(s) ? '\"' + s.replace(/\"/g,'\"\"') + '\"' : s;
  };
  return [cols.join(',')]
    .concat(rows.map(r => cols.map(c => q(r[c])).join(','))).join('\\n');
}
function download(name, text){
  const b = new Blob([text], {type:'text/csv;charset=utf-8;'});
  const a = document.createElement('a');
  a.href = URL.createObjectURL(b); a.download = name;
  document.body.appendChild(a); a.click();
  document.body.removeChild(a); URL.revokeObjectURL(a.href);
}
function fmt(v){
  if(v === null || v === undefined) return '';
  if(typeof v === 'number') return Number.isInteger(v) ? v : v.toFixed(4);
  return v;
}
function renderTable(el, rows){
  if(!rows || !rows.length){ el.innerHTML = '<p class=note>Nothing to show.</p>'; return; }
  const cols = Object.keys(rows[0]);
  el.innerHTML = '<table class=dt><thead><tr>' +
    cols.map(c => '<th>' + c + '</th>').join('') + '</tr></thead><tbody>' +
    rows.map(r => '<tr>' + cols.map(c => '<td>' + fmt(r[c]) + '</td>').join('') +
      '</tr>').join('') + '</tbody></table>';
}

document.querySelectorAll('nav button').forEach(b => {
  b.onclick = () => {
    document.querySelectorAll('nav button')
      .forEach(x => x.setAttribute('aria-selected', x === b));
    document.querySelectorAll('main > section')
      .forEach(s => s.hidden = (s.id !== b.dataset.tab));
    window.scrollTo(0,0);
  };
});

document.querySelectorAll('[data-dl]').forEach(b => {
  b.onclick = () => {
    const key = b.dataset.dl;
    download('drsvyr_' + key + '.csv',
             toCSV(key === 'all_estimates' ? DATA.__long : DATA[key]));
  };
});

// The estimator toggle. Same rows, three readings, switching in place. The
// whole argument of this tool is the size of the gap between them, and three
// stacked tables do not show it moving.
const dom = DATA.domain_estimates;
if(dom){
  const est = document.getElementById('est-toggle');
  const sel = document.getElementById('dom-var');
  const box = document.getElementById('dom-table');
  const vars = [...new Set(dom.map(r => r.variable))];
  sel.innerHTML = '<option value=\"__all\">All domains</option>' +
    vars.map(v => '<option>' + v + '</option>').join('');
  const draw = () => {
    const e = est.querySelector('[aria-pressed=true]').dataset.est;
    const v = sel.value;
    renderTable(box, dom.filter(r =>
      r.estimator === e && (v === '__all' || r.variable === v)));
  };
  est.querySelectorAll('button').forEach(b => b.onclick = () => {
    est.querySelectorAll('button')
      .forEach(x => x.setAttribute('aria-pressed', x === b));
    draw();
  });
  sel.onchange = draw;
  draw();
}

Object.keys(DATA).forEach(k => {
  const el = document.getElementById('tbl-' + k);
  if(el) renderTable(el, DATA[k]);
});
"


# ---- 3. the document --------------------------------------------------------

# One tab per artefact. The order is the order an analyst reads in: what was
#   found, then what it rests on, then who decided what.
REPORT_TABS <- c(
  summary      = "Summary",
  segments     = "Segments",
  responses    = "Response probabilities",
  domains      = "Domains",
  shares       = "Population shares",
  diagnostics  = "Diagnostics",
  decisions    = "Decisions",
  spec         = "Specification",
  tested       = "What was tested")

tab_section <- function(id, ..., hidden = TRUE)
  paste0("<section id=\"", id, "\"", if (hidden) " hidden" else "", ">",
         paste0(..., collapse = ""), "</section>")

dl_button <- function(key, label = "Download CSV")
  paste0("<button class=dl data-dl=\"", key, "\">", label, "</button>")

build_report_html <- function(state, summary_text = NULL,
                              not_answered = NULL) {
  tabs = report_tables(state)

  # One long-format table for anyone who would rather read a single file than
  #   eleven. table_name says which of the above a row came from; the columns
  #   are the union, so most rows carry NA in most of them. That is the price
  #   of one file and it is the right one to pay here.
  payload = c(tabs, list(`__long` = purrr::imap(tabs, function(d, nm)
    tibble::as_tibble(d) |>
      dplyr::mutate(dplyr::across(dplyr::everything(), as.character)) |>
      dplyr::mutate(table_name = nm, .before = 1)) |>
    purrr::list_rbind()))

  # jsonlite warns on a named vector -- "Input to asJSON(keep_vec_names=TRUE)
  #   is a named vector" -- and in a future version will serialise it as an
  #   array instead of an object, silently changing the payload. Several
  #   columns here carry names (cfg$cats is named by item, coef() names its
  #   output), so names are stripped before anything is serialised.
  # </ is escaped because a literal </script> inside a string ends the script
  #   element in every browser regardless of the quoting around it.
  json = gsub("</", "<\\/", jsonlite::toJSON(
    purrr::map(payload, function(d)
      as.data.frame(lapply(as.data.frame(d), unname),
                    stringsAsFactors = FALSE, optional = TRUE)),
    dataframe = "rows", na = "null", auto_unbox = TRUE, digits = 8),
    fixed = TRUE)

  # report_html() already returns the narrative as tags; converted one at a
  #   time so this file takes no shiny dependency of its own.
  # report_html() renders one tag per block, so the first two are the h1 and
  #   the metadata line that report_blocks() always opens with. The header
  #   above prints both, and the report was showing its own title twice.
  #   Dropped by position rather than by rebuilding the block list, because
  #   report_blocks() draws the figures and running it twice would draw them
  #   twice. report_blocks() itself is untouched: the on-screen review has no
  #   header of its own and still needs them.
  tags = report_html(state, summary_text, not_answered)
  if (length(tags) >= 2) tags = tags[-(1:2)]
  narrative = paste0(purrr::map_chr(tags, as.character), collapse = "")

  has = function(k) !is.null(tabs[[k]])

  nav = paste0(
    "<nav>",
    paste0(purrr::imap_chr(REPORT_TABS, function(lab, id)
      paste0("<button data-tab=\"", id, "\" aria-selected=",
             if (id == "summary") "true" else "false", ">", lab,
             "</button>")), collapse = ""),
    "</nav>")

  body = paste0(
    tab_section("summary", narrative, hidden = FALSE),

    tab_section("segments",
      "<h2>Segments</h2>",
      "<p class=note>Segment prevalence is the estimated share of the ",
      "population in each segment: a parameter of the fitted model, estimated ",
      "under the survey design, with a 95 per cent interval from refitting in ",
      "every replicate. It is not the share of respondents assigned to each ",
      "segment, which is a scoring check and is narrower because it treats the ",
      "segment boundaries as known. It is not an inclusion probability ",
      "either.</p>",
      "<div class=bar>", dl_button("segments"), "</div>",
      "<div id=\"tbl-segments\"></div>",
      if (has("segment_profiles")) paste0(
        "<h3>Position on each question</h3>",
        "<div class=bar>", dl_button("segment_profiles"), "</div>",
        "<div id=\"tbl-segment_profiles\"></div>") else ""),

    tab_section("responses",
      "<h2>Response probabilities</h2>",
      "<p class=note>The probability of each answer, given membership of each ",
      "segment. These are the parameters the segments are made of.</p>",
      if (has("response_probabilities")) paste0(
        "<div class=bar>", dl_button("response_probabilities"), "</div>",
        "<div id=\"tbl-response_probabilities\"></div>")
      else "<p class=note>Replicate intervals were not estimated for this run.</p>"),

    tab_section("domains",
      "<h2>Domain estimates</h2>",
      "<p class=note>The share of each group falling in each segment, read ",
      "three ways. Unweighted ignores the survey design. Design-based accounts ",
      "for it. Corrected additionally removes the flattening that placing ",
      "people into segments introduces. Switch between them to see how far ",
      "apart they are.</p>",
      "<div class=bar>",
      "<label>Estimator</label>",
      "<span class=seg id=\"est-toggle\">",
      "<button data-est=\"Unweighted\" aria-pressed=false>Unweighted</button>",
      "<button data-est=\"Design-based\" aria-pressed=true>Design-based</button>",
      "<button data-est=\"Corrected\" aria-pressed=false>Corrected</button>",
      "</span>",
      "<label>Domain</label><select id=\"dom-var\"></select>",
      dl_button("domain_estimates", "Download all three"),
      "</div>",
      "<div id=\"dom-table\"></div>"),

    tab_section("shares",
      "<h2>Population shares</h2>",
      "<p class=note>The composition of the population, estimated on the whole ",
      "design. n is everyone at that level; n scored is the number the segment ",
      "estimates actually rest on.</p>",
      "<div class=bar>", dl_button("population_shares"), "</div>",
      "<div id=\"tbl-population_shares\"></div>"),

    tab_section("diagnostics",
      "<h2>Diagnostics</h2>",
      "<div class=box>These rank; they do not test. Under a design-weighted ",
      "pseudo-likelihood none of them has a reference distribution, so there ",
      "is no threshold at which any of them becomes a result.</div>",
      if (!is.null(state$measure$travel_ratio)) paste0(
        "<h3>Where the intervals came from</h3><p class=note>",
        "The measurement model was refitted in ", state$measure$replicates,
        " replicates. ", state$measure$failed,
        " did not converge and were kept in the variance rather than dropped. ",
        "The furthest replicate moved ",
        sprintf("%.1f", state$measure$travel_ratio),
        " times the median distance from the full-sample fit, and ",
        state$measure$n_wild, " moved more than five times it. ",
        "A heavy tail here means a few refits found a different arrangement ",
        "of the segments and the width is theirs; an even spread means the ",
        "parameters are weakly identified and the width is real.</p>") else "",
      "<h3>Who these estimates rest on</h3>",
      "<div class=bar>", dl_button("coverage"), "</div>",
      "<div id=\"tbl-coverage\"></div>",
      "<h3>The questions analysed</h3>",
      "<div class=bar>", dl_button("item_dictionary"), "</div>",
      "<div id=\"tbl-item_dictionary\"></div>",
      if (has("assignment_quality")) paste0(
        "<h3>How confidently respondents were placed</h3>",
        "<div class=bar>", dl_button("assignment_quality"), "</div>",
        "<div id=\"tbl-assignment_quality\"></div>") else "",
      if (has("design_checks")) paste0(
        "<h3>Design checks</h3>",
        "<div class=bar>", dl_button("design_checks"), "</div>",
        "<div id=\"tbl-design_checks\"></div>") else "",
      if (has("recode_audit")) paste0(
        "<h3>Recodes applied</h3>",
        "<div class=bar>", dl_button("recode_audit"), "</div>",
        "<div id=\"tbl-recode_audit\"></div>") else ""),

    # The decision log is six markdown files written as decisions are made,
    #   not a table, so it is shown as what it is rather than forced into rows.
    tab_section("decisions",
      "<h2>Decisions</h2>",
      "<p class=note>Every choice the analyst made, with the evidence that was ",
      "on screen when they made it. This is the record of how the analysis was ",
      "reached, and it is the part a reviewer should read alongside the ",
      "numbers.</p>",
      paste0(purrr::imap_chr(WISE_LOGS, function(f, which) {
        txt = read_decisions(which)
        if (!nzchar(txt)) "" else paste0(
          "<h3>", tools::toTitleCase(which), "</h3><pre>",
          html_escape(txt), "</pre>")
      }), collapse = "")),

    tab_section("spec",
      "<h2>Specification</h2>",
      "<p class=note>The analysis specification. Re-runnable without this app; ",
      "adjust the paths at the top for wherever you unpack the bundle.</p>",
      # Read back off disk so the specification can be shown, not only
      #   shipped. It is written at Review; missing means the analyst has not
      #   got there yet.
      "<pre>", html_escape(paste(
        if (fs::file_exists(wise_path("output", "cfg.R")))
          readLines(wise_path("output", "cfg.R"), warn = FALSE)
        else "Not available.", collapse = "\n")),
      "</pre>"),

    tab_section("tested",
      "<h2>What was tested</h2>",
      "<p class=note>What was verified, what rests on published method, what ",
      "was a judgement call, and what has not been tested at all. The last of ",
      "those is the column to read first.</p>",
      "<div class=bar>", dl_button("what_was_tested"),
      dl_button("all_estimates", "Download every table as one CSV"), "</div>",
      "<div id=\"tbl-what_was_tested\"></div>"))

  path = wise_path("output", "report.html")

  writeLines(c(
    "<!doctype html>",
    "<html lang=\"en\"><head>",
    "<meta charset=\"utf-8\">",
    "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">",
    paste0("<title>DrSvyR report -- ", fs::path_file(state$data_file),
           "</title>"),
    "<style>", REPORT_CSS, REPORT_TAB_CSS, "</style>",
    "</head><body><div class=wrap>",
    "<header><h1>Segments in the population, and how they differ</h1>",
    paste0("<div class=meta>", fs::path_file(state$data_file), " &middot; ",
           format(Sys.Date(), "%d %B %Y"), " &middot; ",
           format(nrow(state$raw), big.mark = ","), " respondents &middot; ",
           "DrSvyR v", WISE_VERSION, "</div></header>"),
    nav,
    "<main>", body, "</main>",
    "</div>",
    paste0("<script type=\"application/json\" id=\"drsvyr-data\">",
           json, "</script>"),
    paste0("<script>", REPORT_JS, "</script>"),
    "</body></html>"), path, useBytes = TRUE)

  path
}

