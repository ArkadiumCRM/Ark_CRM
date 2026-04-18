// ARK CRM — Shared layout interactions
// Tab switching, theme toggle, keyboard shortcuts.

function switchTab(n) {
  document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
  const tab = document.querySelector(`.tab[data-tab="${n}"]`);
  if (!tab) return;
  tab.classList.add('active');
  document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
  const panel = document.getElementById('tab-' + n);
  if (panel) panel.classList.add('active');
}

function toggleTheme() {
  const html = document.documentElement;
  const next = html.dataset.theme === 'dark' ? 'light' : 'dark';
  html.dataset.theme = next;
  const btn = document.getElementById('themeBtn');
  if (btn) btn.textContent = next === 'dark' ? '☾' : '☀';
  localStorage.setItem('ark-theme', next);
}

// Restore theme on load
(function() {
  const stored = localStorage.getItem('ark-theme');
  if (stored) {
    document.documentElement.dataset.theme = stored;
    const btn = document.getElementById('themeBtn');
    if (btn) btn.textContent = stored === 'dark' ? '☾' : '☀';
  }
})();

// Cross-frame theme sync: when another window/iframe changes localStorage,
// update this document too (native browser event, fires on OTHER documents).
window.addEventListener('storage', e => {
  if (e.key === 'ark-theme' && e.newValue) {
    document.documentElement.dataset.theme = e.newValue;
    const btn = document.getElementById('themeBtn');
    if (btn) btn.textContent = e.newValue === 'dark' ? '☾' : '☀';
  }
});

// Collapsible cards
function toggleCollapse(headEl) {
  const card = headEl.closest('.card.collapsible');
  if (card) card.classList.toggle('collapsed');
}

// Section header collapsible (not cards)
function toggleSection(headEl) {
  headEl.classList.toggle('collapsed');
}

// Drawer
let __lastFocusBeforeDrawer = null;
function openDrawer(id, tabIdx) {
  const bd = document.getElementById('drawerBackdrop');
  if (bd) bd.classList.add('open');
  const d = document.getElementById(id);
  if (!d) return;
  d.classList.add('open');
  if (tabIdx != null) drawerTab(id, tabIdx);
  // A11y: Focus-Trap
  __lastFocusBeforeDrawer = document.activeElement;
  d.setAttribute('aria-modal', 'true');
  d.setAttribute('role', 'dialog');
  const focusable = d.querySelectorAll('button, [href], input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])');
  if (focusable.length) setTimeout(() => focusable[0].focus(), 50);
}
function closeDrawer(id) {
  const bd = document.getElementById('drawerBackdrop');
  if (bd) bd.classList.remove('open');
  const targets = id ? [document.getElementById(id)].filter(Boolean) : Array.from(document.querySelectorAll('.drawer.open'));
  targets.forEach(d => {
    d.classList.remove('open');
    d.removeAttribute('aria-modal');
  });
  if (__lastFocusBeforeDrawer) { __lastFocusBeforeDrawer.focus(); __lastFocusBeforeDrawer = null; }
}
// Global Tab-Trap in offenem Drawer
document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') {
    const openD = document.querySelector('.drawer.open');
    if (openD) { e.preventDefault(); closeDrawer(openD.id); return; }
  }
  if (e.key !== 'Tab') return;
  const openD = document.querySelector('.drawer.open');
  if (!openD) return;
  const focusable = openD.querySelectorAll('button:not([disabled]), [href], input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])');
  if (!focusable.length) return;
  const first = focusable[0];
  const last = focusable[focusable.length - 1];
  if (e.shiftKey && document.activeElement === first) { e.preventDefault(); last.focus(); }
  else if (!e.shiftKey && document.activeElement === last) { e.preventDefault(); first.focus(); }
});
function drawerTab(drawerId, idx) {
  const drawer = document.getElementById(drawerId);
  drawer.querySelectorAll('.drawer-tab').forEach((t,i) => t.classList.toggle('active', i===idx));
  drawer.querySelectorAll('.drawer-pane').forEach((p,i) => p.style.display = (i===idx)?'block':'none');
}

