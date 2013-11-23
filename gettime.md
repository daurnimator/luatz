# `luatz.gettime`

A module to get the current time.


## `gettime`

Uses the most accurate method available (in order:)

  - Uses luasocket's `socket.gettime` if available
  - `os.time`
