const express = require("express");
const turf = require("@turf/turf");
const helmet = require("helmet");
const morgan = require("morgan");

const app = express();
app.use(helmet());
app.use(express.json({ limit: "10mb" }));
app.use(morgan("dev"));

/** ======= Helpers ======= **/

function ringFromXY(points) {
  const ring = points.map(p => [p.x, p.y]);
  if (ring.length === 0) return ring;
  const first = ring[0], last = ring[ring.length - 1];
  if (first[0] !== last[0] || first[1] !== last[1]) ring.push([...first]);
  return ring;
}

function polygonFromPoints(points) {
  const ring = ringFromXY(points);
  if (ring.length < 4) return null;
  let poly = turf.polygon([ring]);
  poly = turf.cleanCoords(poly);
  return poly;
}

function circleFrom(center, radius, steps = 64) {
  return turf.circle(center, radius, { steps, units: "meters" });
}

function safeUnion(a, b) {
  if (!a) return b || null;
  if (!b) return a;
  try {
    return turf.union(a, b);
  } catch {
    return a;
  }
}

function safeDifference(a, b) {
  try {
    return turf.difference(a, b);
  } catch {
    return null;
  }
}

function toPointsArray(geom) {
  const out = [];
  if (!geom) return out;
  turf.flattenEach(geom, f => {
    if (f.geometry.type === "Polygon") {
      const coords = f.geometry.coordinates[0];
      for (const [x, y] of coords) {
        out.push({ x, y });
      }
    }
  });
  return out;
}

/** ======= API ======= **/

app.post("/coverage/merge", (req, res) => {
  try {
    const { coverageList, steps = 64 } = req.body || {};
    if (!Array.isArray(coverageList) || coverageList.length === 0) {
      return res.status(400).json({ error: "coverageList is required & non-empty" });
    }

    const detectPolys = [];
    const blindPolys = [];

    for (const c of coverageList) {
      if (!c.centerCoordinate) continue;
      const center = [c.centerCoordinate.x, c.centerCoordinate.y];

      // Detect polygon
      let detectPoly = null;
      if (c.detectCoordinates?.length >= 3)
        detectPoly = polygonFromPoints(c.detectCoordinates);
      else detectPoly = circleFrom(center, c.detectRadius, steps);

      // Blind polygon
      let blindPoly = null;
      if (c.blindCoordinates?.length >= 3)
        blindPoly = polygonFromPoints(c.blindCoordinates);
      else blindPoly = circleFrom(center, c.blindRadius, steps);

      if (detectPoly) detectPolys.push(detectPoly);
      if (blindPoly) blindPolys.push(blindPoly);
    }

    /** ------------------------------
     *  DonutAll = ⋃ (detect_i \ blind_i)
     *  BlindAll = ⋃ blind_i
     *  BlindVisible = BlindAll \ DonutAll
     * ------------------------------ */

    // DonutAll
    let donutAll = null;
    for (let i = 0; i < detectPolys.length; i++) {
      const detect = detectPolys[i];
      const blind = blindPolys[i];
      let diff = safeDifference(detect, blind);
      if (!diff) diff = detect;
      donutAll = safeUnion(donutAll, diff);
    }

    // BlindAll
    let blindAll = null;
    for (const b of blindPolys) {
      blindAll = safeUnion(blindAll, b);
    }

    // BlindVisible = BlindAll \ DonutAll
    let blindVisible = blindAll;
    try {
      blindVisible = donutAll ? turf.difference(blindAll, donutAll) : blindAll;
    } catch {
      // fallback nếu lỗi topo
      blindVisible = blindAll;
    }

    // Union detect lại để trả về detectUnion (gộp toàn bộ detect_i)
    let detectUnionAll = null;
    for (const d of detectPolys) {
      detectUnionAll = safeUnion(detectUnionAll, d);
    }

    // === Convert to point arrays
    const detectUnionPoints = toPointsArray(detectUnionAll);
    const blindVisiblePoints = toPointsArray(blindVisible);

    res.json({
      detectUnion: detectUnionPoints,
      blindVisible: blindVisiblePoints,
    });
  } catch (err) {
    console.error("merge error:", err);
    res.status(500).json({ error: err.message || "Internal error" });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Coverage merge service listening on http://localhost:${PORT}`);
});
