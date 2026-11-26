# Phase 12 Part C 2: the player of an exported page in headless Chrome. No model call. Sourced by tests/smoke.R (heavy run) and runnable alone:
#   Rscript --no-init-file tests/motion_chrome_12.R path/to/dashboard.html
# p12_chrome_dom(html, js, flags, budget) loads a copy of the page with `js` added at the end of its body, in headless Chrome with virtual time, and returns what
#   the script wrote into a <meta name="p12"> (JSON); p12_chrome_pdf(html, js, budget) prints such a copy to PDF and returns every page as a raster (or NULL).
P12_CHROME <- "C:/Program Files/Google/Chrome/Application/chrome.exe"

p12_copy <- function(html, js) {
  h <- paste(readLines(html, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  Encoding(h) <- "UTF-8"
  f <- tempfile("p12_page_", fileext = ".html")
  # first thing in <head>, before the page's own script, so that it sees every request the page makes from the start
  writeLines(sub("<head>", paste0("<head><script>", js, "</script>"), h, fixed = TRUE), f, useBytes = TRUE)
  f
}
p12_args <- function(budget, flags) c("--headless=new", "--disable-gpu", "--no-sandbox", paste0("--user-data-dir=", tempfile("p12_chrome_")), "--window-size=1400,900",
                                      "--no-pdf-header-footer", paste0("--virtual-time-budget=", budget), flags)
p12_chrome_dom <- function(html, js, flags = character(0), budget = 20000) {
  f <- p12_copy(html, js)
  out <- suppressWarnings(system2(P12_CHROME, c(p12_args(budget, flags), "--dump-dom", paste0("file:///", normalizePath(f, winslash = "/"))), stdout = TRUE, stderr = FALSE))
  txt <- paste(out, collapse = "\n")
  m <- utils::tail(regmatches(txt, gregexpr("<meta name=\"p12\" content=\"[^\"]*\"", txt))[[1]], 1L)   # the last: the script that writes it holds the same words
  if (!length(m)) return(NULL)
  jsonlite::fromJSON(gsub("&quot;", "\"", gsub("&amp;", "&", sub("^<meta name=\"p12\" content=\"(.*)\"$", "\\1", m), fixed = TRUE), fixed = TRUE), simplifyVector = FALSE)
}
p12_chrome_pdf <- function(html, js, budget, flags = character(0), dpi = 40) {
  f <- p12_copy(html, js)
  pdf <- tempfile("p12_print_", fileext = ".pdf")
  suppressWarnings(system2(P12_CHROME, c(p12_args(budget, flags), paste0("--print-to-pdf=", pdf), paste0("file:///", normalizePath(f, winslash = "/"))), stdout = FALSE, stderr = FALSE))
  if (!file.exists(pdf)) return(NULL)
  purrr::map(seq_len(pdftools::pdf_info(pdf)$pages), function(i) pdftools::pdf_render_page(pdf, i, dpi = dpi, numeric = TRUE))
}

# The script added to the page: `body` runs once the page has loaded; write(o) puts o into the meta the dump reads. Before that, it records every address the page
#   asks for through an image's src, fetch() or XMLHttpRequest, other than a data address (`req`): it is the first script of <head>, so it runs before the page's
#   player (and before the MutationObserver of the player can see a card), and any request the player makes is seen; the cards are gathered at load; resource timing (`res`) lists what else was loaded (a file:// load is not listed there, hence `req`).
P12_REQ_JS <- paste0("window.__p12req=[];var rec=function(u){u=String(u&&u.url||u);if(u.slice(0,5)!=='data:')window.__p12req.push(u);};",
                     "var dsc=Object.getOwnPropertyDescriptor(HTMLImageElement.prototype,'src');Object.defineProperty(HTMLImageElement.prototype,'src',{configurable:true,",
                     "get:function(){return dsc.get.call(this);},set:function(v){rec(v);dsc.set.call(this,v);}});",
                     "var f0=window.fetch;if(f0)window.fetch=function(u){rec(u);return f0.apply(this,arguments);};",
                     "var x0=XMLHttpRequest.prototype.open;XMLHttpRequest.prototype.open=function(m,u){rec(u);return x0.apply(this,arguments);};")
p12_js <- function(body) paste0("(function(){", P12_REQ_JS, "var write=function(o){o.req=window.__p12req;o.res=performance.getEntriesByType('resource').map(function(e){return e.name;});",
                                "document.head.insertAdjacentHTML('beforeend','<meta name=\"p12\" content=\"'+JSON.stringify(o).replace(/\"/g,'&quot;')+'\">');};",
                                "var boxes=[];var st=function(b){var j=JSON.parse(b.querySelector('script.motion-frames').textContent);",
                                "return {played:b.getAttribute('data-played'),frame:b.getAttribute('data-frame'),playing:b.hasAttribute('data-playing'),canvas:!!b.querySelector('canvas'),",
                                "btn:!b.querySelector('button.motion-replay').hidden,btnTag:b.querySelector('button.motion-replay').tagName,btnText:b.querySelector('button.motion-replay').textContent,",
                                "still:b.querySelector('img.motion-still').style.visibility,last:j.frames.length-1,top:Math.round(b.getBoundingClientRect().top)};};",
                                "window.addEventListener('load',function(){boxes=[].slice.call(document.querySelectorAll('.motion'));", body, "});})();")
# The first box is scrolled into view at load; at 6 s (its 3.6 s of motion done) it is read, Replay is pressed (focused first, as a keyboard reader would), it is read
#   again 1.5 s later (mid-play) and at 12 s (done again). The other boxes are read at the end: they were never on the screen, so they never played.
P12_PLAY_JS <- p12_js(paste0("var b=boxes[0];b.scrollIntoView({block:'center'});var o={n:boxes.length};",
                             "setTimeout(function(){o.first=st(b);var btn=b.querySelector('button.motion-replay');btn.focus();o.focused=document.activeElement===btn;btn.click();",
                             "setTimeout(function(){o.mid=st(b);},1500);setTimeout(function(){o.again=st(b);o.others=boxes.slice(1).map(st);write(o);},6000);},6000);"))
# Print mid-play: the first box is scrolled into view, and at 6 s Replay is pressed; the page is printed when the virtual time runs out (P12_MID_MS later); `rest`
#   prints the same page with nothing pressed, at rest on the finished chart.
P12_MID_MS <- 1200
P12_PRINT_MID_JS <- p12_js("boxes[0].scrollIntoView({block:'center'});setTimeout(function(){boxes[0].querySelector('button.motion-replay').click();},6000);")
P12_PRINT_REST_JS <- p12_js("boxes[0].scrollIntoView({block:'center'});")
# The same mid-play moment read in the DOM rather than printed: proof that the print above was made while the first box was playing.
P12_MID_DOM_JS <- p12_js(paste0("var b=boxes[0];b.scrollIntoView({block:'center'});setTimeout(function(){b.querySelector('button.motion-replay').click();",
                                "setTimeout(function(){write({mid:st(b)});},", P12_MID_MS - 200, ");},6000);"))

# Everything the checks read, for one page.
p12_chrome_all <- function(html) {
  list(play = p12_chrome_dom(html, P12_PLAY_JS),
       reduced = p12_chrome_dom(html, P12_PLAY_JS, "--force-prefers-reduced-motion"),
       mid_dom = p12_chrome_dom(html, P12_MID_DOM_JS, budget = 6000 + P12_MID_MS),
       print_mid = p12_chrome_pdf(html, P12_PRINT_MID_JS, budget = 6000 + P12_MID_MS),
       print_rest = p12_chrome_pdf(html, P12_PRINT_REST_JS, budget = 6000 + P12_MID_MS))
}

if (sys.nframe() == 0L) {
  a <- p12_chrome_all(commandArgs(trailingOnly = TRUE)[[1]])
  str(a[c("play", "reduced", "mid_dom")])
  cat("print mid vs rest: identical ", identical(a$print_mid, a$print_rest), "; share of pixels that differ ", mean(abs(a$print_mid - a$print_rest) > 0.01), "\n")
}
