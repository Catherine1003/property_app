import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/property.dart';
import '../bloc/property_bloc.dart';
import '../bloc/property_event.dart';
import '../bloc/property_state.dart';
import '../widgets/app_drawer.dart';
import '../widgets/filter_widget.dart';
import '../widgets/loading_shimmer.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({Key? key}) : super(key: key);

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  late ScrollController _scrollController;
  late PageStorageKey<String> storageKey;

  static const int initialPageSize = 10;
  static const int nextPageLoadThreshold = 5;
  static const int itemsPerPage = 10;

  String _currentVisibleIndex = "";
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    storageKey = const PageStorageKey('property_list');
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    context.read<PropertyBloc>().add(
      const FetchPropertiesEvent(
        page: 1,
        isRefresh: true,
      ),
    );



  }

  void _onScroll() {
    final state = context.read<PropertyBloc>().state;

    if (state is! PropertyLoaded) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final threshold = maxScroll - (itemsPerPage * 100);

    if (currentScroll >= threshold &&
        state.hasMore &&
        !_isLoadingMore) {
      _isLoadingMore = true;

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.read<PropertyBloc>().add(const LoadMorePropertiesEvent());
          _isLoadingMore = false;
        }
      });
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        onApplyFilter: (filter) {

          _scrollController.jumpTo(0);
          context.read<PropertyBloc>().add(FilterPropertiesEvent(filter));
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showFilterSheet,
            tooltip: 'Filter',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: BlocBuilder<PropertyBloc, PropertyState>(
        builder: (context, state) {

          if (state is PropertyInitial || state is PropertyLoading) {
            return _buildInitialShimmerLoader(isMobile);
          }

          if (state is PropertyError) {
            return _buildErrorState(context);
          }

          if (state is PropertyLoaded) {

            if (state.properties.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                _scrollController.jumpTo(0);
                context.read<PropertyBloc>().add(
                  const FetchPropertiesEvent(isRefresh: true),
                );
              },
              child: _buildPropertyList(
                context,
                state,
                isMobile,
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildInitialShimmerLoader(bool isMobile) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
        child: LoadingShimmer(
          height: isMobile ? 280 : 200,
          borderRadius: AppTheme.radiusLarge,
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            context.read<PropertyBloc>().state is PropertyError
                ? (context.read<PropertyBloc>().state as PropertyError).message
                : 'Failed to load properties',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppTheme.spacing24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<PropertyBloc>().add(
                const FetchPropertiesEvent(isRefresh: true),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_work_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            'No properties found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            'Try adjusting your filters',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTheme.spacing24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<PropertyBloc>().add(const ResetFiltersEvent());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyList(
      BuildContext context,
      PropertyLoaded state,
      bool isMobile,
      ) {
    return ListView.builder(
      key: storageKey,
      controller: _scrollController,
      padding: const EdgeInsets.all(AppTheme.spacing16),
      itemCount: state.properties.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {

        if (index == state.properties.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppTheme.spacing16,
            ),
            child: Column(
              children: [
                LoadingShimmer(
                  height: isMobile ? 280 : 200,
                  borderRadius: AppTheme.radiusLarge,
                ),
                const SizedBox(height: AppTheme.spacing12),
                Text(
                  'Loading more properties...',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        }

        final property = state.properties[index];

        _trackPropertyVisibility(context, property);

        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
          child: _PropertyCardLazy(
            property: property,
            index: index,
          ),
        );
      },
    );
  }

  void _trackPropertyVisibility(BuildContext context, Property property) {

    if (_currentVisibleIndex != property.id) {
      _currentVisibleIndex = property.id;

      context.read<PropertyBloc>().add(
        TrackPropertyInteractionEvent(
          propertyId: property.id,
          action: 'visible_in_list',
        ),
      );
    }
  }
}

class _PropertyCardLazy extends StatefulWidget {
  final Property property;
  final int index;

  const _PropertyCardLazy({
    required this.property,
    required this.index,
  });

  @override
  State<_PropertyCardLazy> createState() => _PropertyCardLazyState();
}

class _PropertyCardLazyState extends State<_PropertyCardLazy> {
  late GlobalKey _cardKey;

  @override
  void initState() {
    super.initState();
    _cardKey = GlobalKey();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _cardKey,
      onTap: () {

        print("************ STEP 1");
        context.read<PropertyBloc>().add(
          TrackPropertyInteractionEvent(
            propertyId: widget.property.id,
            action: 'card_tapped',
          ),
        );

        print("************ STEP 2");
        Navigator.pushNamed(
          context,
          '/property-detail',
          arguments: widget.property,
        );
        print("************ STEP 3");
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _LazyPropertyImage(
              imageUrl: widget.property.images[0],
              status: widget.property.status,
              views: widget.property.views,
            ),

            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.property.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                              Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppTheme.spacing4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: AppTheme.spacing4),
                                Flexible(
                                  child: Text(
                                    widget.property.location?.city ?? "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      Text(
                        '\$${widget.property.price.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.priceColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing12),

                  Row(
                    children: [
                      _FeatureChip(
                        icon: Icons.bed,
                        label: '${widget.property.bedrooms}',
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      _FeatureChip(
                        icon: Icons.shower,
                        label: '${widget.property.bathrooms}',
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      _FeatureChip(
                        icon: Icons.straighten,
                        label:
                        '${widget.property.area.toStringAsFixed(0)} m²',
                      ),
                    ],
                  ),

                  if (widget.property.tags.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacing12),
                    Wrap(
                      spacing: AppTheme.spacing8,
                      runSpacing: AppTheme.spacing4,
                      children: widget.property.tags
                          .take(3)
                          .map((tag) => Chip(
                        label: Text(tag),
                        labelStyle: const TextStyle(
                          fontSize: 11,
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                      ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}




































































class _LazyPropertyImage extends StatefulWidget {
  final String imageUrl;
  final String status;
  final int views;

  const _LazyPropertyImage({
    required this.imageUrl,
    required this.status,
    required this.views,
  });

  @override
  State<_LazyPropertyImage> createState() => _LazyPropertyImageState();
}

class _LazyPropertyImageState extends State<_LazyPropertyImage> {
  late bool isMobile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isMobile = MediaQuery.of(context).size.width < 600;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppTheme.radiusLarge),
            topRight: Radius.circular(AppTheme.radiusLarge),
          ),
          child: _buildImage(),
        ),

        Positioned(
          top: AppTheme.spacing12,
          right: AppTheme.spacing12,
          child: _StatusBadge(status: widget.status),
        ),

        Positioned(
          bottom: AppTheme.spacing12,
          left: AppTheme.spacing12,
          child: _buildViewCount(),
        ),
      ],
    );
  }

  Widget _buildImage() {

    if (widget.imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    return Image.network(
      widget.imageUrl,
      height: isMobile ? 200 : 150,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return Container(
          height: isMobile ? 200 : 150,
          color: AppColors.surface,
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: isMobile ? 200 : 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusLarge),
          topRight: Radius.circular(AppTheme.radiusLarge),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported,
                size: 40, color: AppColors.textSecondary),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Image unavailable',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewCount() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing12,
        vertical: AppTheme.spacing8,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility, color: AppColors.white, size: 16),
          const SizedBox(width: AppTheme.spacing4),
          Text(
            '${widget.views}',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'available':
        bgColor = AppColors.availableColor;
        textColor = AppColors.white;
        break;
      case 'sold':
        bgColor = AppColors.soldColor;
        textColor = AppColors.white;
        break;
      case 'upcoming':
        bgColor = AppColors.upcomingColor;
        textColor = AppColors.white;
        break;
      default:
        bgColor = AppColors.primary;
        textColor = AppColors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing12,
        vertical: AppTheme.spacing4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing12,
        vertical: AppTheme.spacing8,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: AppTheme.spacing4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}