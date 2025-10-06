import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/src/models/checkout_response.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  bool isProcessing = false;
  String confirmationMessage = 'Do you want to cancel payment?';
  bool alwaysPop = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        await _handlePop();
      },
      child: buildChild(context),
    );
  }

  Widget buildChild(BuildContext context);

  Future<void> _handlePop() async {
    if (isProcessing) {
      return;
    }

    var returnValue = getPopReturnValue();
    if (alwaysPop || (returnValue != null && (returnValue is CheckoutResponse && returnValue.status == true))) {
      Navigator.of(context).pop(returnValue);
      return;
    }

    var text = new Text(confirmationMessage);

    var dialog = Platform.isIOS
        ? new CupertinoAlertDialog(
            content: text,
            actions: <Widget>[
              new CupertinoDialogAction(
                child: const Text('Yes'),
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
              new CupertinoDialogAction(
                child: const Text('No'),
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
            ],
          )
        : new AlertDialog(
            content: text,
            actions: <Widget>[
              new TextButton(
                  child: const Text('NO'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  }),
              new TextButton(
                  child: const Text('YES'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  })
            ],
          );

    bool exit = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => dialog,
        ) ??
        false;

    if (exit) {
      Navigator.of(context).pop(returnValue);
    }
  }

  void onCancelPress() async {
    await _handlePop();
  }

  getPopReturnValue() {
    return null;
  }
}
