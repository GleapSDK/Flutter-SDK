class CallbackItem {
  String callbackName;
  Function callbackHandler;
  bool? takesArguments;

  CallbackItem({
    required this.callbackName,
    required this.callbackHandler,
    this.takesArguments = true,
  });
}