// Sub-tabs (inside a tab-panel, e.g. Organisation Stellenplan/Teamrad)
function switchSubtab(groupId, idx) {
  const root = document.getElementById(groupId);
  root.querySelectorAll('.subtab').forEach((t,i) => t.classList.toggle('active', i===idx));
  root.querySelectorAll('.subpane').forEach((p,i) => p.classList.toggle('active', i===idx));
}

// Modal helpers
function openModal(id) {
  const m = document.getElementById(id);
  if (m) m.classList.add('open');
}
function closeModal(id) {
  if (id) {
    const m = document.getElementById(id);
    if (m) m.classList.remove('open');
  } else {
    document.querySelectorAll('.modal-backdrop.open').forEach(m => m.classList.remove('open'));
  }
}

// Stellenplan: toggle List ↔ Org-Chart
function toggleOrgChart(btn) {
  const wrap = btn.closest('.stellenplan');
  wrap.classList.toggle('chart-view');
  btn.classList.toggle('active');
  btn.textContent = wrap.classList.contains('chart-view') ? '📋 Liste anzeigen' : '🌳 Org-Chart';
}

// Multi-toggle (Sparten etc.)
function toggleTag(el) {
  el.classList.toggle('active');
  // If part of a sparte-sync group, update header chip
  const group = el.closest('[data-sync="sparte-header"]');
  if (group) syncSparteHeader(group);
}

function syncSparteHeader(group) {
  const active = [...group.querySelectorAll('.toggle-tag.active')].map(t => t.dataset.code).filter(Boolean);
  const headerChip = document.getElementById('sparteHeaderChip');
  if (headerChip) headerChip.textContent = active.length ? active.join(' · ') : '— keine Sparte';
}

// Section edit mode
function enterEdit(linkEl) {
  const card = linkEl.closest('.card');
  card.classList.add('editing');
  card.querySelectorAll('[data-edit-from]').forEach(target => {
    const tpl = target.querySelector('template');
    if (tpl) {
      target.dataset.original = target.innerHTML;
      target.innerHTML = tpl.innerHTML;
    }
  });
  // Replace edit link with save/cancel
  const head = card.querySelector('.card-head');
  const link = head.querySelector('.card-link');
  if (link) {
    link.dataset.original = link.outerHTML;
    link.outerHTML = `<div style="display:flex;gap:6px"><button class="btn btn-sm btn-primary" onclick="event.stopPropagation();saveEdit(this)">Speichern</button><button class="btn btn-sm" onclick="event.stopPropagation();cancelEdit(this)">Abbrechen</button></div>`;
  }
}
function saveEdit(btn) {
  const card = btn.closest('.card');
  card.classList.remove('editing');
  // For demo: just exit, restore originals (in real app: persist values)
  cancelEdit(btn, true);
}
function cancelEdit(btn, saved=false) {
  const card = btn.closest('.card');
  card.classList.remove('editing');
  card.querySelectorAll('[data-edit-from]').forEach(target => {
    if (target.dataset.original && !saved) target.innerHTML = target.dataset.original;
    else if (target.dataset.original && saved) target.innerHTML = target.dataset.original;  // demo: same content
  });
  const head = card.querySelector('.card-head');
  const actions = head.querySelector('div[style*="display:flex"]');
  if (actions) {
    actions.outerHTML = `<a href="#" class="card-link" onclick="event.stopPropagation();enterEdit(this)">Bearbeiten</a>`;
  }
}

// Status dropdown demo (no real menu, just visual)
function statusMenu(el) {
  alert('Account-Status ändern: Active / Inactive / Prospect / Blacklisted (Demo)');
}

function switchProcView(chipEl, mode) {
  chipEl.parentElement.querySelectorAll('.chip-tab').forEach(c => c.classList.remove('active'));
  chipEl.classList.add('active');
  document.getElementById('proc-view-pipe').style.display = (mode === 'pipe') ? 'block' : 'none';
  document.getElementById('proc-view-tab').style.display = (mode === 'tab') ? 'block' : 'none';
}

