# Opposite-side doorway rule

User direction, 2026-10-24: east exits must arrive on the west of the receiving
room, and north exits on its south, with matching reverse links. No same-side
arrivals or turning/corner teleport connections. This supersedes the bent
vestibule and library-to-dining turning passage used in compact-2.

`assets/mansion/opposite-door-plan.json` records the approved, integrated compact-3 plan.
The foyer becomes a four-door hub, with its north/front entrance locked.

| First room exit | Receiving room entrance |
| --- | --- |
| Foyer west | Library east |
| Foyer east | Main stair hall west |
| Foyer south | Dining north |
| Library south | Kitchen north |
| Dining west | Kitchen east |
| Kitchen south | Basement storage north |
| Main stair hall north/up | Upper landing south |
| Upper landing west | Bedroom east |
| Upper landing east | Study west |

This keeps four main ground-floor rooms, two upstairs and one basement, plus
the stair hall/landing. It adds a ground-floor loop without adding rooms.
Foyer, stair hall, dining room and kitchen need the four draft artwork changes;
the approved library and upper/basement artwork can remain.

The user also requested a fuller foyer: welcome table and fitted rug, period
coat/umbrella furnishings and an upholstered bench, with all four approaches
and the central runner clear. Furniture IDs/contacts must be retraced after approval.

`src/mansion/door_travel.gd` gates automatic crossing on intended movement toward the explicit door side inside its trigger. Physics-step evaluation works even when a wall stops actual velocity. Cooldown, inward arrival facing and cleared movement intent prevent bounce-back. All current rooms enable automatic crossing; E remains an optional fallback.

Approval: user, 2026-10-24, “Looks good to me”. Exact four artwork paths and SHA-256 values are in the batch manifest; preflight verified them before integration. Source PNGs were preserved. Four new furniture sidecars replace stale annotations; contacts are provisional, not approved for seating. Decorative coat/umbrella interaction types remain unassigned.

Layout ID `fixed-manor-compact-3` rejects incompatible earlier saves without deleting them. Start a new case for this layout. Lens is now on the welcome table; the old separate reading stand is hidden. Library art and approved Char seat fits remain unchanged.

Verification: `tools/fixed_mansion_checks.gd` passed 108 checks, walking all 18 directed crossings without interaction keys, safe arrivals, facing, lens/knife inspection and save/load. `tools/first_case_checks.gd` passed 31 checks. Packaged export remains untested. Native captures: `test-results/compact-mansion/index.html`; approval gallery: `assets/rooms/revisions/2026-10-24-opposite-doors/index.html`.
