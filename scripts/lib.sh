#!/usr/bin/env bash
# Shared library for install.sh, link.sh, and scripts/setup.d/*.sh.
# Sourced, never executed. bash >= 3.2 compatible. No `set -e` here — callers set their own.

# ---------------------------------------------------------------------------
# Frontmatter (schema v2: root maps/when; dest = string | block src/os/copy/when)
# ---------------------------------------------------------------------------

# fm_read <readme> <key> — print root scalar value for <key> ("" if absent)
fm_read() {
  [ -f "$1" ] || return 1
  awk -v want="$2" '
    NR==1 && $0=="---" { f=1; next }
    f && $0=="---" { exit }
    f && index($0, want ":")==1 { sub(/^[^:]*:[ \t]*/, ""); print; exit }
  ' "$1"
}

# fm_entries <readme> — one mapping per line, TAB-separated:
#   dest <TAB> src <TAB> os <TAB> copy <TAB> when      (empty field = unset)
# Exit 1 + "file: reason" on stderr for any schema violation.
fm_entries() {
  [ -f "$1" ] || { echo "$1: not found" >&2; return 1; }
  awk -v FN="$1" '
    function e(msg) { printf "%s: %s\n", FN, msg > "/dev/stderr"; bad=1; exit 1 }
    function flush() {
      if (pend != "") {
        if (bsrc == "") e("block entry missing src: " pend)
        printf "%s\t%s\t%s\t%s\t%s\n", pend, bsrc, bos, bcopy, bwhen
        pend=""; bsrc=""; bos=""; bcopy=""; bwhen=""
      }
    }
    NR==1 {
      if ($0 != "---") e("frontmatter must start with --- on line 1")
      infm=1; next
    }
    infm && $0=="---" { infm=0; closed=1; exit }
    infm {
      line=$0
      if (line ~ /^  ~/) {                       # dest line (2-space indent)
        flush()
        rest=substr(line,3)
        if (rest ~ /\{/) e("inline object form forbidden: " rest)
        i=index(rest, ":")
        if (i==0) e("dest line missing colon: " line)
        dest=substr(rest,1,i-1); val=substr(rest,i+1); sub(/^[ \t]+/,"",val)
        if (dest !~ /^~\//) e("dest must start with ~/.: " dest)
        if (dest in seen) e("duplicate dest: " dest)
        seen[dest]=1
        if (val=="") pend=dest                   # block entry begins
        else printf "%s\t%s\t\t\t\n", dest, val  # string entry
      } else if (line ~ /^    /) {               # 4-space: block qualifier
        if (pend=="") e("qualifier outside a block entry: " line)
        rest=substr(line,5)
        i=index(rest,":")
        if (i==0) e("malformed qualifier line: " line)
        key=substr(rest,1,i-1); val=substr(rest,i+1); sub(/^[ \t]+/,"",val)
        if (key=="src") bsrc=val
        else if (key=="os") {
          if (val !~ /^\[(macos|linux|windows)(, *(macos|linux|windows))*\]$/) e("bad os list: " val)
          bos=val
        } else if (key=="copy") {
          if (val!="true" && val!="false") e("copy must be true|false: " val)
          bcopy=val
        } else if (key=="when") {
          if (val=="" || val ~ /[][]/) e("when must be a scalar command: " val)
          bwhen=val
        } else e("unknown block key: " key)
      } else if (line ~ /^[A-Za-z_][A-Za-z0-9_]*:/) {   # root key
        flush()
        i=index(line,":"); key=substr(line,1,i-1); val=substr(line,i+1); sub(/^[ \t]+/,"",val)
        if (key=="maps") { if (val!="") e("maps: takes no inline value"); hasmaps=1 }
        else if (key=="when") {
          if (val=="" || val ~ /[][]/) e("root when must be a scalar command: " val)
          rootwhen=1
        } else e("unknown root key: " key)
      } else if (line ~ /^[ \t]*$/) next
      else e("unrecognized frontmatter line: " line)
    }
    END {
      if (bad) exit 1
      if (!closed) e("unterminated frontmatter (missing closing ---)")
      flush()
      if (!hasmaps) e("maps: section required (root when is only valid alongside maps)")
    }
  ' "$1"
}
