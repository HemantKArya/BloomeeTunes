import 'package:Bloomee/blocs/notification/notification_cubit.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

import 'notification_views/notification_tile.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          context.read<NotificationCubit>().clearNotification();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                context.read<NotificationCubit>().clearNotification();
              },
              icon: const Icon(
                MingCute.broom_fill,
                color: Default_Theme.primaryColor1,
              ),
            ),
          ],
          title: Text(
            'Notifications',
            style: const TextStyle(
                    color: Default_Theme.primaryColor1,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)
                .merge(Default_Theme.secondoryTextStyle),
          ),
        ),
        body: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state is NotificationInitial || state.notifications.isEmpty) {
              return const Center(
                child: SignBoardWidget(
                    message: "No Notifications yet!",
                    icon: MingCute.notification_off_line),
              );
            }
            return ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                return NotificationTile(
                  notification: state.notifications[index],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
