library(shiny)
library(ggplot2)

# ── Palette ───────────────────────────────────────────────────────────────────
PLAYER_COLORS <- c(
  "#E63946",  # vivid red
  "#118AB2",  # steel blue
  "#fcdb1e",  # orange
  "#8338EC",  # violet
  "#056e0e",  # mint green
  "#fc900a",  # amber
  "#faafe1",  # hot pink
  "#6A0572",  # deep purple
  "#3ec9f7",  # dark teal
  "#30e320"  # teal
)

# ── UI ────────────────────────────────────────────────────────────────────────
ui <- fluidPage(
  tags$head(
    tags$link(
      href = "https://fonts.googleapis.com/css2?family=Fredoka+One&family=Nunito:wght@400;600;700;800&display=swap",
      rel  = "stylesheet"
    ),
    tags$style(HTML("
      :root {
        --bg:      #f4f6f8;
        --surface: #ffffff;
        --card:    #eef2f5;
        --accent:  #ff2d55;
        --gold:    #e5a000;
        --text:    #1a1a2a;
        --muted:   #5b677a;
        --shadow:  0 8px 24px rgba(0,0,0,.08);
        --border-light: rgba(0,0,0,.15);
        --border-subtle: rgba(0,0,0,.08);
        --bg-subtle: rgba(0,0,0,.04);
      }

      * { box-sizing: border-box; margin: 0; padding: 0; }
      body {
        background: var(--bg);
        color: var(--text);
        font-family: 'Nunito', sans-serif;
        min-height: 100vh;
        background-image:
          radial-gradient(ellipse at 20% 10%, rgba(233,69,96,.12) 0%, transparent 50%),
          radial-gradient(ellipse at 80% 90%, rgba(78,205,196,.10) 0%, transparent 50%);
        transition: background-color 0.3s, color 0.3s;
      }
      
      [data-theme='light'] body {
        background-image:
          radial-gradient(ellipse at 20% 10%, rgba(233,69,96,.06) 0%, transparent 50%),
          radial-gradient(ellipse at 80% 90%, rgba(78,205,196,.06) 0%, transparent 50%);
      }

      /* Header */
      .app-header { text-align:center; padding:16px 24px 20px; }
      .app-header h1 {
        font-family:'Fredoka One',cursive;
        font-size:clamp(3rem,5vw,5rem);
        letter-spacing:2px; color:var(--text);
      }
      .app-header h1 span { color:var(--accent); }
      .app-header p { color:var(--muted); font-size:2rem; margin-top:6px; font-weight:600; }
      .dice-icons { font-size:4rem; margin-bottom:8px; }

      /* Setup */
      .setup-card {
        max-width:540px; margin:0 auto 40px;
        background:var(--surface);
        border:1px solid var(--border-subtle);
        border-radius:var(--radius);
        padding:32px 36px; box-shadow:var(--shadow);
      }
      .setup-card h2 {
        font-family:'Fredoka One',cursive; font-size:2rem;
        color:var(--text); margin-bottom:22px;
        display:flex; align-items:center; gap:10px;
      }

      /* Shiny overrides */
      .form-control {
        background:var(--bg) !important;
        border:1.5px solid var(--border-light) !important;
        color:var(--text) !important;
        border-radius:8px !important;
        font-family:'Nunito',sans-serif !important;
        font-size:1.5rem !important;
        transition:border-color .2s;
      }
      .form-control:focus { border-color:var(--accent) !important; outline:none !important; box-shadow:none !important; }
      label { color:var(--muted) !important; font-weight:700 !important; font-size:1.25rem !important; letter-spacing:.6px; text-transform:uppercase; }

      /* Buttons */
      .btn-primary {
        background:var(--accent) !important; border:none !important;
        border-radius:10px !important; font-family:'Fredoka One',cursive !important;
        font-size:1.75rem !important; letter-spacing:1px !important;
        color:#fff !important; padding:11px 28px !important;
        cursor:pointer; transition:transform .15s,box-shadow .15s !important;
        box-shadow:0 4px 16px rgba(233,69,96,.35) !important;
      }
      .btn-primary:hover { transform:translateY(-2px); box-shadow:0 8px 24px rgba(233,69,96,.5) !important; }
      .btn-success {
        background:#27ae60 !important; border:none !important;
        border-radius:10px !important; font-family:'Fredoka One',cursive !important;
        font-size:1.75rem !important; color:#fff !important; padding:12px 28px !important;
        transition:transform .15s,box-shadow .15s !important;
        box-shadow:0 4px 14px rgba(39,174,96,.35) !important;
        width:100%;
      }
      .btn-success:hover { transform:translateY(-2px); }
      .btn-danger {
        background:#636e72 !important; border:none !important;
        border-radius:8px !important; font-family:'Nunito',sans-serif !important;
        font-weight:700 !important; font-size:1.75rem !important;
        color:#fff !important; padding:7px 18px !important;
      }
      [data-theme='light'] .btn-danger { background: #8795a1 !important; }

      /* Layout */
      .main-wrap {
        display:grid; grid-template-columns:360px 1fr;
        gap:24px; max-width:1200px; margin:0 auto; padding:0 20px 40px;
      }
      @media(max-width:860px){ .main-wrap{grid-template-columns:1fr;} }

      /* Panel cards */
      .panel-card {
        background:var(--surface);
        border:1px solid var(--border-subtle);
        border-radius:var(--radius); padding:24px; box-shadow:var(--shadow);
      }
      .panel-card h3 {
        font-family:'Fredoka One',cursive; font-size:2rem;
        margin-bottom:18px; display:flex; align-items:center; gap:8px; color:var(--text);
      }

      /* Active player spotlight */
      .active-player-card {
        background:var(--card);
        border-radius:var(--radius); padding:20px 22px; margin-bottom:16px;
        border:2px solid var(--player-color, var(--accent));
        box-shadow:0 0 28px color-mix(in srgb, var(--player-color,var(--accent)) 28%, transparent);
        transition:border-color .3s,box-shadow .3s;
      }
      .active-player-header {
        display:flex; align-items:center; gap:14px; margin-bottom:16px;
      }
      .active-avatar {
        width:48px; height:48px; border-radius:50%;
        display:flex; align-items:center; justify-content:center;
        font-family:'Fredoka One',cursive; font-size:1.4rem;
        color:#1a1a2e; flex-shrink:0;
        box-shadow:0 4px 12px rgba(0,0,0,.4);
      }
      [data-theme='light'] .active-avatar { color: #ffffff; }
      
      .active-player-info { flex:1; }
      .active-label { font-size:1rem; color:var(--muted); text-transform:uppercase; letter-spacing:.8px; font-weight:700; }
      .active-name  { font-family:'Fredoka One',cursive; font-size:1.45rem; color:var(--muted); line-height:1.1; }
      .active-total { font-family:'Fredoka One',cursive; font-size:1rem; color:var(--muted); line-height:1.1; text-align:right; }
      .active-total span { display:block; font-size:1rem;text-transform:uppercase; letter-spacing:.8px; font-weight:700; }

      /* Big score input */
      .score-input-wrap { margin-bottom:14px; }
      .score-input-wrap .form-control {
        font-size:1.7rem !important; font-family:'Fredoka One',cursive !important;
        text-align:center !important; padding:12px !important; height:62px !important;
        letter-spacing:2px !important;
      }
      
      /* In/Bust selection */
      .in-bust-row {
        display: flex; gap: 10px; margin-bottom: 14px;
      }
      .in-bust-row .btn {
        flex: 1; height: auto;
        font-family: 'Fredoka One', cursive !important;
        font-size: 1.5rem !important;
        padding: 12px 16px !important;
      }
      .btn-in {
        background: #27ae60 !important; border: none !important;
        border-radius: 10px !important; color: #fff !important;
        cursor: pointer; transition: transform .15s, box-shadow .15s !important;
        box-shadow: 0 4px 14px rgba(39, 174, 96, .35) !important;
      }
      .btn-in:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(39, 174, 96, .5) !important; }
      .btn-in:disabled { opacity: 0.5; cursor: not-allowed; }
      
      .btn-in-bust {
        background: #e74c3c !important; border: none !important;
        border-radius: 10px !important; color: #fff !important;
        cursor: pointer; transition: transform .15s, box-shadow .15s !important;
        box-shadow: 0 4px 14px rgba(231, 76, 60, .35) !important;
      }
      .btn-in-bust:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(231, 76, 60, .5) !important; }
      .btn-in-bust:disabled { opacity: 0.5; cursor: not-allowed; }
      
      /* Score buttons row */
      .score-buttons-row {
        display: flex; gap: 10px; align-items: center;
      }
      .score-buttons-row .btn-success {
        flex: 1;
        margin-bottom: 0 !important;
      }
      .btn-undo {
        background: #95a5a6 !important; border: none !important;
        border-radius: 8px !important; font-family: 'Fredoka One', cursive !important;
        font-size: 1.3rem !important; color: #fff !important; padding: 10px 14px !important;
        cursor: pointer; transition: transform .15s, box-shadow .15s !important;
        box-shadow: 0 4px 14px rgba(149, 165, 166, .35) !important;
        min-width: 50px; height: 50px; display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
      }
      .btn-undo:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 24px rgba(149, 165, 166, .5) !important;
      }
      .btn-undo:disabled {
        opacity: 0.5;
        cursor: not-allowed;
        transform: none !important;
      }

      /* Chips */
      .chip-row { display:flex; gap:8px; margin-bottom:16px; flex-wrap:wrap; }
      .chip {
        display:inline-flex; align-items:center; gap:5px;
        background:var(--card); border-radius:20px; padding:4px 13px;
        font-family:'Fredoka One',cursive; font-size:1.5rem; color:var(--accent);
        border:1px solid rgba(233,69,96,.3);
      }
      .chip.muted { color:var(--muted); border-color:var(--border-light); }

      /* Queue */
      .queue-label { font-size:1.25rem; color:var(--muted); text-transform:uppercase; letter-spacing:.8px; font-weight:700; margin-bottom:8px; }
      .queue-row {
        display:flex; align-items:center; gap:10px;
        padding:8px 10px; border-radius:8px;
        background:var(--bg-subtle); margin-bottom:6px;
        border:1px solid var(--border-subtle);
      }
      .queue-dot  { width:10px; height:10px; border-radius:50%; flex-shrink:0; }
      .queue-name { font-weight:700; font-size:1.5rem; flex:1; }
      .queue-score{ font-family:'Fredoka One',cursive; font-size:1.5rem; color:var(--muted); }

      /* Leaderboard */
      .leader-row {
        display:flex; align-items:center; gap:12px;
        padding:11px 14px; border-radius:10px; margin-bottom:8px;
        background:var(--bg-subtle); border:1px solid var(--border-subtle);
        position:relative; overflow:hidden;
      }
      .leader-row.top-1    { background:rgba(245,197,24,.10); border-color:rgba(245,197,24,.3); }
      .leader-row.is-active{ background:rgba(233,69,96,.08);  border-color:rgba(233,69,96,.25); }
      .rank-badge { font-family:'Fredoka One',cursive; font-size:1.5rem; width:28px; text-align:center; color:var(--muted); }
      .top-1 .rank-badge { color:var(--gold); }
      .player-color-bar { width:10px; height:38px; border-radius:5px; flex-shrink:0; }
      .leader-name { flex:1; font-weight:800; font-size:1.5rem; }
      .leader-score{ font-family:'Fredoka One',cursive; font-size:1.3rem; letter-spacing:1px; }
      .leader-sub  { font-size:1rem; color:var(--muted); text-align:right; }
      .progress-bar-outer { height:4px; background:var(--border-subtle); border-radius:4px; margin-top:5px; overflow:hidden; }
      .progress-bar-inner { height:100%; border-radius:4px; transition:width .4s ease; }
      .now-badge {
        font-size:1rem; background:var(--accent); color:#fff;
        border-radius:4px; padding:1px 5px; margin-left:5px;
        font-family:'Nunito',sans-serif; font-weight:800; vertical-align:middle;
      }

      /* Win banner */
      .win-banner {
        text-align:center; padding:22px;
        background:linear-gradient(135deg,rgba(245,197,24,.2),rgba(233,69,96,.2));
        border:2px solid var(--gold); border-radius:var(--radius); margin-bottom:20px;
        animation:pulse 1.6s ease-in-out infinite;
      }
      @keyframes pulse {
        0%,100%{ box-shadow:0 0 20px rgba(245,197,24,.3); }
        50%    { box-shadow:0 0 40px rgba(245,197,24,.7); }
      }
      .win-banner h2 { font-family:'Fredoka One',cursive; font-size:1.8rem; color:var(--black); }
      .win-banner p  { color:var(--black); margin-top:4px; font-weight:700; }

      /* Chart */
      .chart-wrap {
        background:var(--surface); border-radius:var(--radius);
        border:1px solid var(--border-subtle); padding:22px; box-shadow:var(--shadow);
      }
      .chart-wrap h3 { font-family:'Fredoka One',cursive; font-size:1.25rem; margin-bottom:16px; }

      hr { border-color:var(--border-subtle); margin:16px 0; }
      #name_inputs .name-field { margin-bottom:12px; }

      /* Right column top row */
      .right-top-row {
        display:grid; grid-template-columns:2fr 1fr;
        gap:22px; margin-bottom:0;
      }
      @media(max-width:1100px){ .right-top-row{grid-template-columns:1fr;} }
      .flex-panel { display:flex; flex-direction:column; }

      /* Bust counter */
      .bust-row {
        display:flex; align-items:center; gap:12px;
        padding:11px 14px; border-radius:10px; margin-bottom:8px;
        background:var(--bg-subtle); border:1px solid var(--border-subtle);
        position:relative; overflow:hidden;
      }
      .bust-dot   { width:10px; height:10px; border-radius:50%; flex-shrink:0; }
      .bust-name  { flex:1; font-weight:800; font-size:1.5rem; }
      .bust-count { font-family:'Fredoka One',cursive; font-size:1.3rem; letter-spacing:1px; }
      .bust-label { font-size:1.3rem; color:var(--muted); margin-left:3px; }
      .bust-skulls{ font-size:.1.1rem; letter-spacing:2px; }
      

    ")),
    tags$script("
      $(document).on('change', '#theme_toggle', function() {
        if(this.checked) {
          document.documentElement.setAttribute('data-theme', 'light');
        } else {
          document.documentElement.removeAttribute('data-theme');
        }
      });
    ")
  ),
  
  # Theme toggle header
  
  div(class = "app-header",
      tags$h1(HTML("🎲 Dice Game Calculator 🎲")),
      p("Track scores and see your game stats!")
  ),
  
  uiOutput("setup_ui"),
  uiOutput("game_ui")
)

# ── Server ────────────────────────────────────────────────────────────────────
server <- function(input, output, session) {
  
  game <- reactiveValues(
    started   = FALSE,
    players   = NULL,
    colors    = NULL,
    win_score = 10000,
    scores    = NULL,
    history   = NULL,
    round     = 1,
    pidx      = 1,
    winner    = NULL,
    in_status = NULL
  )
  
  current_player <- reactive({
    req(game$started)
    game$players[game$pidx]
  })
  
  # ── Setup UI ────────────────────────────────────────────────────────────────
  output$setup_ui <- renderUI({
    if (game$started) return(NULL)
    
    div(class = "setup-card",
        tags$h2("⚙️ Game Setup"),
        numericInput("n_players", "Number of Players", value = 2, min = 2, max = 10, step = 1),
        numericInput("win_score", "Winning Score", value = 10000, min = 100, step = 100),
        hr(),
        tags$h2("👥 Player Details"),
        uiOutput("name_fields_ui"),
        hr(),
        actionButton("start_game", "🎲 Start Game", class = "btn-success")
    )
  })
  
  # Separate reactive for name fields so they update when n_players changes
  output$name_fields_ui <- renderUI({
    n <- max(2, min(10, as.integer(input$n_players %||% 2)))
    if (is.na(n)) n <- 2
    lapply(seq_len(n), function(i)
      div(class = "name-field",
          textInput(paste0("pname_", i), paste("Player", i, "name"),
                    value = paste0("Player ", i))
      )
    )
  })
  
  # ── Start game ──────────────────────────────────────────────────────────────
  observeEvent(input$start_game, {
    n  <- max(2, min(10, as.integer(input$n_players)))
    ws <- suppressWarnings(as.numeric(input$win_score))
    if (is.na(ws) || ws < 100) ws <- 10000
    
    names_raw <- vapply(seq_len(n), function(i) {
      v <- trimws(input[[paste0("pname_", i)]])
      if (nchar(v) == 0) paste0("Player ", i) else v
    }, character(1))
    players <- make.unique(names_raw, sep = " ")
    cols    <- setNames(PLAYER_COLORS[seq_len(n)], players)
    
    game$players  <- players
    game$colors   <- cols
    game$win_score <- ws
    game$scores   <- setNames(rep(0, n), players)
    game$in_status <- setNames(rep(FALSE, n), players)
    game$history  <- data.frame(
      round = integer(0), player = character(0),
      round_score = numeric(0), total = numeric(0),
      stringsAsFactors = FALSE
    )
    game$round   <- 1
    game$pidx    <- 1
    game$winner  <- NULL
    game$busts   <- setNames(rep(0L, n), players)
    game$started <- TRUE
  })
  
  # ── Game UI ─────────────────────────────────────────────────────────────────
  output$game_ui <- renderUI({
    if (!game$started) return(NULL)
    
    p   <- current_player()
    col <- game$colors[p]
    n   <- length(game$players)
    
    # Player up next this round
    remaining <- if (game$pidx < n) game$players[(game$pidx + 1)] else character(0)
    
    queue_rows <- lapply(remaining, function(q) {
      qcol <- game$colors[q]
      div(class = "queue-row",
          div(class = "queue-dot",  style = paste0("background:", qcol, ";")),
          div(class = "queue-name", q),
          div(class = "queue-score", format(game$scores[q], big.mark = ","))
      )
    })
    
    next_label <- if (length(remaining) > 0)
      paste0("Submit")
    else
      "Submit"
    
    btn_label <- if (!is.null(game$winner)) "🏆 Game Over" else paste0(next_label)
    
    active_card <- div(class = "active-player-card",
                       style = paste0("--player-color:", col, ";"),
                       div(class = "active-player-header",
                           div(class = "active-avatar", style = paste0("background:", col, ";"),
                               substr(p, 1, 1)),
                           div(class = "active-player-info",
                               div(class = "active-label", "Now rolling"),
                               div(class = "active-name", p)
                           ),
                           div(class = "active-player-info",
                               div(class = "active-label", "Score"),
                               div(class = "active-name", game$scores[p])
                           )
                       ),
                       # Show In/Bust selection if player is not yet in
                       if (!game$in_status[p]) {
                         div(class = "in-bust-row",
                             actionButton("player_in", "✓ In", class = "btn-in"),
                             actionButton("player_bust", "✗ Bust", class = "btn-in-bust")
                         )
                       } else {
                         # Show score input and submit button once player is in
                         tagList(
                           div(class = "score-input-wrap",
                               numericInput("round_score", "Score this roll", value = 0, min = 0, step = 50)
                           ),
                           div(class = "score-buttons-row",
                               actionButton("submit_score", btn_label, class = "btn-success",
                                            disabled = if (!is.null(game$winner)) "disabled" else NULL),
                               actionButton("undo_score", icon("undo"), class = "btn-undo")
                           )
                         )
                       }
    )
    
    div(class = "main-wrap",
        # Left column: turn input
        div(
          div(class = "panel-card",
              tags$h3("🎲 Current Turn"),
              div(class = "chip-row",
                  div(class = "chip", paste("Round", game$round)),
                  div(class = "chip muted", paste0(game$pidx, " / ", n, " players"))
              ),
              active_card,
              if (length(queue_rows) > 0) tagList(
                hr(),
                div(class = "queue-label", "Up next:"),
                do.call(tagList, queue_rows)
              ),
              div(
                hr(),
                actionButton("reset_game", "Start a New Game", class = "btn-undo")
              ),
          ),
          

        ),
        # Right column: leaderboard + bust on top, chart on bottom
        div(
          uiOutput("win_banner_ui"),
          div(class = "right-top-row",
              div(class = "panel-card flex-panel",
                  tags$h3("🏆 Leaderboard"),
                  uiOutput("leaderboard_ui")
              ),
              div(class = "panel-card flex-panel",
                  tags$h3("💥 Bust Counter"),
                  uiOutput("bust_ui")
              )
          ),
          div(class = "chart-wrap", style = "margin-top:22px;",
              tags$h3("📈 Score Progress"), #TODO: increase font size here
              plotOutput("score_plot", height = "380px")
          ),
          
        )
    )
  })
  
  # ── Submit one player's score ────────────────────────────────────────────────
  # ── Player clicks "In" ───────────────────────────────────────────────────────
  observeEvent(input$player_in, {
    if (!game$started || !is.null(game$winner)) return()
    
    p <- current_player()
    game$in_status[p] <- TRUE  # Reset for next round
    
    # Advance turn
    if (game$pidx < length(game$players)) {
      game$pidx <- game$pidx + 1
    } else {
      game$pidx  <- 1
      game$round <- game$round + 1
    }
    
    updateNumericInput(session, "round_score", value = 0)
  })
  
  # ── Player busts (doesn't get in) ────────────────────────────────────────────
  observeEvent(input$player_bust, {
    if (!game$started || !is.null(game$winner)) return()
    
    p <- current_player()
    game$busts[p] <- game$busts[p] + 1L
    game$in_status[p] <- FALSE  # Reset for next round
    
    # Advance turn
    if (game$pidx < length(game$players)) {
      game$pidx <- game$pidx + 1
    } else {
      game$pidx  <- 1
      game$round <- game$round + 1
      # Reset all players' in_status for new round
    }
    
    updateNumericInput(session, "round_score", value = 0)
  })
  
  observeEvent(input$submit_score, {
    if (!game$started || !is.null(game$winner)) return()
    
    p   <- current_player()
    val <- suppressWarnings(as.numeric(input$round_score))
    if (is.na(val) || val < 0) val <- 0
    
    game$scores[p] <- game$scores[p] + val
    if (val == 0) game$busts[p] <- game$busts[p] + 1L
    
    game$history <- rbind(game$history, data.frame(
      round       = game$round,
      player      = p,
      round_score = val,
      total       = game$scores[p],
      stringsAsFactors = FALSE
    ))
    
    if (game$scores[p] >= game$win_score) game$winner <- p
    
    # Advance turn
    if (game$pidx < length(game$players)) {
      game$pidx <- game$pidx + 1
    } else {
      game$pidx  <- 1
      game$round <- game$round + 1
      # Reset all players' in_status for new round
    }
    
    updateNumericInput(session, "round_score", value = 0)
  })
  
  # ── Undo last score ──────────────────────────────────────────────────────────
  observeEvent(input$undo_score, {
    if (!game$started || nrow(game$history) == 0) return()
    
    # Get the last entry in history
    last_entry <- game$history[nrow(game$history), ]
    
    # Remove the last entry from history
    game$history <- game$history[-nrow(game$history), ]
    
    # Reverse the score change
    p <- last_entry$player
    val <- last_entry$round_score
    game$scores[p] <- game$scores[p] - val
    
    # Reverse bust counter if it was a bust
    if (val == 0) game$scores[p] <- game$scores[p] + val
    if (val == 0) game$busts[p] <- pmax(0L, game$busts[p] - 1L)
    
    # Go back to the player who just played
    # Find the index of the player to undo
    player_idx <- which(game$players == p)
    
    # Go back one turn
    if (player_idx == 1) {
      # If first player, go back to last player of previous round
      if (game$round > 1) {
        game$pidx <- length(game$players)
        game$round <- game$round - 1
      } else {
        # Already at first turn, can't undo further - just keep pidx at 1
        game$pidx <- 1
      }
    } else {
      game$pidx <- player_idx - 1
    }
    
    # Clear winner if they had reached the winning score
    if (!is.null(game$winner) && game$winner == p && game$scores[p] < game$win_score) {
      game$winner <- NULL
    }
    
    # Reset in_status for the player being undone so they can get in again
    game$in_status[p] <- FALSE
    
    updateNumericInput(session, "round_score", value = 0)
  })
  
  # ── Reset ───────────────────────────────────────────────────────────────────
  observeEvent(input$reset_game, {
    game$started <- FALSE
    game$winner  <- NULL
    game$in_status <- NULL
  })
  
  # ── Win banner ───────────────────────────────────────────────────────────────
  output$win_banner_ui <- renderUI({
    if (is.null(game$winner)) return(NULL)
    div(class = "win-banner",
        tags$h2(paste0("🏆 ", game$winner, " wins! 🏆"))
    )
  })
  
  # ── Leaderboard ──────────────────────────────────────────────────────────────
  output$leaderboard_ui <- renderUI({
    req(game$started)
    scores <- sort(game$scores, decreasing = TRUE)
    ws     <- game$win_score
    cp     <- current_player()
    
    rows <- lapply(seq_along(scores), function(i) {
      p         <- names(scores)[i]
      sc        <- scores[i]
      col       <- game$colors[p]
      pct       <- min(100, round(sc / ws * 100))
      remaining <- max(0, ws - sc)
      trophy    <- if (!is.null(game$winner) && p == game$winner) " 🏆" else ""
      rank_icon <- if (i == 1 && is.null(game$winner)) "👑" else as.character(i)
      is_active <- (p == cp && is.null(game$winner))
      row_class <- trimws(paste("leader-row",
                                if (i == 1) "top-1"    else "",
                                if (is_active) "is-active" else ""))
      now_badge <- if (is_active) tags$span(class = "now-badge", "NOW") else NULL
      
      div(class = row_class,
          # Left accent bar (inline so it respects the player colour)
          div(style = paste0(
            "position:absolute;left:0;top:0;bottom:0;width:3px;",
            "border-radius:3px 0 0 3px;background:", col, ";"
          )),
          div(class = "rank-badge", rank_icon),
          div(class = "player-color-bar", style = paste0("background:", col, ";")),
          div(style = "flex:1;min-width:0;",
              div(class = "leader-name", paste0(p, trophy), now_badge),
              div(class = "progress-bar-outer",
                  div(class = "progress-bar-inner",
                      style = paste0("width:", pct, "%;background:", col, ";"))
              )
          ),
          div(style = "text-align:right;",
              div(class = "leader-score", style = paste0(";"),
                  format(sc, big.mark = ",")),
              div(class = "leader-sub",
                  if (remaining == 0) "✅ Winner!" else paste0(format(remaining, big.mark = ","), " pts to win"))
          )
      )
    })
    
    tagList(rows)
  })
  
  # -- Bust Counter UI
  output$bust_ui <- renderUI({
    req(game$started)
    # Sort by bust count descending
    bust_sorted <- sort(game$busts, decreasing = TRUE)
    
    rows <- lapply(seq_along(bust_sorted), function(i) {
      p    <- names(bust_sorted)[i]
      cnt  <- bust_sorted[i]
      col  <- game$colors[p] 
      div(class = "bust-row",
          div(class = "bust-dot", style = paste0("background:", col, ";")),
          div(class = "bust-name", p),
          div(style = "text-align:right;",
              div(class = "bust-count", style = paste0( ";"), as.character(cnt))
          )
      )
    })
    
    tagList(rows)
  })
  
  # -- Chart ────────────────────────────────────────────────────────────────────
  output$score_plot <- renderPlot({
    req(game$started)
    df   <- game$history
    ws   <- game$win_score
    cols <- game$colors
    
    # Check theme state
    is_light <- isTruthy(input$theme_toggle)
    text_col <- if (is_light) "#1a1a2a" else "#d0d8e8"
    grid_col <- if (is_light) "#00000015" else "#ffffff22"
    point_col <- if (is_light) "#ffffff" else "#1a1a2e"
    
    # Only include rounds where every player has submitted.
    complete_rounds <- seq_len(game$round - 1)
    
    # Origin row for every player at round 0
    origin <- data.frame(
      round = 0L, player = game$players,
      round_score = 0, total = 0,
      stringsAsFactors = FALSE
    )
    
    # Pull only completed-round rows from history
    df_complete <- df[df$round %in% complete_rounds, ]
    df2 <- rbind(origin, df_complete)
    
    # If no complete rounds yet show placeholder
    if (nrow(df_complete) == 0) {
      return(ggplot() +
               annotate("text", x = .5, y = .5,
                        label = "Chart updates after each\ncomplete round",
                        color = text_col, size = 5.5, hjust = .5) +
               theme_void() +
               theme(plot.background  = element_rect(fill = "transparent", color = NA),
                     panel.background = element_rect(fill = "transparent", color = NA)))
    }
    
    # Label at the latest point for each player
    last_pts <- do.call(rbind, lapply(game$players, function(p) {
      sub <- df2[df2$player == p, ]
      sub[nrow(sub), ]
    }))
    
    max_round <- max(df2$round)
    
    ggplot(df2, aes(x = round, y = total, color = player, group = player)) +
      geom_hline(yintercept = ws, color = "red", linewidth = .8,
                 linetype = "dashed", alpha = .8) +
      annotate("text", x = 0, y = ws * 1.04,
               label = paste0("Win: ", format(ws, big.mark = ",")),
               color = "red", size = 3.2, hjust = 0, fontface = "bold") +
      geom_line(linewidth = 1.7, lineend = "round", linejoin = "round") +
      geom_point(data = df2[df2$round > 0, ],
                 aes(fill = player), shape = 21,
                 size = 3.5, stroke = 0.5, color = point_col) +
      geom_text(data = last_pts[last_pts$round > 0, ],
                aes(label = format(total, big.mark = ",")),
                hjust = -0.25, size = 3.2, fontface = "bold") +
      scale_color_manual(values = cols, name = NULL) +
      scale_fill_manual(values  = cols, name = NULL) +
      scale_y_continuous(labels = function(x) format(x, big.mark = ","),
                         expand = expansion(mult = c(0, .1))) +
      scale_x_continuous(
        breaks = seq(0, max_round),
        labels = function(x) ifelse(x == 0, "Start", paste( x)),
        expand = expansion(mult = c(.02, .16))
      ) +
      labs(x = "Round", y = "Cumulative Score") +
      theme_minimal(base_family = "sans") +
      theme(
        plot.background   = element_rect(fill = "transparent", color = NA),
        panel.background  = element_rect(fill = "transparent", color = NA),
        panel.grid.major  = element_line(color = grid_col, linewidth = .5),
        panel.grid.minor  = element_blank(),
        axis.text         = element_text(color = "black", size = 10),
        axis.title        = element_text(color = "black", size = 11),
        legend.text       = element_text(color = "black", size = 10, face = "bold"),
        legend.position   = "right",
        legend.key        = element_rect(fill = NA, color = NA),
        legend.background = element_rect(fill = NA, color = NA)
      )
  }, bg = "transparent")
}

`%||%` <- function(a, b) if (!is.null(a)) a else b

shinyApp(ui, server)

## TODO:
## - add an undo last turn button 
## - allow for clicking enter to add scores
## - add tab for full score sheet