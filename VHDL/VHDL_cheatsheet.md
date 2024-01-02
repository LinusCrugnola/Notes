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

### Logic Vectors:
STD_LOGIC_VECTOR as array of type std_logic (don't forget to include the ieee library)
```vhdl
signal signal_name : STD_LOGIC_VECTOR(high downto low);
```
TODO: other types and operations!!!

### Array types:
Arrays can be defined as follows:
```vhdl
type array_type_name_1 is array (low to high) of base_type;
type array_type_name_2 is array (high downto low) of base_type;
type array_type_name_3_2D is array (integer range <>) of array_type_name_2;
-- signal declaration
signal signal_1_name : array_type_name_1;
signal signal_2_name : array_type_name_3(low to high);
```

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

## Component
A component is one instance of an entity, it must be declared in the preamble and instantiated in the body of the architecture in which it is used:

Declared of a component for the entity [declared here](#entities)
```vhdl
component component_name is
    generic (
        generic_1_name : generic_1_type;
        generic_2_name : generic_2_type
    );
    port (
        port_1_name : port_1_dir port_1_type;
        port_2_name : port_2_dir port_2_type
    );
end component;
```

Instantiation:
```vhdl
begin -- architecture body
    -- Component instantiation:
    instance_1_name : component_name
    GENERIC MAP (
        generic_1_name => CONSTANT_EXP_1_1,
        generic_2_name => CONSTANT_EXP_1_2
    )
    PORT MAP (
        port_1_name => port_1_1_signal,
        port_2_name => port_1_2_signal
    );
    -- Or anther way:
    instance_2_name : component_name
    GENERIC MAP ( CONSTANT_EXP_2_1, CONSTANT_EXP_2_2)
    PORT MAP ( port_2_1_signal, port_2_2_signal );
end architecture_name;
```

## Conditional statements:
Rule: every conditional statement must be complete, otherwise we create latches which is not allowed in synchronous RTL design.

### If else:
```vhdl
if boolean_expression then
    signal_1 <= expression
elsif boolean_expression_2 then
    signal_1 <= expression_2
else
    signal_2 <= expression_3
end if;
```

### Conditional assignment:
```vhdl
target_signal <= expression_1 when boolean_expression_1 else
    expression_2 when boolean_expression_2 else
    …
    expression_N; -- else statement
```

### With select statement:
Used for multi-valued conditions
```vhdl
with cond_signal select
    target_signal <=
    expression_1 when constant_1,
    expression_2 when constant_2,
    …
    expression_N when others;
```

## Processes
A process can contain sequential statements, they are evaluated one after another. The process runs when any signal in the senitivity list changes.
```vhdl
process_name: process (…)
begin
    target_signal_1 <= expression;
    target_signal_1 <= expression_2;
end process process_name;
```
Multiple assignments are possible, the signal keeps the value that was last assigned to it. Assignments must be complete, otherwise latches are generated. This can be avoided with default assignments. Assigning don't care by default minimizes the logic.

### Case statement
Can be used in processes to evaluate non-binary conditions:
```vhdl
case expression is
    when choice_1 =>
        sequential_statement_1;
        sequential_statement_1a;
        …
    when choice_2 =>
        sequential_statement_2;
        …
    when others =>
        sequential_statement_3;
        …
end case;
```

## Describing edge triggered registers (flipflops)
Flipflop that triggers on positive clock edge and has an asynchronous reset
```vhdl
-- Clocked Process, generating a FlipFlop behavior
p_seq: process (clock_signal, async_reset_signal) is
begin
    if async_reset_signal = '1' then
        present_state_signal <= constant;
    elsif clock_signal’event and clock_signal = '1' then
        present_state_signal <= next_state_signal;
    end if;
end process p_seq;
```
