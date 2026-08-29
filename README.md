# Javier's Profilarr Database

[TRaSH Guides](https://trash-guides.info) profiles converted to PCD format for
[Profilarr](https://github.com/Dictionarry-Hub/profilarr), with Javier's custom
Spanish-friendly release preferences.

This repository is based on
[Dictionarry-Hub/trash-pcd](https://github.com/Dictionarry-Hub/trash-pcd).

## Customizations

- Prefer BTM, BEN THE MEN, LatTeam, SyncTeam, and SMS releases with a custom
  format score of `2000` in Radarr and Sonarr profiles.
- Use release-title fallbacks when an Arr application does not parse the
  release group.
- Do not penalize BTM or BEN THE MEN through the upstream LQ formats.
- Keep the combined 2160p Sonarr profile's Remux, Bluray, and WEB ladder. This
  behavior is now included in the upstream v2 database.

## Branches

| Branch | Description |
|--------|-------------|
| `v2` | Default Profilarr v2-compatible database with customizations |
| `stable` | Preserved legacy Profilarr v1 database |

## Usage

Add this repository as a database in Profilarr:
```
https://github.com/JavierOchoa/profilarr-db
```

Leave the **Branch** field empty to use the default `v2` branch. The `stable`
branch is retained only as a backup for Profilarr v1 and is not compatible with
Profilarr v2.

## Credits

The base configurations are made by the TRaSH Guides team and converted to PCD
by the Dictionarry team. The Spanish Priority operation is maintained in this
repository.

## License

MIT - Same as [TRaSH Guides](https://github.com/TRaSH-Guides/Guides/blob/master/LICENSE)

## Links

- [TRaSH Guides](https://trash-guides.info)
- [Profilarr](https://github.com/Dictionarry-Hub/profilarr)
- [Schema Reference](https://github.com/Dictionarry-Hub/schema)
