import 'package:flutter/material.dart';
import 'AppStyles.dart';


class ArticleCard extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Card(
      margin: EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 8.0),
      child: new Container(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Container(
              padding: EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 8.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
                    child: new Text('Article Title', style: AppTextStyle.h6HighEmp),
                  ),
                  new Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
                    child: new Text('Author', style: AppTextStyle.body2HighEmp),
                  ),
                ],
              ),
            ),
            new Image.network("https://raw.githubusercontent.com/flutter/website/master/_includes/code/layout/lakes/images/lake.jpg"),
            new Container(
              padding: EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 8.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
                    child: new Text('Greyhound divisively hello coldly wonderfully marginally far upon...', style: AppTextStyle.body2MedEmp),
                  ),
                ],
              ),
            ),
            new ButtonTheme.bar(
              textTheme: ButtonTextTheme.primary,
              child: new ButtonBar(
                alignment: MainAxisAlignment.start,
                children: <Widget>[
                  new FlatButton(
                    child: new Text('READ'),
                    onPressed: () {},
                  )
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}