# Remaining co-op validation and feature gaps

1. Nemesis: shared choices, empower/banish, player item containers and reward/progression transactions need a dedicated authority protocol. Object visibility replication alone is insufficient.
2. Shrine: different offline PCG placement/types, absent matching shrine, variants without CastAtPointInteraction, and late-join buff duration need authoritative encounter data. Current replay only handles recognized matching/nearby native shrines.
3. Crowd control: real two-PC stun/freeze/immune-boss behavior and local damage bonuses must be tested. General ailments, leech/cull attribution and other proc state are not fully authoritative.
4. Aerial/scripted monster appearances: visual-position replication is implemented; custom scene scripts and actor-specific sequences remain unverified.
5. Cosmetic aura/footprint variants: prefab identity is replicated; custom native visual scripts, bone bindings and exact step timing/lifetime are not fully covered.
6. Performance: corpse history and dead-actor sampling are bounded, and locally loaded template data is reused. Real Guest FPS, packet-to-presentation delay and cold native asset/spawn hitches remain unmeasured.
7. Reward errors: room disconnect is prevented and a missing dying reference is initialized. A partially failed native grant is not automatically retried; validate actual loot/XP on fresh replicas.
8. More than 512 concurrent world records remains a protocol budget. Long maps can exceed 512 lifetime identities, but an excessive simultaneous wave/death burst can exceed presentation/reward coverage.
9. Previous Gift items are not automatically rewritten. Verify new gifts with affixes, uniques/LP, memories and crafting changes, including inventory take-out/reload.
