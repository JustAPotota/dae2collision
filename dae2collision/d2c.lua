local xml2lua = require("dae2collision.xml2lua.xml2lua")
local xmltree = require("dae2collision.xml2lua.tree")

local M = {}

-- Split a string into an array by spaces
local function split(s)
	local t = {}
	for w in s:gmatch("[^%s]+") do
		table.insert(t, w)
	end
	return t
end

local function find_by_attribute(array, attr_name, value)
	for i,v in ipairs(array) do
		if v._attr[attr_name] == value then
			return v
		end
	end
end

-- We don't have vmath.* when running from an editor script
local function vector3(x, y, z) return {x = x, y = y, z = z} end

local function build_verts(positions, up_axis)
	local verts = {}
	for i = 1,#positions,3 do
		if up_axis == "Z_UP" then
			-- x, z, -y
			table.insert(verts, vector3(positions[i+0], positions[i+2], -positions[i+1]))
		elseif up_axis == "X_UP" then
			-- -y, x, z
			table.insert(verts, vector3(-positions[i+1], positions[i+0], positions[i+2]))
		else
			-- x, y, z
			table.insert(verts, vector3(positions[i+0], positions[i+1], positions[i+2]))
		end
	end

	return verts
end

local function build_tris(p)
	local tris = {}
	for i = 1,#p,9 do
		table.insert(tris, {p[i]+1, p[i+3]+1, p[i+6]+1})
	end

	return tris
end

local function build_convexshape(verts)
	local out = "shape_type: TYPE_HULL"
	for _,vert in ipairs(verts) do
		out = out .. ("\ndata: %f data: %f data: %f"):format(vert.x, vert.y, vert.z)
	end

	return out
end

local function parse_xml(s)
	local handler = xmltree:new()
	local parser = xml2lua.parser(handler)
	parser:parse(s)
	return handler
end

function M.shapes_from_string(s)
	local xml = parse_xml(s)

	local geometries = xml.root.COLLADA.library_geometries.geometry
	local up_axis = xml.root.COLLADA.asset.up_axis

	-- Make sure geometries is an array
	if geometries[1] == nil then
		geometries = {geometries}
	end

	local shapes = {}
	for i,geometry in ipairs(geometries) do
		local mesh = geometry.mesh
		if mesh.triangles then
			local positions_id = mesh.vertices.input._attr.source:sub(2)

			-- An array of vertex positions in the format: {x1, y1, z1, x2, y2, z2, ...}
			local positions = split(find_by_attribute(mesh.source, "id", positions_id).float_array[1])

			local verts = build_verts(positions, up_axis)

			table.insert(shapes, build_convexshape(verts))
		else
			print("No triangles found for " .. geometry._attr.name .. ", skipping...")
		end
	end

	return shapes
end


-- Editor script helpers --
local function read(path)
	local file = assert(io.open(path, "r"))
	local data = file:read("*a")
	file:close()
	return data
end

local function write(path, data)
	local file = assert(io.open(path, "w"))
	file:write(data)
	file:close()
end

--[[
`properties` example:
{
	type = "COLLISION_OBJECT_TYPE_STATIC",
	mass = 1,
	friction = 0.1,
	restitution = 0.5,
	linear_damping = 0,
	angular_damping = 0,
	locked_rotation = false,
	bullet = false,
	group = "world",
	mask = "player,enemies"
}
]]--
function M.generate_collision(dae_path, properties)
	local name = dae_path:sub(2,-5)
	local shapes = M.shapes_from_string(read(dae_path:sub(2)))
	local digits = #tostring(#shapes)

	local out = ""
	for i,v in ipairs(shapes) do
		-- Write convex shape
		local shape_path = name .. "_" .. ("%0" .. digits .. "i"):format(i) .. ".convexshape"
		write(shape_path, v)

		-- Add collision object to game object
		out = out .. ([[embedded_components {
  id: "collisionobject]] .. i .. [["
  type: "collisionobject"
  data: "collision_shape: \"/]] .. shape_path .. [[\"\n"
  "type: %s\n"
  "mass: %f\n"
  "friction: %f\n"
  "restitution: %f\n"
  "group: \"%s\"\n"
  "mask: \"%s\"\n"
  "linear_damping: %f\n"
  "angular_damping: %f\n"
  "locked_rotation: %s\n"
  "bullet: %s\n"
  ""
  position {
    x: 0.0
    y: 0.0
    z: 0.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
]]):format(
			properties.type,
			properties.mass,
			properties.friction,
			properties.restitution,
			properties.group,
			properties.mask,
			properties.linear_damping,
			properties.angular_damping,
			properties.locked_rotation and "true" or "false",
			properties.bullet and "true" or "false"
		)
	end

	write(name .. "_generated.go", out)
	print("[D2C] Generated collision for " .. dae_path)
end

return M