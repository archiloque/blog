class MyClass {
}

class MyMethodAsClass {
    private final MyClass myClass;
    private final int param1;
    private final String param2;

    public MyMethodAsClass(MyClass myClass, int param1, String param2) {
        this.myClass = myClass;
        this.param1 = param1;
        this.param2 = param2;
    }

    public void invoke() {
        // Do something here
    }
}

class MyOtherClass {
    void myOtherMethod() {
        new MyMethodAsClass(instanceOfMyClass, 10, "nya").invoke();
    }
}