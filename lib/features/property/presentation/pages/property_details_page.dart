import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../../../config/app_colors.dart';
import '../../domain/entities/property.dart';
import '../widgets/camera_widget.dart';

class PropertyDetailsPage extends StatefulWidget {
  final Property property;

  const PropertyDetailsPage({super.key, required this.property});

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  List<String> images = [];

  @override
  void initState() {
    super.initState();
    images = [...widget.property.images];
  }

  void _addImageToProperty(dynamic imageData) {
    setState(() {
      images.insert(0, imageData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildImageAppBar(theme),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _titleAndPrice(theme),
                  const SizedBox(height: 16),
                  _highlightRow(theme),
                  const SizedBox(height: 20),
                  _section("Description", theme),
                  Text(widget.property.description, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 20),
                  _section("Location", theme),
                  _locationCard(theme),
                  const SizedBox(height: 20),
                  _section("Tags", theme),
                  _tagChips(theme),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildImageAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 280,
                viewportFraction: 1,
                autoPlay: true,
              ),
              items: images.map((url) {
                return (url.contains("http")
                ? Image.network(
                  url,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                : Image.asset(
                  url,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ));
              }).toList(),
            ),

            Positioned(
              top: 40,
              right: 16,
              child: _statusBadge(theme),
            ),

            Positioned(
              bottom: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => _openImageCapture(context),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_a_photo,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(ThemeData theme) {
    Color badgeColor;

    switch (widget.property.status) {
      case "Available":
        badgeColor = AppColors.availableColor;
        break;
      case "Sold":
        badgeColor = AppColors.soldColor;
        break;
      case "Upcoming":
        badgeColor = AppColors.upcomingColor;
        break;
      default:
        badgeColor = theme.colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        widget.property.status,
        style: theme.textTheme.titleSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _titleAndPrice(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.property.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          "₹${widget.property.price}",
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.priceColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _highlightRow(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _highlight(Icons.bed, "${widget.property.bedrooms} Beds", theme),
        _highlight(Icons.bathtub, "${widget.property.bathrooms} Baths", theme),
        _highlight(Icons.square_foot, "${widget.property.area} sqft", theme),
      ],
    );
  }

  Widget _highlight(IconData icon, String text, ThemeData theme) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        const SizedBox(height: 4),
        Text(text, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  Widget _section(String title, ThemeData theme) {
    return Text(title, style: theme.textTheme.titleLarge);
  }

  Widget _locationCard(ThemeData theme) {
    if (widget.property.location == null) {
      return Text(
        "No location information",
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    final loc = widget.property.location!;

    return Card(
      elevation: 2,
      color: theme.cardColor,
      child: ListTile(
        leading: Icon(Icons.location_on, color: theme.colorScheme.primary),
        title: Text(loc.address ?? "", style: theme.textTheme.bodyLarge),
        subtitle: Text(
          "${loc.city}, ${loc.state}, ${loc.zip}",
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _tagChips(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: widget.property.tags
          .map((tag) => Chip(
        label: Text(tag),
      ))
          .toList(),
    );
  }

  void _openImageCapture(BuildContext context) {
    if (kIsWeb) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => WebCameraCapturePage(
          onCaptured: (bytes) {
            _addImageToProperty(bytes);
          },
        )),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MobileCameraCapturePage(
          onCaptured: (path) {
            _addImageToProperty(path);
          },
        )),
      );
    }
  }
}
