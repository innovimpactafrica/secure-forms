import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_routes.dart';
import 'package:secure_link/features/client/domain/bloc/notifications_bloc.dart';
import 'package:secure_link/features/client/domain/bloc/notifications_state.dart';
import 'package:secure_link/features/client/presentation/pages/notifications_screen.dart';
import 'package:secure_link/core/widgets/user_avatar.dart';

class HomeHeader extends StatelessWidget {
  final String initials;
  const HomeHeader({super.key, required this.initials});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/images/qf.png', width: 160, height: 55, fit: BoxFit.contain, alignment: Alignment.centerLeft),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<NotificationsBloc>(),
                      child: const NotificationsScreen(),
                    ),
                  ),
                ),
                child: const HomeNotifBadge(),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.clientProfil),
                child: const UserAvatar(size: 42, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeNotifBadge extends StatelessWidget {
  const HomeNotifBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        final unread = state is NotificationsLoaded
            ? state.notifications.where((n) => !n.isRead).length
            : 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_outlined, size: 26, color: AppColors.textBlack87),
            if (unread > 0)
              Positioned(
                top: -3,
                right: -3,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: const BoxDecoration(color: AppColors.statusRejected, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: const TextStyle(color: AppColors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
