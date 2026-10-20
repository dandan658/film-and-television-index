#!/usr/bin/env bash
set -euo pipefail
image="${1:?image required}"
name=film-index-smoke
cleanup() { docker logs --tail=160 "$name" || true; docker rm -f "$name" >/dev/null 2>&1 || true; }
trap cleanup EXIT
docker run -d --name "$name" -p 127.0.0.1:18510:3000 -e NASTOOL_AUTO_UPDATE=false "$image"
ready=0
for attempt in $(seq 1 90); do
  if curl --max-time 5 -fsS http://127.0.0.1:18510/profile-info > /tmp/film-profile.json; then ready=1; break; fi
  sleep 2
done
[[ "$ready" == 1 ]]
curl --max-time 45 -fsS http://127.0.0.1:18510/ > /tmp/film-login.html
grep -q liquid-glass.css /tmp/film-login.html
curl --max-time 60 -fsS -c /tmp/film-cookies -d 'username=admin&password=password&remember=on' http://127.0.0.1:18510/ > /tmp/film-navigation.html
grep -q layout-navbar /tmp/film-navigation.html
for page in mediafile unidentification history tmdbcache service basic users library directorysync notification filterrule customwords indexer downloader mediaserver subtitle douban; do
  curl --max-time 45 -fsS -b /tmp/film-cookies "http://127.0.0.1:18510/$page" > "/tmp/film-$page.html"
  ! grep -q 'name="username"' "/tmp/film-$page.html"
done
curl --max-time 15 -fsS http://127.0.0.1:18510/project-source.zip -o /tmp/film-source.zip
python3 - <<'PY'
import zipfile
with zipfile.ZipFile('/tmp/film-source.zip') as z:
    assert z.testzip() is None
    assert any(n.endswith('liquid-glass.css') for n in z.namelist())
print('PASS: real container starts, admin login, all 17 retained pages and source archive')
PY
