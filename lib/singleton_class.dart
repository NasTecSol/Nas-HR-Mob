class SingletonClass {
  factory SingletonClass() {
    if (_singleton == null) {
      _singleton = SingletonClass._();
      _singleton!.init();
    }
    return _singleton!;
  }

  SingletonClass._();

  static SingletonClass? _singleton;

  bool initialized = false;
  String? baseURL = 'https://d774-39-63-125-6.ngrok-free.app';


  init() async {
    _singleton ??= SingletonClass._();
  }
}
