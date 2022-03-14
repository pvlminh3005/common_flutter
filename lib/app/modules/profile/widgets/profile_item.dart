import 'package:flutter/material.dart';

import '../../../data/models/user_model.dart';

class ProfileItem extends StatelessWidget {
  final UserModel user;
  const ProfileItem(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 7.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
        boxShadow: [
          BoxShadow(
            offset: Offset(5, 4),
            blurRadius: 5,
            color: Colors.black12,
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(user.avatar!),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? '',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  user.age.toString(),
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
