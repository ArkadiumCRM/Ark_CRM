/* ARK Theme-Sync
   Shared theme-loader + postMessage-listener für alle iframe-Content-Pages.
   Shell (elearn.html, hr.html, etc.) broadcastet `{type:'ark-theme', value:'dark'|'light'}` an iframe via postMessage.
   Pages apply theme on load from localStorage + subscribe to live updates. */
(function () {
  var t = localStorage.getItem('ark-theme') || 'light';
  document.documentElement.setAttribute('data-theme', t);

  window.addEventListener('message', function (e) {
    if (!e.data || e.data.type !== 'ark-theme') return;
    document.documentElement.setAttribute('data-theme', e.data.value);
    localStorage.setItem('ark-theme', e.data.value);
    var b = document.getElementById('themeBtn');
    if (b) b.textContent = e.data.value === 'dark' ? '☾' : '☀';
  });
})();
