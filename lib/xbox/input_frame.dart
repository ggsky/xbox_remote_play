import 'package:xbox_remote_play/xbox/input_key.dart';

class InputFrame {
  bool nexus = false;
  bool menu = false;
  bool view = false;
  bool a = false;
  bool b = false;
  bool x = false;
  bool y = false;
  bool dPadLeft = false;
  bool dPadUp = false;
  bool dPadRight = false;
  bool dPadDown = false;
  bool leftShoulder = false;
  bool rightShoulder = false;
  bool leftThumb = false;
  bool rightThumb = false;

  int leftStickXAxis = 0;
  int leftStickYAxis = 0;
  int rightStickXAxis = 0;
  int rightStickYAxis = 0;
  int leftTrigger = 0;
  int rightTrigger = 0;

  void Touch(InputKey key, bool state) {
    switch (key) {
      case InputKey.nexus:
        nexus = state;
        break;
      case InputKey.menu:
        menu = state;
        break;
      case InputKey.view:
        view = state;
        break;
      case InputKey.a:
        a = state;
        break;
      case InputKey.b:
        b = state;
        break;
      case InputKey.x:
        x = state;
        break;
      case InputKey.y:
        y = state;
        break;
      case InputKey.dpadLeft:
        dPadLeft = state;
        break;
      case InputKey.dpadUp:
        dPadUp = state;
        break;
      case InputKey.dpadRight:
        dPadRight = state;
        break;
      case InputKey.dpadDown:
        dPadDown = state;
        break;
      case InputKey.leftShoulder:
        leftShoulder = state;
        break;
      case InputKey.rightShoulder:
        rightShoulder = state;
        break;
      case InputKey.leftThumb:
        leftThumb = state;
        break;
      case InputKey.rightThumb:
        rightThumb = state;
        break;
      default:
        break;
    }
  }

  void Click(InputKey key, int? milliseconds) async {
    var duration = Duration(milliseconds: milliseconds ?? 50);
    switch (key) {
      case InputKey.nexus:
        nexus = true;
        await Future.delayed(duration);
        nexus = false;
        break;
      case InputKey.menu:
        menu = true;
        await Future.delayed(duration);
        menu = false;
        break;
      case InputKey.view:
        view = true;
        await Future.delayed(duration);
        view = false;
        break;
      case InputKey.a:
        a = true;
        await Future.delayed(duration);
        a = false;
        break;
      case InputKey.b:
        b = true;
        await Future.delayed(duration);
        b = false;
        break;
      case InputKey.x:
        x = true;
        await Future.delayed(duration);
        x = false;
        break;
      case InputKey.y:
        y = true;
        await Future.delayed(duration);
        y = false;
        break;
      case InputKey.dpadLeft:
        dPadLeft = true;
        await Future.delayed(duration);
        dPadLeft = false;
        break;
      case InputKey.dpadUp:
        dPadUp = true;
        await Future.delayed(duration);
        dPadUp = false;
        break;
      case InputKey.dpadRight:
        dPadRight = true;
        await Future.delayed(duration);
        dPadRight = false;
        break;
      case InputKey.dpadDown:
        dPadDown = true;
        await Future.delayed(duration);
        dPadDown = false;
        break;
      case InputKey.leftShoulder:
        leftShoulder = true;
        await Future.delayed(duration);
        leftShoulder = false;
        break;
      case InputKey.rightShoulder:
        rightShoulder = true;
        await Future.delayed(duration);
        rightShoulder = false;
        break;
      case InputKey.leftThumb:
        leftThumb = true;
        await Future.delayed(duration);
        leftThumb = false;
        break;
      case InputKey.rightThumb:
        rightThumb = true;
        await Future.delayed(duration);
        rightThumb = false;
        break;
      default:
        break;
    }
  }

  void SetAxis(InputKey key, int value) {
    switch (key) {
      case InputKey.leftStickXAxis:
        leftStickXAxis = value;
        break;
      case InputKey.leftStickYAxis:
        leftStickYAxis = value;
        break;
      case InputKey.rightStickXAxis:
        rightStickXAxis = value;
        break;
      case InputKey.rightStickYAxis:
        rightStickYAxis = value;
        break;
      case InputKey.leftTrigger:
        leftTrigger = value;
        break;
      case InputKey.rightTrigger:
        rightTrigger = value;
        break;
      default:
        break;
    }
  }

  bool Equals(InputFrame value) {
    if (a != value.a ||
        b != value.b ||
        x != value.x ||
        y != value.y ||
        leftStickXAxis != value.leftStickXAxis ||
        leftStickYAxis != value.leftStickYAxis ||
        rightStickXAxis != value.rightStickXAxis ||
        rightStickYAxis != value.rightStickYAxis ||
        leftThumb != value.leftThumb ||
        rightThumb != value.rightThumb ||
        dPadLeft != value.dPadLeft ||
        dPadUp != value.dPadUp ||
        dPadRight != value.dPadRight ||
        dPadDown != value.dPadDown ||
        leftTrigger != value.leftTrigger ||
        rightTrigger != value.rightTrigger ||
        leftShoulder != value.leftShoulder ||
        rightShoulder != value.rightShoulder ||
        nexus != value.nexus ||
        menu != value.menu ||
        view != value.view) {
      return false;
    }
    return true;
  }

  InputFrame DeepCopy() {
    var value = InputFrame();
    value.a = a;
    value.b = b;
    value.x = x;
    value.y = y;
    value.leftStickXAxis = leftStickXAxis;
    value.leftStickYAxis = leftStickYAxis;
    value.rightStickXAxis = rightStickXAxis;
    value.rightStickYAxis = rightStickYAxis;
    value.leftThumb = leftThumb;
    value.rightThumb = rightThumb;
    value.dPadLeft = dPadLeft;
    value.dPadUp = dPadUp;
    value.dPadRight = dPadRight;
    value.dPadDown = dPadDown;
    value.leftTrigger = leftTrigger;
    value.rightTrigger = rightTrigger;
    value.leftShoulder = leftShoulder;
    value.rightShoulder = rightShoulder;
    value.nexus = nexus;
    value.menu = menu;
    value.view = view;
    return value;
  }
}
