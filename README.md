# dae2collision
A Defold library for converting DAE meshes to collision objects.

# Installation
You can use dae2collision in your own project by adding it as a Defold library dependency. Open your game.project file and in the dependencies field add:

https://github.com/JustAPotota/dae2collision/archive/master.zip

Or point to the ZIP file of a specific release, like https://github.com/JustAPotota/dae2collision/archive/v1.0.zip.

# Usage
The [`d2c` module](dae2collision/d2c.lua) exposes two functions intended to be used in an [editor script](https://defold.com/manuals/editor-scripts/):

## d2c.shapes_from_string(s)
Converts the contents of a `.dae` file to an array of [convex shapes](https://defold.com/manuals/physics-shapes/#convex-hull-shape).

### Parameters
- s: `string` - The contents of a `.dae` file.

### Returns
- shapes: `table` - An array of strings holding the contents of the resulting convex shapes, one per object in the mesh.


## d2c.generate_collision(dae_path, properties)
Reads the `.dae` file given by `dae_path` and writes the convex shapes from [d2c.shapes_from_string()](#d2cshapes_from_strings) into the same folder. It also creates a game object containing collision objects with the shape set to one of the convex shapes and its properties set to `properties`.

### Parameters
- dae_path: `string` - The project path to a `.dae` file.
- properties: `table` - A table with settings to be applied to the generated collision objects. Its structure is as follows:
  - mass: `number`
  - friction: `number`
  - restitution: `number`
  - linear_damping: `number`
  - angular_damping: `number`
  - locked_rotation: `bool`
  - bullet: `bool`
  - group: `string`
  - mask: `string`
  - type: `string` - The type of collision object. Can be `COLLISION_OBJECT_TYPE_DYNAMIC`, `COLLISION_OBJECT_TYPE_KINEMATIC`, `COLLISION_OBJECT_TYPE_STATIC`, or `COLLISION_OBJECT_TYPE_TRIGGER`

# Example
Here's an example of an editor script that creates a "Generate Collision" option when right-clicking a `.dae` file:
```lua
local d2c = require("dae2collision.d2c")

local M = {}

local function get_extension(path)
    return path:match("%.(%w+)$")
end

function M.get_commands()
    return {
        {
            label = "Generate Collision",
            locations = {"Edit", "Assets"},
            query = {
                selection = {type = "resource", cardinality = "one"}
            },
            active = function(opts)
                return get_extension(editor.get(opts.selection, "path")) == "dae"
            end,
            run = function(opts)
                local path = editor.get(opts.selection, "path")
                d2c.generate_collision(path, {
                    type = "COLLISION_OBJECT_TYPE_STATIC",
                    mass = 0,
                    friction = 0.1,
                    restitution = 0.5,
                    linear_damping = 0,
                    angular_damping = 0,
                    locked_rotation = false,
                    bullet = false,
                    group = "world",
                    mask = "marbles"
                })
            end
        }
    }
end

return M
```
