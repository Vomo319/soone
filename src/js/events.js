// File created: $jsfile
// Add your JavaScript code here
// ════════════════════════════════════════════════════════════════
// EVENT MANAGEMENT
// ════════════════════════════════════════════════════════════════

let currentEvent = null; 
let editingId = null;
let selectedTab = 'all'; 
let selectedCategory = 'all';
let countdownTimer = null;

// ─── FILTERS ───
function filterTab(t) { 
  selectedTab = t; 
  document.querySelectorAll('[data-tab]').forEach(e => e.classList.toggle('active', e.dataset.tab===t)); 
  renderEvents(); 
}

function filterCategory(c) { 
  selectedCategory = selectedCategory === c ? 'all' : c; 
  document.querySelectorAll('[data-cat]').forEach(e => e.classList.toggle('active', e.dataset.cat===selectedCategory)); 
  renderEvents(); 
}

// ─── RENDER EVENTS ───
function renderEvents() {
  const grid = $('events-grid');
  if(!currentUser) {
    grid.innerHTML = `<div class="empty"><div class="icon">🔒</div><div class="title">Sign in required</div><div class="desc">Please sign in to see your events.</div></div>`;
    return;
  }
  
  let evts = getAllEvents(currentUser.username);
  if(selectedTab === 'my') evts = evts.filter(e => e._owned);
  if(selectedTab === 'joined') evts = evts.filter(e => e._joined);
  
  const catMap = { milestone: 'Milestone', travel: 'Travel' };
  if(selectedCategory !== 'all') evts = evts.filter(e => e.category === catMap[selectedCategory]);
  
  evts.sort((a,b) => new Date(a.event_date) - new Date(b.event_date));
  $('greeting').textContent = `${evts.length} events tracking`;

  if(!evts.length) {
    grid.innerHTML = `<div class="empty"><div class="icon">✨</div><div class="title">Clean slate.</div><div class="desc">Create a countdown to look forward to something.</div></div>`;
    return;
  }

  grid.innerHTML = evts.map((e, i) => {
    const days = getDays(e.event_date); 
    const isPast = days < 0;
    const prog = calcProgress(e);
    const accent = ['#38BDF8', '#34D399', '#FB7185', '#FBBF24', '#A78BFA'][i % 5];
    
    return `
      <div class="event-card" onclick="openDetail('${e.id}')">
        ${e.cover_image ? `<div class="card-bg" style="background-image:url('${e.cover_image}')"></div>` : ''}
        <div class="card-inner">
           <div class="card-header">
             <div class="card-icon" style="background:${accent}15; color:${accent}">${e.emoji || '🎉'}</div>
             ${e.category ? `<div class="card-tag" style="color:${accent}; background:${accent}10; border-color:${accent}20">${e.category}</div>` : ''}
           </div>
           <div class="card-body">
             <h3>${escapeHtml(e.title)}</h3>
             <p>${formatDate(e.event_date)} ${e._joined ? '· 🤝 Joined' : ''}</p>
           </div>
           <div class="card-footer">
             <div class="card-progress-wrap"><div class="card-progress"><div class="fill" style="width:${prog}%; background:${accent}"></div></div></div>
             <div class="card-countdown">
               <strong>${Math.abs(days)}</strong>
               <span>${isPast ? 'AGO' : 'DAYS'}</span>
             </div>
           </div>
        </div>
      </div>
    `;
  }).join('');
}

// ─── DETAIL ───
function openDetail(id) {
  currentEvent = getAllEvents(currentUser.username).find(e => e.id === id);
  if(!currentEvent) return;
  const e = currentEvent; 
  const days = getDays(e.event_date);
  
  $('d-name').textContent = e.title; 
  $('d-date').textContent = formatLongDate(e.event_date);
  $('d-emoji').textContent = e.emoji || '🎉';
  $('d-days').textContent = Math.abs(days); 
  $('d-days-label').textContent = days >= 0 ? 'DAYS TO GO' : 'DAYS AGO';
  
  $('detail-bg').style.backgroundImage = e.cover_image ? `url('${e.cover_image}')` : 'none';
  $('edit-btn').style.display = e._owned ? 'block' : 'none';
  
  const ac = $('action-container');
  if(e._joined) ac.innerHTML = `<button class="btn btn-danger" onclick="leaveEvent()">Leave Countdown</button>`;
  else ac.innerHTML = '';

  if(countdownTimer) clearInterval(countdownTimer);
  const updateCd = () => {
    const ms = new Date(e.event_date + 'T00:00:00') - Date.now();
    const abs = Math.abs(Math.floor(ms/1000));
    $('cd-d').textContent = Math.floor(abs/86400); 
    $('cd-h').textContent = String(Math.floor((abs%86400)/3600)).padStart(2,'0');
    $('cd-m').textContent = String(Math.floor((abs%3600)/60)).padStart(2,'0'); 
    $('cd-s').textContent = String(abs%60).padStart(2,'0');
  };
  updateCd(); 
  countdownTimer = setInterval(updateCd, 1000);
  switchScreen('detail');
}

