library numeric_input;

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum _InputAction { increment, decrement, reset }

enum Style {
  inline,
  inlineStackButtons,
  inlineSymmetric,
  roundStacked,
  roundInline
}

class NumericInput extends ConsumerWidget {
  NumericInput({
    Key? key,
    this.style = Style.inlineStackButtons,
    required this.textEditingController,
    this.initialValue = 0.00,
    this.label = '',
    this.labelTextStyle,
    this.inputTextStyle,
    this.isNegativeValid = false,
    this.isInteger = true,
    this.isDouble = false,
    this.readOnly = true,
    this.canReset = true,
    this.canIncrement = true,
    this.canDecrement = true,
    this.useMaterial,
    this.useCupertino,
    this.decoration,
    this.padding,
    this.prefix,
    this.suffix,
    this.prefixMode = OverlayVisibilityMode.always,
    this.suffixMode = OverlayVisibilityMode.always,
    this.clearButtonMode = OverlayVisibilityMode.never,
    this.dividerColor,
    this.incrementButtonColor,
    this.incrementButtonIconColor,
    this.decrementButtonColor,
    this.decrementButtonIconColor,
    this.resetButtonColor,
    this.resetButtonIconColor,
    this.iosTheme,
    this.inputBoxColor,
    this.borderRadius,
    this.borderStyle,
    this.borderWidth = 2.0,
    this.borderSide,
    this.inputBorderColor,
    this.materialTheme,
  })  : assert(isInteger != isDouble),
        assert(useCupertino == null || useMaterial == null),
        super(key: key);

