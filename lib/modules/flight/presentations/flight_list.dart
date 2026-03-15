import "package:booking_app/app/routes/app_routes.dart";
import "package:booking_app/app/theme/app_colors.dart";
import "package:booking_app/app/widgets/background.dart";
import "package:booking_app/app/widgets/common_button.dart";
import "package:booking_app/app/widgets/custom_appbar.dart";
import "package:booking_app/app/widgets/universel_card.dart";
import "package:booking_app/data/models/flight_model.dart";
import "package:booking_app/modules/flight/controllers/flight_controller.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

class FlightResultPage extends StatelessWidget {
  FlightResultPage({super.key});

  final FlightController flightController = Get.find<FlightController>();

  // ─── Filter state (local, not persisted to controller until Apply) ───────────
  final RxString _filterAirline = ''.obs;
  final RxDouble _filterPriceMin = 0.0.obs;
  final RxDouble _filterPriceMax = 5000.0.obs;
  final RxInt _filterStops = (-1).obs;
  final RxString _filterAircraftType = ''.obs;

  // Which top-level filter option is expanded inside the sheet
  final RxString _expandedFilter = ''.obs;

  static const double _priceMax = 5000.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _filterFab(context),
      body: BackgroundGrad(
        gradColors: [Color(0xFFC4C9D5), Color(0xFFE1E1E2), Color(0xFFF0F1F3)],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CommonAppBar(title: "Flight Result", showMoreOption: true),
              sortOptions(),
              flightList(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── FAB ─────────────────────────────────────────────────────────────────────

  Widget _filterFab(BuildContext context) => FloatingActionButton(
    shape: const CircleBorder(),
    backgroundColor: const Color(0xFFACC3F4),
    child: Icon(LucideIcons.funnel300, color: AppColors.primary, size: 22),
    onPressed: () => _showFilterSheet(context),
  );

  // ─── Bottom sheet ─────────────────────────────────────────────────────────────

  void _showFilterSheet(BuildContext context) {
    // Reset expanded panel each time sheet opens
    _expandedFilter.value = '';

    // Load the lists used in the filter sheet (airlines + aircraft types)
    flightController.loadFilterData();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _FilterSheet(
            filterAirline: _filterAirline,
            filterPriceMin: _filterPriceMin,
            filterPriceMax: _filterPriceMax,
            filterStops: _filterStops,
            filterAircraftType: _filterAircraftType,
            expandedFilter: _expandedFilter,
            priceMax: _priceMax,
            onApply: () {
              Navigator.of(context).pop();
              _applyFilters();
            },
            onReset: _resetFilters,
          ),
    );
  }

  void _applyFilters() {
    final filters = {
      "airline": _filterAirline.value,
      "price_min": _filterPriceMin.value,
      "price_max":
          _filterPriceMax.value == _priceMax ? 0 : _filterPriceMax.value,
      "stops": _filterStops.value == -1 ? 0 : _filterStops.value,
      "aircraft_type": _filterAircraftType.value,
    };
    // Pass filters into controller and re-search
    flightController.applyFiltersAndSearch(filters);
  }

  void _resetFilters() {
    _filterAirline.value = '';
    _filterPriceMin.value = 0;
    _filterPriceMax.value = _priceMax;
    _filterStops.value = -1;
    _filterAircraftType.value = '';
  }

  // ─── Flight list ──────────────────────────────────────────────────────────────

  Widget flightList() => Expanded(
    child: Obx(() {
      final isLoading = flightController.isSearchingFlights.value;
      final isLoadMore = flightController.isLoadingMoreFlights.value;
      final hasNextPage = flightController.hasNextPage.value;
      final flights = flightController.foundFlights;

      return Stack(
        children: [
          //  The RefreshIndicator wraps both the empty state and the populated list
          RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: Colors.white,
            onRefresh: () async {
              // This triggers a brand new search
              await flightController.findFlights(navigate: false);
            },
            child:
                flights.isEmpty && !isLoading
                    //  Even the empty state must be a ListView so the user can pull it down!
                    ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: Get.height * 0.3),
                        const Center(
                          child: Text(
                            "No flights found.\nPull down to try again.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    )
                    //  The populated list with Pagination
                    : NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!isLoadMore &&
                            hasNextPage &&
                            scrollInfo.metrics.pixels >=
                                scrollInfo.metrics.maxScrollExtent - 50) {
                          flightController.loadMoreFlights();
                          return true;
                        }
                        return false;
                      },
                      child: ListView.separated(
                        // Forces the list to be scrollable even if there are only 1 or 2 items
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(
                          top: 10,
                          bottom: 40,
                          left: 5,
                          right: 5,
                        ),
                        itemCount: flights.length + (hasNextPage ? 1 : 0),
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          // Pagination Loader at the bottom
                          if (index == flights.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          }

                          // Normal Flight Card
                          final FlightModel flight = flights[index];
                          return UniversalTicketCard(
                            cardHeight: Get.height * 0.32,
                            dividerPosition: Get.height * 0.3 * 0.65,
                            topContent: _buildTopContent(flight),
                            bottomContent: _buildBottomContent(flight),
                          );
                        },
                      ),
                    ),
          ),

          //  Initial full-screen loading state (Only shows on the VERY first load)
          if (isLoading && flights.isEmpty)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.75),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      );
    }),
  );

  Widget _buildTopContent(FlightModel flight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // CircleAvatar(backgroundImage: NetworkImage(flight.airlineLogo),),
            CircleAvatar(
              radius: 25,
              child: Image(
                image: NetworkImage(flight.airlineLogo),
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                flight.airlineName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flight.departure.time.substring(0, 5),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      flight.departure.airportCode,
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    ),
                    Text(
                      " (${flight.departure.city})",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                Image.asset("assets/flight-icon.png", height: 30),
                Text(
                  flight.duration,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  flight.arrival.time.substring(0, 5),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      flight.arrival.airportCode,
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    ),
                    Text(
                      " (${flight.arrival.city})",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomContent(FlightModel flight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${flight.price.currency} ${flight.price.amount}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Text(
              "/person",
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        CommonButton(
          buttonText: "Select flight",
          onChanged: () {
            Get.toNamed(Routes.flightDetails);
            flightController.getFlightDetails(flight.id);
          },
        ),
      ],
    );
  }

  // ─── Sort chips ───────────────────────────────────────────────────────────────

  Widget sortOptions() => Padding(
    padding: const EdgeInsets.only(top: 20.0),
    child: SizedBox(
      height: 50,
      child: Obx(
        () => ListView(
          scrollDirection: Axis.horizontal,
          children:
              flightController.sortOptions.map((item) {
                final isSelected =
                    item == flightController.selectedSortOption.value;
                return GestureDetector(
                  onTap: () {
                    if (flightController.selectedSortOption.value == item)
                      return;
                    flightController.selectedSortOption.value = item;
                    flightController.findFlights(navigate: false);
                  },
                  child: sortTile(title: item, isSelected: isSelected),
                );
              }).toList(),
        ),
      ),
    ),
  );

  Widget sortTile({required String title, required bool isSelected}) => Card(
    color: isSelected ? AppColors.primary : Colors.white,
    surfaceTintColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Center(
        child: Text(
          title,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// Filter Bottom Sheet — extracted as its own StatelessWidget for clean Obx scope
// ═══════════════════════════════════════════════════════════════════════════════

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({
    required this.filterAirline,
    required this.filterPriceMin,
    required this.filterPriceMax,
    required this.filterStops,
    required this.filterAircraftType,
    required this.expandedFilter,
    required this.priceMax,
    required this.onApply,
    required this.onReset,
  });

  final RxString filterAirline;
  final RxDouble filterPriceMin;
  final RxDouble filterPriceMax;
  final RxInt filterStops;
  final RxString filterAircraftType;
  final RxString expandedFilter;
  final double priceMax;
  final VoidCallback onApply;
  final VoidCallback onReset;

  static const List<String> _filterKeys = [
    'Airline',
    'Price Range',
    'Stops',
    'Aircraft Type',
  ];

  // stop options: -1 = Any, 0 = Non-stop, 1 = 1 Stop, 2 = 2+ Stops
  static const List<Map<String, dynamic>> _stopOptions = [
    {'label': 'Any', 'value': -1},
    {'label': 'Non-stop', 'value': 0},
    {'label': '1 Stop', 'value': 1},
    {'label': '2+ Stops', 'value': 2},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── handle ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: onReset,
                  child: Text(
                    'Reset all',
                    style: TextStyle(color: Colors.red.shade400, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── filter list ──────────────────────────────────────
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filterKeys.length,
              itemBuilder: (_, i) {
                final key = _filterKeys[i];
                return Obx(() {
                  final isExpanded = expandedFilter.value == key;
                  return _FilterSection(
                    title: key,
                    subtitle: _subtitle(key),
                    isExpanded: isExpanded,
                    onTap: () => expandedFilter.value = isExpanded ? '' : key,
                    content: _sectionContent(key, context),
                  );
                });
              },
            ),
          ),

          // ── apply button ─────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              14,
              20,
              MediaQuery.of(context).padding.bottom + 14,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: onApply,
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── subtitle helper (shows active value) ─────────────────────────────────────

  String _subtitle(String key) {
    switch (key) {
      case 'Airline':
        return filterAirline.value.isEmpty
            ? 'All airlines'
            : filterAirline.value;
      case 'Price Range':
        final min = filterPriceMin.value.toStringAsFixed(0);
        final max =
            filterPriceMax.value >= priceMax
                ? 'Any'
                : filterPriceMax.value.toStringAsFixed(0);
        return '\$$min – \$$max';
      case 'Stops':
        final match = _stopOptions.firstWhere(
          (s) => s['value'] == filterStops.value,
          orElse: () => {'label': 'Any'},
        );
        return match['label'] as String;
      case 'Aircraft Type':
        return filterAircraftType.value.isEmpty
            ? 'All types'
            : filterAircraftType.value;
      default:
        return '';
    }
  }

  // ── sub-content for each section ─────────────────────────────────────────────

  Widget _sectionContent(String key, BuildContext context) {
    switch (key) {
      case 'Airline':
        return Obx(() {
          final controller = Get.find<FlightController>();

          if (controller.isLoadingAirlines.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final options = controller.airlineOptions;

          if (options.isEmpty) {
            return const Text(
              'No airlines found.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'Search airlines...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                ),
                onChanged: controller.onAirlineSearchChanged,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    options.map((airline) {
                      final selected = filterAirline.value == airline;
                      return _ChoiceChip(
                        label: airline,
                        selected: selected,
                        onTap:
                            () => filterAirline.value = selected ? '' : airline,
                      );
                    }).toList(),
              ),
            ],
          );
        });

      case 'Price Range':
        return Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${filterPriceMin.value.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    filterPriceMax.value >= priceMax
                        ? 'Any'
                        : '\$${filterPriceMax.value.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              RangeSlider(
                values: RangeValues(filterPriceMin.value, filterPriceMax.value),
                min: 0,
                max: priceMax,
                divisions: 50,
                activeColor: AppColors.primary,
                inactiveColor: Colors.grey.shade200,
                onChanged: (v) {
                  filterPriceMin.value = v.start;
                  filterPriceMax.value = v.end;
                },
              ),
            ],
          ),
        );

      case 'Stops':
        return Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _stopOptions.map((s) {
                  final selected = filterStops.value == s['value'];
                  return _ChoiceChip(
                    label: s['label'] as String,
                    selected: selected,
                    onTap: () => filterStops.value = s['value'] as int,
                  );
                }).toList(),
          ),
        );

      case 'Aircraft Type':
        return Obx(() {
          final controller = Get.find<FlightController>();

          if (controller.isLoadingAircraftTypes.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final options = controller.aircraftTypeOptions;

          if (options.isEmpty) {
            return const Text(
              'No aircraft types found.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'Search aircraft types...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                ),
                onChanged: controller.onAircraftTypeSearchChanged,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    options.map((type) {
                      final selected = filterAircraftType.value == type;
                      return _ChoiceChip(
                        label: type,
                        selected: selected,
                        onTap:
                            () =>
                                filterAircraftType.value = selected ? '' : type,
                      );
                    }).toList(),
              ),
            ],
          );
        });

      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Reusable expandable section tile ────────────────────────────────────────

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.subtitle,
    required this.isExpanded,
    required this.onTap,
    required this.content,
  });

  final String title;
  final String subtitle;
  final bool isExpanded;
  final VoidCallback onTap;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: content,
          ),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

// ─── Reusable choice chip ─────────────────────────────────────────────────────

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: selected ? Colors.white : Colors.black87,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
