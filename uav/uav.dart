// ====== PagedResult theo bạn ======
class PagedResult<T> {
  final List<T> items;
  final int totalCount;
  PagedResult({required this.items, required this.totalCount});
}

// ====== Filter model ======
class CatalogFilter {
  final Set<String> brands;
  final int minPrice; // VND
  final int maxPrice; // VND
  const CatalogFilter({
    this.brands = const {},
    this.minPrice = 0,
    this.maxPrice = 100000000, // 100tr default
  });

  CatalogFilter copyWith({Set<String>? brands, int? minPrice, int? maxPrice}) =>
      CatalogFilter(
        brands: brands ?? this.brands,
        minPrice: minPrice ?? this.minPrice,
        maxPrice: maxPrice ?? this.maxPrice,
      );
}

// ====== Demo repo có filter (thay bằng API thật của bạn) ======
class AircraftRepository {
  static const _allBrands = [
    'SAMSUNG', 'ARAREE', 'UAG', 'SPIGEN', 'GEAR4',
    'UNIQ', 'ZAGG', 'PLTAKA', 'MPOW', 'Apple Reseller'
  ];

  // sinh "giá" và "brand" demo để filter hoạt động
  ({int price, String brand}) _mockMetaForId(int id) {
    final brand = _allBrands[id % _allBrands.length];
    final price = 10000000 + (id % 60) * 900000; // 10tr .. ~63tr
    return (price: price, brand: brand);
  }

