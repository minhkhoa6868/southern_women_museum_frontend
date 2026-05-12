import 'package:flutter/material.dart';

import '../../core/theme/text_styles.dart';
import '../../models/artifact_model.dart';

Future<void> showArtifactDetailModal({
  required BuildContext context,
  required Artifact artifact,
  required Color primary,
  required Color textColor,
  String locationLabel = 'Ao Dai Gallery',
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return ArtifactDetailModal(
        artifact: artifact,
        primary: primary,
        textColor: textColor,
        locationLabel: locationLabel,
      );
    },
  );
}

class ArtifactDetailModal extends StatelessWidget {
  const ArtifactDetailModal({
    super.key,
    required this.artifact,
    required this.primary,
    required this.textColor,
    this.locationLabel = 'Ao Dai Gallery',
  });

  final Artifact artifact;
  final Color primary;
  final Color textColor;
  final String locationLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        color: surface,
        child: DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 350,
                        color: Colors.black.withValues(alpha: 0.3),
                        child:
                            artifact.imgUrl != null &&
                                artifact.imgUrl!.isNotEmpty
                            ? Image.network(
                                artifact.imgUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, _) => Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 48,
                                    color: textColor.withValues(alpha: 0.3),
                                  ),
                                ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color: textColor.withValues(alpha: 0.3),
                                ),
                              ),
                      ),
                      Positioned(
                        right: 16,
                        top: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.5),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(artifact.name, style: AppTextStyles.h3(textColor)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              artifact.formattedDate.isNotEmpty
                                  ? artifact.formattedDate
                                  : 'No date available',
                              style: AppTextStyles.h6(primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 16,
                              color: primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                (artifact.roomName?.isNotEmpty ?? false)
                                    ? artifact.roomName!
                                    : locationLabel,
                                style: AppTextStyles.h5(textColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Divider(
                          color: textColor.withValues(alpha: 0.1),
                          height: 1,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          artifact.description.isNotEmpty
                              ? artifact.description
                              : artifact.descriptionEn,
                          style: AppTextStyles.h6(
                            textColor.withValues(alpha: 0.75),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
