# Groups

A **group** decides which OpenVPN servers its clients get. Instead of ticking servers on every client, put clients in groups: *economy* gets the main server, *premium* gets every server.

## Create a group

**Groups → Create group**: give it a name and pick its servers. **All servers, including ones added later** gives the group every server the panel will ever have, so a new node needs no changes.

## Put clients in groups

- On one client: **Clients → client → Edit → Groups**. 
- On many: select clients in the list, then **Groups**, choose the groups to add to and remove from, and apply. The client list can also be filtered by group.
- New and bulk-created clients can be given groups in the same form.

## How access is decided

- A client in several groups gets **all** their servers.
- A **disabled** group gives nothing. A client whose groups are all disabled has no servers until one is switched back on.
- A client in **no group** keeps the servers it was created with (every server, unless the list was narrowed). Groups are optional and existing clients are unaffected until you use them.
- Deleting a group takes its servers away from the clients that only had them through it. Tunnels already open on a server a client lost are closed within seconds.
