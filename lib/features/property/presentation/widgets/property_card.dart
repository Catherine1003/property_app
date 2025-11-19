import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/property.dart';

class PropertyCard extends StatefulWidget {
  final Property property;

  const PropertyCard({
    Key? key,
    required this.property,
  }) : super(key: key);

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/property-detail',
          arguments: widget.property,
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusLarge),
                    topRight: Radius.circular(AppTheme.radiusLarge),
                  ),
                  child: Image.network(
                    widget.property.images[0],
                    height: isMobile ? 200 : 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: isMobile ? 200 : 150,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppTheme.radiusLarge),
                          topRight: Radius.circular(AppTheme.radiusLarge),
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: AppTheme.spacing12,
                  right: AppTheme.spacing12,
                  child: _StatusBadge(status: widget.property.status),
                ),

                Positioned(
                  bottom: AppTheme.spacing12,
                  left: AppTheme.spacing12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing12,
                      vertical: AppTheme.spacing8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius:
                      BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.visibility,
                          color: AppColors.white,
                          size: 16,
                        ),
                        const SizedBox(width: AppTheme.spacing4),
                        Text(
                          '${widget.property.views}',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
                              style: Theme.of(context).textTheme.titleMedium,
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
                                    style:
                                    Theme.of(context).textTheme.bodySmall,
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
                        label: '${widget.property.area.toStringAsFixed(0)} m²',
                      ),
                    ],
                  ),

                  if (widget.property.tags.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacing12),
                    Wrap(
                      spacing: AppTheme.spacing8,
                      runSpacing: AppTheme.spacing4,
                      children: widget.property.tags
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
      padding: EdgeInsets.symmetric(
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