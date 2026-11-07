// chat.js -- the inteRn chat page. Talks to the R session over a websocket.
// Assistant HTML arrives already sanitised by R (viewer.R); everything else
// the page shows (user text, tool lines, output, approval details) is set as
// text, never as HTML.
(function () {
  "use strict";

  const log = document.getElementById("log");
  const input = document.getElementById("input");
  const form = document.getElementById("ask");
  const send = document.getElementById("send");
  const status = document.getElementById("status");
  const conn = document.getElementById("conn");
  const model = document.getElementById("model");
  let ws = null;
  let busy = false;

  // ---- connection -------------------------------------------------------
  // Relative to the page, so it also works behind RStudio Server's proxy.
  function socketUrl() {
    const base = location.pathname.endsWith("/") ? location.pathname : location.pathname + "/";
    const proto = location.protocol === "https:" ? "wss:" : "ws:";
    return proto + "//" + location.host + base + "ws?t=" + encodeURIComponent(window.INTERN_TOKEN);
  }

  function connect() {
    ws = new WebSocket(socketUrl());
    ws.onopen = () => { conn.textContent = ""; ws.send(JSON.stringify({ type: "hello" })); };
    ws.onmessage = (ev) => handle(JSON.parse(ev.data));
    ws.onclose = () => {
      conn.textContent = "reconnecting to R…";
      setBusy(false);
      setTimeout(connect, 2000);
    };
  }

  function post(msg) {
    if (ws && ws.readyState === WebSocket.OPEN) ws.send(JSON.stringify(msg));
  }

  // ---- rendering --------------------------------------------------------
  function scroll() { log.scrollTop = log.scrollHeight; }

  function add(cls, text) {
    const div = document.createElement("div");
    div.className = "msg " + cls;
    div.textContent = text;
    log.appendChild(div);
    scroll();
    return div;
  }

  function addAssistant(html) {
    const div = document.createElement("div");
    div.className = "msg assistant";
    div.innerHTML = html;               // sanitised in R
    div.querySelectorAll("pre > code").forEach(addCodeTools);
    log.appendChild(div);
    scroll();
  }

  function addCodeTools(code) {
    const bar = document.createElement("div");
    bar.className = "code-tools";
    const button = (label, title, fn) => {
      const b = document.createElement("button");
      b.type = "button"; b.textContent = label; b.title = title;
      b.addEventListener("click", () => fn(b));
      bar.appendChild(b);
    };
    const text = () => code.textContent.replace(/\n$/, "");
    button("Copy", "Copy to the clipboard", (b) => copy(text(), b));
    button("Insert", "Insert at the cursor in the editor", () => post({ type: "insert", code: text() }));
    button("To console", "Put in the console without running it", () => post({ type: "console", code: text() }));
    code.parentElement.after(bar);
  }

  function copy(text, b) {
    const done = () => { b.textContent = "Copied"; setTimeout(() => (b.textContent = "Copy"), 1200); };
    if (navigator.clipboard && window.isSecureContext) {
      navigator.clipboard.writeText(text).then(done, () => fallbackCopy(text, done));
    } else fallbackCopy(text, done);
  }

  function fallbackCopy(text, done) {
    const ta = document.createElement("textarea");
    ta.value = text; document.body.appendChild(ta); ta.select();
    try { document.execCommand("copy"); done(); } finally { ta.remove(); }
  }

  function addOutput(text) {
    if (!text) return;
    const d = document.createElement("details");
    d.className = "output";
    const s = document.createElement("summary");
    s.textContent = "Output (shown to you only)";
    const pre = document.createElement("pre");
    pre.textContent = text;
    d.append(s, pre);
    log.appendChild(d);
    scroll();
  }

  // A diff's lines get a background by their first character.
  function detailBlock(text) {
    const pre = document.createElement("pre");
    const isDiff = /^@@ /m.test(text);
    text.split("\n").forEach((line) => {
      const span = document.createElement("span");
      span.textContent = line + "\n";
      if (isDiff && line.startsWith(">")) span.className = "line-add";
      if (isDiff && line.startsWith("<")) span.className = "line-del";
      pre.appendChild(span);
    });
    return pre;
  }

  function addApproval(m) {
    const box = document.createElement("div");
    box.className = "approval";
    const title = document.createElement("div");
    title.className = "title";
    title.textContent = m.title;
    box.appendChild(title);
    if (m.detail) box.appendChild(detailBlock(m.detail));
    const choices = document.createElement("div");
    choices.className = "choices";
    m.choices.forEach((c, i) => {
      const b = document.createElement("button");
      b.type = "button"; b.textContent = c;
      if (i === 0) b.className = "primary";
      b.addEventListener("click", () => {
        post({ type: "approve", id: m.id, choice: c });
        choices.querySelectorAll("button").forEach((x) => (x.disabled = true));
        box.classList.add("answered");
        const a = document.createElement("div");
        a.className = "answer"; a.textContent = "You chose: " + c;
        box.appendChild(a);
      });
      choices.appendChild(b);
    });
    box.appendChild(choices);
    log.appendChild(box);
    scroll();
  }

  function show(m) {
    switch (m.type) {
      case "user": add("user", m.text); break;
      case "assistant": addAssistant(m.html); break;
      case "tool": add("tool", m.text); break;
      case "output": addOutput(m.text); break;
      case "error": add("error", m.text); break;
      case "note": add("note", m.text); break;
    }
  }

  function setBusy(v) {
    busy = !!v;
    status.hidden = !busy;
    send.disabled = busy;
  }

  function handle(m) {
    switch (m.type) {
      case "replay":
        log.querySelectorAll(".msg:not(#welcome), details, .approval").forEach((n) => n.remove());
        (m.items || []).forEach(show);
        if (m.model) model.textContent = m.model;
        setBusy(m.busy);
        break;
      case "busy": setBusy(m.value); break;
      case "approval": addApproval(m); break;
      case "cleared":
        log.querySelectorAll(".msg:not(#welcome), details, .approval").forEach((n) => n.remove());
        break;
      default: show(m);
    }
  }

  // ---- input ------------------------------------------------------------
  form.addEventListener("submit", (e) => {
    e.preventDefault();
    const text = input.value.trim();
    if (!text || busy) return;
    post({ type: "user", text: text });
    input.value = "";
  });
  input.addEventListener("keydown", (e) => {
    if (e.key === "Enter" && !e.shiftKey && !e.isComposing) {
      e.preventDefault();
      form.requestSubmit();
    }
  });
  document.getElementById("reset").addEventListener("click", () => post({ type: "reset" }));

  connect();
})();