function closeDetail() { 
  clearInterval(countdownTimer); 
  switchScreen('home'); 
}

function leaveEvent() { 
  if(confirm('Leave this countdown?')) { 
    leaveJoinedEvent(currentUser.username, currentEvent.id); 
    closeDetail(); 
    renderEvents(); 
  } 
}

// ─── FORMS ───
function initDatePicker() {
  const m = $('form-month'), d = $('form-day'), y = $('form-year');
  m.innerHTML = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'].map((v,i)=>`<option value="${i}">${v}</option>`).join('');
  d.innerHTML = [...Array(31)].map((_,i)=>`<option value="${i+1}">${i+1}</option>`).join('');
  const cy = new Date().getFullYear(); 
  y.innerHTML = [...Array(6)].map((_,i)=>`<option value="${cy+i}">${cy+i}</option>`).join('');
}

let formCover = null;

function openCreateForm() {
  editingId = null; 
  $('form-title').textContent = 'Create';
  $('form-name').value = ''; 
  removeCover();
  const n = new Date(); 
  $('form-month').value = n.getMonth(); 
  $('form-day').value = n.getDate(); 
  $('form-year').value = n.getFullYear();
  $('del-wrap').style.display = 'none'; 
  switchScreen('form');
}

function editEvent() {
  openEditForm();
}

function openEditForm() {
  if(!currentEvent) return;
  editingId = currentEvent.id; 
  $('form-title').textContent = 'Edit';
  $('form-name').value = currentEvent.title;
  const d = new Date(currentEvent.event_date + 'T00:00:00');
  $('form-month').value = d.getMonth(); 
  $('form-day').value = d.getDate(); 
  $('form-year').value = d.getFullYear();
  if(currentEvent.cover_image) {
     formCover = currentEvent.cover_image;
     $('cover-preview').src = formCover; 
     $('cover-preview').style.display = 'block';
     $('cover-upload').classList.add('has-img'); 
     $('cover-remove').style.display = 'block';
  } else removeCover();
  $('del-wrap').style.display = 'block'; 
  switchScreen('form');
}

function closeForm() { 
  switchScreen('home'); 
}

function handleCoverUpload(e) {
  const f = e.target.files[0]; 
  if(!f) return;
  const r = new FileReader();
  r.onload = ev => { 
    formCover = ev.target.result; 
    $('cover-preview').src = formCover; 
    $('cover-preview').style.display = 'block';
    $('cover-upload').classList.add('has-img'); 
    $('cover-remove').style.display = 'block';
  };
  r.readAsDataURL(f);
}

function removeCover() { 
  formCover = null; 
  $('cover-preview').style.display='none'; 
  $('cover-upload').classList.remove('has-img'); 
  $('cover-remove').style.display='none'; 
  $('cover-input').value=''; 
}

function submitForm() {
  const name = $('form-name').value.trim(); 
  if(!name) return showToast('Name required');
  const m = parseInt($('form-month').value), d = parseInt($('form-day').value), y = parseInt($('form-year').value);
  const ds = `${y}-${String(m+1).padStart(2,'0')}-${String(d).padStart(2,'0')}`;
  
  const data = { 
    title: name, 
    event_date: ds, 
    cover_image: formCover, 
    emoji: ['🎉','✈️','❤️','🥂','🎂'][Math.floor(Math.random()*5)] 
  };
  
  if(editingId) { 
    updateEvent(currentUser.username, editingId, data); 
    showToast('Updated'); 
  } else { 
    createEvent(currentUser.username, data); 
    showToast('Created'); 
  }
  closeForm(); 
  renderEvents();
}

function confirmDelete() {
  if(confirm('Delete event permanently?')) { 
    deleteEvent(currentUser.username, editingId); 
    closeForm(); 
    closeDetail(); 
    renderEvents(); 
  }
}
