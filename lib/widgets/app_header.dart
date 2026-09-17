import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          padding:
              const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color:
                colors.primaryContainer,
            borderRadius:
                BorderRadius.circular(19),
            border: Border.all(
              color: colors.primary
                  .withValues(
                    alpha: 0.10,
                  ),
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow
                    .withValues(
                      alpha: 0.07,
                    ),
                blurRadius: 12,
                offset:
                    const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(15),
            child: Image.asset(
              'assets/branding/app_logo.png',
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) {
                return Container(
                  color: colors.primary,
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 29,
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color: colors
                          .onSurfaceVariant,
                      height: 1.35,
                      fontWeight:
                          FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
