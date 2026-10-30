# 1. Collect every asset URL referenced anywhere (absolute or root-relative)
{ grep -rhoE 'https?://(www\.)?thorneprotocol\.com/[^"'"'"' )>]+' . ;
  grep -rhoE '"/(media|stills|drawings|brand|kit)/[^"]+' . | tr -d '"' | sed 's#^#https://thorneprotocol.com#' ;
} | sed -E 's#https?://(www\.)?#https://#' | sort -u > urls.txt
wc -l urls.txt

# 2. Download each one into the matching local path
while read -r u; do
  p="${u#https://thorneprotocol.com/}"; p="${p%%\?*}"
  [ -f "$p" ] && continue
  mkdir -p "$(dirname "$p")"
  curl -sfL "$u" -o "$p" || echo "FAILED: $u"
done < urls.txt

# 3. Point absolute links at your own copies
grep -rlE 'https?://(www\.)?thorneprotocol\.com/' --include='*.html' --include='*.css' --include='*.js' --include='*.json' . \
  | xargs sed -i '' -E 's#https?://(www\.)?thorneprotocol\.com/#/#g'


