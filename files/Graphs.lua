----------------------------------------------------------------------
-- Graphs ipelet
-- vibe coded by Omrit Filtser (using chatGPT), June 2025
----------------------------------------------------------------------

label = "Graphs"
about = "Nearest Neighbor Graph, Minimum Spanning Tree, Delaunay Graph, or Unit Disk Graph"

---------------------------------------------------------------------
-- Utility Functions

function distance(p, q)
  return (p - q):len()
end

function orient2D(a, b, c)
  return (b.x - a.x)*(c.y - a.y) - (b.y - a.y)*(c.x - a.x)
end

function isDegenerate(a, b, c)
  return math.abs(orient2D(a, b, c)) < 1e-10
end

function inCircle(a, b, c, p)
  local orientation = orient2D(a, b, c)
  if math.abs(orientation) < 1e-10 then
    return false
  end

  local ax, ay = a.x - p.x, a.y - p.y
  local bx, by = b.x - p.x, b.y - p.y
  local cx, cy = c.x - p.x, c.y - p.y

  local a2 = ax*ax + ay*ay
  local b2 = bx*bx + by*by
  local c2 = cx*cx + cy*cy

  local det = a2 * (bx * cy - cx * by)
            - b2 * (ax * cy - cx * ay)
            + c2 * (ax * by - bx * ay)

  if orientation > 0 then
    return det > 1e-10
  else
    return det < -1e-10
  end
end

---------------------------------------------------------------------
-- Graph Computation Functions

function nearestNeighborGraph(points)
  local V = #points
  local neighbors = {}

  for i = 1, V do
    local minDist = math.huge
    local nearest = -1
    local pointU = points[i]

    for j = 1, V do
      if i ~= j then
        local dist = distance(pointU, points[j])
        if dist < minDist then
          minDist = dist
          nearest = j
        end
      end
    end

    neighbors[i] = nearest
  end

  return neighbors
end

function computeMST(points)
  local n = #points
  local edges = {}

  local selected = {}
  local minEdge = {}
  local dist = {}
  for i = 1, n do dist[i] = math.huge end
  dist[1] = 0

  for count = 1, n do
    local u = -1
    for i = 1, n do
      if not selected[i] and (u == -1 or dist[i] < dist[u]) then
        u = i
      end
    end

    selected[u] = true
    if minEdge[u] then
      table.insert(edges, {u, minEdge[u]})
    end

    for v = 1, n do
      if not selected[v] then
        local d = distance(points[u], points[v])
        if d < dist[v] then
          dist[v] = d
          minEdge[v] = u
        end
      end
    end
  end

  return edges
end

function delaunayEdges(points)
  local n = #points
  local edges = {}
  local edgeSet = {}

  local function addEdge(i, j)
    local key = (i < j) and (i .. "-" .. j) or (j .. "-" .. i)
    if not edgeSet[key] then
      edgeSet[key] = true
      table.insert(edges, {i, j})
    end
  end

  for i = 1, n - 2 do
    for j = i + 1, n - 1 do
      for k = j + 1, n do
        if not isDegenerate(points[i], points[j], points[k]) then
          local valid = true
          for l = 1, n do
            if l ~= i and l ~= j and l ~= k then
              if inCircle(points[i], points[j], points[k], points[l]) then
                valid = false
                break
              end
            end
          end
          if valid then
            addEdge(i, j)
            addEdge(j, k)
            addEdge(k, i)
          end
        end
      end
    end
  end

  return edges
end

function computeUDG(points, unitLength)
  local edges = {}
  for i = 1, #points do
    for j = i + 1, #points do
      if distance(points[i], points[j]) <= unitLength then
        table.insert(edges, {i, j})
      end
    end
  end
  return edges
end

---------------------------------------------------------------------
-- Geometry and Selection

function getSelectedPoints(model)
  local points = {}
  local p = model:page()
  if not p:hasSelection() then
    model:warning("No selection found. Please select at least two points.")
    return
  end

  for _, obj, sel, _ in p:objects() do
    if sel and obj:type() == "reference" then
      local pt = obj:matrix() * obj:position()
      table.insert(points, pt)
    end
  end

  if #points < 2 then
    model:warning("Please select at least two points.")
    return
  end

  return points
end

function getSelectedPointsAndSegment(model)
  local points = {}
  local segment = nil
  local p = model:page()
  if not p:hasSelection() then
    model:warning("No selection found. Please select points and one segment.")
    return
  end

  for _, obj, sel, _ in p:objects() do
    if sel then
      if obj:type() == "reference" then
        local pt = obj:matrix() * obj:position()
        table.insert(points, pt)

      elseif obj:type() == "path" then
        local shape = obj:shape()
        if #shape == 1 and shape[1].type == "curve" and #shape[1] == 1 then
          local seg = shape[1][1]
          if seg.type == "segment" then
            if segment then
              model:warning("Multiple segments selected. Please select only one segment.")
              return
            end
            local mtx = obj:matrix()
            segment = { mtx * seg[1], mtx * seg[2] }
          end
        end
      end
    end
  end

  if not segment then
    model:warning("No segment selected. Please select exactly one segment.")
    return
  end

  if #points < 2 then
    model:warning("Please select at least two points.")
    return
  end

  return points, segment
end

---------------------------------------------------------------------
-- Drawing Function

function drawEdges(model, points, edges, title)
  local paths = {}
  for _, edge in ipairs(edges) do
    local i, j = edge[1], edge[2]
    local segment = {type = "segment", points[i], points[j]}
    local shape = {type = "curve", closed = false, segment}
    local path = ipe.Path(model.attributes, {shape})
    table.insert(paths, path)
  end
  model:creation(title, ipe.Group(paths))
end

---------------------------------------------------------------------
-- Ipelet Methods

methods = {
  {
    label = "Nearest Neighbor Graph",
    run = function(model)
      local points = getSelectedPoints(model)
      if not points then return end
      local neighbors = nearestNeighborGraph(points)
      local edges = {}
      for i, j in ipairs(neighbors) do
        if j ~= -1 then
          table.insert(edges, {i, j})
        end
      end
      drawEdges(model, points, edges, "Create Nearest Neighbor Graph")
    end
  },
  {
    label = "Minimum Spanning Tree",
    run = function(model)
      local points = getSelectedPoints(model)
      if not points then return end
      local edges = computeMST(points)
      drawEdges(model, points, edges, "Create Minimum Spanning Tree")
    end
  },
  {
    label = "Delaunay Graph",
    run = function(model)
      local points = getSelectedPoints(model)
      if not points then return end
      local edges = delaunayEdges(points)
      drawEdges(model, points, edges, "Create Delaunay Graph")
    end
  },
  {
    label = "Unit Disk Graph",
    run = function(model)
      local points, segment = getSelectedPointsAndSegment(model)
      if not points then return end
      local unitLength = distance(segment[1], segment[2])
      local edges = computeUDG(points, unitLength)
      drawEdges(model, points, edges, "Create Unit Disk Graph")
    end
  }
}
