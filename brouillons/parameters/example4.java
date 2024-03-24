class MyClass {
}

class MyMethodAsClass {
    public static record MyClassConstructorParameters(int param1, String param2) {}

    private final MyClass myClass;
    private final MyClassConstructorParameters myClassConstructorParameters;

    public MyMethodAsClass(MyClass myClass, MyClassConstructorParameters myClassConstructorParameters) {
        this.myClass = myClass;
        this.myClassConstructorParameters = myClassConstructorParameters;
    }

    public void invoke() {
        // Do something here
    }
}

class MyOtherClass {
    void myOtherMethod() {
        new MyMethodAsClass(
            instanceOfMyClass, 
            new MyMethodAsClass.MyClassConstructorParameters(10, "nya")
            ).invoke();
    }
}