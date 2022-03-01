# dae2collision
A Defold library for converting DAE meshes to collision objects.

# Installation
You can use dae2collision in your own project by adding it as a Defold library dependency. Open your game.project file and in the dependencies field add:

https://github.com/JustAPotota/dae2collision/archive/master.zip

Or point to the ZIP file of a specific release, like https://github.com/JustAPotota/dae2collision/archive/v1.1.0.zip.

# Usage
This library comes with an [editor script](https://defold.com/manuals/editor-scripts/) (located at [`/dae2collision/d2c.editor_script`](dae2collision/d2c.editor_script)) that adds a context menu option to `.dae` files which uses [d2c.generate_collision](#d2cgenerate_collisiondae_path-properties) to create a game object with collision objects in the shape of the selected mesh. The collision objects are given default properties which will work for many, but not all, games. If you need custom settings for your game, you can simply make a copy of the included editor script or build your own using one of the two functions provided by the [`d2c` module](dae2collision/d2c.lua):

## d2c.generate_collision(dae_path, properties)
Reads the `.dae` file given by `dae_path` and writes the [convex shapes](https://defold.com/manuals/physics-shapes/#convex-hull-shape) from [d2c.shapes_from_string()](#d2cshapes_from_strings) into the same folder. It then generates a game object containing collision objects which use those convex shapes as well as the settings specified in `properties`.

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


## d2c.shapes_from_string(s)
Converts the contents of a `.dae` file to an array of [convex shapes](https://defold.com/manuals/physics-shapes/#convex-hull-shape).

### Parameters
- s: `string` - The contents of a `.dae` file.

### Returns
- shapes: `table` - An array of strings holding the contents of the resulting convex shapes, one per object in the mesh.
