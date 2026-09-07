#!/usr/bin/env bash
# mapas — vizualus VISŲ projektų + infrastruktūros žemėlapis (neon)
# Naudojimas:  mapas          sugeneruoja index.html iš data.json ir atidaro naršyklėje
#              mapas --print  tik atspausdina medį terminale (be naršyklės)
set -uo pipefail

# --no-open: sugeneruoja index.html, bet neatidaro naršyklės (naudoja CloudCLI plugin'as)
NOOPEN=0
for a in "$@"; do [[ "$a" == "--no-open" ]] && NOOPEN=1; done

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA="$DIR/data.json"
OUT="$DIR/index.html"

[[ -f "$DATA" ]] || { echo "Nėra $DATA"; exit 1; }

# ---- Terminalinis medis (--print) ----
if [[ "${1:-}" == "--print" ]]; then
  C=$'\e[38;5;51m'; D=$'\e[38;5;245m'; BOLD=$'\e[1m'; RST=$'\e[0m'
  clear 2>/dev/null || true
  printf "\n  ${BOLD}${C}🗺  mapas${RST}${D} — viskas vienoje vietoje   ·   %s${RST}\n" "$(date '+%Y-%m-%d')"
  python3 - "$DATA" <<'PY'
import json,sys
d=json.load(open(sys.argv[1]))
cats={"infra":"🌐 Tinklas & Infrastruktūra","project":"🎥 Produktai","business":"💼 Verslas / NIS2 / VPA",
      "website":"🚀 Svetainės","ai":"🤖 Lokalus AI","webapp":"🧩 Web aplikacijos","tool":"🛠  Įrankiai","system":"⚙  Sistema / Backup"}
badge={"live":"\033[38;5;48m●LIVE","dev":"\033[38;5;227m●DEV","done":"\033[38;5;51m●DONE","idle":"\033[38;5;245m●IDLE"}
D="\033[38;5;245m";B="\033[1m";R="\033[0m";M="\033[38;5;207m"
roots=[n for n in d['nodes'] if not n['parent']]
def kids(pid): return [n for n in d['nodes'] if n['parent']==pid]
def line(n,ind):
    bg=badge.get(n['status'],'')+R
    print(f"  {ind}{B}{M}{n['label']}{R} {bg}  {D}{n.get('address') or n.get('path','')}{R}")
    for k in kids(n['id']): line(k,ind+"   └ ")
for cat,title in cats.items():
    cr=[r for r in roots if r['category']==cat]
    if not cr: continue
    print(f"\n  {B}\033[38;5;51m{title}{R}")
    for r in cr: line(r,"")
print()
PY
  exit 0
fi

