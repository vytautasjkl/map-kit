#!/usr/bin/env bash
# map-kit installer — sudeda „mapas" įrankį + /map ClaudeCLI skill.
# Naudojimas:  ./install.sh
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_PROJ="$HOME/projektai/mapas"
DEST_SKILL="$HOME/.claude/skills/map"
BIN_DIR="$HOME/.local/bin"

echo "🗺  map-kit diegimas..."

# 1) Priklausomybės
command -v bash    >/dev/null || { echo "❌ reikia bash"; exit 1; }
command -v python3 >/dev/null || { echo "❌ reikia python3 (sudo apt install python3)"; exit 1; }

# 2) mapas projektas (neperrašom esamo data.json jei jau yra)
mkdir -p "$DEST_PROJ/bin"
cp "$HERE/mapas/bin/mapas.sh" "$DEST_PROJ/bin/mapas.sh"
cp "$HERE/mapas/CLAUDE.md"    "$DEST_PROJ/CLAUDE.md"
chmod +x "$DEST_PROJ/bin/mapas.sh"
if [[ -f "$DEST_PROJ/data.json" ]]; then
  echo "ℹ️  Rastas esamas data.json — paliekamas (tavo duomenys saugūs)."
else
  cp "$HERE/mapas/data.json" "$DEST_PROJ/data.json"
  echo "✅ Idetas sablonis data.json (redaguok ranka arba paleisk /map atnaujinima)."
fi

# 3) `mapas` komanda į PATH
mkdir -p "$BIN_DIR"
cat > "$BIN_DIR/mapas" <<EOF
#!/usr/bin/env bash
exec "$DEST_PROJ/bin/mapas.sh" "\$@"
EOF
chmod +x "$BIN_DIR/mapas"

# 4) /map ClaudeCLI skill
mkdir -p "$DEST_SKILL"
cp "$HERE/skill/map/SKILL.md" "$DEST_SKILL/SKILL.md"

# 5) CloudCLI (claude-code-ui) „Žemėlapis" tab plugin — jei naudoji web sąsają
CCUI="$HOME/.claude-code-ui"
PLUGIN_INSTALLED=0
if [[ -d "$CCUI" ]]; then
  DEST_PLUGIN="$CCUI/plugins/cloudcli-mapas"
  mkdir -p "$DEST_PLUGIN/dist"
  cp "$HERE/plugin/cloudcli-mapas/manifest.json" "$DEST_PLUGIN/manifest.json"
  cp "$HERE/plugin/cloudcli-mapas/package.json"  "$DEST_PLUGIN/package.json"
  cp "$HERE/plugin/cloudcli-mapas/icon.svg"      "$DEST_PLUGIN/icon.svg"
  cp "$HERE/plugin/cloudcli-mapas/dist/index.js"  "$DEST_PLUGIN/dist/index.js"
  cp "$HERE/plugin/cloudcli-mapas/dist/server.js" "$DEST_PLUGIN/dist/server.js"
  PLUGIN_INSTALLED=1
fi

echo
echo "✅ Baigta."
echo "   • Projektas:  $DEST_PROJ"
echo "   • Skill:      $DEST_SKILL"
echo "   • Komanda:    $BIN_DIR/mapas"
if ! echo "$PATH" | tr ':' '\n' | grep -qx "$BIN_DIR"; then
  echo
  echo "⚠️  $BIN_DIR nėra tavo PATH'e. Pridėk į ~/.bashrc:"
  echo "     export PATH=\"\$HOME/.local/bin:\$PATH\""
  echo "   tada:  source ~/.bashrc"
fi
if [[ "$PLUGIN_INSTALLED" == "1" ]]; then
  echo "   • CloudCLI tab: $CCUI/plugins/cloudcli-mapas  (Žemėlapis)"
fi
echo
echo "▶  Bandyk:  mapas          (atidarys žemėlapį naršyklėje)"
echo "▶  Arba ClaudeCLI'e:  /map"
echo "▶  Užpildyk savo duomenimis:  ClaudeCLI'e parašyk  /map  ir  „atnaujink iš mano projektų\""
if [[ "$PLUGIN_INSTALLED" == "1" ]]; then
  echo
  echo "🖥  CloudCLI web sąsajoj atsiras tab'as „Žemėlapis\" — hard-refresh naršyklę (Ctrl+Shift+R)."
  echo "    (plugin'ai skenuojami gyvai, restart nereikia)"
else
  echo
  echo "ℹ️  CloudCLI (~/.claude-code-ui) nerastas — web tab'as praleistas."
  echo "    Jei vėliau įsidiegsi CloudCLI, paleisk ./install.sh dar kartą."
fi
