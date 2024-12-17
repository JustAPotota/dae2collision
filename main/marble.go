components {
  id: "marble"
  component: "/main/marble.script"
}
embedded_components {
  id: "model"
  type: "model"
  data: "mesh: \"/builtins/assets/meshes/sphere.dae\"\n"
  "name: \"unnamed\"\n"
  "materials {\n"
  "  name: \"default\"\n"
  "  material: \"/main/model.material\"\n"
  "  textures {\n"
  "    sampler: \"tex0\"\n"
  "    texture: \"/main/assets/marble.png\"\n"
  "  }\n"
  "}\n"
  ""
}
embedded_components {
  id: "collisionobject"
  type: "collisionobject"
  data: "type: COLLISION_OBJECT_TYPE_DYNAMIC\n"
  "mass: 0.1\n"
  "friction: 0.5\n"
  "restitution: 1.0\n"
  "group: \"marbles\"\n"
  "mask: \"world\"\n"
  "mask: \"marbles\"\n"
  "mask: \"reset\"\n"
  "embedded_collision_shape {\n"
  "  shapes {\n"
  "    shape_type: TYPE_SPHERE\n"
  "    position {\n"
  "    }\n"
  "    rotation {\n"
  "    }\n"
  "    index: 0\n"
  "    count: 1\n"
  "  }\n"
  "  data: 0.5\n"
  "}\n"
  ""
}
