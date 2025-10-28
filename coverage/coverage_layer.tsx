import React, { useMemo } from "react";
import { Source, Layer } from "react-map-gl";
import * as turf from "@turf/turf";
import dissolve from "@turf/dissolve";
import { CoverageData } from "@/types";
import { MapLayerID } from "@/config";
import polygonToLine from "@turf/polygon-to-line";
import { RootState } from "@/slices";
import { useSelector } from "react-redux";

const DETECT_COLOR = "#16a34a"; // vòng to
const BLIND_COLOR = "#86efac"; // vòng nhỏ

interface CoverageMergedLayerProps {
  coverageList: CoverageData[];
  steps: number;
  showPoints: boolean;
  idSource: string;
  isCreate: boolean;
}

export const CoverageMergedLayer = ({
  coverageList,
  steps = 64,
  showPoints = false,
  idSource = "",
  isCreate = false,
}: CoverageMergedLayerProps) => {
  const height = useSelector(
    (state: RootState) => state.setting.heightCoverage
  );

  // helper: Multi -> FeatureCollection<Polygon>
  const toFeatureCollection = (geom: turf.Feature<any> | null) => {
    const out: turf.Feature<turf.Polygon>[] = [];
    if (geom) {
      turf.flattenEach(geom, (f) => {
        if (f.geometry.type === "Polygon")
          out.push(f as turf.Feature<turf.Polygon>);
      });
    }
    return turf.featureCollection(out);
  };

  // helper: union
  const safeUnion = (
    a: turf.Feature<turf.Polygon | turf.MultiPolygon> | null,
    b: turf.Feature<turf.Polygon | turf.MultiPolygon> | null
  ) => {
    if (!a) return b || null;
    if (!b) return a;
    try {
      return turf.union(a as any, b as any) as any;
    } catch (error) {
      return a;
    }
  };

  const {
    donutFeatures,
    blindPointsFeatures,
    detectPointFeatures,
    detectLabelLinesFeatures,
  } = useMemo(() => {
    /// --- Bước 1: Khai báo các mảng chứa dữ liệu
    const detectPolys: turf.Feature<turf.Polygon>[] = [];
    const blindPolys: turf.Feature<turf.Polygon>[] = [];
    const blindPts: turf.Feature<turf.Point>[] = [];
    const detectPts: turf.Feature<turf.Point>[] = [];

    /// --- Bước 2: Gán giá trị
    for (const c of coverageList || []) {
      const center: [number, number] = [
        c.centerCoordinate.x,
        c.centerCoordinate.y,
      ];
      const blind = turf.circle(center, c.blindRadius, {
        steps,
        units: "meters",
      }) as turf.Feature<turf.Polygon>;
      const detect = turf.circle(center, c.detectRadius, {
        steps,
        units: "meters",
      }) as turf.Feature<turf.Polygon>;
      blindPolys.push(blind);
      detectPolys.push(detect);

      if (showPoints) {
        (c.blindCoordinates || []).forEach((p) =>
          blindPts.push(turf.point([p.x, p.y], { kind: "blind" }))
        );
        (c.detectCoordinates || []).forEach((p) =>
          detectPts.push(turf.point([p.x, p.y], { kind: "detect" }))
        );
      }
    }

    // --- Bước 3: Union tất cả detect (merge các vùng detect giao nhau)
    let detectUnionAll: turf.Feature<turf.Polygon | turf.MultiPolygon> | null =
      null;
    for (const poly of detectPolys) {
      try {
        detectUnionAll = detectUnionAll
          ? turf.union(detectUnionAll, poly as any)
          : poly;
      } catch (err) {
        detectUnionAll = detectUnionAll ?? poly;
      }
    }

    /// --- helper: union đường detect của coverage khác
    const unionOthers = (skipIdx: number) => {
      let u: turf.Feature<turf.Polygon | turf.MultiPolygon> | null = null;
      for (let i = 0; i < detectPolys.length; i++) {
        if (i === skipIdx) continue;
        u = safeUnion(u, detectPolys[i]);
      }
      return u;
    };

    /// --- Bước 4.1: tính blindVisible_i: blind_i \ union(detect_j!=i)
    const blindVisiblePieces: turf.Feature<turf.Polygon>[] = [];
    for (let i = 0; i < coverageList.length; i++) {
      const blind_i = blindPolys[i];
      const othersDetectU = unionOthers(i); // union detect của các coverage khác

      let visible_i: turf.Feature<turf.Polygon | turf.MultiPolygon> | null =
        blind_i;
      try {
        visible_i = othersDetectU
          ? (turf.difference(blind_i as any, othersDetectU as any) as any)
          : blind_i;
      } catch {
        visible_i = blind_i;
      }

      if (visible_i) {
        turf.flattenEach(visible_i, (f) => {
          if (f.geometry.type === "Polygon")
            blindVisiblePieces.push(f as turf.Feature<turf.Polygon>);
        });
      }
    }

    /// --- Bước 4.2: blindVisible = union tất cả blindVisible_i
    let blindVisible: turf.Feature<turf.Polygon | turf.MultiPolygon> | null =
      null;
    for (const piece of blindVisiblePieces) {
      blindVisible = safeUnion(blindVisible, piece);
    }

    /// --- Bước 5: Vẽ đường detect (có merge) để phục vụ cho bước 6
    const detectPieces: turf.Feature<turf.Polygon>[] = [];
    if (detectUnionAll) {
      turf.flattenEach(detectUnionAll, (f) => {
        if (f.geometry.type === "Polygon")
          detectPieces.push(f as turf.Feature<turf.Polygon>);
      });
    }
    const detectMergedFeatures = turf.featureCollection(detectPieces);

    /// --- Bước 6: Vẽ label (độ cao vùng phủ) lên đường detect đã merge
    const labelLines: turf.Feature<turf.LineString | turf.MultiLineString>[] =
      [];
    turf.flattenEach(detectMergedFeatures, (f) => {
      if (f.geometry.type === "Polygon") {
        const line = polygonToLine(f as turf.Feature<turf.Polygon>);
        (line as any).properties = {
          ...(line as any).properties,
          label: `${height}m`,
        };
        turf.flattenEach(line as any, (lf) => {
          if (
            lf.geometry.type === "LineString" ||
            lf.geometry.type === "MultiLineString"
          ) {
            labelLines.push(lf as any);
          }
        });
      }
    });
    const detectLabelLinesFeatures = turf.featureCollection(labelLines);

    /// --- Bước 7.1: Tình vùng donut = detectUnionAll - blindVisible
    let donut: turf.Feature<turf.Polygon | turf.MultiPolygon> | null = null;
    try {
      donut = detectUnionAll
        ? blindVisible
          ? (turf.difference(detectUnionAll as any, blindVisible as any) as any)
          : detectUnionAll
        : null;
    } catch (error) {
      donut = detectUnionAll;
    }

    /// --- Bước 7.2: Chuyển vùng donut sang FeatureCollection<Polygon>
    const donutFeatures = toFeatureCollection(donut);

    return {
      donutFeatures,
      blindPointsFeatures: turf.featureCollection(blindPts), // nối các point của blind thành line
      detectPointFeatures: turf.featureCollection(detectPts), // nối các point của detect thành line
      detectLabelLinesFeatures, // label
    };
  }, []);

  // ===================== Layers =====================
  const donutFill: any = {
    id: `${MapLayerID.MERGE_COVERAGE_DONUT_FILL_LAYER}_${idSource}`,
    type: "fill",
    paint: { "fill-color": DETECT_COLOR, "fill-opacity": isCreate ? 0.4 : 0.1 },
  };

  const donutOutline: any = {
    id: `${MapLayerID.MERGE_COVERAGE_DONUT_OUTLINE_LAYER}_${idSource}`,
    type: "line",
    paint: { "line-color": DETECT_COLOR, "line-width": isCreate ? 4 : 2 },
  };

  const detectLabelLayer: any = {
    id: `${MapLayerID.MERGE_COVERAGE_LABEL_LAYER}_${idSource}`,
    type: "symbol",
    layout: {
      "symbol-placement": "line",
      "text-field": ["get", "label"],
      "text-size": 12,
      "text-font": ["Open Sans Semibold", "Arial Unicode MS Regular"],
      "text-anchor": "center",
      "text-allow-overlap": true,
    },
    paint: {
      "text-color": "#166534",
      "text-halo-color": "#ffffff",
      "text-halo-width": 1,
    },
  };

  const blindPointsLayer: any = {
    id: `${MapLayerID.MERGE_COVERAGE_BLIND_POINTS_LAYER}_${idSource}`,
    type: "circle",
    paint: {
      "circle-radius": 2,
      "circle-color": BLIND_COLOR,
      "circle-stroke-width": 1,
      "circle-stroke-color": "#166534",
    },
  };

  const detectPointsLayer: any = {
    id: `${MapLayerID.MERGE_COVERAGE_DETECT_POINTS_LAYER}_${idSource}`,
    type: "circle",
    paint: {
      "circle-radius": 2,
      "circle-color": DETECT_COLOR,
      "circle-stroke-width": 1,
      "circle-stroke-color": "#14532d",
    },
  };

  if (!coverageList || coverageList.length === 0) return null;

  return (
    <>
      <Source
        id={`${MapLayerID.MERGE_COVERAGE_LABEL_SOURCE}_${idSource}`}
        type="geojson"
        data={detectLabelLinesFeatures}
      >
        <Layer {...detectLabelLayer} />
      </Source>

      <Source
        id={`${MapLayerID.MERGE_COVERAGE_DONUT_SOURCE}_${idSource}`}
        type="geojson"
        data={donutFeatures}
      >
        <Layer {...donutFill} />
        <Layer {...donutOutline} />
      </Source>

      {showPoints && (
        <>
          <Source
            id={`${MapLayerID.MERGE_COVERAGE_BLIND_POINTS_SOURCE}_${idSource}`}
            type="geojson"
            data={turf.featureCollection(blindPts)}
          >
            <Layer {...blindPointsLayer} />
          </Source>

          <Source
            id={`${MapLayerID.MERGE_COVERAGE_DETECT_POINTS_SOURCE}_${idSource}`}
            type="geojson"
            data={turf.featureCollection(detectPts)}
          >
            <Layer {...detectPointsLayer} />
          </Source>
        </>
      )}
    </>
  );
};
