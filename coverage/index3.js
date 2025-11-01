const express = require("express");
const turf = require("@turf/turf");
const helmet = require("helmet");
const morgan = require("morgan");

const app = express();
app.use(helmet());
app.use(express.json({ limit: "10mb" }));
app.use(morgan("dev"));

/** ===== Helpers ===== */

function ringFromXY(points) {
  const ring = points.map(p => [p.x, p.y]);
  if (ring.length === 0) return ring;
  const [fx, fy] = ring[0];
  const [lx, ly] = ring[ring.length - 1];
  if (fx !== lx || fy !== ly) ring.push([fx, fy]);
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
  try { return turf.union(a, b); } catch { return a; }
}

function safeDifference(a, b) {
  try { return turf.difference(a, b); } catch { return null; }
}

/**
 * Convert any (Multi)Polygon geom to:
 * [
 *   [{x,y}, {x,y}, ...],   // polygon 1 (outer ring)
 *   [{x,y}, {x,y}, ...],   // polygon 2 (outer ring)
 *   ...
 * ]
 * - BỎ qua holes để Flutter vẽ đơn giản (nếu cần holes, có thể mở rộng trả về outer/holes)
 */
function geomToPolygonsList(geom) {
  const polys = [];
  if (!geom) return polys;
  turf.flattenEach(geom, f => {
    if (f.geometry?.type === "Polygon" && f.geometry.coordinates?.length > 0) {
      const outer = f.geometry.coordinates[0]; // chỉ outer ring
      polys.push(outer.map(([x, y]) => ({ x, y })));
    }
  });
  return polys;
}

/** ===== API ===== */

app.post("/coverage/merge", (req, res) => {
  try {
    const { coverageList, steps = 64 } = req.body || {};
    if (!Array.isArray(coverageList) || coverageList.length === 0) {
      return res.status(400).json({ error: "coverageList is required & non-empty" });
    }

    const detectPolys = [];
    const blindPolys  = [];

    // 1) Build polygons (ưu tiên points; thiếu thì fallback circle)
    for (const c of coverageList) {
      if (!c?.centerCoordinate) continue;
      const center = [c.centerCoordinate.x, c.centerCoordinate.y];

      let detectPoly = null;
      if (Array.isArray(c.detectCoordinates) && c.detectCoordinates.length >= 3) {
        detectPoly = polygonFromPoints(c.detectCoordinates);
      } else if (typeof c.detectRadius === "number") {
        detectPoly = circleFrom(center, c.detectRadius, steps);
      }

      let blindPoly = null;
      if (Array.isArray(c.blindCoordinates) && c.blindCoordinates.length >= 3) {
        blindPoly = polygonFromPoints(c.blindCoordinates);
      } else if (typeof c.blindRadius === "number") {
        blindPoly = circleFrom(center, c.blindRadius, steps);
      }

      if (detectPoly) detectPolys.push(detectPoly);
      if (blindPoly)  blindPolys.push(blindPoly);
    }

    // 2) DonutAll = ⋃ (detect_i \ blind_i)
    let donutAll = null;
    for (let i = 0; i < detectPolys.length; i++) {
      const diff = safeDifference(detectPolys[i], blindPolys[i]);
      donutAll = safeUnion(donutAll, diff || detectPolys[i]);
    }

    // 3) BlindAll = ⋃ blind_i
    let blindAll = null;
    for (const b of blindPolys) blindAll = safeUnion(blindAll, b);

    // 4) BlindVisible = BlindAll \ DonutAll
    let blindVisible = blindAll;
    try {
      blindVisible = donutAll ? turf.difference(blindAll, donutAll) : blindAll;
    } catch {
      blindVisible = blindAll;
    }

    // 5) detectUnion = ⋃ detect_i
    let detectUnionAll = null;
    for (const d of detectPolys) detectUnionAll = safeUnion(detectUnionAll, d);

    // 6) Trả về dạng mảng các polygon (mỗi polygon là mảng điểm {x,y})
    res.json({
      detectUnion: geomToPolygonsList(detectUnionAll),
      blindVisible: geomToPolygonsList(blindVisible),
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
