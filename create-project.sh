#!/bin/bash

PROJECT_NAME="soone-app"

echo "📁 Creating project: $PROJECT_NAME"

# Create folders
mkdir -p "$PROJECT_NAME/src/css"
mkdir -p "$PROJECT_NAME/src/js"
mkdir -p "$PROJECT_NAME/src/assets/icons"

# Create index.html
cat > "$PROJECT_NAME/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
  <meta name="apple-mobile-web-app-title" content="Soone">
  <meta name="mobile-web-app-capable" content="yes">
  <meta name="theme-color" content="#09090B">
  <title>Soone</title>
  <link rel="stylesheet" href="src/css/styles.css">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
  <link rel="manifest" href="manifest.json">
</head>
<body>
  <div id="loader"><div class="loader-dot"></div><div class="loader-text">Soone</div></div>
  <div id="toast-container"><div class="toast" id="toast"></div></div>
  <div id="app"><div id="main">
    <!-- Login Screen -->
    <div class="screen active" id="screen-login">
      <div id="login-screen">
        <div class="hero-icon">⏳</div>
        <h1 class="title">Time,<br>beautifully<br>measured.</h1>
        <p class="sub">Track the moments that matter without passwords or emails.</p>
        <div class="login-box">
          <div class="tab-switcher">
            <button class="active" id="tab-login-btn" onclick="switchLoginTab('login')">Sign In</button>
            <button id="tab-signup-btn" onclick="switchLoginTab('signup')">Create</button>
          </div>
          <div id="login-form">
            <div class="input-group"><label>Username</label><input id="login-username" placeholder="Your username"></div>
            <div class="input-group"><label>Recovery Key</label><input id="login-phrase" placeholder="word1-word2...-123"><div class="hint">8 words + 3 digits separated by hyphens.</div></div>
            <button class="btn btn-primary" onclick="handleLogin()">Access Vault</button>
          </div>
          <div id="signup-form" style="display:none;">
            <div class="input-group"><label>Choose Username</label><input id="signup-username" placeholder="Unique identifier"></div>
            <button class="btn btn-primary" onclick="handleSignup()">Generate Key</button>
          </div>
        </div>
      </div>
    </div>
    <!-- Home Screen -->
    <div class="screen" id="screen-home">
      <div class="header"><div><div class="header-title">Events</div><div class="header-sub" id="greeting">0 upcoming</div></div>
      <div class="header-actions"><button class="header-btn" onclick="showRecoveryKey()">🔑</button><button class="header-btn" onclick="openSettings()">⚙️</button></div></div>
      <div class="scroll-row">
        <button class="pill-btn active" data-tab="all" onclick="filterTab('all')">All</button>
        <button class="pill-btn" data-tab="my" onclick="filterTab('my')">Mine</button>
        <button class="pill-btn" data-tab="joined" onclick="filterTab('joined')">Joined</button>
        <div style="width:1px;height:24px;background:var(--border);margin:0 4px;"></div>
        <button class="pill-btn" data-cat="milestone" onclick="filterCategory('milestone')">Milestones</button>
        <button class="pill-btn" data-cat="travel" onclick="filterCategory('travel')">Travel</button>
      </div>
      <div id="events-grid" class="events-grid"></div>
    </div>
    <!-- Other screens (detail, form, join, settings) -->
    <div class="screen" id="screen-detail">
      <div class="detail-wrap">
        <div class="detail-cover" id="detail-bg"></div>
        <div class="detail-nav"><button onclick="closeDetail()">Close</button><div style="display:flex;gap:8px;"><button onclick="shareEvent()">Share</button><button onclick="editEvent()" id="edit-btn">Edit</button></div></div>
        <div class="detail-content">
          <div class="d-hero"><span class="d-emoji" id="d-emoji">🎉</span><h1 class="d-title" id="d-name">Event</h1><p class="d-date" id="d-date">Date</p></div>
          <div class="d-massive-countdown"><strong id="d-days">0</strong><span id="d-days-label">DAYS</span></div>
          <div class="d-metrics">
            <div class="d-metric-box"><strong id="cd-d">0</strong><span>Days</span></div>
            <div class="d-metric-box"><strong id="cd-h">00</strong><span>Hrs</span></div>
            <div class="d-metric-box"><strong id="cd-m">00</strong><span>Min</span></div>
            <div class="d-metric-box"><strong id="cd-s">00</strong><span>Sec</span></div>
          </div>
          <div id="action-container"></div>
        </div>
      </div>
    </div>
    <div class="screen" id="screen-form">
      <div class="form-header"><button class="action-text" onclick="closeForm()">Cancel</button><span class="title" id="form-title">New Event</span><button onclick="submitForm()">Save</button></div>
      <div class="form-body">
        <div class="f-section"><input class="f-input" id="form-name" placeholder="What are we waiting for?" maxlength="60"></div>
        <div class="f-section">
          <label class="f-label">Cover Image</label>
          <div class="image-upload" id="cover-upload" onclick="document.getElementById('cover-input').click()">
            <span style="font-size:24px;margin-bottom:8px;">📷</span>
            <span style="font-size:14px;color:var(--text-muted);font-weight:600;">Tap to upload</span>
            <img id="cover-preview" style="display:none;">
            <input type="file" id="cover-input" accept="image/*" style="display:none;" onchange="handleCoverUpload(event)">
          </div>
          <button class="btn btn-secondary btn-sm mt-16" id="cover-remove" style="display:none;width:100%;" onclick="removeCover()">Remove Image</button>
        </div>
        <div class="f-section">
          <label class="f-label">Date</label>
          <div class="date-row">
            <select id="form-month"></select>
            <select id="form-day"></select>
            <select id="form-year"></select>
          </div>
        </div>
        <div class="f-section" id="del-wrap" style="display:none;">
           <button class="btn btn-danger" onclick="confirmDelete()">Delete Event</button>
        </div>
      </div>
    </div>
    <div class="screen" id="screen-join">
      <div class="form-header"><button class="action-text" onclick="closeJoin()">Back</button><span class="title">Join</span><div style="width:40px;"></div></div>
      <div class="form-body">
        <h2 style="font-size:32px;font-weight:800;margin-bottom:24px;line-height:1.1;">Join a<br>countdown.</h2>
        <div class="f-section"><label class="f-label">Share Code</label><input class="f-input" id="join-code-input" placeholder="WF-XXXXXX" maxlength="9"></div>
        <button class="btn btn-primary" onclick="handleJoin()">Join Now</button>
      </div>
    </div>
    <div class="screen" id="screen-settings">
      <div class="form-header"><button class="action-text" onclick="closeSettings()">Back</button><span class="title">Settings</span><div style="width:40px;"></div></div>
      <div class="form-body">
        <div class="f-section">
          <label class="f-label">Account</label>
          <div style="background:var(--surface);border:1px solid var(--border);border-radius:var(--radius-lg);padding:16px;">
            <div class="flex justify-between" style="margin-bottom:16px;">
              <span style="color:var(--text-muted);font-weight:600;">Username</span>
              <span id="settings-username" style="font-weight:700;">user</span>
            </div>
            <button class="btn btn-secondary" onclick="showRecoveryKey()">View Recovery Key</button>
          </div>
        </div>
        <div class="f-section">
          <label class="f-label">Appearance</label>
          <div class="flex gap-8">
            <button class="btn btn-secondary" onclick="setTheme('dark')">Dark</button>
            <button class="btn btn-secondary" onclick="setTheme('light')">Light</button>
          </div>
        </div>
        <button class="btn btn-danger" onclick="logout()">Sign Out</button>
      </div>
    </div>
  </div>
  <nav id="bottom-nav" class="hidden">
    <button class="nav-item active" onclick="switchScreen('home')" id="nav-home">
      <svg viewBox="0 0 24 24" stroke="currentColor" fill="none"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg>
    </button>
    <div class="nav-fab-wrap">
      <button class="nav-fab" onclick="openCreateForm()">
        <svg viewBox="0 0 24 24" stroke="currentColor" fill="none"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
      </button>
    </div>
    <button class="nav-item" onclick="switchScreen('join')" id="nav-join">
      <svg viewBox="0 0 24 24" stroke="currentColor" fill="none"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
    </button>
  </nav>
