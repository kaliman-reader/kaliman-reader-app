import 'package:flutter/material.dart';

class TheAppDrawer extends StatelessWidget {
  const TheAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
              decoration: BoxDecoration(
                color: Color(Theme.of(context).scaffoldBackgroundColor.value),
              ),
              padding: const EdgeInsets.all(0),
              child: FittedBox(
                fit: BoxFit.fitWidth,
                clipBehavior: Clip.antiAlias,
                child: Image.asset('assets/kaliman-cover.jpg'),
              )),
          ListTile(
            onTap: () {},
            leading: Icon(Icons.star,
                color: Color(Theme.of(context).colorScheme.primary.value)),
            title: const Text('Danos amor'),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
            },
            leading: Icon(Icons.share,
                color: Color(Theme.of(context).colorScheme.primary.value)),
            title: const Text('Comparte con tus amigos'),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
            },
            leading: Icon(Icons.facebook_outlined,
                color: Color(Theme.of(context).colorScheme.primary.value)),
            title: const Text('Grupo de Facebook'),
          ),
        ],
      ),
    );
  }
}