# ---- HTML generacija ----
cat > "$OUT" <<'HTMLHEAD'
<!doctype html><html lang="lt"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>🗺 mapas — visų projektų žemėlapis</title>
<style>
:root{--bg:#070912;--bg2:#0c1024;--cy:#3df0ff;--mg:#ff5cf0;--gr:#38ffa8;--yl:#ffe35c;--pu:#a97bff;--dim:#7a86a8;--card:#111634;}
*{box-sizing:border-box}
body{margin:0;font-family:'Segoe UI',system-ui,sans-serif;background:
 radial-gradient(1200px 700px at 15% -10%,#141a3e 0,transparent 60%),
 radial-gradient(1000px 600px at 110% 10%,#2a1140 0,transparent 55%),var(--bg);
 color:#e8ecff;min-height:100vh}
header{padding:26px 30px 14px;display:flex;align-items:center;gap:16px;flex-wrap:wrap}
h1{margin:0;font-size:26px;letter-spacing:.5px;
 background:linear-gradient(90deg,var(--cy),var(--mg));-webkit-background-clip:text;background-clip:text;color:transparent;text-shadow:0 0 24px rgba(61,240,255,.25)}
.sub{color:var(--dim);font-size:13px}
.tools{margin-left:auto;display:flex;gap:10px;align-items:center;flex-wrap:wrap}
#q{background:var(--bg2);border:1px solid #26305e;color:#e8ecff;padding:9px 14px;border-radius:10px;font-size:14px;outline:none;min-width:220px}
#q:focus{border-color:var(--cy);box-shadow:0 0 0 3px rgba(61,240,255,.15)}
.chip{font-size:12px;color:var(--dim);border:1px solid #26305e;padding:5px 10px;border-radius:20px;cursor:pointer;user-select:none}
.chip.on{color:#04121a;font-weight:700}
.legend{display:flex;gap:14px;padding:0 30px 10px;flex-wrap:wrap;font-size:12px;color:var(--dim)}
.dot{display:inline-block;width:9px;height:9px;border-radius:50%;margin-right:5px;vertical-align:middle}
.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(340px,1fr));gap:18px;padding:14px 30px 60px}
.sec{background:linear-gradient(180deg,rgba(255,255,255,.03),transparent);border:1px solid #1c2450;border-radius:16px;padding:16px 16px 8px;box-shadow:0 10px 40px rgba(0,0,0,.35)}
.sec h2{margin:2px 4px 12px;font-size:15px;display:flex;align-items:center;gap:8px;color:#cdd6ff}
.sec h2 .n{margin-left:auto;font-size:11px;color:var(--dim);font-weight:400}
.node{border:1px solid #212a58;border-left:3px solid var(--cy);background:var(--card);border-radius:10px;padding:10px 12px;margin:8px 4px;cursor:pointer;transition:.15s}
.node:hover{transform:translateX(3px);border-left-color:var(--mg);box-shadow:0 6px 22px rgba(255,92,240,.12)}
.node .top{display:flex;align-items:center;gap:8px}
.node .label{font-weight:600;font-size:14px}
.badge{margin-left:auto;font-size:10px;font-weight:800;letter-spacing:.5px;padding:2px 8px;border-radius:20px}
.b-live{background:rgba(56,255,168,.15);color:var(--gr);border:1px solid rgba(56,255,168,.4)}
.b-dev{background:rgba(255,227,92,.13);color:var(--yl);border:1px solid rgba(255,227,92,.4)}
.b-done{background:rgba(61,240,255,.12);color:var(--cy);border:1px solid rgba(61,240,255,.4)}
.b-idle{background:rgba(122,134,168,.14);color:var(--dim);border:1px solid rgba(122,134,168,.4)}
.node .sum{color:var(--dim);font-size:12px;margin-top:5px;line-height:1.45}
.node .meta{margin-top:7px;display:flex;gap:8px;flex-wrap:wrap;font-size:11px}
.tag{background:#0e1430;border:1px solid #222c58;color:#9fb0e6;padding:2px 8px;border-radius:6px}
.tag a{color:var(--cy);text-decoration:none}
.tag a:hover{text-decoration:underline}
.kid{margin:6px 4px 6px 22px;border-left:2px dashed #2a3468;padding:6px 10px;border-radius:0 8px 8px 0;background:rgba(255,255,255,.02);font-size:13px}
.kid .k-lab{font-weight:600;color:#c7d2ff}
.kid .k-sum{color:var(--dim);font-size:11px;margin-top:3px}
.subsvc{display:inline-block;font-size:10px;background:#0e1430;border:1px solid #22315f;color:#8fa6e6;padding:1px 7px;border-radius:5px;margin:3px 4px 0 0}
footer{color:var(--dim);font-size:12px;text-align:center;padding:10px 0 40px}
.hidden{display:none!important}
</style></head><body>
<header>
 <h1>🗺 mapas</h1>
 <div class="sub" id="stamp"></div>
 <div class="tools">
  <input id="q" placeholder="🔎 ieškoti (qnap, nis2, port, live…)">
  <span class="chip on" data-f="all" style="background:#3df0ff">Viskas</span>
  <span class="chip" data-f="live">Live</span>
  <span class="chip" data-f="dev">Dev</span>
  <span class="chip" data-f="idle">Idle</span>
 </div>
</header>
<div class="legend">
 <span><i class="dot" style="background:#38ffa8"></i>LIVE — veikia gyvai</span>
 <span><i class="dot" style="background:#ffe35c"></i>DEV — kuriama</span>
 <span><i class="dot" style="background:#3df0ff"></i>DONE — baigta</span>
 <span><i class="dot" style="background:#7a86a8"></i>IDLE — pauzėje</span>
</div>
<div class="grid" id="grid"></div>
<footer>Generuota iš data.json · atnaujink: <b>mapas</b> (arba <b>/map</b> ClaudeCLI) · terminale: <b>mapas --print</b></footer>
<script>
const DATA =
HTMLHEAD

# įterpiam data.json turinį
cat "$DATA" >> "$OUT"

cat >> "$OUT" <<'HTMLTAIL'
;
const CATS=[["infra","🌐 Tinklas & Infrastruktūra"],["website","🚀 Svetainės (Live)"],
["project","🎥 Produktai"],["business","💼 Verslas / NIS2 / VPA"],["ai","🤖 Lokalus AI"],
["webapp","🧩 Web aplikacijos"],["tool","🛠 Įrankiai"],["system","⚙ Sistema / Backup"]];
const nodes=DATA.nodes;
const kidsOf=id=>nodes.filter(n=>n.parent===id);
const roots=nodes.filter(n=>!n.parent);
const esc=s=>(s||"").replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;");
document.getElementById('stamp').textContent="viskas vienoje vietoje · "+(DATA.generated||"");
function catColor(c){return{infra:"#3df0ff",website:"#38ffa8",project:"#ff5cf0",business:"#a97bff",ai:"#3df0ff",webapp:"#38ffa8",tool:"#ffe35c",system:"#7a86a8"}[c]||"#3df0ff";}
function addr(n){
  if(!n.address) return n.path?`<span class="tag">${esc(n.path)}</span>`:"";
  const isUrl=n.address.startsWith("http");
  const u=isUrl?n.address.replace("*","klientas"):null;
  const a=isUrl?`<a href="${esc(u)}" target="_blank" rel="noopener">${esc(n.address)}</a>`:esc(n.address);
  return `<span class="tag">${a}</span>`+(n.path?`<span class="tag">${esc(n.path)}</span>`:"");
}
function nodeHTML(n){
  const subs=(n.children||[]).map(c=>`<span class="subsvc">${esc(c)}</span>`).join("");
  const kids=kidsOf(n.id).map(k=>`
    <div class="kid" data-status="${k.status}" data-txt="${esc((k.label+' '+k.summary+' '+(k.address||'')).toLowerCase())}">
      <div class="k-lab">↳ ${esc(k.label)} <span class="badge b-${k.status}">${k.status}</span></div>
      <div class="k-sum">${esc(k.summary)}</div>
      ${addr(k)}
    </div>`).join("");
  const searchTxt=esc((n.label+' '+n.summary+' '+(n.address||'')+' '+(n.tech||'')+' '+n.status).toLowerCase());
  return `<div class="node" data-status="${n.status}" data-txt="${searchTxt}" style="border-left-color:${catColor(n.category)}">
    <div class="top"><span class="label">${esc(n.label)}</span><span class="badge b-${n.status}">${n.status}</span></div>
    <div class="sum">${esc(n.summary)}</div>
    <div class="meta">${addr(n)}${n.tech?`<span class="tag">${esc(n.tech)}</span>`:""}</div>
    ${subs?`<div style="margin-top:6px">${subs}</div>`:""}
    ${kids}
  </div>`;
}
const grid=document.getElementById('grid');
const mk=html=>document.createRange().createContextualFragment(html);
CATS.forEach(([cat,title])=>{
  const rs=roots.filter(r=>r.category===cat);
  if(!rs.length)return;
  const sec=document.createElement('div');sec.className='sec';sec.dataset.cat=cat;
  sec.appendChild(mk(`<h2>${title}<span class="n">${rs.length}</span></h2>`+rs.map(nodeHTML).join("")));
  grid.appendChild(sec);
});
// paieška + filtrai
let curF="all",curQ="";
function apply(){
  document.querySelectorAll('.node').forEach(el=>{
    const okF=curF==="all"||el.dataset.status===curF;
    const okQ=!curQ||el.dataset.txt.includes(curQ)||[...el.querySelectorAll('.kid')].some(k=>k.dataset.txt.includes(curQ));
    el.classList.toggle('hidden',!(okF&&okQ));
  });
  document.querySelectorAll('.sec').forEach(s=>{
    const vis=[...s.querySelectorAll('.node')].some(n=>!n.classList.contains('hidden'));
    s.classList.toggle('hidden',!vis);
  });
}
document.getElementById('q').addEventListener('input',e=>{curQ=e.target.value.toLowerCase().trim();apply();});
document.querySelectorAll('.chip').forEach(c=>c.addEventListener('click',()=>{
  document.querySelectorAll('.chip').forEach(x=>{x.classList.remove('on');x.style.background='';});
  c.classList.add('on');c.style.background=catColor('infra');curF=c.dataset.f;apply();
}));
</script></body></html>
HTMLTAIL

echo "✅ Sugeneruota: $OUT"
if [[ "$NOOPEN" == "1" ]]; then
  : # tyliai, be naršyklės
elif command -v xdg-open >/dev/null 2>&1; then
  ( xdg-open "$OUT" >/dev/null 2>&1 & )
  echo "🌐 Atidaryta naršyklėje."
else
  echo "Atidaryk rankiniu: file://$OUT"
fi