  final String _counterId = 'numeric-input-${DateTime.now().toIso8601String()}';
  final TextEditingController textEditingController;
  late final Style style;
  late final _NumericBloc bloc;
  final num initialValue;
  final String label;
  final bool isNegativeValid;
  final bool isInteger;
  final bool isDouble;
  final bool readOnly;
  late final bool canReset;
  late final bool canIncrement;
  late final bool canDecrement;
  late final bool? useMaterial;
  late final bool? useCupertino;
  final BoxDecoration? decoration;
  final EdgeInsets? padding;
  final Widget? prefix;
  final Widget? suffix;
  final OverlayVisibilityMode prefixMode;
  final OverlayVisibilityMode suffixMode;
  final OverlayVisibilityMode clearButtonMode;
  final Color? dividerColor;
  final Color? inputBoxColor;
  final Color? inputBorderColor;
  final Color? incrementButtonColor;
  final Color? incrementButtonIconColor;
  final Color? decrementButtonColor;
  final Color? decrementButtonIconColor;
  final Color? resetButtonColor;
  final Color? resetButtonIconColor;
  final TextStyle? labelTextStyle;
  final TextStyle? inputTextStyle;
  final BorderRadius? borderRadius;
  final BorderStyle? borderStyle;
  final double borderWidth;
  final BorderSide? borderSide;
  final CupertinoThemeData? iosTheme;
  final ThemeData? materialTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bloc = isInteger
        ? _IntBloc(
            context: context,
            initialValue: initialValue.toInt(),
            isNegativeValid: isNegativeValid)
        : _DoubleBloc(
            context: context,
            initialValue: initialValue.toDouble(),
            isNegativeValid: isNegativeValid);
    bool _isIOS = false;
    if (useMaterial == null && useCupertino == null) {
      _isIOS = Platform.isIOS || Platform.isMacOS;
    } else if (useMaterial == true) {
      _isIOS = false;
    } else if (useCupertino == true) {
      _isIOS = true;
    }
    CupertinoThemeData? _iosTheme;
    ThemeData? _materialTheme;
    if (_isIOS) {
      _iosTheme = iosTheme ?? CupertinoTheme.of(context);
    } else {
      _materialTheme = materialTheme ?? Theme.of(context);
    }
    Color _dividerColor = dividerColor ?? Theme.of(context).dividerColor;
    Color _inputBoxColor = inputBoxColor ?? Theme.of(context).canvasColor;
    Color _inputBorderColor =
        inputBorderColor ?? Theme.of(context).primaryColorDark;
    Color _incrementButtonColor =
        incrementButtonColor ?? Theme.of(context).colorScheme.secondary;
    Color _incrementButtonIconColor =
        incrementButtonIconColor ?? Theme.of(context).colorScheme.onSecondary;
    Color _decrementButtonColor =
        decrementButtonColor ?? Theme.of(context).colorScheme.secondary;
    Color _decrementButtonIconColor =
        decrementButtonIconColor ?? Theme.of(context).colorScheme.onSecondary;
    Color _resetButtonColor =
        resetButtonColor ?? Theme.of(context).colorScheme.secondary;
    Color _resetButtonIconColor =
        resetButtonIconColor ?? Theme.of(context).colorScheme.onSecondary;
    BorderRadius _borderRadius =
        borderRadius ?? const BorderRadius.all(Radius.circular(4.0));
    BorderStyle _borderStyle = borderStyle ?? BorderStyle.solid;
    TextStyle _labelTextStyle = labelTextStyle ??
        TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 24,
            letterSpacing: 0);
    double _borderWidth = borderWidth;
    BorderSide _borderSide = borderSide ??
        BorderSide(
          color: _inputBorderColor,
          style: _borderStyle,
          width: _borderWidth,
        );
    final _WidgetParams params = _WidgetParams(
        _inputBoxColor,
        _dividerColor,
        _decrementButtonColor,
        _decrementButtonIconColor,
        _incrementButtonColor,
        _incrementButtonIconColor,
        _resetButtonColor,
        _resetButtonIconColor,
        _borderWidth,
        _borderSide,
        _borderRadius,
        _labelTextStyle,
        _isIOS);
    return _isIOS
        ? CupertinoTheme(data: _iosTheme!, child: _ioWidget(params))
        : Theme(data: _materialTheme!, child: _ioWidget(params));
  }

  Widget _ioWidget(_WidgetParams params) {
    switch (style) {
      case Style.inline:
        return _rowInline(params);
      case Style.inlineSymmetric:
        return rowSymmetric(params);
      case Style.inlineStackButtons:
        return _rowStack(params);
      case Style.roundStacked:
        return _roundStack(params);
      case Style.roundInline:
        return _roundInline(params);
    }
  }

  Widget _rowInline(_WidgetParams params) => Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 16),
            _rowDisplay(params.fieldColor, params.side, params.radius,
                params.labelStyle, params.isIOS),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  params.isIOS
                      ? const SizedBox(
                          height: 36,
                        )
                      : Container(),
                  Row(
                    children: [
                      canDecrement /* Decrement Button */
                          ? _decrementButton(params.decrementButtonColor,
                              params.decrementIconColor, params.isIOS)
                          : Container(),
                      (params.isIOS &&
                              (canDecrement && canIncrement ||
                                  canDecrement && canReset)) /* Divider */
                          ? _dividerHorizontal(params)
                          : Container(),
                      canIncrement /* Increment Button */
                          ? _incrementButton(params.incrementButtonColor,
                              params.incrementIconColor, params.isIOS)
                          : Container(),
                      (params.isIOS && canIncrement && canReset) /* Divider */
                          ? _dividerHorizontal(params)
                          : Container(),
                      canReset /* Clear Button */
                          ? _resetButton(params.resetButtonColor,
                              params.resetIconColor, params.isIOS)
                          : Container(),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ]);

  Widget rowSymmetric(_WidgetParams params) => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 16),
          Wrap(
            children: [
              Column(
                children: [
                  params.isIOS ? const SizedBox(height: 36) : Container(),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      canDecrement
                          ? _decrementButton(params.decrementButtonColor,
                              params.decrementIconColor, params.isIOS)
                          : Container()
                    ],
                  )
                ],
              ),
            ],
          ),
          const SizedBox(width: 16),
          _rowDisplay(params.fieldColor, params.side, params.radius,
              params.labelStyle, params.isIOS),
          const SizedBox(width: 16),
          Wrap(
            children: [
              Column(
                children: [
                  params.isIOS ? const SizedBox(height: 36) : Container(),
                  Row(
                    children: [
                      canIncrement /* Increment Button */
                          ? _incrementButton(params.incrementButtonColor,
                              params.incrementIconColor, params.isIOS)
                          : Container(),
                      (params.isIOS && canIncrement && canReset) /* Divider */
                          ? _dividerHorizontal(params)
                          : Container(),
                      canReset /* Clear Button */
                          ? _resetButton(params.resetButtonColor,
                              params.resetIconColor, params.isIOS)
                          : Container(),
                    ],
                  )
                ],
              ),
            ],
          ),
          const SizedBox(width: 16)
        ],
      );

  Widget _rowStack(_WidgetParams params) => Wrap(
        children: [
          Row(
            children: [
              const SizedBox(width: 16),
              _rowDisplay(params.fieldColor, params.side, params.radius,
                  params.labelStyle, params.isIOS),
              const SizedBox(width: 8),
              Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      _incrementButton(params.incrementButtonColor,
                          params.incrementIconColor, params.isIOS),
                      params.isIOS
                          ? _dividerVertical(params)
                          : const SizedBox(height: 6),
                      _decrementButton(params.decrementButtonColor,
                          params.decrementIconColor, params.isIOS),
                    ],
                  ),
                  params.isIOS ? _dividerHorizontal(params) : Container(),
                  _resetButton(params.resetButtonColor, params.resetIconColor,
                      params.isIOS),
                ],
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      );

  Widget _roundInline(_WidgetParams params) => Wrap(
        direction: Axis.horizontal,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 16),
              _decrementButton(params.decrementButtonColor,
                  params.decrementIconColor, params.isIOS),
              const SizedBox(width: 8),
              _rowDisplay(params.fieldColor, params.side, params.radius,
                  params.labelStyle, params.isIOS),
              const SizedBox(width: 8),
              _incrementButton(params.incrementButtonColor,
                  params.incrementIconColor, params.isIOS),
              params.isIOS ? _dividerHorizontal(params) : Container(),
              _resetButton(
                  params.resetButtonColor, params.resetIconColor, params.isIOS),
              const SizedBox(width: 16),
            ],
          ),
        ],
      );

  Widget _roundStack(_WidgetParams params) => Wrap(
        direction: Axis.horizontal,
        children: [
          Row(
            children: [
              const SizedBox(width: 16),
              Column(
                children: [
                  _incrementButton(params.incrementButtonColor,
                      params.incrementIconColor, params.isIOS),
                  params.isIOS ? _dividerVertical(params) : Container(),
                  _rowDisplay(params.fieldColor, params.side, params.radius,
                      params.labelStyle, params.isIOS),
                  params.isIOS ? _dividerVertical(params) : Container(),
                  _decrementButton(params.decrementButtonColor,
                      params.decrementIconColor, params.isIOS),
                ],
              ),
              params.isIOS ? _dividerHorizontal(params) : Container(),
              _resetButton(
                  params.resetButtonColor, params.resetIconColor, params.isIOS),
              const SizedBox(width: 16),
            ],
          ),
        ],
      );

  Widget _dividerHorizontal(_WidgetParams params) => Row(
        children: [
          SizedBox(width: params.borderWidth),
          Ink(
              width: params.borderWidth,
              height: 24,
              color: params.dividerColor),
          SizedBox(width: params.borderWidth),
        ],
      );
  Widget _dividerVertical(_WidgetParams params) => Column(
        children: [
          SizedBox(height: params.borderWidth),
          Ink(
              height: params.borderWidth,
              width: 24,
              color: params.dividerColor),
          SizedBox(height: params.borderWidth),
        ],
      );

  Widget _rowDisplay(Color fieldColor, BorderSide side, BorderRadius radius,
          TextStyle labelStyle, bool isIOS) =>
      (style == Style.roundInline || style == Style.roundStacked)
          ? SizedBox(
              width: 54,
              height: 54,
              child: StreamBuilder(
                  stream: bloc.stream,
                  initialData: initialValue,
                  builder: (context, snapshot) {
                    textEditingController.text = snapshot.data.toString();
                    return TextFormField(
                        textAlign: TextAlign.center,
                        controller: textEditingController,
                        readOnly: readOnly,
                        keyboardType: TextInputType.number,
                        style: inputTextStyle,
                        decoration: InputDecoration(
                          fillColor: fieldColor,
                          // labelText: label,
                          labelStyle: labelTextStyle,
                          border: OutlineInputBorder(
                            borderSide: side,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(27.0)),
                          ),
                        ));
                  }),
            )
          : Expanded(
              child: isIOS /* Text Display Area */
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        (label.isNotEmpty)
                            ? Padding(
                                padding: const EdgeInsets.only(left: 18),
                                child: Text(
                                  label,
                                  style: labelStyle,
                                ),
                              )
                            : Row(),
                        CupertinoFormRow(
                          child: StreamBuilder(
                            stream: bloc.stream,
                            initialData: initialValue,
                            builder: (context, snapshot) {
                              textEditingController.text =
                                  snapshot.data.toString();
                              return FormField(
                                builder: (FormFieldState<String> state) =>
                                    CupertinoTextField(
                                  key: key,
                                  style: inputTextStyle,
                                  padding: const EdgeInsets.all(12),
                                  controller: textEditingController,
                                  readOnly: readOnly,
                                  keyboardType: TextInputType.number,
                                  prefix: prefix,
                                  prefixMode: prefixMode,
                                  suffix: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: suffix,
                                  ),
                                  suffixMode: suffixMode,
                                  textAlign: TextAlign.start,
                                  clearButtonMode: clearButtonMode,
                                  placeholder: label,
                                  placeholderStyle: labelTextStyle,
                                  decoration: decoration ??
                                      BoxDecoration(
                                        color: fieldColor,
                                        border: Border(
                                          top: side,
                                          bottom: side,
                                          left: side,
                                          right: side,
                                        ),
                                        borderRadius: radius,
                                      ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: StreamBuilder(
                          stream: bloc.stream,
                          initialData: initialValue,
                          builder: (context, snapshot) {
                            textEditingController.text =
                                snapshot.data.toString();
                            return TextFormField(
                              readOnly: readOnly,
                              controller: textEditingController,
                              keyboardType: TextInputType.number,
                              style: inputTextStyle,
                              decoration: InputDecoration(
                                fillColor: fieldColor,
                                labelText: label,
                                labelStyle: labelTextStyle,
                                border: OutlineInputBorder(
                                  borderSide: side,
                                  borderRadius: radius,
                                ),
                              ),
                            );
                          }),
                    ),
            );
  Widget _decrementButton(Color buttonColor, Color iconColor, bool isIOS) =>
      Wrap(
        children: [
          isIOS
              ? SizedBox(
                  height: 36,
                  width: 36,
                  child: CupertinoButton.filled(
                    minSize: 24.0,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.remove,
                      color: iconColor,
                    ),
                    onPressed: () => bloc.decrement(),
                  ),
                )
              : FloatingActionButton(
                  backgroundColor: buttonColor,
                  heroTag: "decrement $_counterId",
                  mini: true,
                  child: Icon(
                    Icons.remove,
                    color: iconColor,
                  ),
                  onPressed: () => bloc.decrement(),
                ),
        ],
      );
  Widget _incrementButton(Color buttonColor, Color iconColor, bool isIOS) =>
      Wrap(
        children: [
          isIOS
              ? SizedBox(
                  height: 36,
                  width: 36,
                  child: CupertinoButton.filled(
                    minSize: 24.0,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.add,
                      color: iconColor,
                    ),
                    onPressed: () => bloc.increment(),
                  ),
                )
              : FloatingActionButton(
                  backgroundColor: buttonColor,
                  heroTag: "increment $_counterId",
                  mini: true,
                  child: Icon(
                    Icons.add,
                    color: iconColor,
                  ),
                  onPressed: () => bloc.increment(),
                ),
        ],
      );
  Widget _resetButton(Color buttonColor, Color iconColor, bool isIOS) => Wrap(
        children: [
          isIOS
              ? SizedBox(
                  height: 36,
                  width: 36,
                  child: CupertinoButton.filled(
                    minSize: 24.0,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.refresh,
                      color: iconColor,
                    ),
                    onPressed: () => bloc.reset(),
                  ),
                )
              : FloatingActionButton(
                  backgroundColor: buttonColor,
                  heroTag: "reset $_counterId",
                  mini: true,
                  child: Icon(
                    Icons.refresh,
                    color: iconColor,
                  ),
                  onPressed: () => bloc.reset(),
                ),
        ],
      );
}

