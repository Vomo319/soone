// ════════════════════════════════════════════════════════════════
// NAVIGATION
// ════════════════════════════════════════════════════════════════

let currentScreen = 'login';

function switchScreen(id) {
  // Remove active from all screens
  document.querySelectorAll('.screen').forEach(el => {
    el.classList.remove('active');
  });
  // Add active to target
  const el = $('screen-' + id);
  if(el) {
    el.classList.add('active');
    currentScreen = id;
  }
  // Update nav highlight
  updateNav(id);
}

function updateNav(scr) {
  document.querySelectorAll('.nav-item').forEach(e => e.classList.remove('active'));
  if(scr === 'home') {
    const target = $('nav-home');
    if(target) target.classList.add('active');
  } else if(scr === 'join') {
    const target = $('nav-join');
    if(target) target.classList.add('active');
  }
}

function openSettings() { 
  if(!currentUser) return;
  $('settings-username').textContent = currentUser.username; 
  switchScreen('settings'); 
}

function closeSettings() { 
  switchScreen('home'); 
}
