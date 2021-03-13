import 'package:relines/components/desktop_app_bar.dart';
import 'package:relines/state/colors.dart';
import 'package:relines/types/changelog_item.dart';
import 'package:relines/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class Changelog extends StatefulWidget {
  @override
  _ChangelogState createState() => _ChangelogState();
}

class _ChangelogState extends State<Changelog> {
  List<ChangelogItem> changelogItemsList = [];

  @override
  void initState() {
    super.initState();
    initContent();
  }

  initContent() {
    changelogItemsList.addAll([
      itemChangelogTemplate(
        textTitle: "2.5.0",
        date: DateTime(2021, 01, 24),
        children: [
          descriptionRow("• Add routing system (for better navigation)"),
          descriptionRow("• Update icons"),
          descriptionRow("• Use better authentication management"
              " (-> real time updates)"),
          descriptionRow("• Re-design quote page (web)"),
          descriptionRow("• Update user dashboard layout (web)"),
          descriptionRow("• Update footer component and about page (web)"),
        ],
      ),
      itemChangelogTemplate(
        textTitle: "2.0.0",
        date: DateTime(2020, 12, 01),
        children: [
          descriptionRow("• Re-design add quote experience"),
          descriptionRow("• Re-design icon assets"),
          descriptionRow("• Fix push notifications"),
          descriptionRow("• Add share image quote"),
          descriptionRow("• Update quote page & other pages layout"),
          descriptionRow("• Add search by quotes, authors, references"),
          descriptionRow("• Add changelog"),
          descriptionRow("• Add swipe actions on quote tiles"),
          descriptionRow("• Re-work application icon"),
          descriptionRow("• Add onboarding"),
          descriptionRow("• Update first app's page"),
          descriptionRow("• Use better image preview"),
          descriptionRow("• Bug fixes and other improvements"),
        ],
      ),
      itemChangelogTemplate(
        textTitle: "1.3.0",
        date: DateTime(2020, 07, 22),
        children: [
          descriptionRow(
              "• Minor UI update: add a top right close button on quotidian page"),
        ],
      ),
      itemChangelogTemplate(
        textTitle: "1.2.3",
        date: DateTime(2020, 07, 08),
        children: [
          descriptionRow(
              "• Fix an issue where a draft without topics wouldn't show"),
          descriptionRow("• Speed up topics animation on add quote page"),
        ],
      ),
      itemChangelogTemplate(
        textTitle: "1.2.1",
        date: DateTime(2020, 06, 17),
        children: [
          descriptionRow(
              "• Fix a visual bug where link cards on author page would have a longer height than expected"),
        ],
      ),
      itemChangelogTemplate(
        textTitle: "1.2.0",
        date: DateTime(2020, 06, 15),
        children: [
          descriptionRow("• Add help center link"),
          descriptionRow("• Update design"),
          descriptionRow("• Add inputs format checks for username & email"),
          descriptionRow("• Add availability checks for email & username"),
          descriptionRow("• Better error messages"),
          descriptionRow("• Bug fixes"),
        ],
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    double horPadding = 80.0;

    if (width < Constants.maxMobileWidth) {
      horPadding = 20.0;
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          DesktopAppBar(),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: horPadding,
              vertical: 60.0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                titleContainer(),
                subtitleContainer(),
                expansionPanList(),
                onlineReleasesButton(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  ChangelogItem itemChangelogTemplate({
    @required DateTime date,
    @required String textTitle,
    List<Widget> children = const <Widget>[],
  }) {
    return ChangelogItem(
      title: Text(
        textTitle,
        style: TextStyle(
          fontSize: 18.0,
          color: stateColors.secondary,
          fontWeight: FontWeight.w700,
        ),
      ),
      date: date,
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget descriptionRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Opacity(
        opacity: 0.6,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget expansionPanList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 600.0,
          child: ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                changelogItemsList[index].isExpanded = !isExpanded;
              });
            },
            children: changelogItemsList.map((changelogItem) {
              final date = changelogItem.date;
              final day = date.day < 10 ? '0${date.day}' : date.day;
              final month = date.month < 10 ? '0${date.month}' : date.month;

              return ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return ListTile(
                    title: changelogItem.title,
                    subtitle: Opacity(
                      opacity: 0.5,
                      child: Text("$day/$month/${date.year}"),
                    ),
                    onTap: () {
                      setState(
                        () {
                          changelogItem.isExpanded = !changelogItem.isExpanded;
                        },
                      );
                    },
                  );
                },
                isExpanded: changelogItem.isExpanded,
                body: changelogItem.child,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget onlineReleasesButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Opacity(
          opacity: 0.6,
          child: InkWell(
            onTap: () =>
                launch("https://github.com/rootasjey/fig.style/releases"),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 20.0,
                children: [
                  Text(
                    "See releases online",
                    style: TextStyle(
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  Icon(
                    UniconsLine.external_link_alt,
                    size: 18.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget subtitleContainer() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Opacity(
        opacity: 0.4,
        child: Text(
          "You can find the app version history below",
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }

  Widget titleContainer() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Opacity(
        opacity: 0.8,
        child: Text(
          "Changelog",
          style: TextStyle(
            fontSize: 60.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
