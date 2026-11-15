# llm_async.R: the app's versions of the calls in R/llm.R. Each returns a promise, so a question
#   in one session does not hold up the others (ellmer's chat_async() and stream_async(), driven by
#   later; no extra R process). Function definitions and constants only.

call_model_async <- function(m, kind, system, user, key, schema = NULL) {
  chat = model_chat(m, kind, system, key, schema)
  t0 = Sys.time()
  promises::then(chat$chat_async(user),
                 onFulfilled = function(txt) structure(as.character(txt), usage = chat_usage(chat, m, t0)),
                 onRejected = function(e) stop(gsub(key, "[key]", conditionMessage(e), fixed = TRUE), call. = FALSE))
}

plan_question_async <- function(question, profile, key, context = NULL) {
  req = plan_request(question, context)
  promises::then(call_model_async(profile_model(profile), "plan", req$system, req$user, key, req$schema),
                 function(r) plan_from_reply(r, req, question))
}

# The answer as it streams: on_text(text so far) after each chunk; resolves to the whole reply.
answer_stream_async <- function(question, gathered, profile, key, on_text = function(x) NULL, context = NULL, my_data = NULL) {
  m = profile_model(profile)
  chat = model_chat(m, "answer", read_reflex("answer.md"), key)
  t0 = Sys.time()
  gen = chat$stream_async(answer_user(question, gathered, context, my_data))
  acc = new.env()
  acc$text = ""
  pump = function() promises::then(gen(), function(x) {
    if (coro::is_exhausted(x)) return(structure(acc$text, usage = chat_usage(chat, m, t0)))
    acc$text = paste0(acc$text, x)
    on_text(acc$text)
    pump()
  })
  promises::catch(pump(), function(e) stop(gsub(key, "[key]", conditionMessage(e), fixed = TRUE), call. = FALSE))
}

# plan, search, answer; on_stage("plan" | "search" | "answer") as each starts. Resolves to ask_result().
ask_async <- function(question, profile, key, con, context = NULL, my_data = NULL, open_input = NULL,
                      on_stage = function(s) NULL, on_text = function(x) NULL) {
  t0 = Sys.time()
  on_stage("plan")
  promises::then(plan_question_async(question, profile, key, context), function(plan) {
    t1 = Sys.time()
    on_stage("search")
    g = gather(con, plan)
    t2 = Sys.time()
    on_stage("answer")
    promises::then(answer_stream_async(question, g, profile, key, on_text, context, my_data), function(a)
      ask_result(question, plan, g, a, c(plan = as.numeric(difftime(t1, t0, units = "secs")),
                                         search = as.numeric(difftime(t2, t1, units = "secs"))), open_input))
  })
}
