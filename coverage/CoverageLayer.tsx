import React, { useMemo } from "react";
import { Source, Layer } from "react-map-gl";
import * as turf from "@turf/turf";

type Coordinate = { x: number; y: number }; // x: lon, y: lat
type Coverage = {
  centerCoordinate: Coordinate;
  blindCoordinates: Coordinate[];
  detectCoordinates: Coordinate[];
  blindRadius: number;  // meters
  detecRadius: number;  // meters
};

export default function CoverageMergeDetectKeepBlind({
  id = "coverage-merge-detect",
  coverageList,
  steps = 64,
  showPoints = false,
}: {
  id?: string;
  coverageList: Coverage[];
  steps?: number;
  showPoints?: boolean;
}) {
  const {
    detectMergedFC,     // union của toàn bộ detect, đã tách thành nhiều polygon nếu rời nhau
    blindFC,            // tất cả blind (KHÔNG merge)
    detectOutlineFC,    // outline detect union
    blindPtsFC,
    detectPtsFC,
  } = useMemo(() => {
    const detectPolys: turf.Feature<turf.Polygon>[] = [];
    const blindPolys: turf.Feature<turf.Polygon>[] = [];
    const blindPts: turf.Feature<turf.Point>[] = [];
    const detectPts: turf.Feature<turf.Point>[] = [];

    for (const c of coverageList || []) {
      const center: [number, number] = [c.centerCoordinate.x, c.centerCoordinate.y];
      const blind = turf.circle(center, c.blindRadius, { steps, units: "meters" }) as turf.Feature<turf.Polygon>;
      const detect = turf.circle(center, c.detecRadius, { steps, units: "meters" }) as turf.Feature<turf.Polygon>;
      blindPolys.push(blind);
      detectPolys.push(detect);

      if (showPoints) {
        (c.blindCoordinates || []).forEach(p => blindPts.push(turf.point([p.x, p.y], { kind: "blind" })));
        (c.detectCoordinates || []).forEach(p => detectPts.push(turf.point([p.x, p.y], { kind: "detect" })));
      }
    }

    // --- Union TẤT CẢ detect (merge các vùng giao nhau, giữ vùng rời như mảnh riêng) ---
    let merged: turf.Feature<turf.Polygon | turf.MultiPolygon> | null = null;
    for (const poly of detectPolys) {
      try {
        merged = merged ? (turf.union(merged, poly) as any) : poly;
      } catch {
        // nếu union lỗi topo hiếm gặp, fallback: vẽ rời (không crash)
        merged = merged ?? poly;
      }
    }

    // Tách MultiPolygon thành list Polygon để Mapbox hiển thị đủ mọi mảnh (kể cả mảnh rời)
    const detectPieces: turf.Feature<turf.Polygon>[] = [];
    if (merged) {
      turf.flattenEach(merged, (f) => {
        if (f.geometry.type === "Polygon") detectPieces.push(f as turf.Feature<turf.Polygon>);
      });
    }
    const detectMergedFC = turf.featureCollection(detectPieces);
    const detectOutlineFC = detectMergedFC;

    // Blind giữ nguyên (không merge)
    const blindFC = turf.featureCollection(blindPolys);

    return {
      detectMergedFC,
      blindFC,
      detectOutlineFC,
      blindPtsFC: turf.featureCollection(blindPts),
      detectPtsFC: turf.featureCollection(detectPts),
    };
  }, [coverageList, steps, showPoints]);

  // --- Layers ---
  const detectFill: any = {
    id: `${id}-detect-fill`,
    type: "fill",
    paint: { "fill-color": "#16a34a", "fill-opacity": 0.25 },
  };
  const detectOutline: any = {
    id: `${id}-detect-outline`,
    type: "line",
    paint: { "line-color": "#16a34a", "line-width": 2 },
  };

  const blindFill: any = {
    id: `${id}-blind-fill`,
    type: "fill",
    paint: { "fill-color": "#86efac", "fill-opacity": 0.5 },
  };
  const blindOutline: any = {
    id: `${id}-blind-outline`,
    type: "line",
    paint: { "line-color": "#16a34a", "line-width": 1 },
  };

  const blindPtsLayer: any = {
    id: `${id}-blind-pts`,
    type: "circle",
    paint: {
      "circle-radius": 4,
      "circle-color": "#86efac",
      "circle-stroke-width": 1,
      "circle-stroke-color": "#166534",
    },
  };
  const detectPtsLayer: any = {
    id: `${id}-detect-pts`,
    type: "circle",
    paint: {
      "circle-radius": 4,
      "circle-color": "#16a34a",
      "circle-stroke-width": 1,
      "circle-stroke-color": "#14532d",
    },
  };

  return (
    <>
      {/* 1) Detect union (ở dưới) */}
      <Source id={`${id}-detect-src`} type="geojson" data={detectMergedFC}>
        <Layer {...detectFill} />
        <Layer {...detectOutline} />
      </Source>

      {/* 2) Blind (ở trên, không merge) */}
      <Source id={`${id}-blind-src`} type="geojson" data={blindFC}>
        <Layer {...blindFill} />
        <Layer {...blindOutline} />
      </Source>

      {showPoints && (
        <>
          <Source id={`${id}-blind-pts-src`} type="geojson" data={blindPtsFC}>
            <Layer {...blindPtsLayer} />
          </Source>
          <Source id={`${id}-detect-pts-src`} type="geojson" data={detectPtsFC}>
            <Layer {...detectPtsLayer} />
          </Source>
        </>
      )}
    </>
  );
}
