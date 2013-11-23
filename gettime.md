# `luatz.gettime`

A module to get the current time.


## `gettime ( )`

Uses the most accurate method available (in order:)

  - luasocket's `socket.gettime`
  - `os.time`