</div>
<div class="modal-overlay" id="modal-recovery">
  <div class="modal"><h3>Recovery Key</h3><p>Save this somewhere secure. It's the only way to recover your account.</p>
  <div class="code-box" id="recovery-key-display"></div>
  <div class="modal-actions"><button class="btn btn-secondary" onclick="closeModal('modal-recovery')">Close</button><button class="btn btn-primary" onclick="copyRecoveryKey()">Copy</button></div></div>
</div>
<div class="modal-overlay" id="modal-share">
  <div class="modal"><h3>Share Code</h3><p>Give this code to friends so they can track this event with you.</p>
  <div class="code-box" id="share-code-display"></div>
  <div class="modal-actions"><button class="btn btn-secondary" onclick="closeModal('modal-share')">Close</button><button class="btn btn-primary" onclick="copyShareCode()">Copy</button></div></div>
</div>
<script src="src/js/utils.js"></script>
<script src="src/js/data.js"></script>
<script src="src/js/auth.js"></script>
<script src="src/js/navigation.js"></script>
<script src="src/js/events.js"></script>
<script src="src/js/share.js"></script>
<script src="src/js/app.js"></script>
</body>
</html>
EOF

echo "  ✅ Created: index.html"

# Create manifest.json
cat > "$PROJECT_NAME/manifest.json" << 'EOF'
{
  "name": "Soone",
  "short_name": "Soone",
  "description": "Countdown to what matters",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#09090B",
  "theme_color": "#09090B",
  "icons": [
    {"src": "src/assets/icons/icon-192.png", "sizes": "192x192", "type": "image/png"},
    {"src": "src/assets/icons/icon-512.png", "sizes": "512x512", "type": "image/png"}
  ]
}
EOF

