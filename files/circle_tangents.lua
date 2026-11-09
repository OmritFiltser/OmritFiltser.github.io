-- Circle Tangents -- Ipe 7 Lua ipelet.
-- Install this file in an Ipelets folder and restart Ipe.
-- Select a circle and a point mark, or two circles, in either order.
-- Choose the corresponding function under Ipelets > Circle Tangents.
-- The two segments are grouped; Ungroup lets you edit them separately.

label = "Circle Tangents"

about = [[
Three constructions, with inputs selected in either order:
1. Point to circle: select one circle and one point mark outside it.
2. Outer tangents: select two circles; neither may contain the other
   or touch it internally. Intersecting circles are allowed.
3. Internal (crossing) tangents: select two disjoint circles whose
   boundaries do not touch.

Draws segments between the tangency points (or from the point to each
tangency point), using the current stroke color, pen width, and dash style.
The segments form one group and can be undone in one step.

Requires two distinct tangents. Ungroup grouped inputs first.
Moved, rotated, reflected, and uniformly scaled circles are supported.
Noncircular ellipses and degenerate circles are rejected.
]]

local function finite(x)
  return x == x and math.abs(x) < math.huge
end

local function circle_geometry(obj)
  local shape = obj:shape()
  if #shape ~= 1 or shape[1].type ~= "ellipse" then
    return nil, nil, "Select a complete circle, not an arc or another path."
  end

  -- Both the ellipse matrix and the object's transformation matter.
  local m = obj:matrix() * shape[1][1]
  local a = m:elements()
  local u, v = ipe.Vector(a[1], a[2]), ipe.Vector(a[3], a[4])
  local ru, rv = u:len(), v:len()
  if not finite(ru) or not finite(rv) or ru == 0 or rv == 0
      or not finite(a[5]) or not finite(a[6]) then
    return nil, nil, "The circle has zero radius or invalid coordinates."
  end

  -- A transformed unit circle is circular precisely when its two
  -- matrix columns have equal lengths and are perpendicular.
  local tolerance = 1e-9
  if math.abs(ru - rv) > tolerance * math.max(ru, rv)
      or math.abs(((1 / ru) * u) ^ ((1 / rv) * v)) > tolerance then
    return nil, nil, "The selected ellipse is not a circle."
  end
  return ipe.Vector(a[5], a[6]), 0.5 * ru + 0.5 * rv
end

local function segment(attributes, p, q)
  local obj = ipe.Path(attributes, {
    { type = "curve", closed = false,
      { type = "segment", p, q } },
  })
  -- Segments must remain visible even when the UI is set to fill only.
  obj:set("pathmode", "stroked")
  return obj
end

local function selected_objects(model)
  local selected = {}
  for _, obj, sel in model:page():objects() do
    if sel then selected[#selected + 1] = obj end
  end
  return selected
end

local function point_to_circle(model)
  local selected = selected_objects(model)
  if #selected ~= 2 then
    model:warning("Select exactly one circle and one point mark.")
    return
  end

  local circle, mark
  for _, obj in ipairs(selected) do
    if obj:type() == "path" then
      circle = obj
    elseif obj:type() == "reference"
        and obj:symbol():sub(1, 5) == "mark/" then
      mark = obj
    end
  end
  if not circle or not mark then
    model:warning("Select one circle and one point made with the Mark tool.",
                  "Ungroup grouped objects before running this ipelet.")
    return
  end

  local c, r, err = circle_geometry(circle)
  if not c then model:warning(err) return end
  local p = mark:matrix() * mark:position()
  local delta = p - c
  local d = delta:len()
  if not finite(d) then
    model:warning("The point has invalid coordinates.")
    return
  end
  local tolerance = 1e-10 * math.max(r, d)
  if d < r - tolerance then
    model:warning("The point is inside the circle; no real tangents exist.")
    return
  elseif d <= r + tolerance then
    model:warning("The point is on or too close to the circle.",
                  "Two distinct tangents require a point outside the circle.")
    return
  end

  -- Unit radial direction e and perpendicular n:
  -- T = C + r (r/d) e +/- r sqrt(1 - (r/d)^2) n.
  -- Factoring 1-q^2 improves accuracy near the boundary.
  local e = (1 / d) * delta
  local q = r / d
  local base = c + (r * q) * e
  local offset = (r * math.sqrt((1 - q) * (1 + q))) * e:orthogonal()
  local t1, t2 = base + offset, base - offset
  local tangents = ipe.Group({
    segment(model.attributes, p, t1),
    segment(model.attributes, p, t2),
  })
  model:creation("draw two tangents to circle", tangents)
end

local function circle_to_circle(model, crossing)
  local selected = selected_objects(model)
  if #selected ~= 2 then
    model:warning("Select exactly two circles.")
    return
  end
  for _, obj in ipairs(selected) do
    if obj:type() ~= "path" then
      model:warning("Select exactly two circles.",
                    "Ungroup grouped objects before running this ipelet.")
      return
    end
  end
  local c1, r1, err1 = circle_geometry(selected[1])
  if not c1 then model:warning(err1) return end
  local c2, r2, err2 = circle_geometry(selected[2])
  if not c2 then model:warning(err2) return end

  local delta = c2 - c1
  local d = delta:len()
  -- Outer tangents put both centers on the same side of the line;
  -- internal tangents put them on opposite sides.
  local sign = crossing and -1 or 1
  local difference = r1 - sign * r2
  if not finite(d) or not finite(difference) then
    model:warning("The circles have invalid or excessively large coordinates.")
    return
  end
  local tolerance = 1e-10 * math.max(d, r1, r2)
  if d <= tolerance then
    model:warning("The circles have the same or nearly the same center.",
                  "Two distinct common tangent segments cannot be constructed.")
    return
  end
  local limit = math.abs(difference)
  if d < limit - tolerance then
    if crossing then
      model:warning("Internal tangents require two separate circles.",
                    "These circles overlap or one contains the other.")
    else
      model:warning("One circle contains the other; no outer tangents exist.")
    end
    return
  elseif d <= limit + tolerance then
    model:warning("The circles touch or are too close to tangency.",
                  "This construction requires two distinct tangent segments.")
    return
  end

  -- A unit normal n must satisfy delta dot n = r1 - sign*r2.
  -- Its two solutions give the contact points on both circles.
  local e = (1 / d) * delta
  local q = difference / d
  local side = math.sqrt((1 - q) * (1 + q)) * e:orthogonal()
  local n1, n2 = q * e + side, q * e - side
  local tangents = ipe.Group({
    segment(model.attributes, c1 + r1 * n1, c2 + (sign * r2) * n1),
    segment(model.attributes, c1 + r1 * n2, c2 + (sign * r2) * n2),
  })
  model:creation(crossing and "draw two internal circle tangents"
                            or "draw two outer circle tangents", tangents)
end

function run(model, num)
  if num == 2 then
    circle_to_circle(model, false)
  elseif num == 3 then
    circle_to_circle(model, true)
  else
    point_to_circle(model)
  end
end

methods = {
  { label = "Point to circle" },
  { label = "Outer tangents of two circles" },
  { label = "Internal (crossing) tangents of two circles" },
}
