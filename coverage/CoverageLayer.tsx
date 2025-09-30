import React, { useMemo } from "react";
import { Source, Layer } from "react-map-gl";
import * as turf from "@turf/turf";
// ⬇️ nhớ cài: npm i @turf/dissolve
import dissolve from "@turf/dissolve";

type Coordinate = { x: number; y: number }; // x: lon, y: lat
type Coverage = {
  centerCoordinate: Coordinate;
  blindCoordinates: Coordinate[];   // (không bắt buộc dùng để merge)
  detectCoordinates: Coordinate[];  // (không bắt buộc dùng để merge)
  blindRadius: number;   // meters
  detecRadius: number;   // meters
};

export default function CoverageMergedLayer({
  id = "coverage-merged",
  coverageList,
  steps = 64,
  showPoints = false
}: {
  id?: string;
  coverageList: Coverage[];
  steps?: number;
  showPoints?: boolean;
}) {
  const {
    donutFC,       // unionDetect \ unionBlind
    blindUnionFC,  // union blind (màu #86efac)
    detectOutlineFC,
    blindPtsFC,
    detectPtsFC
  } = useMemo(() => {
    // 1) tạo các vòng tròn
    const blindPolys: turf.Feature<turf.Polygon>[] = [];
    const detectPolys: turf.Feature<turf.Polygon>[] = [];
    const blindPts: turf.Feature<turf.Point>[] = [];
    const detectPts: turf.Feature<turf.Point>[] = [];

    for (const c of coverageList || []) {
      const center: [number, number] = [c.centerCoordinate.x, c.centerCoordinate.y];
      const blind = turf.circle(center, c.blindRadius, { steps, units: "meters" }) as turf.Feature<turf.Polygon>;
      const detect = turf.circle(center, c.detecRadius, { steps, units: "meters" }) as turf.Feature<turf.Polygon>;
      // Đặt thuộc tính để dissolve theo lớp
      blind.properties = { layer: "blind" };
      detect.properties = { layer: "detect" };
      blindPolys.push(blind);
      detectPolys.push(detect);

      if (showPoints) {
        (c.blindCoordinates || []).forEach(p => blindPts.push(turf.point([p.x, p.y], { kind: "blind" })));
        (c.detectCoordinates || []).forEach(p => detectPts.push(turf.point([p.x, p.y], { kind: "detect" })));
      }
    }

    // 2) gộp mỗi lớp
    const blindFC = turf.featureCollection(blindPolys);
    const detectFC = turf.featureCollection(detectPolys);

    const blindUnion = blindPolys.length > 0 ? dissolve(blindFC, { propertyName: "layer" }) : turf.featureCollection([]);
    const detectUnion = detectPolys.length > 0 ? dissolve(detectFC, { propertyName: "layer" }) : turf.featureCollection([]);

    // dissolve trả FC theo nhóm; lấy tất cả features layer="blind"/"detect"
    const blindUnionFeature =
      (blindUnion as turf.FeatureCollection).features.find(f => f.properties?.layer === "blind") ??
      (blindPolys[0] ? blindPolys[0] : null);

    const detectUnionFeature =
      (detectUnion as turf.FeatureCollection).features.find(f => f.properties?.layer === "detect") ??
      (detectPolys[0] ? detectPolys[0] : null);

    // 3) donut = detectUnion \ blindUnion
    let donutFeature: turf.Feature<turf.Polygon | turf.MultiPolygon> | null = null;
    try {
      if (detectUnionFeature) {
        donutFeature = blindUnionFeature
          ? (turf.difference(detectUnionFeature as any, blindUnionFeature as any) as any)
          : (detectUnionFeature as any);
      }
    } catch {
      donutFeature = detectUnionFeature as any;
    }

    const donutFC = donutFeature
      ? turf.featureCollection([donutFeature])
      : turf.featureCollection([]);

    const blindUnionFC = blindUnionFeature
      ? turf.featureCollection([blindUnionFeature as any])
      : turf.featureCollection([]);

    const detectOutlineFC = detectUnionFeature
      ? turf.featureCollection([detectUnionFeature as any])
      : turf.featureCollection([]);

    return {
      donutFC,
      blindUnionFC,
      detectOutlineFC,
      blindPtsFC: turf.featureCollection(blindPts),
      detectPtsFC: turf.featureCollection(detectPts),
    };
  }, [coverageList, steps, showPoints]);

  // 4) layers
  const donutFill: any = {
    id: `${id}-donut-fill`,
    type: "fill",
    paint: {
      "fill-color": "#16a34a",   // detect
      "fill-opacity": 0.25
    }
  };
  const donutOutline: any = {
    id: `${id}-donut-outline`,
    type: "line",
    paint: { "line-color": "#16a34a", "line-width": 2 }
  };

  const blindFill: any = {
    id: `${id}-blind-fill`,
    type: "fill",
    paint: {
      "fill-color": "#86efac",   // blind
      "fill-opacity": 0.35
    }
  };
  const blindOutline: any = {
    id: `${id}-blind-outline`,
    type: "line",
    paint: { "line-color": "#16a34a", "line-width": 1 }
  };

  const detectOutline: any = {
    id: `${id}-detect-outline`,
    type: "line",
    paint: { "line-color": "#16a34a", "line-width": 1, "line-dasharray": [2, 2] }
  };

  const blindPtsLayer: any = {
    id: `${id}-blind-pts`,
    type: "circle",
    paint: { "circle-radius": 4, "circle-color": "#86efac", "circle-stroke-width": 1, "circle-stroke-color": "#16a34a" }
  };
  const detectPtsLayer: any = {
    id: `${id}-detect-pts`,
    type: "circle",
    paint: { "circle-radius": 4, "circle-color": "#16a34a", "circle-stroke-width": 1, "circle-stroke-color": "#14532d" }
  };

  return (
    <>
      {/* donut: detect \ blind (phần vành xanh lá) */}
      <Source id={`${id}-donut-src`} type="geojson" data={donutFC}>
        <Layer {...donutFill} />
        <Layer {...donutOutline} />
      </Source>

      {/* union blind (xanh nhạt) */}
      <Source id={`${id}-blind-union-src`} type="geojson" data={blindUnionFC}>
        <Layer {...blindFill} />
        <Layer {...blindOutline} />
      </Source>

      {/* detect union outline (đường đứt để thấy biên tổng) */}
      <Source id={`${id}-detect-union-outline-src`} type="geojson" data={detectOutlineFC}>
        <Layer {...detectOutline} />
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
