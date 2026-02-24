func GenerateLayouts(req GenerateWeaponRequest) []NamedWeaponComplexes {
	r := rand.New(rand.NewSource(time.Now().UnixNano()))

	layoutCount := req.LayoutCount
	if layoutCount <= 0 {
		return []NamedWeaponComplexes{}
	}

	primary := Sector{
		Start: float64(req.CombatCenter.PrimaryAngleStart),
		End:   float64(req.CombatCenter.PrimaryAngleEnd),
	}
	secondary := Sector{
		Start: float64(req.CombatCenter.SecondaryAngleStart),
		End:   float64(req.CombatCenter.SecondaryAngleEnd),
	}

	center := GeoPoint{
		Lat: req.CombatCenter.Latitude,
		Lon: req.CombatCenter.Longtidue,
	}

	out := make([]NamedWeaponComplexes, 0, layoutCount)

	for i := 0; i < layoutCount; i++ {
		layoutName := "Layout " + itoa(i+1)

		weapons := make([]WeaponComplexRequest, 0, 64)

		// Sinh số lượng theo min/max cho từng loại
		// Radar cần xử lý ưu tiên primary rồi mới secondary
		for _, c := range req.Complexes {
			qty := randIntRange(r, c.MinQuantity, c.MaxQuantity)
			if qty <= 0 {
				continue
			}

			switch c.ComplexType {
			case SMPK_Complex:
				// Súng: primary, quanh 1km
				for k := 0; k < qty; k++ {
					p := randomPointInSector(r, center, 0.8, 1.2, primary)
					weapons = append(weapons, WeaponComplexRequest{
						Name:          complexTypeName(c.ComplexType) + "-" + itoa(k+1),
						ComplexTypeID: c.ComplexTypeID,
						Longitude:     p.Lon,
						Latitude:      p.Lat,
					})
				}

			case PPK_Complex:
				// Pháo: primary, quanh 3km
				for k := 0; k < qty; k++ {
					p := randomPointInSector(r, center, 2.6, 3.4, primary)
					weapons = append(weapons, WeaponComplexRequest{
						Name:          complexTypeName(c.ComplexType) + "-" + itoa(k+1),
						ComplexTypeID: c.ComplexTypeID,
						Longitude:     p.Lon,
						Latitude:      p.Lat,
					})
				}

			case BV5_Complex, BV15_Complex:
				// BV5/BV15: secondary, <= 5km
				for k := 0; k < qty; k++ {
					p := randomPointInSector(r, center, 1.0, 5.0, secondary)
					weapons = append(weapons, WeaponComplexRequest{
						Name:          complexTypeName(c.ComplexType) + "-" + itoa(k+1),
						ComplexTypeID: c.ComplexTypeID,
						Longitude:     p.Lon,
						Latitude:      p.Lat,
					})
				}

			case RADAR_Complex:
				// Radar: ưu tiên primary, rồi mới secondary, <= 5km
				primaryCount := qty // default: cố nhét hết vào primary
				// Nếu bạn muốn giới hạn primary theo ý (vd max 8 radar primary) thì chỉnh ở đây.
				// primaryCount = min(qty, 8)

				for k := 0; k < primaryCount; k++ {
					p := randomPointInSector(r, center, 0.8, 5.0, primary)
					weapons = append(weapons, WeaponComplexRequest{
						Name:          complexTypeName(c.ComplexType) + "-P-" + itoa(k+1),
						ComplexTypeID: c.ComplexTypeID,
						Longitude:     p.Lon,
						Latitude:      p.Lat,
					})
				}
				remain := qty - primaryCount
				for k := 0; k < remain; k++ {
					p := randomPointInSector(r, center, 0.8, 5.0, secondary)
					weapons = append(weapons, WeaponComplexRequest{
						Name:          complexTypeName(c.ComplexType) + "-S-" + itoa(k+1),
						ComplexTypeID: c.ComplexTypeID,
						Longitude:     p.Lon,
						Latitude:      p.Lat,
					})
				}

			default:
				// Các loại khác: mặc định secondary trước, <= 5km
				for k := 0; k < qty; k++ {
					p := randomPointInSector(r, center, 1.0, 5.0, secondary)
					weapons = append(weapons, WeaponComplexRequest{
						Name:          complexTypeName(c.ComplexType) + "-" + itoa(k+1),
						ComplexTypeID: c.ComplexTypeID,
						Longitude:     p.Lon,
						Latitude:      p.Lat,
					})
				}
			}
		}

		out = append(out, NamedWeaponComplexes{
			Name:            layoutName,
			WeaponComplexes: weapons,
		})
	}

	return out
}

