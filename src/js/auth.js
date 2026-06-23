// ════════════════════════════════════════════════════════════════
// AUTHENTICATION
// ════════════════════════════════════════════════════════════════

let currentUser = null;
let isLoggedIn = false;

// ─── AUTH FUNCTIONS ───
function switchLoginTab(t) {
  const loginBtn = $('tab-login-btn');
  const signupBtn = $('tab-signup-btn');
  const loginForm = $('login-form');
  const signupForm = $('signup-form');
  
  if(t === 'login') {
    loginBtn.classList.add('active');
    signupBtn.classList.remove('active');
    loginForm.style.display = 'block';
    signupForm.style.display = 'none';
  } else {
    loginBtn.classList.remove('active');
    signupBtn.classList.add('active');
    loginForm.style.display = 'none';
    signupForm.style.display = 'block';
  }
}

function handleLogin() {
  const u = $('login-username').value.trim(); 
  const p = $('login-phrase').value.trim();
  const users = Store.get('users', {});
  if(users[u] && users[u] === p) {
    currentUser = {username: u, phrase: p}; 
    Store.set('session', currentUser);
    isLoggedIn = true;
    updateNavVisibility();
    switchScreen('home');
    renderEvents();
    $('loader').classList.add('hidden');
    showToast('Welcome back, ' + u + '!');
  } else showToast('Invalid credentials');
}

function handleSignup() {
  const u = $('signup-username').value.trim();
  if(!u || u.length < 3) return showToast('Username too short');
  const users = Store.get('users', {});
  if(users[u]) return showToast('Username taken');
  const p = [...Array(8)].map(()=>Math.random().toString(36).slice(2,6)).join('-') + '-' + Math.floor(100+Math.random()*900);
  users[u] = p; 
  Store.set('users', users);
  currentUser = {username: u, phrase: p}; 
  Store.set('session', currentUser);
  isLoggedIn = true;
  $('recovery-key-display').textContent = p; 
  openModal('modal-recovery'); 
  updateNavVisibility();
  switchScreen('home');
  renderEvents();
  $('loader').classList.add('hidden');
  showToast('Account created! 🎉');
}

function logout() { 
  Store.remove('session'); 
  currentUser = null; 
  isLoggedIn = false;
  updateNavVisibility();
  switchScreen('login'); 
}

function showRecoveryKey() { 
  if(!currentUser) return;
  $('recovery-key-display').textContent = currentUser.phrase; 
  openModal('modal-recovery'); 
}

function copyRecoveryKey() { 
  navigator.clipboard.writeText($('recovery-key-display').textContent); 
  showToast('Copied'); 
  closeModal('modal-recovery'); 
}

// ─── NAV VISIBILITY ───
function updateNavVisibility() {
  const nav = $('bottom-nav');
  if(isLoggedIn && currentUser) {
    nav.classList.remove('hidden');
  } else {
    nav.classList.add('hidden');
  }
}
