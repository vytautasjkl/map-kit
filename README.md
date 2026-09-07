# 🗺 map-kit — vizualus visų tavo projektų žemėlapis

Neon HTML dashboard'as, rodantis VISĄ tavo setupą (tinklas, serveriai, svetainės,
projektai, įrankiai, AI) vienoje vietoje — su paieška ir Live/Dev filtrais.
Plius `/map` komanda ClaudeCLI'ui.

Savarankiškas: reikia tik **Bash + Python3**. Jokių išorinių priklausomybių.

## Diegimas (Linux / Mac / WSL)

```bash
git clone https://github.com/vytautasjkl/map-kit.git
cd map-kit
./install.sh
```

Tada:

```bash
mapas          # sugeneruoja + atidaro žemėlapį naršyklėje
mapas --print  # medis terminale
```

Arba ClaudeCLI'e parašyk **`/map`**.

### CloudCLI web sąsaja (claude-code-ui) — „Žemėlapis" tab'as

Jei naudoji **CloudCLI / claude-code-ui** web sąsają, `install.sh` automatiškai įdeda
plugin'ą (`~/.claude-code-ui/plugins/cloudcli-mapas/`) ir atsiranda nuolatinis
**„Žemėlapis"** tab'as su „↻ Atnaujinti" mygtuku. Po diegimo tik **hard-refresh**
naršyklę (Ctrl+Shift+R) — restart nereikia (plugin'ai skenuojami gyvai).

> Jei CloudCLI įsidiegi vėliau — paleisk `./install.sh` dar kartą, tab'as atsiras.

## Kaip užpildyti SAVO duomenimis

Du būdai:

1. **Automatiškai (rekomenduoju):** ClaudeCLI'e parašyk
   `/map` ir „**atnaujink iš mano projektų**". Claude perskaitys tavo užrašus
   (memory failus, `~/projektai/*/CLAUDE.md`) ir pats surašys viską į `data.json`.

2. **Ranka:** redaguok `~/projektai/mapas/data.json`. Kiekvienas node:
   ```
   { "id","label","category","status","address?","path?","tech?","summary","parent?","children?[] }
   ```
   - `category`: infra | website | project | business | ai | webapp | tool | system
   - `status`: live | dev | done | idle
   - `parent`: kito node id (kad kabotų po juo) arba null (šaknis)

   Tada paleisk `mapas`.

## Kas viduje
```
map-kit/
├── install.sh                      # diegiklis
├── mapas/
│   ├── bin/mapas.sh                # generatorius (data.json → index.html)
│   ├── data.json                   # ŠABLONAS — pakeisk savo duomenimis
│   └── CLAUDE.md
├── skill/map/SKILL.md              # /map ClaudeCLI skill
└── plugin/cloudcli-mapas/          # CloudCLI „Žemėlapis" tab plugin'as
    ├── manifest.json               #   slot:"tab" + entry/server
    └── dist/{index.js,server.js}   #   frontend iframe + backend (GET /html)
```

## Ką įdiegia install.sh
| Kas | Kur | Reikalinga |
|-----|-----|-----------|
| `mapas` komanda | `~/.local/bin/mapas` | visada |
| `/map` skill | `~/.claude/skills/map/` | visada |
| projektas + data.json | `~/projektai/mapas/` | visada |
| CloudCLI „Žemėlapis" tab | `~/.claude-code-ui/plugins/cloudcli-mapas/` | tik jei turi CloudCLI |