// ====== Geometry helpers ======

type GeoPoint struct {
	Lat float64
	Lon float64
}

type Sector struct {
	Start float64 // degrees
	End   float64 // degrees
}

// randomPointInSector: chọn 1 điểm ngẫu nhiên cách center [minKm..maxKm] theo góc nằm trong sector
func randomPointInSector(r *rand.Rand, center GeoPoint, minKm, maxKm float64, sector Sector) GeoPoint {
	distKm := randFloatRange(r, minKm, maxKm)
	bearingDeg := randomAngleInSector(r, sector)
	return destinationPoint(center, distKm, bearingDeg)
}

// destinationPoint theo công thức địa cầu (WGS84 approx sphere)
func destinationPoint(start GeoPoint, distKm float64, bearingDeg float64) GeoPoint {
	const earthRadiusKm = 6371.0

	lat1 := deg2rad(start.Lat)
	lon1 := deg2rad(start.Lon)
	brng := deg2rad(normalizeDeg(bearingDeg))

	dr := distKm / earthRadiusKm

	lat2 := math.Asin(math.Sin(lat1)*math.Cos(dr) + math.Cos(lat1)*math.Sin(dr)*math.Cos(brng))
	lon2 := lon1 + math.Atan2(
		math.Sin(brng)*math.Sin(dr)*math.Cos(lat1),
		math.Cos(dr)-math.Sin(lat1)*math.Sin(lat2),
	)

	return GeoPoint{
		Lat: rad2deg(lat2),
		Lon: normalizeLon(rad2deg(lon2)),
	}
}

func randomAngleInSector(r *rand.Rand, s Sector) float64 {
	start := normalizeDeg(s.Start)
	end := normalizeDeg(s.End)

	// sector có thể wrap qua 360 (vd 300 -> 30)
	if start <= end {
		return randFloatRange(r, start, end)
	}
	// wrap: [start..360) U [0..end]
	part1 := 360.0 - start
	part2 := end
	pick := randFloatRange(r, 0, part1+part2)
	if pick < part1 {
		return start + pick
	}
	return pick - part1
}

func normalizeDeg(a float64) float64 {
	x := math.Mod(a, 360.0)
	if x < 0 {
		x += 360.0
	}
	return x
}

func normalizeLon(lon float64) float64 {
	// đưa về [-180..180]
	x := math.Mod(lon+180.0, 360.0)
	if x < 0 {
		x += 360.0
	}
	return x - 180.0
}

func deg2rad(d float64) float64 { return d * math.Pi / 180.0 }
func rad2deg(r float64) float64 { return r * 180.0 / math.Pi }

func randIntRange(r *rand.Rand, min, max int) int {
	if max < min {
		min, max = max, min
	}
	if max == min {
		return min
	}
	return min + r.Intn(max-min+1)
}

func randFloatRange(r *rand.Rand, min, max float64) float64 {
	if max < min {
		min, max = max, min
	}
	return min + r.Float64()*(max-min)
}

func complexTypeName(t ComplexTypeEnum) string {
	switch t {
	case BV5_Complex:
		return "BV5"
	case BV15_Complex:
		return "BV15"
	case PPK_Complex:
		return "PPK"
	case SMPK_Complex:
		return "SMPK"
	case RADAR_Complex:
		return "RADAR"
	case E320_Complex:
		return "E320"
	case BV5_XDT_Complex:
		return "BV5_XDT"
	default:
		return "UNKNOWN"
	}
}

// itoa tối giản (tránh import strconv nếu bạn muốn)
func itoa(n int) string {
	if n == 0 {
		return "0"
	}
	sign := ""
	if n < 0 {
		sign = "-"
		n = -n
	}
	buf := make([]byte, 0, 12)
	for n > 0 {
		d := n % 10
		buf = append(buf, byte('0'+d))
		n /= 10
	}
	// reverse
	for i, j := 0, len(buf)-1; i < j; i, j = i+1, j-1 {
		buf[i], buf[j] = buf[j], buf[i]
	}
	return sign + string(buf)
}