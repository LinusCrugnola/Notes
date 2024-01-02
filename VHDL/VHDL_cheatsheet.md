# VHDL cheatsheet

## Libraries and Packages
Include package from a libary:
```vhdl
library library_name;
use library_name.package_name.reference;
```
Reference can be a function name, a constant name or ```all``` to use the whole package.

Project specific packages are compiled into the ```WORK``` library and are used like this:
```vhdl
use WORK.my_package.all;
```

### Important libraries
```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
```

### Package declaration
```vhdl
package package_name is
    -- content & constants / types / functions
end package package_name;
```

## Entities
An entity is declarated as follows:
```vhdl
entity entity_name is
    generic(
        generic_1_name : generic_1_type;
        generic_2_name : generic_2_type
    );
    port(
        port_1_name : port_1_dir port_1_type;
        port_2_name : port_2_dir port_2_type
    );
end entity_name;
```
Ports: interface of the component, inputs and ouputs. Port directions can be: ```in, out, inout, buffer```

Generics: Instance specific parameters that resolve to a constant known at compile time

The port and generics sections are optional

## Architecture
Architecture declaration defines its name, the name of the associated entity and the architecture itself:
```vhdl
architecture architecture_name of entity_name is
    -- signals to be used are declared here
begin
    -- Insert VHDL statements to assign outputs to
    -- each of the output signals defined in the
    -- entity declaration.
end architecture_name;
```

## Signals
Signals are wires on the hardware, they connect ports and are declared in the architecture preamble:
```vhdl
signal signal_name : signal_type;
```

### Constants:
Constants are special signals that represent fixes values and can be declared in Packages, as generics in an entity or as constants in the preamble of an architecture, they can be derived expressions from other constants.
```vhdl
constant constant_name : constant_type := expression;
```

### Built-in data types:
VHDL supports 6 native scalar data types:

1)  Bit     : 1 or 0
2)  Boolean : true / false
3)  Integer : defined by a range, default 32 bit
4)  Char    : 8 bit integer
5)  Real    : floating point number
6)  Time    : for modeling of delays in [ps, ns]

Not all of those types can be used in synthesis, time has no hardware equivalent and real does introduce a lot of complexity

### Extended data type std_logic:
Often used, possible values are:

1) Logic-0 : '0'
2) Logic-1 : '1'
3) Don't care : '-'
4) High impedance : 'Z'
5) Unknown : 'X' (for simulation)
6) Weak-0 : 'L'
7) Weak-1 : 'H'
8) Weak-X : 'W'
9) Uninitialized : 'U' (for simulation)

The values are encoded as characters

### Concurrent signal assignments:
```vhdl
signal <= expression;
```
Never assign more than one value to a signal in one concurrent statement!

### Boolean operators:
Valid operators are: ```AND, OR, NOT, XOR, NAND, NOR, XNOR``` They can be used like:
```vhdl
signal <= signal_1 <boolean_operator> signal_2;
```

### Signal naming convention:
![](names.png)
