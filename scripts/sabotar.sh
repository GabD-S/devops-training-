#!/usr/bin/env bash
# Uso: ./scripts/sabotar.sh 1|2|3|4
# Aplica uma falha, commita e da push SEM mostrar o diff (a dupla investiga).
set -euo pipefail
case "${1:-}" in
  1) sed -i.bak 's/host: app.localtest.me/host: app.localtest.mee/' manifests/treino-rails/ingress.yaml ;;
  2) sed -i.bak 's/ingressClassName: nginx/ingressClassName: ngnix/' manifests/treino-rails/ingress.yaml ;;
  3) sed -i.bak 's/targetPort: http/targetPort: 3001/' manifests/treino-rails/service.yaml ;;
  4) sed -i.bak '/readinessProbe/,/path:/ s#path: /up#path: /upp#' manifests/treino-rails/deployment.yaml ;;
  *) echo "uso: $0 1|2|3|4"; exit 1 ;;
esac
find manifests -name '*.bak' -delete
git add -A
git commit -qm "chore: ajustes de configuracao"
git push -q
echo "feito."
