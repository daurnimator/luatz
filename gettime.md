# `luatz.gettime`

A module to get the current time.


## `gettime ( )`

Uses the most precise method available (in order:)

  - luasocket's `socket.gettime`
  - `os.time`