  Future<PagedResult<Aircraft>> fetchPage({
    required int offset,
    required int limit,
    required CatalogFilter filter,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    const totalRaw = 120;

    // Tạo toàn bộ list -> gắn meta (brand, price) -> lọc -> phân trang
    final generated = List<Aircraft>.generate(totalRaw, (i) {
      final id = i + 1;
      final imgSeed = (i % 50) + 1;
      return Aircraft(
        id: id,
        model: 'Galaxy Z Fold7 #$id',
        description: 'Mô tả ngắn gọn cho mẫu #$id',
        country: 'VN',
        length: '8.2m',
        width: '2.3m',
        height: '1.9m',
        weightEmpty: '1,200kg',
        weightTakeOff: '1,850kg',
        fullLoad: '300kg',
        cruiseSpeed: '450km/h',
        maxSpeed: '520km/h',
        maxAltitude: '6,500m',
        flightRange: '750km',
        largeImageUrl: 'https://picsum.photos/seed/$imgSeed/900/900',
        mediumImageUrl: 'https://picsum.photos/seed/$imgSeed/600/600',
        smallImageUrl: 'https://picsum.photos/seed/$imgSeed/300/300',
      );
    });

    // áp filter
    final filtered = <Aircraft>[];
    for (final a in generated) {
      final meta = _mockMetaForId(a.id);
      final passBrand = filter.brands.isEmpty || filter.brands.contains(meta.brand);
      final passPrice = meta.price >= filter.minPrice && meta.price <= filter.maxPrice;
      if (passBrand && passPrice) filtered.add(a);
    }

    final end = (offset + limit).clamp(0, filtered.length);
    final pageItems = offset >= filtered.length ? <Aircraft>[] : filtered.sublist(offset, end);
    return PagedResult(items: pageItems, totalCount: filtered.length);
  }

  static List<String> get allBrands => _allBrands;
}

// ====== Giá demo để hiển thị trên card (không sửa model)
extension AircraftMeta on Aircraft {
  int get mockPrice {
    final base = 10000000 + (id % 60) * 900000;
    return base;
  }
  String get mockBrand => AircraftRepository.allBrands[id % AircraftRepository.allBrands.length];
}

// ====== VIEW có sidebar filter ======
class CatalogView extends StatefulWidget {
  const CatalogView({super.key});
  @override
  State<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<CatalogView> {
  final _repo = AircraftRepository();
  final _scrollCtrl = ScrollController();

  static const _pageSize = 9;
  final List<Aircraft> _items = [];
  int _totalCount = 0;

  bool _initialLoading = true;
  bool _loadingMore = false;
  bool _error = false;

  CatalogFilter _filter = const CatalogFilter(minPrice: 0, maxPrice: 70000000);

  bool get _hasMore => _items.length < _totalCount;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _initialLoading = true;
      _error = false;
    });
    try {
      final page = await _repo.fetchPage(
        offset: 0,
        limit: _pageSize,
        filter: _filter,
      );
      setState(() {
        _items
          ..clear()
          ..addAll(page.items);
        _totalCount = page.totalCount;
      });
    } catch (_) {
      setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _initialLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final page = await _repo.fetchPage(
        offset: _items.length,
        limit: _pageSize,
        filter: _filter,
      );
      setState(() {
        _items.addAll(page.items);
        _totalCount = page.totalCount;
      });
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _onRefresh() => _loadInitial();

  void _applyFilter(CatalogFilter f) {
    setState(() => _filter = f);
    _loadInitial(); // reload từ đầu
  }

  @override
  Widget build(BuildContext context) {
    // responsive: <900px sẽ tự full chiều ngang (filter nằm trên cùng)
    return LayoutBuilder(builder: (context, c) {
      final isWide = c.maxWidth >= 900;

      if (_initialLoading) {
        return isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  FilterReactivePanel(
                    value: _filter,                 // CatalogFilter hiện tại
                    onApply: _applyFilter,          // gọi setState + _loadInitial()
                  ),
                  Expanded(child: _GridSkeleton()),
                ],
              )
            : const _GridSkeleton();
      }
      if (_error) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Có lỗi xảy ra'),
              const SizedBox(height: 8),
              FilledButton(onPressed: _loadInitial, child: const Text('Thử lại')),
            ],
          ),
        );
      }

      final grid = RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollCtrl,
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(isWide ? 12 : 12, 0, 12, 12),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 3 : (c.maxWidth >= 600 ? 2 : 1),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: _items.length,
                itemBuilder: (_, i) => _ProductCard(item: _items[i]),
              ),
            ),
            SliverToBoxAdapter(
              child: _loadingMore
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : const SizedBox.shrink(),
            ),
            if (!_hasMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: Text('— Hết dữ liệu —')),
                ),
              ),
          ],
        ),
      );

      // Wide: filter bên trái, Grid bên phải
      if (isWide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FilterPanel(
              value: _filter,
              onApply: _applyFilter,
            ),
            const SizedBox(width: 12),
            Expanded(child: grid),
          ],
        );
      }

      // Narrow: filter thành Expansion ở trên Grid
      return CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          SliverToBoxAdapter(
            child: _FilterPanel.collapsed(
              value: _filter,
              onApply: _applyFilter,
            ),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 8)),
          ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: c.maxWidth >= 600 ? 2 : 1,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: _items.length,
                itemBuilder: (_, i) => _ProductCard(item: _items[i]),
              ),
            ),
            SliverToBoxAdapter(
              child: _loadingMore
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : const SizedBox.shrink(),
            ),
            if (!_hasMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: Text('— Hết dữ liệu —')),
                ),
              ),
          ]
        ],
      );
    });
  }
}

import 'package:reactive_forms/reactive_forms.dart';
import 'package:flutter/material.dart';

class FilterReactivePanel extends StatelessWidget {
  final CatalogFilter value;
  final void Function(CatalogFilter) onApply;
  const FilterReactivePanel({super.key, required this.value, required this.onApply});

