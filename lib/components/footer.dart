import 'package:auto_route/auto_route.dart';
import 'package:relines/router/app_router.gr.dart';
import 'package:relines/state/user.dart';
import 'package:relines/types/enums.dart';
import 'package:relines/utils/constants.dart';
import 'package:relines/utils/snack.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatefulWidget {
  final ScrollController pageScrollController;
  final bool closeModalOnNav;
  final bool autoNavToHome;

  Footer({
    this.autoNavToHome = true,
    this.pageScrollController,
    this.closeModalOnNav = false,
  });

  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 60.0,
        vertical: 90.0,
      ),
      foregroundDecoration: BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, 0.1),
      ),
      child: Wrap(
        runSpacing: 80.0,
        alignment: WrapAlignment.spaceAround,
        children: <Widget>[
          apps(),
          developers(),
          resourcesLinks(),
        ],
      ),
    );
  }

  Widget apps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            bottom: 30.0,
            left: 4.0,
          ),
          child: Opacity(
            opacity: 0.5,
            child: Text(
              'APPS',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
        ),
        TextButton.icon(
            onPressed: () => launch(Constants.webAppUrl),
            icon: Icon(UniconsLine.globe),
            label: Text('Web'),
            style: TextButton.styleFrom(
              primary: Colors.deepPurple,
            )),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: TextButton.icon(
              onPressed: () => launch(Constants.playStoreUrl),
              icon: Icon(UniconsLine.android),
              label: Text('Android'),
              style: TextButton.styleFrom(
                primary: Colors.green,
              )),
        ),
        TextButton.icon(
          onPressed: () => launch(Constants.appStoreUrl),
          icon: Icon(UniconsLine.store),
          label: Text('iOS'),
        ),
      ],
    );
  }

  Widget basicButtonLink({Function onTap, @required String textValue}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 6.0,
        ),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
            // side: BorderSide(),
          ),
        ),
        child: Opacity(
          opacity: onTap != null ? 0.7 : 0.3,
          child: Text(
            textValue,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget developers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            bottom: 30.0,
            left: 10.0,
          ),
          child: Opacity(
            opacity: 0.5,
            child: Text(
              'DEVELOPERS',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
        ),
        basicButtonLink(
          textValue: 'Dashboard',
          onTap: () => launch(Constants.developersPortal),
        ),
        basicButtonLink(
          textValue: 'Documentation',
        ),
        basicButtonLink(
          textValue: 'API References',
        ),
        basicButtonLink(
          textValue: 'API Status',
        ),
        basicButtonLink(
          textValue: 'GitHub',
          onTap: () async {
            onBeforeNav();
            await launch(Constants.githubUrl);
          },
        ),
      ],
    );
  }

  Widget resourcesLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            bottom: 30.0,
            left: 10.0,
          ),
          child: Opacity(
            opacity: 0.5,
            child: Text(
              'RESOURCES',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
        ),
        basicButtonLink(
          textValue: 'About',
          onTap: () {
            onBeforeNav();
            context.router.root.push(AboutRoute());
          },
        ),
        basicButtonLink(
          textValue: 'Contact',
          onTap: () {
            onBeforeNav();
            context.router.root.push(ContactRoute());
          },
        ),
        basicButtonLink(
          textValue: 'Privacy & Terms',
          onTap: () {
            onBeforeNav();
            context.router.root.push(TosRoute());
          },
        ),
      ],
    );
  }

  void notifyLangSuccess() {
    if (widget.pageScrollController != null) {
      widget.pageScrollController.animateTo(
        0.0,
        duration: Duration(seconds: 1),
        curve: Curves.easeOut,
      );
    } else if (widget.autoNavToHome) {
      context.router.root.navigate(HomeRoute());
    }

    showSnack(
      context: context,
      message: 'Your language has been successfully updated.',
      type: SnackType.success,
    );
  }

  void onBeforeNav() {
    if (widget.closeModalOnNav) {
      context.router.pop();
    }
  }

  void updateUserAccountLang() async {
    final userAuth = stateUser.userAuth;

    if (userAuth == null) {
      notifyLangSuccess();
      return;
    }
  }
}
