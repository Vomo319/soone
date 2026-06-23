// ════════════════════════════════════════════════════════════════
// DATA LAYER - Storage & CRUD Operations
// ════════════════════════════════════════════════════════════════

const Store = {
  get(key, fb) { 
    try { 
      const v = localStorage.getItem('sn_' + key); 
      return v !== null ? JSON.parse(v) : fb; 
    } catch { return fb; } 
  },
  set(key, v) { 
    try { 
      localStorage.setItem('sn_' + key, JSON.stringify(v)); 
      return true; 
    } catch { return false; } 
  },
  remove(key) { 
    try { 
      localStorage.removeItem('sn_' + key); 
      return true; 
    } catch { return false; } 
  }
};

// ─── EVENTS CRUD ───
function getEvents(usr) { 
  return (Store.get('evts', {})[usr] || []).map(e => ({...e, _owned:true})); 
}

function getJoinedEvents(usr) { 
  return (Store.get('joined', {})[usr] || []).map(e => ({...e, _joined:true})); 
}

function getAllEvents(usr) { 
  return [...getEvents(usr), ...getJoinedEvents(usr)]; 
}

function saveEvents(usr, evts) { 
  const all = Store.get('evts', {}); 
  all[usr] = evts; 
  Store.set('evts', all); 
}

function saveJoinedEvents(usr, evts) { 
  const all = Store.get('joined', {}); 
  all[usr] = evts; 
  Store.set('joined', all); 
}

function createEvent(usr, data) {
  const evts = getEvents(usr);
  const ev = { id: 'ev_' + Date.now(), ...data, createdAt: Date.now() };
  evts.push(ev); 
  saveEvents(usr, evts); 
  return ev;
}

function updateEvent(usr, id, data) {
  const evts = getEvents(usr); 
  const idx = evts.findIndex(e => e.id === id);
  if(idx > -1) { 
    evts[idx] = { ...evts[idx], ...data }; 
    saveEvents(usr, evts); 
  }
}

function deleteEvent(usr, id) { 
  saveEvents(usr, getEvents(usr).filter(e => e.id !== id)); 
}

function leaveJoinedEvent(usr, id) { 
  saveJoinedEvents(usr, getJoinedEvents(usr).filter(e => e.id !== id)); 
}

// ─── SHARING ───
function joinEvent(usr, code) {
  const shares = Store.get('shares', {});
  if(!shares[code]) throw new Error('Invalid code');
  const { eventId, owner } = shares[code];
  if(getJoinedEvents(usr).find(e => e.id === eventId)) throw new Error('Already joined');
  const ev = (Store.get('evts', {})[owner] || []).find(e => e.id === eventId);
  if(!ev) throw new Error('Event not found');
  const joined = getJoinedEvents(usr); 
  joined.push(ev); 
  saveJoinedEvents(usr, joined);
  return ev.id;
}

function generateShareCode(usr, evId) {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; 
  let code = 'WF-';
  for(let i=0; i<6; i++) code += chars[Math.floor(Math.random() * chars.length)];
  const shares = Store.get('shares', {}); 
  shares[code] = { eventId: evId, owner: usr }; 
  Store.set('shares', shares);
  return code;
}

function getShareCode(usr, evId) {
  const shares = Store.get('shares', {});
  const entry = Object.entries(shares).find(([c, d]) => d.eventId === evId && d.owner === usr);
  return entry ? entry[0] : null;
}
