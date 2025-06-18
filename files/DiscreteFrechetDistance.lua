----------------------------------------------------------------------
-- Discrete Free-space diagram
-- vibe coded by Omrit Filtser (using chatGPT), June 2025
----------------------------------------------------------------------

label = "Discrete Frechet distance diagram"

about = [[
Computes the discrete free-space diagram for two polygonal curves for
a fixed distance threshold (from length of a selected segment).
You can run two versions: arc-length grid or uniform grid.
Each grid vertex is shown as an X (for distance > eps) or circle (for distance ≤ eps).
]]

function incorrect_input(model,s)
  model:warning("Cannot create free-space diagram", s)
end

function arc_lengths(P)
  local off = {0}
  for i = 1, #P-1 do
    local d = (P[i+1] - P[i]):len()
    off[i+1] = off[i] + d
  end
  return off
end

function uniform_param(P, scale)
  local n = #P
  local L = {}
  for i = 0, n-1 do
    table.insert(L, i * scale)
  end
  return L
end

function compute_grid_coordinates(P, mode, scale)
  if mode == "arc-length" then
    return arc_lengths(P)
  elseif mode == "uniform" then
    return uniform_param(P, scale)
  end
end

function DFSD(model, gridmode)
  local p = model:page()
  local prim = p:primarySelection()
  if not prim then model.ui:explain("no selection") return end

  local seg = p[prim]
  if seg:type() ~= "path" then
     incorrect_input(model,"Primary selection is not a segment")
     return
  end
  local shape = seg:shape()
  if #shape ~= 1 or shape[1].type ~= "curve" or #shape[1] ~= 1 or shape[1][1].type ~= "segment" then
     incorrect_input(model,"Primary selection is not a segment")
     return
  end

  local p0 = seg:matrix() * shape[1][1][1]
  local p1 = seg:matrix() * shape[1][1][2]
  local eps = (p1 - p0):len()

  -- Parse curves
  local curves = {}
  for i,obj,sel,layer in p:objects() do
    if sel == 2 then
      if obj:type() ~= "path" then
        incorrect_input(model,"Some secondary selection is not a path")
        return
      end
      local shape = obj:shape()
      local vertices = {}
      for _,subpath in ipairs(shape) do
        if subpath.type ~= "curve" then
          incorrect_input(model,"Some secondary selection is not a polygonal path")
          return
        end
        for i,s in ipairs(subpath) do
          if s.type ~= "segment" then
            incorrect_input(model,"Some secondary selection is not a polygonal path")
            return
          end
          if #vertices == 0 then
            table.insert(vertices, obj:matrix() * s[1])
          end
          table.insert(vertices, obj:matrix() * s[2])
        end
      end
      table.insert(curves, vertices)
    end
  end

  if #curves ~= 2 then
    incorrect_input(model,"Need exactly two polygonal paths selected")
    return
  end

  local V, W = curves[1], curves[2]

  local sV = compute_grid_coordinates(V, gridmode, eps)
  local sW = compute_grid_coordinates(W, gridmode, eps)
  local extentV = sV[#sV]
  local extentW = sW[#sW]

  -- Draw grid
  local gridshape = {}
  for i, s in ipairs(sV) do
    table.insert(gridshape, {type="curve", closed=false, {type="segment", ipe.Vector(s,0), ipe.Vector(s,extentW)}})
  end
  for j, t in ipairs(sW) do
    table.insert(gridshape, {type="curve", closed=false, {type="segment", ipe.Vector(0,t), ipe.Vector(extentV,t)}})
  end
  local grid = ipe.Path(model.attributes, gridshape)
  grid:set("pathmode", "stroked")

  local rectshape = {{
    type="curve", closed=true,
    {type="segment", ipe.Vector(0,0), ipe.Vector(extentV,0)},
    {type="segment", ipe.Vector(extentV,0), ipe.Vector(extentV,extentW)},
    {type="segment", ipe.Vector(extentV,extentW), ipe.Vector(0,extentW)},
    {type="segment", ipe.Vector(0,extentW), ipe.Vector(0,0)}
  }}
  local boundingrect = ipe.Path(model.attributes, rectshape)
  boundingrect:set("pathmode", "filled", nil, "gray")

  -- Draw symbols
  local symbols = {}
  local size = 0.12 * math.min(extentV / #V, extentW / #W)  -- doubled size

  for i = 1, #V do
    for j = 1, #W do
      local d = (V[i] - W[j]):len()
      local pos = ipe.Vector(sV[i], sW[j])

      if d <= eps then
        local circle = { type="ellipse", ipe.Matrix(size, 0, 0, size, pos.x, pos.y) }
        local disk = ipe.Path(model.attributes, {circle})
        disk:set("pathmode", "strokedfilled", "black", "white")	
        table.insert(symbols, disk)
      else
        local line1 = {type="curve", closed=false, {type="segment", pos + ipe.Vector(-size, -size), pos + ipe.Vector(size, size)}}
        local line2 = {type="curve", closed=false, {type="segment", pos + ipe.Vector(-size, size), pos + ipe.Vector(size, -size)}}
        local cross = ipe.Path(model.attributes, {line1, line2})
        cross:set("pathmode", "stroked")
        cross:set("pen", "0.5")  -- thicker cross
        table.insert(symbols, cross)
      end
    end
  end

  local obj = ipe.Group{boundingrect, grid, ipe.Group(symbols)}
  model:creation("create discrete free-space diagram", obj)
end

methods = {
  { label = "arc-length parameterization", run = function(model) DFSD(model, "arc-length") end },
  { label = "uniform grid", run = function(model) DFSD(model, "uniform") end },
}
