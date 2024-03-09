class MyClass {
    public static class MyMethodParameters {
        final int param1;
        final String param2;

        public MyMethodParameters(int param1, String param2) {
            this.param1 = param1;
            this.param2 = param2;
        }
    }

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