class MyClass {
    public static record MyMethodParameters(int param1, String param2) {}

    void myMethod(MyMethodParameters myMethodParameters) {
        // Do something here
    }

}

class MyOtherClass {
    void myOtherMethod() {
        instanceOfMyClass.myMethod(
                new MyClass.MyMethodParameters(10, "nya"));
    }
}