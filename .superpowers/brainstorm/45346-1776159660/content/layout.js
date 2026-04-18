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

// Keyboard shortcuts
document.addEventListener('keydown', e => {
  if (e.target.matches('input, textarea, select')) return;
  if (e.metaKey || e.ctrlKey || e.altKey) return;
  if (e.key >= '1' && e.key <= '9') switchTab(parseInt(e.key));
  else if (e.key === '0') switchTab(10);
  else if (e.key === 't' || e.key === 'T') toggleTheme();
});
