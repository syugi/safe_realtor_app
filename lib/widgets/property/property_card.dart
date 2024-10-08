import 'package:flutter/material.dart';
import 'package:safe_realtor_app/screens/property/property_detail_screen.dart';
import 'package:safe_realtor_app/models/Property.dart';
import 'package:safe_realtor_app/services/property_service.dart';

import 'package:safe_realtor_app/utils/message_utils.dart';
import 'package:safe_realtor_app/mixins/login_helper.dart';
import 'package:safe_realtor_app/utils/user_utils.dart';

class PropertyCard extends StatefulWidget {
  final Property property;

  const PropertyCard({super.key, required this.property});

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard>
    with LoginHelper<PropertyCard> {
  final PropertyService _propertyService = PropertyService();

  void _toggleFavorite() async {
    bool loggedIn = await isLoggedIn();
    if (loggedIn) {
      try {
        setState(() {
          widget.property.isFavorite = !widget.property.isFavorite;
          if (widget.property.isFavorite) {
            _propertyService.addFavorite(widget.property.id);
          } else {
            _propertyService.removeFavorite(widget.property.id);
          }
        });
      } catch (e) {
        showErrorMessage(context, '찜 상태를 변경하는 중 오류가 발생했습니다.',
            error: e.toString());
      }
    } else {
      showLoginBottomSheet(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PropertyDetailScreen(property: widget.property),
            ),
          );
        },
        child: Card(
          child: Row(
            children: <Widget>[
              _buildPropertyImage(widget.property),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${widget.property.type} ${widget.property.price}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                          '${widget.property.roomType}, ${widget.property.floor}, ${widget.property.area}㎡',
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('관리비 ${widget.property.maintenanceFee}',
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(widget.property.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  widget.property.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: widget.property.isFavorite ? Colors.red : null,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
        ));
  }

  Widget _buildPropertyImage(Property property) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(4.0),
        bottomLeft: Radius.circular(4.0),
      ),
      child: Image.network(
        property.thumbnailUrl,
        width: 150,
        height: 150,
        fit: BoxFit.cover,
      ),
    );
  }
}
