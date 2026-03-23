import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';
import 'package:secure_link/features/auth/domain/bloc/user_bloc.dart';
import 'package:secure_link/features/auth/domain/bloc/user_state.dart';

/// Avatar réutilisable : affiche la photo si disponible, sinon les initiales,
/// sinon un shimmer pendant le chargement.
class UserAvatar extends StatelessWidget {
  final double size;
  final double fontSize;

  const UserAvatar({super.key, this.size = 42, this.fontSize = 14});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final bloc = context.read<UserBloc>();
        final pictureBytes = bloc.profilePictureBytes;
        final user = state is UserLoaded ? state.user : bloc.cachedUser;
        final isLoading = state is UserLoading ||
            (pictureBytes == null && state is! UserProfilePictureNone);

        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.primaryDark,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: pictureBytes != null
                ? Image.memory(pictureBytes,
                    fit: BoxFit.cover, width: size, height: size)
                : isLoading
                    ? _ShimmerCircle(size: size)
                    : Center(
                        child: Text(
                          user?.initials.isNotEmpty == true
                              ? user!.initials
                              : '??',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: fontSize,
                            fontFamily: AppConstants.fontFamilySofiaSans,
                          ),
                        ),
                      ),
          ),
        );
      },
    );
  }
}

class _ShimmerCircle extends StatefulWidget {
  final double size;
  const _ShimmerCircle({required this.size});

  @override
  State<_ShimmerCircle> createState() => _ShimmerCircleState();
}

class _ShimmerCircleState extends State<_ShimmerCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.size,
        height: widget.size,
        color: AppColors.white.withValues(alpha: _anim.value),
      ),
    );
  }
}
