# mapas — visų projektų + infrastruktūros vizualus žemėlapis

## Kas tai
Vienas neon dashboard'as, rodantis VISKĄ (tinklas, serveriai, svetainės, projektai,
įrankiai, AI) su paieška ir Live/Dev/Idle filtrais. Savarankiškas: tik Bash + Python3.

## Kaip paleisti
- `mapas`            → sugeneruoja index.html iš data.json ir atidaro naršyklėje
- `mapas --print`    → spalvotas medis terminale
- `/map` (ClaudeCLI) → tas pats; gali ir ATNAUJINTI data.json iš tavo užrašų

## Struktūra
- `data.json`     — vienintelė tiesa (node'ai: id/label/category/status/address/path/tech/summary/parent/children)
- `bin/mapas.sh`  — Bash generatorius (data.json → index.html, XSS-escaped) + xdg-open
- `index.html`    — sugeneruotas (NEREDAGUOTI ranka)

## Atnaujinimas
Naujas projektas? Pridėk node į `data.json` (kategorijos: infra/website/project/business/ai/webapp/tool/system;
statusai: live/dev/done/idle) ir paleisk `mapas`. Arba per `/map` „atnaujink" —
Claude perskaito tavo užrašus ir perrašo data.json.