class _IntBloc implements _NumericBloc {
  late int _counter;
  late final bool isNegativeValid;
  late final _stateStreamController = StreamController<int>();
  late final _eventStreamController = StreamController<_InputAction>();

  StreamSink<int> get _counterSink => _stateStreamController.sink;
  Stream<int> get _counterStream => _stateStreamController.stream;
  StreamSink<_InputAction> get _eventSink => _eventStreamController.sink;
  Stream<_InputAction> get _eventStream => _eventStreamController.stream;
  @override
  Stream<int> get stream => _counterStream;

  _IntBloc({
    required BuildContext context,
    required int initialValue,
    required bool isNegativeValid,
  }) {
    _counter = initialValue;
    _eventStream.listen((event) {
      switch (event) {
        case _InputAction.increment:
          _counter++;
          break;
        case _InputAction.decrement:
          {
            if (!isNegativeValid && _counter == 0) {
              break;
            }
            _counter--;
          }
          break;
        case _InputAction.reset:
          _counter = 0;
          break;
      }
      _counterSink.add(_counter);
    });
  }

  @override
  increment() => _eventSink.add(_InputAction.increment);
  @override
  decrement() => _eventSink.add(_InputAction.decrement);
  @override
  reset() => _eventSink.add(_InputAction.reset);
}

