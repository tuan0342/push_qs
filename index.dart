// SquareOverlay.tsx
import { useMemo } from "react";
import { Source, Layer } from "react-map-gl";
import { useSelector } from "react-redux";
import type { Feature, FeatureCollection, Polygon, Point as GPoint } from "geojson";
import { point as turfPoint, polygon as turfPolygon } from "@turf/helpers";
import destination from "@turf/destination";

type PointState = {
  latitude: number;
  longitude: number;
  radius: number; // chiều dài cạnh hình vuông (m)
};

// TODO: sửa selector theo store của bạn
const selectPoint = (state: any): PointState => state.point as PointState;

export default function SquareOverlay() {
  const { latitude, longitude, radius } = useSelector(selectPoint);

  const geojson = useMemo<FeatureCollection>(() => {
    const center: Feature<GPoint> = turfPoint([longitude, latitude]);

    // luôn có feature tâm
    const features: Feature[] = [
      {
        type: "Feature",
        geometry: center.geometry,
        properties: { kind: "center" },
      },
    ];

    // nếu radius > 0 thì vẽ hình vuông
    if (radius > 0) {
      const half = radius / 2; // nửa cạnh (m)

      // Lấy 4 điểm cực N/E/S/W ở khoảng cách half (m)
      const north = destination(center, half, 0, { units: "meters" });
      const east = destination(center, half, 90, { units: "meters" });
      const south = destination(center, half, 180, { units: "meters" });
      const west = destination(center, half, 270, { units: "meters" });

      // Góc vuông trục-địa lý (vuông theo kinh/vĩ)
      const nw = [west.geometry.coordinates[0], north.geometry.coordinates[1]];
      const ne = [east.geometry.coordinates[0], north.geometry.coordinates[1]];
      const se = [east.geometry.coordinates[0], south.geometry.coordinates[1]];
      const sw = [west.geometry.coordinates[0], south.geometry.coordinates[1]];

      const square: Feature<Polygon> = turfPolygon([[nw, ne, se, sw, nw]], {
        kind: "square",
      });

      features.push(square);
    }

    return { type: "FeatureCollection", features };
  }, [latitude, longitude, radius]);

  return (
    <>
      {/* Hình vuông (fill + viền) */}
      <Source id="square-src" type="geojson" data={geojson}>
        <Layer
          id="square-fill"
          type="fill"
          filter={["==", ["get", "kind"], "square"]}
          paint={{
            "fill-color": "#16a34a",
            "fill-opacity": 0.2,
          }}
        />
        <Layer
          id="square-line"
          type="line"
          filter={["==", ["get", "kind"], "square"]}
          paint={{
            "line-color": "#16a34a",
            "line-width": 2,
          }}
        />

        {/* Tâm */}
        <Layer
          id="center-circle"
          type="circle"
          filter={["==", ["get", "kind"], "center"]}
          paint={{
            "circle-radius": 5,
            "circle-color": "#0ea5e9",
            "circle-stroke-color": "#075985",
            "circle-stroke-width": 1.5,
          }}
        />
      </Source>
    </>
  );
}
