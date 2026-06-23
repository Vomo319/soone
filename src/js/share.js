// ════════════════════════════════════════════════════════════════
// SHARING & JOINING
// ════════════════════════════════════════════════════════════════

function shareEvent() {
  if(!currentEvent) return;
  const code = getShareCode(currentUser.username, currentEvent.id) || generateShareCode(currentUser.username, currentEvent.id);
  $('share-code-display').textContent = code; 
  openModal('modal-share');
}

function copyShareCode() { 
  navigator.clipboard.writeText($('share-code-display').textContent); 
  showToast('Copied'); 
  closeModal('modal-share'); 
}

function handleJoin() {
  const c = $('join-code-input').value.trim().toUpperCase();
  if(!c) return;
  try { 
    const id = joinEvent(currentUser.username, c.startsWith('WF-')?c:'WF-'+c); 
    showToast('Joined!'); 
    $('join-code-input').value=''; 
    closeJoin(); 
    renderEvents(); 
    setTimeout(()=>openDetail(id), 300); 
  } catch(e) { 
    showToast(e.message); 
  }
}

function closeJoin() { 
  switchScreen('home'); 
}