  FormGroup _buildForm() {
    final min = value.minPrice;
    final max = value.maxPrice;
    return fb.group(<String, Object>{
      'selectedBrands': fb.array<String>(value.brands.toList()),
      'priceMin': FormControl<int>(value: min, validators: [Validators.number, Validators.min(0)]),
      'priceMax': FormControl<int>(value: max, validators: [Validators.number, Validators.min(0)]),
      'priceRange': FormControl<RangeValues>(
        value: RangeValues(min / 1e6, max / 1e6),
      ),
    }, validators: [
      // min <= max
      (AbstractControl<dynamic> group) {
        final g = group as FormGroup;
        final a = g.control('priceMin').value as int;
        final b = g.control('priceMax').value as int;
        return (a <= b) ? null : {'min_gt_max': true};
      }
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final brands = AircraftRepository.allBrands;
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(width: 280),
      child: Card(
        margin: const EdgeInsets.fromLTRB(12, 0, 0, 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ReactiveFormBuilder(
            form: _buildForm,
            builder: (context, form, _) {
              void submit() {
                if (!form.valid) {
                  form.markAllAsTouched();
                  return;
                }
                final selected = (form.control('selectedBrands') as FormArray<String>).value.toSet();
                final min = form.control('priceMin').value as int;
                final max = form.control('priceMax').value as int;
                onApply(value.copyWith(brands: selected, minPrice: min, maxPrice: max));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Thương hiệu', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),

                  // Chips = ReactiveArray
                  ReactiveFormConsumer(
                    builder: (context, form, _) {
                      final arr = form.control('selectedBrands') as FormArray<String>;
                      return Wrap(
                        spacing: 8, runSpacing: 8,
                        children: brands.map((b) {
                          final selected = arr.value.contains(b);
                          return ChoiceChip(
                            label: Text(b),
                            selected: selected,
                            onSelected: (v) {
                              if (v) {
                                arr.add(FormControl<String>(value: b));
                              } else {
                                final idx = arr.controls.indexWhere((c) => c.value == b);
                                if (idx >= 0) arr.removeAt(idx);
                              }
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  Text('Mức giá', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),

                  // Range slider reactive (triệu đồng)
                  ReactiveRangeSlider(
                    formControlName: 'priceRange',
                    min: 0, max: 70, divisions: 70,
                    labelBuilder: (v) => '${v.start.toStringAsFixed(0)}tr — ${v.end.toStringAsFixed(0)}tr',
                    onChanged: (context, range) {
                      // đồng bộ về priceMin/priceMax (VND)
                      context.form.control('priceMin').value = (range.start.round() * 1000000);
                      context.form.control('priceMax').value = (range.end.round() * 1000000);
                    },
                  ),

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ReactiveTextField<int>(
                          formControlName: 'priceMin',
                          keyboardType: TextInputType.number,
                          valueAccessor: IntValueAccessor(),
                          decoration: _inBox('Min'),
                          onChanged: (field) {
                            final min = field.value ?? 0;
                            final max = form.control('priceMax').value as int;
                            final r = form.control('priceRange').value as RangeValues;
                            final newStart = (min / 1e6).clamp(0, 70).toDouble();
                            form.control('priceRange').value = RangeValues(newStart, r.end);
                            if (min > max) form.control('priceMax').value = min;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ReactiveTextField<int>(
                          formControlName: 'priceMax',
                          keyboardType: TextInputType.number,
                          valueAccessor: IntValueAccessor(),
                          decoration: _inBox('Max'),
                          onChanged: (field) {
                            final max = field.value ?? 0;
                            final min = form.control('priceMin').value as int;
                            final r = form.control('priceRange').value as RangeValues;
                            final newEnd = (max / 1e6).clamp(0, 70).toDouble();
                            form.control('priceRange').value = RangeValues(r.start, newEnd);
                            if (max < min) form.control('priceMin').value = max;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: ReactiveFormConsumer(
                      builder: (context, form, _) => FilledButton(
                        onPressed: form.valid ? submit : null,
                        child: const Text('ÁP DỤNG'),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  _quickPriceBtn('Dưới 5 triệu', form, 0, 5_000_000, submit),
                  _quickPriceBtn('Dưới 7 triệu', form, 0, 7_000_000, submit),
                  _quickPriceBtn('1 đến 2 triệu', form, 1_000_000, 2_000_000, submit),
                  _quickPriceBtn('1 đến 3 triệu', form, 1_000_000, 3_000_000, submit),

                  const SizedBox(height: 4),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.expand_more),
                    label: const Text('XEM THÊM'),
                  ),
                  const SizedBox(height: 4),

                  // Hiển thị lỗi chung (vd min>max)
                  ReactiveStatusListenableBuilder(
                    formControlName: '',
                    builder: (_, control, __) {
                      return control.hasErrors
                          ? Text('Giá min phải nhỏ hơn hoặc bằng giá max',
                              style: TextStyle(color: Theme.of(context).colorScheme.error))
                          : const SizedBox.shrink();
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  InputDecoration _inBox(String hint) => InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      );

  Widget _quickPriceBtn(String label, FormGroup form, int min, int max, VoidCallback submit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: 40,
        child: OutlinedButton(
          onPressed: () {
            form.control('priceMin').value = min;
            form.control('priceMax').value = max;
            form.control('priceRange').value = RangeValues(min / 1e6, max / 1e6);
            submit();
          },
          child: Align(alignment: Alignment.centerLeft, child: Text(label)),
        ),
      ),
    );
  }
}

class ReactiveRangeSlider extends ReactiveFormField<RangeValues, RangeValues> {
  ReactiveRangeSlider({
    super.key,
    required String formControlName,
    required this.min,
    required this.max,
    this.divisions,
    this.onChanged,
    String Function(RangeValues values)? labelBuilder,
  }) : _labelBuilder = labelBuilder,
       super(
        formControlName: formControlName,
        builder: (field) {
          final widget = field as ReactiveRangeSliderState;
          final v = field.value ?? RangeValues(0, 0);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RangeSlider(
                min: widget.min,
                max: widget.max,
                divisions: widget.divisions,
                values: v,
                labels: widget._labelBuilder != null
                    ? RangeLabels(
                        widget._labelBuilder!(v).split('—').first.trim(),
                        widget._labelBuilder!(v).split('—').last.trim(),
                      )
                    : RangeLabels('${v.start}', '${v.end}'),
                onChanged: (val) {
                  field.didChange(val);
                  widget.onChanged?.call(field, val);
                },
              ),
            ],
          );
        },
      );

  final double min;
  final double max;
  final int? divisions;
  final void Function(ReactiveFormFieldState<RangeValues, RangeValues> context, RangeValues value)? onChanged;
  final String Function(RangeValues values)? _labelBuilder;

  @override
  ReactiveFormFieldState<RangeValues, RangeValues> createState() =>
      ReactiveRangeSliderState();
}

class ReactiveRangeSliderState
    extends ReactiveFormFieldState<RangeValues, RangeValues> {
  double get min => (widget as ReactiveRangeSlider).min;
  double get max => (widget as ReactiveRangeSlider).max;
  int? get divisions => (widget as ReactiveRangeSlider).divisions;
  String Function(RangeValues values)? get _labelBuilder =>
      (widget as ReactiveRangeSlider)._labelBuilder;
  void Function(ReactiveFormFieldState<RangeValues, RangeValues>, RangeValues)?
      get onChanged => (widget as ReactiveRangeSlider).onChanged;
}

class IntValueAccessor extends ControlValueAccessor<String, int> {
  @override
  String? modelToViewValue(int? modelValue) => modelValue?.toString();
  @override
  int? viewToModelValue(String? viewValue) => int.tryParse(viewValue ?? '');
}

/// ====== Skeleton ban đầu (loading 9 ô) ======
class _GridSkeleton extends StatelessWidget {
  const _GridSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final width = c.maxWidth;
      final crossAxisCount = width >= 1100
          ? 4
          : width >= 900
              ? 3
              : width >= 600
                  ? 2
                  : 1;
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 9,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (_, __) => const _SkeletonCard(),
      );
    });
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    Widget box([double h = 12]) => Container(
          height: h,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
        );

    return Card(
      elevation: 0.8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            box(),
            const SizedBox(height: 8),
            box(),
            const Spacer(),
            SizedBox(height: 40, child: box(40)),
          ],
        ),
      ),
    );
  }
}