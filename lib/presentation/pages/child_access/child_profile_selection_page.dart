import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/family_child.dart';
import 'package:kidsdo/presentation/controllers/child_access_controller.dart';
import 'package:kidsdo/presentation/widgets/auth/parental_pin_dialog.dart';
import 'package:kidsdo/presentation/widgets/common/cached_avatar.dart';
import 'package:kidsdo/routes.dart';

class ChildProfileSelectionPage extends StatefulWidget {
  const ChildProfileSelectionPage({super.key});

  @override
  State<ChildProfileSelectionPage> createState() =>
      _ChildProfileSelectionPageState();
}

class _ChildProfileSelectionPageState extends State<ChildProfileSelectionPage>
    with TickerProviderStateMixin {
  final ChildAccessController childAccessController = Get.find();
  AnimationController? _animationController;
  List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();
    // Initial load and animation setup
    _loadProfilesAndAnimate();

    // Listen for changes in available children to re-initialize animations
    ever(childAccessController.availableChildren, (_) {
      _disposeAnimationController(); // Dispose existing controller safely
      _loadProfilesAndAnimate(); // Re-initialize animations
    });
  }

  void _loadProfilesAndAnimate() {
    // Ensure profiles are loaded before trying to animate
    if (childAccessController.status.value != ChildAccessStatus.loading) {
      childAccessController.loadAvailableChildProfiles().then((_) {
        if (mounted && childAccessController.availableChildren.isNotEmpty) {
          _initializeAnimations();
        }
      });
    } else {
      // If already loading, wait for it to complete via the `ever` listener or Obx
    }
  }

  void _initializeAnimations() {
    if (!mounted) return; // Ensure widget is still in the tree

    final numberOfChildren = childAccessController.availableChildren.length;
    if (numberOfChildren == 0) return;

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500 + (numberOfChildren * 150)),
    );

    _animations = List.generate(
      numberOfChildren,
      (index) => CurvedAnimation(
        parent: _animationController!,
        curve: Interval(
          (index * 150).toDouble() /
              _animationController!.duration!.inMilliseconds,
          (500 + index * 150).toDouble() /
              _animationController!.duration!.inMilliseconds,
          curve: Curves.easeOut,
        ),
      ),
    );
    _animationController!.forward();
  }

  void _disposeAnimationController() {
    _animationController?.stop(); // Stop any ongoing animation
    _animationController?.dispose();
    _animationController = null;
    _animations = [];
  }

  @override
  void dispose() {
    _disposeAnimationController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/child_profile_selection_background.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: AppColors.childBlue);
                },
              ),
            ),
            Column(
              children: [
                const SizedBox(height: AppDimensions.xl),
                Text(
                  Tr.t(TrKeys.whoIsUsing),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: AppDimensions
                        .fontHeading, // Using 30.0 as a fallback if needed
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 4.0,
                        color: Colors.black.withValues(alpha: 0.3),
                        offset: const Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),
                Expanded(
                  child: Obx(() {
                    // Re-initialize animations if controller was disposed or children changed
                    // and we are in a success state with children
                    if (childAccessController.status.value ==
                            ChildAccessStatus.success &&
                        childAccessController.availableChildren.isNotEmpty &&
                        (_animationController == null ||
                            _animations.length !=
                                childAccessController
                                    .availableChildren.length)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          _disposeAnimationController();
                          _initializeAnimations();
                        }
                      });
                    }

                    switch (childAccessController.status.value) {
                      case ChildAccessStatus.loading:
                      case ChildAccessStatus
                            .initial: // Treat initial as loading for UI
                        return const Center(
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white)));
                      case ChildAccessStatus.error:
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppDimensions.lg),
                            child: Text(
                              childAccessController.errorMessage.isNotEmpty
                                  ? childAccessController.errorMessage.value
                                  : Tr.t(TrKeys.unexpectedErrorMessage),
                              style: TextStyle(
                                  color: Colors.red.shade300,
                                  fontSize: AppDimensions.fontLg),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      case ChildAccessStatus.success:
                        if (childAccessController.availableChildren.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppDimensions.lg),
                              child: Text(
                                Tr.t(TrKeys.noChildProfilesSelectMessage),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: AppDimensions.fontXl,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }

                        final children =
                            childAccessController.availableChildren;

                        // Ensure animations list matches children count, providing a fallback
                        final currentAnimations = _animations.length ==
                                children.length
                            ? _animations
                            : List.generate(
                                children.length,
                                (_) =>
                                    const AlwaysStoppedAnimation<double>(1.0));

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            if (children.length <= 3) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: List.generate(
                                  children.length,
                                  (index) => _ChildAvatarItem(
                                    child: children[index],
                                    entryAnimation: currentAnimations[index],
                                  ),
                                ),
                              );
                            } else {
                              return GridView.builder(
                                padding: const EdgeInsets.all(AppDimensions.md),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.8,
                                  crossAxisSpacing: AppDimensions.md,
                                  mainAxisSpacing: AppDimensions.md,
                                ),
                                itemCount: children.length,
                                itemBuilder: (context, index) {
                                  return _ChildAvatarItem(
                                    child: children[index],
                                    entryAnimation: currentAnimations[index],
                                  );
                                },
                              );
                            }
                          },
                        );
                    }
                  }),
                ),
              ],
            ),
            Positioned(
              bottom: AppDimensions.lg,
              right: AppDimensions.lg,
              child: IconButton(
                icon: const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: Colors.white,
                  size: AppDimensions.iconXl,
                ),
                tooltip: Tr.t(TrKeys.parentAccessButtonTooltip),
                onPressed: () async {
                  final result = await ParentalPinDialog.show();
                  if (result == true) {
                    childAccessController.exitChildMode();
                    Get.offAllNamed(Routes.mainParent);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildAvatarItem extends StatefulWidget {
  final FamilyChild child;
  final Animation<double> entryAnimation;

  const _ChildAvatarItem({required this.child, required this.entryAnimation});

  @override
  State<_ChildAvatarItem> createState() => _ChildAvatarItemState();
}

class _ChildAvatarItemState extends State<_ChildAvatarItem> {
  bool _isPressed = false;
  final ChildAccessController childAccessController = Get.find();

  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return AppColors.primary; // Default color
    }
    try {
      // Handles format "Color(0xffaabbcc)"
      String valueString = colorString.split('(0x')[1].split(')')[0];
      int value = int.parse(valueString, radix: 16);
      return Color(value);
    } catch (e) {
      // Fallback for simple color names or if parsing fails
      switch (colorString.toLowerCase()) {
        case 'purple':
          return AppColors.childPurple;
        case 'blue':
          return AppColors.childBlue;
        case 'green':
          return AppColors.childGreen;
        case 'orange':
          return AppColors.childOrange;
        case 'pink':
          return AppColors.childPink;
        case 'teal':
          return AppColors.childTeal;
        default:
          return AppColors.primary;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double avatarRadius = 50.0;

    Color itemColor = AppColors.primary; // Default
    final dynamic colorSetting = widget.child.settings['color'];

    if (colorSetting is Color) {
      itemColor = colorSetting;
    } else if (colorSetting is String) {
      itemColor = _parseColor(colorSetting);
    }

    return FadeTransition(
      opacity: widget.entryAnimation,
      child: ScaleTransition(
        scale: widget.entryAnimation,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            childAccessController.activateChildProfile(widget.child);
            Get.toNamed(Routes.childDashboard); // Navigate to child dashboard
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.child.avatarUrl != null &&
                    widget.child.avatarUrl!.isNotEmpty)
                  CachedAvatar(
                      url: widget.child.avatarUrl!, radius: avatarRadius)
                else
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: itemColor,
                    child: const Icon(Icons.person,
                        size: avatarRadius, color: Colors.white),
                  ),
                const SizedBox(height: AppDimensions.sm),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppDimensions.xs),
                  child: Text(
                    widget.child.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppDimensions.fontLg,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          blurRadius: 2.0,
                          color: Colors.black.withValues(alpha: 0.5),
                          offset: const Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