function switchDocView(chipEl, mode) {
  chipEl.parentElement.querySelectorAll('.chip-tab').forEach(c => c.classList.remove('active'));
  chipEl.classList.add('active');
  document.getElementById('doc-view-list').style.display = (mode === 'list') ? 'block' : 'none';
  document.getElementById('doc-view-grid').style.display = (mode === 'grid') ? 'block' : 'none';
}

function filterDocCat(chipEl, cat) {
  chipEl.parentElement.querySelectorAll('.chip-tab').forEach(c => c.classList.remove('active'));
  chipEl.classList.add('active');
  const rows = document.querySelectorAll('#doc-view-list tbody tr[data-cat]');
  rows.forEach(r => {
    r.style.display = (cat === 'all' || r.dataset.cat === cat) ? '' : 'none';
  });
}

const DOC_LINK_ITEMS = {
  account: ['Nur Account-Level (ohne Verknüpfung)'],
  mandat: [
    'Mandat · CFO-Suche',
    'Mandat · PL Hochbau Taskforce',
    'Mandat · Bauleiter Tiefbau',
    'Mandat · BIM-Manager',
    'Mandat · HR-Leitung (abgeschlossen)',
  ],
  assessment: [
    'Order ORD-2026-042 · 10×ASSESS + 5×EQ (aktiv)',
    'Order ORD-2025-118 · 5×ASSESS (abgeschlossen)',
    'Order ORD-2024-091 · 3×MDI (archiviert)',
  ],
  erfolgsbasis: [
    'Erfolgsbasis · Nico Jäger (Controller)',
    'Erfolgsbasis · Corinne Zäch (HR-BP)',
    'Erfolgsbasis · Sven Aebi (platziert)',
  ],
  schutzfrist: [
    'Claim · Tobias Sommer (pending)',
    'Schutzfrist · Markus Gerber (active)',
    'Schutzfrist · Stefan Keller (extended 16 Mt)',
    'Schutzfrist · Roland Bühler (active)',
  ],
};

function filterRemStatus(chipEl, group) {
  chipEl.parentElement.querySelectorAll('.chip-tab').forEach(c => c.classList.remove('active'));
  chipEl.classList.add('active');
  // Scope: innerhalb des enthaltenden tab-panel (damit mehrere Reminder-Sections pro Seite isoliert sind)
  const scope = chipEl.closest('.tab-panel') || document;
  scope.querySelectorAll('[data-rem-group]').forEach(sec => {
    sec.style.display = (group === 'all' || sec.dataset.remGroup === group) ? '' : 'none';
  });
  // Erledigt-Sektion (collapsed .section-head + .section-body) separat toggeln
  const doneHead = scope.querySelector('.section-head');
  const doneBody = scope.querySelector('.section-body');
  if (doneHead) doneHead.style.display = (group === 'all' || group === 'done') ? '' : 'none';
  if (doneBody) doneBody.style.display = (group === 'done') ? '' : 'none';
}

function updateDocLinkItems(type) {
  const sel = document.getElementById('doc-link-item');
  sel.innerHTML = '';
  if (!type) {
    sel.disabled = true;
    sel.innerHTML = '<option>— erst Typ wählen —</option>';
    return;
  }
  sel.disabled = false;
  const items = DOC_LINK_ITEMS[type] || [];
  sel.innerHTML = '<option value="">Alle ' + type + '</option>' +
    items.map(i => '<option>' + i + '</option>').join('');
}

// Keyboard shortcuts
document.addEventListener('keydown', e => {
  if (e.target.matches('input, textarea, select')) return;
  if (e.metaKey || e.ctrlKey || e.altKey) return;
  if (e.key >= '1' && e.key <= '9') switchTab(parseInt(e.key));
  else if (e.key === '0') switchTab(10);
  else if (e.key === 't' || e.key === 'T') toggleTheme();
});
