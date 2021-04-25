# Snuflake

Snuflake creates IDs on the fly.

`iex -S mix` with run `Snuflake.Application.start()` with no commands.

`Snuflake.Application.start()` initializes the node with an id of 0.

or

`Snuflake.Application.start([], node_id: node_id)` where node_id is any value between 0 to 1023.

`Snuflake.Application.get_id()` to get an id with no error checking.

`Snuflake.Application.get_id(previous_id)` to get an id with error checking.

### Breakdown of pattern

Timestamp - 41 bits

`10111100011111110010110101101101000101000`

Ids per node per millisecond - 13

`0000000000000`

Node - 10

`1000000000`

Put them altogether for 64 bits and turn it back into an integer again.

Something like this: `13583691495168278528`