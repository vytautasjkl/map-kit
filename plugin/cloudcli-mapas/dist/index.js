// cloudcli-mapas — frontend (map-kit standalone versija).
// Rodo neon žemėlapį (index.html) Žemėlapio tab'e per iframe.
// HTML ateina iš backend (dist/server.js): GET /html -> { html }.
// „↻ Atnaujinti" perkuria iš data.json.

function h(tag, cls, txt) {
  const e = document.createElement(tag);
  if (cls) e.className = cls;
  if (txt != null) e.textContent = txt;
  return e;
}

function ensureStyles() {
  if (document.getElementById('mpx-style')) return;
  const s = document.createElement('style');
  s.id = 'mpx-style';
  s.textContent = `
    .mpx-root{display:flex;flex-direction:column;height:100%;background:#0b0f17;color:#e6edf7;font:14px/1.4 system-ui,sans-serif}
    .mpx-bar{display:flex;align-items:center;gap:10px;padding:8px 12px;border-bottom:1px solid #1c2740;flex:0 0 auto}
    .mpx-title{font-weight:600;letter-spacing:.3px}
    .mpx-title small{opacity:.6;font-weight:400;margin-left:8px}
    .mpx-btn{margin-left:auto;background:#12315a;color:#bfe0ff;border:1px solid #21518f;border-radius:8px;padding:6px 12px;cursor:pointer;font-size:13px}
    .mpx-btn:hover{background:#173a6b}
    .mpx-btn:disabled{opacity:.5;cursor:default}
    .mpx-frame{flex:1 1 auto;border:0;width:100%;height:100%;background:#0b0f17}
  `;
  document.head.appendChild(s);
}

async function load(api, iframe, btn, fresh) {
  if (btn) { btn.disabled = true; btn.textContent = '⏳ kuriama…'; }
  try {
    const route = fresh ? 'html?fresh=1' : 'html';
    const res = await api.rpc('GET', route);
    if (!res || !res.html) throw new Error('Tuščias atsakymas iš backend');
    iframe.srcdoc = res.html;
  } catch (err) {
    iframe.srcdoc = '<body style="background:#0b0f17;color:#ff8080;font:14px system-ui;padding:40px">✗ '
      + String(err && err.message ? err.message : err) + '</body>';
  } finally {
    if (btn) { btn.disabled = false; btn.textContent = '↻ Atnaujinti'; }
  }
}

export async function mount(container, api) {
  ensureStyles();
  const root = h('div', 'mpx-root');

  const bar = h('div', 'mpx-bar');
  const title = h('div', 'mpx-title', '🗺 Visi projektai');
  const sub = document.createElement('small');
  sub.textContent = 'Projektų žemėlapis';
  title.appendChild(sub);
  const btn = h('button', 'mpx-btn', '↻ Atnaujinti');
  bar.appendChild(title);
  bar.appendChild(btn);

  const iframe = document.createElement('iframe');
  iframe.className = 'mpx-frame';
  iframe.setAttribute('sandbox', 'allow-scripts allow-same-origin allow-downloads allow-popups');
  iframe.srcdoc = '<body style="background:#0b0f17;color:#9fb3d1;font:14px system-ui;padding:40px">⏳ kraunamas žemėlapis…</body>';

  root.appendChild(bar);
  root.appendChild(iframe);
  container.appendChild(root);

  btn.addEventListener('click', () => load(api, iframe, btn, true));
  await load(api, iframe, btn, false);
}

export function unmount(container) {
  container.replaceChildren();
}
