curl -X POST "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/purge_cache" -H "X-Auth-Email: $CF_AUTH_EMAIL" -H "X-Auth-Key: $CF_API_KEY" -H "Content-Type: application/json" --data '{"files": ["https://www.dxfoto.ru/", "https://amp.dxfoto.ru/", "https://www.dxfoto.ru/feed.xml"]}'
