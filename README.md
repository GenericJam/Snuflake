# Snuflake

Snuflake creates IDs on the fly.

`Snuflake.Application.start()` initializes the node with an id from 0 to 1023.

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