echo "  ✅ Created: manifest.json"

# Create vercel.json
cat > "$PROJECT_NAME/vercel.json" << 'EOF'
{
  "version": 2,
  "builds": [{"src": "index.html", "use": "@vercel/static"}],
  "routes": [{"src": "/(.*)", "dest": "/index.html"}]
}
EOF

echo "  ✅ Created: vercel.json"

# Create .gitignore
cat > "$PROJECT_NAME/.gitignore" << 'EOF'
.DS_Store
Thumbs.db
*.log
.vscode/
.idea/
node_modules/
package-lock.json
dist/
build/
.env
.env.local
EOF

echo "  ✅ Created: .gitignore"

# Create package.json
cat > "$PROJECT_NAME/package.json" << 'EOF'
{
  "name": "soone",
  "version": "2.0.0",
  "description": "Countdown app — track what matters",
  "scripts": {"deploy": "vercel --prod"}
}
EOF

echo "  ✅ Created: package.json"

# Create CSS file
cat > "$PROJECT_NAME/src/css/styles.css" << 'EOF'
:root {
  --bg: #09090B;
  --surface: #18181B;
  --border: rgba(255,255,255,0.08);
  --text: #FAFAFA;
  --text-muted: #A1A1AA;
  --nav-height: 72px;
}
* { margin:0; padding:0; box-sizing:border-box; }
html, body {
  height:100%;
  background:var(--bg);
  color:var(--text);
  font-family:'Inter',sans-serif;
  overflow:hidden;
}
#loader {
  position:fixed; inset:0;
  background:var(--bg);
  display:flex; flex-direction:column;
  align-items:center; justify-content:center;
  z-index:9999;
  transition:opacity 0.6s ease;
}
#loader.hidden { opacity:0; pointer-events:none; }
.loader-dot {
  width:48px; height:48px;
  background:var(--text);
  border-radius:50%;
  animation:pulse 1.2s infinite;
}
.loader-text { margin-top:16px; color:var(--text-muted); font-size:13px; letter-spacing:0.1em; }
@keyframes pulse { 0%,100%{transform:scale(0.8);opacity:0.5} 50%{transform:scale(1.2);opacity:1} }
#app { position:fixed; inset:0; display:flex; flex-direction:column; background:var(--bg); }
#main { flex:1; overflow:hidden; position:relative; }
.screen {
  position:absolute; inset:0;
  overflow-y:auto;
  opacity:0; pointer-events:none;
  transition:opacity 0.35s ease;
  padding-bottom:calc(var(--nav-height) + 40px);
  background:var(--bg);
  z-index:1;
}
.screen.active { opacity:1; pointer-events:auto; z-index:10; }
.header {
  padding:24px 24px 16px;
  display:flex; justify-content:space-between; align-items:flex-start;
  position:sticky; top:0; z-index:10;
  background:linear-gradient(to bottom, var(--bg) 60%, transparent);
}
.header-title { font-size:32px; font-weight:800; }
.header-sub { font-size:14px; color:var(--text-muted); margin-top:4px; }
.header-btn {
  width:44px; height:44px;
  border-radius:9999px;
  border:1px solid var(--border);
  background:var(--surface);
  color:var(--text);
  display:flex; align-items:center; justify-content:center;
  cursor:pointer;
  font-size:18px;
  transition:all 0.2s;
}
.header-btn:active { transform:scale(0.92); }
.btn {
  padding:16px 24px;
  border:none;
  border-radius:9999px;
  font-size:16px;
  font-weight:600;
  cursor:pointer;
  transition:all 0.2s;
  font-family:inherit;
  width:100%;
}
.btn:active { transform:scale(0.96); }
.btn-primary { background:var(--text); color:var(--bg); }
.btn-secondary { background:var(--surface); color:var(--text); border:1px solid var(--border); }
.btn-danger { background:rgba(239,68,68,0.1); color:#EF4444; }
.btn-sm { padding:10px 16px; font-size:14px; width:auto; }
.events-grid { padding:8px 24px 24px; display:grid; gap:16px; }
.event-card {
  background:var(--surface);
  border-radius:24px;
  border:1px solid var(--border);
  overflow:hidden;
  position:relative;
  cursor:pointer;
  padding:20px;
  box-shadow:0 4px 12px rgba(0,0,0,0.1);
}
.event-card:active { transform:scale(0.97); }
.card-inner { display:flex; flex-direction:column; gap:16px; }
.card-header { display:flex; justify-content:space-between; align-items:flex-start; }
.card-icon {
  width:48px; height:48px;
  border-radius:16px;
  display:flex; align-items:center; justify-content:center;
  font-size:24px;
  background:rgba(255,255,255,0.05);
}
.card-body h3 { font-size:20px; font-weight:700; margin-bottom:4px; }
.card-body p { font-size:13px; color:var(--text-muted); }
.card-footer { display:flex; align-items:center; gap:16px; margin-top:4px; }
.card-progress-wrap { flex:1; }
.card-progress { height:6px; background:var(--bg); border-radius:9999px; overflow:hidden; }
.card-progress .fill { height:100%; border-radius:9999px; transition:width 1s ease; }
.card-countdown { text-align:right; line-height:1; display:flex; flex-direction:column; align-items:flex-end; }
.card-countdown strong { font-size:28px; font-weight:900; }
.card-countdown span { font-size:10px; font-weight:700; color:var(--text-muted); margin-top:2px; }
.empty { text-align:center; padding:60px 24px; display:flex; flex-direction:column; align-items:center; }
.empty .icon { font-size:64px; margin-bottom:24px; opacity:0.8; }
.empty .title { font-size:24px; font-weight:800; margin-bottom:8px; }
.empty .desc { font-size:15px; color:var(--text-muted); max-width:260px; line-height:1.5; }
#bottom-nav {
  position:fixed;
  bottom:20px;
  left:50%;
  transform:translateX(-50%);
  width:calc(100% - 48px);
  max-width:400px;
  height:64px;
  background:rgba(24,24,27,0.75);
  backdrop-filter:blur(24px);
  border:1px solid var(--border);
  border-radius:9999px;
  display:flex;
  align-items:center;
  justify-content:space-between;
  padding:0 8px;
  z-index:100;
  box-shadow:0 8px 32px rgba(0,0,0,0.6);
  transition:opacity 0.3s ease, transform 0.3s ease;
}
#bottom-nav.hidden { opacity:0; transform:translateX(-50%) translateY(20px); pointer-events:none; }
.nav-item {
  flex:1;
  display:flex;
  flex-direction:column;
  align-items:center;
  justify-content:center;
  background:none;
  border:none;
  color:var(--text-muted);
  cursor:pointer;
  transition:all 0.2s;
}
.nav-item.active { color:var(--text); }
.nav-item:active { transform:scale(0.9); }
.nav-item svg { width:24px; height:24px; stroke-width:2.2; margin-bottom:2px; }
.nav-fab-wrap { position:relative; margin-top:-32px; flex:0 0 64px; display:flex; justify-content:center; }
.nav-fab {
  width:56px; height:56px;
  border-radius:50%;
  border:none;
  background:var(--text);
  color:var(--bg);
  display:flex;
  align-items:center;
  justify-content:center;
  box-shadow:0 8px 32px rgba(0,0,0,0.6);
  cursor:pointer;
  transition:transform 0.2s;
}
.nav-fab:active { transform:scale(0.85); }
.nav-fab svg { width:24px; height:24px; stroke-width:3; }
#login-screen { display:flex; flex-direction:column; justify-content:center; padding:40px 24px; min-height:100%; }
.hero-icon { font-size:72px; margin-bottom:24px; }
#login-screen .title { font-size:40px; font-weight:900; letter-spacing:-0.04em; margin-bottom:8px; line-height:1.1; }
#login-screen .sub { font-size:16px; color:var(--text-muted); margin-bottom:40px; line-height:1.5; }
.login-box { background:var(--surface); border:1px solid var(--border); border-radius:32px; padding:24px; }
.tab-switcher { display:flex; background:var(--bg); border-radius:9999px; padding:4px; margin-bottom:24px; }
.tab-switcher button {
  flex:1; padding:12px; border:none; background:transparent; border-radius:9999px;
  color:var(--text-muted); font-size:14px; font-weight:600; transition:all 0.2s;
}
.tab-switcher button.active { background:var(--surface-hover); color:var(--text); box-shadow:0 2px 8px rgba(0,0,0,0.1); }
.input-group { margin-bottom:20px; }
.input-group label { display:block; font-size:12px; font-weight:700; color:var(--text-muted); margin-bottom:8px; text-transform:uppercase; letter-spacing:0.05em; }
.input-group input {
  width:100%; padding:16px 20px;
  background:var(--bg); border:1px solid var(--border);
  border-radius:16px; color:var(--text); font-size:16px; font-weight:500; transition:all 0.2s;
}
.input-group input:focus { border-color:var(--text); outline:none; background:var(--surface-hover); }
.input-group .hint { font-size:12px; color:var(--text-subtle); margin-top:8px; }
.form-header { display:flex; justify-content:space-between; align-items:center; padding:20px 24px; background:var(--bg); position:sticky; top:0; z-index:20; border-bottom:1px solid var(--border); }
.form-header .title { font-size:18px; font-weight:700; }
.form-header button { background:none; border:none; font-size:16px; font-weight:600; color:var(--text); padding:8px 0; }
.form-header .action-text { color:var(--text-muted); }
.form-body { padding:24px; }
.f-section { margin-bottom:32px; }
.f-label { display:block; font-size:13px; font-weight:700; color:var(--text-muted); margin-bottom:12px; text-transform:uppercase; letter-spacing:0.05em; }
.f-input {
  width:100%; background:transparent; border:none; border-bottom:2px solid var(--border);
  padding:12px 0; font-size:24px; font-weight:700; color:var(--text); transition:border-color 0.2s;
}
.f-input:focus { border-color:var(--text); outline:none; }
.f-input::placeholder { color:var(--text-subtle); font-weight:500; }
.image-upload {
  height:140px; border-radius:24px; background:var(--surface); border:1px dashed var(--text-subtle);
  display:flex; flex-direction:column; align-items:center; justify-content:center; cursor:pointer; position:relative; overflow:hidden;
}
.image-upload.has-img { border-style:solid; border-color:var(--border); }
.image-upload img { position:absolute; inset:0; width:100%; height:100%; object-fit:cover; }
.date-row { display:flex; gap:12px; }
.date-row select {
  flex:1; padding:16px; background:var(--surface); border:1px solid var(--border);
  border-radius:16px; color:var(--text); font-size:16px; font-weight:600; -webkit-appearance:none;
}
.detail-wrap { position:relative; min-height:100vh; display:flex; flex-direction:column; }
.detail-cover {
  position:absolute; top:0; left:0; right:0; height:50vh;
  background-size:cover; background-position:center;
  mask-image:linear-gradient(to bottom, black 40%, transparent 100%);
  -webkit-mask-image:linear-gradient(to bottom, black 40%, transparent 100%);
  z-index:0; opacity:0.6;
}
.detail-nav { padding:16px 24px; position:relative; z-index:10; display:flex; justify-content:space-between; }
.detail-nav button { background:rgba(0,0,0,0.4); backdrop-filter:blur(12px); border:1px solid rgba(255,255,255,0.1); color:white; border-radius:9999px; padding:8px 16px; font-weight:600; font-size:14px; }
.detail-content { position:relative; z-index:1; margin-top:auto; padding:24px; }
.d-hero { text-align:left; margin-bottom:32px; }
.d-emoji { font-size:64px; margin-bottom:16px; display:inline-block; }
.d-title { font-size:40px; font-weight:900; line-height:1.1; letter-spacing:-0.04em; margin-bottom:8px; }
.d-date { font-size:16px; color:var(--text-muted); font-weight:500; }
.d-massive-countdown { display:flex; align-items:baseline; gap:12px; margin:32px 0; }
.d-massive-countdown strong { font-size:80px; font-weight:900; letter-spacing:-0.05em; line-height:0.9; }
.d-massive-countdown span { font-size:20px; font-weight:700; color:var(--text-muted); }
.d-metrics { display:grid; grid-template-columns:repeat(4,1fr); gap:8px; margin-bottom:32px; }
.d-metric-box { background:var(--surface); border:1px solid var(--border); border-radius:16px; padding:16px 8px; text-align:center; }
.d-metric-box strong { display:block; font-size:24px; font-weight:800; margin-bottom:4px; }
.d-metric-box span { font-size:10px; font-weight:700; color:var(--text-muted); text-transform:uppercase; letter-spacing:0.05em; }
.modal-overlay {
  position:fixed; inset:0; background:rgba(0,0,0,0.8); backdrop-filter:blur(8px);
  display:none; align-items:center; justify-content:center; z-index:500; padding:24px;
}
.modal-overlay.active { display:flex; }
.modal {
  width:100%; max-width:400px; background:var(--surface); border:1px solid var(--border);
  border-radius:32px; padding:32px 24px; text-align:center;
  animation:popIn 0.3s cubic-bezier(0.16,1,0.3,1);
}
@keyframes popIn { from{opacity:0;transform:scale(0.9)} to{opacity:1;transform:scale(1)} }
.modal h3 { font-size:24px; font-weight:800; margin-bottom:12px; }
.modal p { color:var(--text-muted); font-size:15px; margin-bottom:24px; line-height:1.5; }
.modal-actions { display:flex; gap:12px; }
.code-box {
  background:var(--bg); border:1px solid var(--border); padding:16px;
  border-radius:16px; font-family:monospace; font-size:20px; font-weight:700;
  letter-spacing:0.1em; margin-bottom:24px; word-break:break-all;
}
#toast-container {
  position:fixed; bottom:calc(var(--nav-height) + 24px); left:50%; transform:translateX(-50%); z-index:1000; pointer-events:none;
}
.toast {
  background:var(--text); color:var(--bg); padding:12px 24px; border-radius:9999px;
  font-size:14px; font-weight:600; box-shadow:0 8px 32px rgba(0,0,0,0.4);
  opacity:0; transform:translateY(10px); transition:all 0.3s cubic-bezier(0.16,1,0.3,1);
}
.toast.show { opacity:1; transform:translateY(0); }
.flex { display:flex; }
.justify-between { justify-content:space-between; }
.gap-8 { gap:8px; }
.mt-16 { margin-top:16px; }
EOF

echo "  ✅ Created: src/css/styles.css"

# Create JS files
for jsfile in utils.js data.js auth.js navigation.js events.js share.js app.js; do
  cat > "$PROJECT_NAME/src/js/$jsfile" << 'EOF'
// File created: $jsfile
// Add your JavaScript code here
EOF
  echo "  ✅ Created: src/js/$jsfile"
done

echo ""
echo "✅ Project created successfully!"
echo "📂 Location: $(pwd)/$PROJECT_NAME"
echo ""
echo "🚀 Next steps:"
echo "  cd $PROJECT_NAME"
echo "  git init"
echo "  git add ."
echo "  git commit -m 'Initial commit'"
echo "  # Create repo on GitHub, then:"
echo "  git remote add origin https://github.com/yourusername/$PROJECT_NAME.git"
echo "  git push -u origin main"
