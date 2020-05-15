import 'package:flutter/material.dart';

Future buildShowDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('An Error occured'),
      content: Text('Something went wrong'),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text('Ok'),
        ),
      ],
    ),
  );
}