class _DoubleBloc implements _NumericBloc {
  late double _counter;
  late final bool isNegativeValid;
  late final _stateStreamController = StreamController<double>();
  late final _eventStreamController = StreamController<_InputAction>();

  StreamSink<double> get _counterSink => _stateStreamController.sink;
  Stream<double> get _counterStream => _stateStreamController.stream;
  StreamSink<_InputAction> get _eventSink => _eventStreamController.sink;
  Stream<_InputAction> get _eventStream => _eventStreamController.stream;
  @override
  Stream<double> get stream => _counterStream;

  _DoubleBloc({
    required BuildContext context,
    required double initialValue,
    required bool isNegativeValid,
  }) {
    _counter = initialValue;
    _eventStream.listen((event) {
      switch (event) {
        case _InputAction.increment:
          _counter++;
          break;
        case _InputAction.decrement:
          {
            if (!isNegativeValid && _counter == 0) {
              break;
            }
            _counter--;
          }
          break;
        case _InputAction.reset:
          _counter = 0;
          break;
      }
      _counterSink.add(_counter);
    });
  }

  @override
  increment() => _eventSink.add(_InputAction.increment);
  @override
  decrement() => _eventSink.add(_InputAction.decrement);
  @override
  reset() => _eventSink.add(_InputAction.reset);
}

abstract class _NumericBloc {
  Stream get stream;
  increment();
  decrement();
  reset();
}

class _WidgetParams {
  _WidgetParams(
      this.fieldColor,
      this.dividerColor,
      this.decrementButtonColor,
      this.decrementIconColor,
      this.incrementButtonColor,
      this.incrementIconColor,
      this.resetButtonColor,
      this.resetIconColor,
      this.borderWidth,
      this.side,
      this.radius,
      this.labelStyle,
      this.isIOS);
  Color fieldColor;
  Color dividerColor;
  Color decrementButtonColor;
  Color decrementIconColor;
  Color incrementButtonColor;
  Color incrementIconColor;
  Color resetButtonColor;
  Color resetIconColor;
  double borderWidth;
  BorderSide side;
  BorderRadius radius;
  TextStyle labelStyle;
  bool isIOS;
}
