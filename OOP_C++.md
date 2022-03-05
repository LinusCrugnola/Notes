# OOP in C++

## Core Concepts of OOP
### OOP definition:
OOP means Object Oriented Programming i.e. the architecture of a program is decomposed in objects that follow four main principles:
### Encapsulation:
Mechanism of hiding of data implementation by restricting the access to functions and variables.
### Abstraction:
A problem is decomposed in abstract pieces (modules) that ar as independant from each other as possible. The user doesn't know about the implementation of functions inside a module.
### Inheritance:
Classes can inherit from higher level classes, that allows to reuse a lot of code.
### Polymorphism:
Elements can appear in several different forms.

## Class Notation
### Attributes and Methods:
An attribute is a variable (propertie of the class), a Method is a function that belongs to the class and can change attributes.<br>
Methods that don't change attributes should contain the expression const:
```cpp
void foo() const {}
```
### Private and Public
Private: and public: are keywords to define the range of attributes and functions of a class. Private elements of a class are only knewn to other members of the class, public elements are known to everyone.
### Interface:
The Interface of a class (Class definition) with the prototypes of the methods go in the **header file** (.h).\
Example for a Header file (class definition):
```cpp
class Rectangle{
    private:
        //attributes
    public:
        //some functions
    private:
        //functions (class-internal use)
}; //Do not forget semicolon!
```
### Implementation:
The implementation of the methods as well as variables, that are not atributes of the class go into the ***.cc*** file (Namespace for variables). The interface of the class is included in the implementation with #include filename.
### Namespace
Each class has its generic namespace. If variables are defined in the ***.cc*** file, they must be part of the non-named namespace, otherwise they are global variables that everyone has access to.
Definition of a variable in the non-named namespace:
```cpp
namespace{
    int variable;
    void foo();
    //...
}
```
Another possibility is to add the keyword ***static*** in front of the definition.
### This Pointer
A local variable can mask a variable on a higher level with the same name (e.g. function (method) parameter masks attribute of class) in this case we can use ***this-pointer*** to reach the level from which the function is called (class):
```cpp
private:
    int var; //attribute of class
public:
    void foo(int var){
        this->var = var; //access to the attribute
    }
```
## Constructors
Constructors are used to to generate instances of a class (i.e. Objects). Constructors are functions without return type.
### Syntax of constructors:
```cpp
class MyClass{
    MyClass(int a, int b)
    : attribute1(a), attribute2(b) //assignment of attributes
    {}  //body of constructor (validation)
}
```
### Default constructor:
It is possible to create constructors, that assign default values or no values to attributes:
```cpp
MyClass() : attribute(5) {}
```
### Default default constructor:
If no constructor is specified, the compiler generates automatically a constructor that generates a class but assigns no values at all.
It is possible to define manually a default default constructor like this:
```cpp
MyClass() = default;
```
### Remarks:
* A Constructor can call another constructor.
* It is possible to assign default values to attributes in the declaration of the class as well.
### Copy constructor:
Generates a copy of an object. Syntax:
```cpp
MyClass Copy_Name(Object);
```
this calls the standard copy constructor that automatically generates the new instance. A custom prototype is defined like:
```cpp
MyClass(MyClass const& item) : element(element) {}
```
Usually it is not necessary to define a custom copy constructor. But there are cases where it is very important to define a custom copy constructer e.g. a counter keeps track of the number of objects of an instace. This counter must be incremented by the copy constructer as well as by the constructor.<br>
To avoid the copy of an Object, add ***= delete;*** behind the custom prototype.

## Destructors
Destructors can delete existing objects, which is very important to minimalize memory usage. Syntax:
```cpp
~MyClass(){//free memory allocated by class
}
```
A minimal version without body-content is generated automatically by the compiler, if no destructor is defined.

## Attributes and Methods of a Class
### Class Attributes:
We can create attributes that every object of a class has access to. For this purpose we add static in front of the definition of the attribute. Example:
```cpp
static int counter;
```
A class attribute can be private or public and can be acessed from outside of the class with the following syntax:
```cpp
MyClass::Attribut
```
It is as well possible to initialise a such attribute (but not with a constructor):
```cpp
int MyClass::Attribut = 5;
```
### Class Methods:
In the same way we can define methods. The advantage is that this function already exists when no Object of this class has been constructed. This feature is rarely used.