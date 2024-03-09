class MyClass {
}

class MyMethodAsClass {
    public static class MyClassConstructorParameters {
        final int param1;
        final String param2;

        public MyClassConstructorParameters(int param1, String param2) {
            this.param1 = param1;
            this.param2 = param2;
        }

    }

    private final MyClass myClass;
    private final MyClassConstructorParameters myClassConstructorParameters;

    public MyMethodAsClass(MyClass myClass, MyClassConstructorParameters myClassConstructorParameters) {
        this.myClass = myClass;
        this.myClassConstructorParameters = myClassConstructorParameters;
    }

    public void call() {
        // Do something here
    }
}

class MyOtherClass {
    void myOtherMethod() {
        new MyMethodAsClass(
            instanceOfMyClass, 
            new MyMethodAsClass.MyClassConstructorParameters(10, "nya")
            ).call();
    }
}