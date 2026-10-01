---
when: wakatime-cli
maps:
  ~/.wakatime.cfg: private.cfg
---

# Wakatime Config

`private.cfg` is the mapped source but is gitignored — on a fresh clone the map is skipped with a warning. Bootstrap: `cp config.cfg private.cfg`, then add your api key.
