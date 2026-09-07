---
name: map
description: Show a visual map/tree of ALL the user's projects, websites, servers and infrastructure, built from the user's memory files / notes. Use when the user types /map or asks to "see everything", "map of all projects", "visų projektų žemėlapis", "kas kur veikia", or wants an overview of their whole setup. Opens a neon HTML dashboard and can print a terminal tree.
---

# map — vizualus visko žemėlapis

Vienas neon HTML dashboard'as, rodantis VISKĄ (tinklas, serveriai, svetainės,
projektai, įrankiai, AI) su paieška ir Live/Dev/Idle filtrais. Savarankiškas —
reikia tik Bash + Python3, jokių papildomų priklausomybių.

Artefaktai gyvena `~/projektai/mapas/`:
- `data.json`     — VIENINTELĖ tiesa (visi node'ai)
- `bin/mapas.sh`  — generatorius (data.json → index.html) + atidaro naršyklę
- `index.html`    — sugeneruotas (NIEKADA neredaguok ranka)

## Ką daryti kai iškviečiama /map

1. **Rodyti (DEFAULT):** paleisk `~/projektai/mapas/bin/mapas.sh`
   (arba `~/projektai/mapas/bin/mapas.sh --print` terminalo medžiui).
   Tai perkuria ir atidaro `index.html` naršyklėje.

2. **ATNAUJINTI / „surašyk mano projektus":**
   - Perskaityk vartotojo memory/užrašų failus (pvz. `~/.claude/**/memory/*.md`,
     `~/projektai/*/CLAUDE.md`, arba paklausk vartotojo ką turi).
   - Perrašyk `~/projektai/mapas/data.json` node'ais. Schema:
     `{id, label, category, status, address?, path?, tech?, summary, parent?, children?[]}`
     - `category`: infra | website | project | business | ai | webapp | tool | system
     - `status`: live | dev | done | idle
     - `parent`: kito node `id` (medžio vaikas) arba `null` (šaknis)
     - `children`: paprastų paslaugų vardų sąrašas (stringai), rodomi kaip žymos
   - Paleisk `bin/mapas.sh`.

3. Trumpai atsakyk: kiek node'ų / kategorijų, kur atidaryta.

## Svarbu
- `data.json` = vienintelė tiesa; `index.html` visada perrašomas skripto.
- Viskas XSS-escaped skripte, saugu.
