# Entities Protection

Protects entities from other players inside protected areas in Minetest. This mod ensures that only the owners of an area (or those with the appropriate permissions) can interact with entities within it.

## Features

- Protects entities inside a protected area from being damaged by players who do not own the area.
- Configurable settings to exclude specific types of entities or individual entities from protection.

## Configuration

The mod includes configurable settings to customize its behavior. These settings can be adjusted in the `minetest.conf` file or through the Minetest settings menu.

### Settings

1. **Exclude Monsters**: Choose whether to exclude all entities of type "monster" from protection.

   ```
   entities_protection.exclude_monsters (Exclude monsters from protection) bool true
   ```

2. **Excluded Entities List**: Specify a comma-separated list of entity names that should be excluded from protection.

   ```
   entities_protection.excluded_entities (List of entities to exclude from protection) string ""
   ```

   Example: `entities_protection.excluded_entities = "mobs:sheep, mobs:creeper"`

## Usage

- Install the mod in your Minetest environment.
- Configure the settings as needed.
- Entities within protected areas will be protected from damage by players who are not the area owners, subject to the configuration settings.
- To exclude specific entities or entity types (like monsters), adjust the settings in the `minetest.conf` file or through the Minetest settings menu.

## License

This project is under the GPLv3-or-later license. For more information, see the [LICENSE](./LICENSE) file.
