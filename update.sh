#!/bin/bash

GITHUB_USER="Michuelnik"
DOCKER_USER="michuelnik"
INDEX_HTML="index.html"

echo "🌀 GitHub Repositories abrufen..."
GITHUB_REPOS=$(curl -s "https://api.github.com/users/$GITHUB_USER/repos?per_page=100")

GITHUB_HTML=""
for row in $(echo "${GITHUB_REPOS}" | jq -r '.[] | @base64'); do
  _jq() {
    echo "${row}" | base64 --decode | jq -r "${1}"
  }

  NAME=$(_jq '.name')
  DESC=$(_jq '.description')
  URL=$(_jq '.html_url')

  # ✂️ GitHub Pages Repo auslassen (case-insensitiver Vergleich)
  NAME_LOWER=$(echo "$NAME" | tr '[:upper:]' '[:lower:]')
  if [[ "$NAME_LOWER" == "${GITHUB_USER,,}.github.io" ]]; then
    echo "⏭️  Überspringe GitHub Pages-Repository: $NAME"
    continue
  fi


  GITHUB_HTML+="<div class=\"repo\">\n"
  GITHUB_HTML+="  <a href=\"$URL\" target=\"_blank\">$NAME</a>\n"
  GITHUB_HTML+="  <p>${DESC:-Keine Beschreibung.}</p>\n"
  GITHUB_HTML+="</div>\n"
done

echo "🐳 Docker Hub Repositories abrufen..."
DOCKER_REPOS=$(curl -s "https://hub.docker.com/v2/repositories/$DOCKER_USER/?page_size=100")

DOCKER_HTML=""
REPO_COUNT=$(echo "$DOCKER_REPOS" | jq '.results | length')
for i in $(seq 0 $((REPO_COUNT - 1))); do
  NAME=$(echo "$DOCKER_REPOS" | jq -r ".results[$i].name")
  DESC=$(echo "$DOCKER_REPOS" | jq -r ".results[$i].description")
  URL="https://hub.docker.com/r/$DOCKER_USER/$NAME"

  DOCKER_HTML+="<div class=\"repo\">\n"
  DOCKER_HTML+="  <a href=\"$URL\" target=\"_blank\">$DOCKER_USER/$NAME</a>\n"
  DOCKER_HTML+="  <p>${DESC:-Keine Beschreibung.}</p>\n"
  DOCKER_HTML+="</div>\n"
done

echo "📝 index.html aktualisieren..."
sed -i "/<!-- BEGIN GITHUB -->/,/<!-- END GITHUB -->/c\\
<!-- BEGIN GITHUB -->\n$GITHUB_HTML<!-- END GITHUB -->" "$INDEX_HTML"

sed -i "/<!-- BEGIN DOCKER -->/,/<!-- END DOCKER -->/c\\
<!-- BEGIN DOCKER -->\n$DOCKER_HTML<!-- END DOCKER -->" "$INDEX_HTML"

echo "✅ Fertig! $INDEX_HTML aktualisiert – ohne Link zur GitHub Pages-Seite."

