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
Note high here is size-1 if low is 0

Operations:
```vhdl
target_array_object(index_range) <= “010-10-”
target_array_object(index_range) <= base_type_object_1 & base_type_object_1 -- concatenation
```

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
Operations:
```vhdl
target_array_object(index) <= base_type_object;
target_array_object <= (value1, value2, ...);
target_array_object <= (idx_1=>value_1, idx_2=>value_2, …);
target_array_object <= (idx_1=>value_1, idx_2|idx_3=>value_2, …);
target_array_object <= (idx_1=>value_1, others=>value_2); -- fill the remaining
```

### Signed and Unsigned types:
Binary representation for numbers from IEEE numeric_std library
```vhdl
signal name_u : unsigned(size-1 downto 0);
signal name : signed(size-1 downto 0);
```
Arithmetic operations:
![](op1.png)
![](op2.png)
Type conversions (no hardware ressources required):
```vhdl
unsigned(std_logic_vector); --for example
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

## State machines (FSM)
Use a Flipflop to store the present state as shown [above](#describing-edge-triggered-registers-flipflops)
Use a process for the output and transition logic and enumerated types for the states:
```vhdl
architecture rtl of my_fsm_states is
    -- type declarations for FSM states
    type state_type is (StateA, StateB, StateC);
    -- signal declaration
    signal STATExDN, STATExDP : state_type;
begin

t_o_logic: process (STATExDP, FSM_input_signals) is
begin
    -- Default assignments
    STATExDN <= STATExDP;
    FSM_output_signal_1 <= default_output_expression;
    case STATExDP is
        when state_1 =>
        -- Conditional statements based on inputs
        if condition_1_on_FSM_input_signals then
            ...
        end if;
        when state_2 =>
        ...
    end case;
end process t_o_logic;
```

## Simulation Testbenches
### Cycle accurate simlation:
Simple but only useful for small blocks, proceeds cycle by cycle
```vhdl
p_ALL : process ( )
begin
-- APPLY STIMULI
-- CHECK RESPONSES
-- GO to NEXT CYCLE
end process p_ALL;
```

### Non cycle accurate simulation:
Defines only the functional stimuli and the responses but not their exact timing, this approach is much more flexible. Done using different processes that run when the inputs change.

### Time and Delays
Only usable in simulation, not on hardware
```vhdl
-- change signal after time delay:
signal <= exmpression after time;
-- retain and propagate changes after time delay:
signal <= transport expression after time;
-- wait for any change in any of the listed signals:
wait on signal_1, signal_2, ...;
-- wait until a condition is fullfilled:
wait until <boolean_expression>;
-- wait for amount of time:
wait for waiting_time;
-- wait forever:
wait;
```

### Assertions
Check expression and report the string to simulator console, severity levels are ```NOTE, WARNING, ERROR, FAILURE``` failure usually aborts the simulation.
```vhdl
assert <boolean_expression> report string severity severity_level;
```

### Creating a clock and a reset
Best practice is to define a clock and a reset like this:
```vhdl
constant CLK_PERIOD : time := 10ns;
constant CLK_HIGH : time := CLK_PERIOD / 2;
constant CLK_LOW : time := CLK_PERIOD / 2;
...
begin -- architecture
    -- Clock Generation
    p_clk : process
    begin
        CLKxC <= ‘0’;
        wait for CLK_LOW;
        CLKxC <= ‘1’;
        wait for CLK_HIGH;
    end process p_clk;

    -- Async Reset Generation
    p_rst : process
    begin
        RSTxRB <= ‘0’;
        wait until CLKxC’event and CLKxC=‘1’;
        wait until CLKxC’event and CLKxC=‘1’;
        wait for 1ns;
        RSTxRB <= ‘1’;
        wait;
    end process p_rst;
    ...
```

### Applying stimuli and checking responses
Can be done in one common process if both steps are tightly related with short latency or in independent processes if there are large latencies or a decoupled timing.
Example for hardcoded stimuli and responses:
```vhdl
-- Stimuli Application
p_stim : process
begin
    INPUTxS <= ‘0’; -- Initial Input during Reset

    wait until CLKxC’EVENT and CLKxC=‘1’ and RSTxRB = ‘1’;
    wait for STIM_APPL_DELAY;
    INPUTxS <= ‘1’; -- First cycle
    
    wait until CLKxC’EVENT and CLKxC=‘1’;
    wait for STIM_APPL_DELAY;
    INPUTxS <= ‘0’; -- Second cycle
    
    wait;
end process p_stim;

-- Response Checking
p_resp : process
begin
    wait until CLKxC’EVENT and CLKxC=‘1’ and RSTxRB = ‘1’;
    wait for RESP_CHK_DELAY;
    assert OUTxS = exp_response_1 REPORT “Mismatch 1” severity FAILURE;
    
    wait until CLKxC’EVENT and CLKxC=‘1’;
    wait for RESP_CHK_DELAY;
    assert OUTxS = exp_response_2 REPORT “Mismatch 2” severity FAILURE;
    
    wait;
end process p_stim;
```

See the [slides here](https://moodle.epfl.ch/pluginfile.php/2841887/mod_resource/content/6/DSD-Lecture-4-VHDL-for-Testbenches.pdf#page=17) for a more sophisticated version with Response acquisition check.


## Sequential code in processes
This can make the implementation of algorithms very convenient but it often results in unnecessairy complex hardware and there are a lot of pitfalls. Example code:
```vhdl
process (a) is
    variable acc, q, r : unsigned(7 downto 0);
    begin
        acc := unsigned(a(0));
        for i in 1 to 3 loop
            acc := acc + unsigned(a(i));
        end loop;
        q := "000" & acc(7 downto 3); -- /8
        r := "00000" & acc(2 downto 0); -- rem 8
        if r > 3 then
            q := q + 1;
        end if;
        outp <= std_logic_vector(q);
end process;
```

## Example for a VHDL Component (Lab04 Arbiter)
```vhdl
--=============================================================================
-- @file arbiter.vhdl
--=============================================================================
-- Standard library
library ieee;
-- Standard packages
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--=============================================================================
--
-- arbiter
--
-- @brief This file specifies a basic arbiter circuit for lab 4 in EE-334 at EPFL
--
--=============================================================================

--=============================================================================
-- ENTITY DECLARATION FOR ARBITER
--=============================================================================
entity arbiter is
    generic (
        CNT_TIMEOUT : integer := 250000000 -- Timeout after 2 seconds @125 MHz
    );
    port (
        CLKxCI : in std_logic;
        RSTxRI : in std_logic;

        Key0xSI : in std_logic;
        Key1xSI : in std_logic;

        GLED0xSO : out std_logic;
        RLED0xSO : out std_logic;
        GLED1xSO : out std_logic;
        RLED1xSO : out std_logic
    );
end arbiter;

--=============================================================================
-- ARCHITECTURE DECLARATION
--=============================================================================
architecture rtl of arbiter is

    type ArbiterFSM_t is (WAIT_REQ0, WAIT_REQ1, GRANT_SS0, GRANT_SS1);

    signal STATExSN, STATExSP : ArbiterFSM_t;
    signal CountxDN, CountxDP : unsigned(28-1 downto 0); -- ceil(log2(CNT_TIMEOUT)) = 28

    signal CountTimeoutxS : std_logic; -- If 1, counter has timed out (block increments)
    signal CountENxS      : std_logic; -- If 1, allow counter to increment
    signal CountCLRxS     : std_logic; -- If 1, reset the counter

--=============================================================================
-- ARCHITECTURE BEGIN
--=============================================================================
begin

--=============================================================================
-- STATE AND DATA REGISTERS
-- Processes for updating the state and data registers
--=============================================================================
    process (CLKxCI, RSTxRI) is
    begin
        if (RSTxRI = '1') then
        STATExSP <= WAIT_REQ0;
        CountxDP <= (others => '0');
        elsif (CLKxCI'event and CLKxCI = '1') then
        STATExSP <= STATExSN;
        CountxDP <= CountxDN;
        end if;
    end process;

--=============================================================================
-- FSM
-- Process defining the FSM for the arbiter
--=============================================================================
    process (all) is
    begin
        STATExSN   <= STATExSP;
        CountCLRxS <= '0';
        GLED0xSO   <= '0';
        GLED1xSO   <= '0';

        -- FSM for arbiter
        --
        -- The WAIT_REQX states are used to wait for a request from a user with
        -- priority, that is, if we are currently in GRANT_SS1 serving U1, and the
        -- counter reaches the timeout, we will switch to WAIT_REQ0. We still give
        -- access to U1 for as long as U0 does not request access but U0 can take
        -- access from U1 in WAIT_REQ0 or GRANT_SS1 as U1 has already been served for 2 seconds.
        -- We need to default to give one of them access, either by starting in a state
        -- where one of them gets access by default or by for example just having a counter
        -- that counts 0 and 1 and based on that if they come at the same time we give
        -- access to U0 or U1 based on the counter
        --
        -- The GRANT_SSX states are used to grant access to the user until the user
        -- removes their request or a timeout occurs and another user requests access
        -- after the timeout has occured.
        case STATExSP is

        -- WAIT_REQ0: State for waiting for request from U0. We thus prioritize
        -- requests from U0 and otherwise serve U1 for as long U1 requests access.
        -- We can also go into GRANT_SS1 if U1 removes its request (which resets the counter)
        -- and then makes another request
        when WAIT_REQ0 =>
            if Key0xSI = '1' then
            GLED0xSO <= '1';
            STATExSN <= GRANT_SS0;
            elsif Key1xSI = '1' then
            GLED1xSO <= '1';
            STATExSN <= GRANT_SS1;
            end if;

        -- WAIT_REQ1: Prioritize requests from U1, otherwise serve U0
        when WAIT_REQ1 =>
            if Key1xSI = '1' then
            GLED1xSO <= '1';
            STATExSN <= GRANT_SS1;
            elsif Key0xSI = '1' then
            GLED0xSO <= '1';
            STATExSN <= GRANT_SS0;
            end if;

        -- GRANT_SS0: Granted U0 access and serves it until request is removed or
        -- U1 makes a request after timeout.
        when GRANT_SS0 =>
            GLED0xSO <= Key0xSI;

            if (Key1xSI = '1' and CountTimeoutxS = '1') or (Key0xSI = '0' and Key1xSI = '1') then
            GLED0xSO   <= '0';
            GLED1xSO   <= '1';
            CountCLRxS <= '1';
            STATExSN   <= GRANT_SS1;
            elsif Key0xSI = '0' or CountTimeoutxS = '1' then
            CountCLRxS <= '1';
            STATExSN   <= WAIT_REQ1;
            end if;

        -- GRANT_SS1: Granted U1 access and serves it until request is removed or
        -- U0 makes a request after timeout.
        when GRANT_SS1 =>
            GLED1xSO <= Key1xSI;

            if (Key0xSI = '1' and CountTimeoutxS = '1') or (Key0xSI = '1' and Key1xSI = '0') then
            GLED0xSO   <= '1';
            GLED1xSO   <= '0';
            CountCLRxS <= '1';
            STATExSN   <= GRANT_SS0;
            elsif Key1xSI = '0' or CountTimeoutxS = '1' then
            CountCLRxS <= '1';
            STATExSN   <= WAIT_REQ0;
            end if;
        when others => NULL;
        end case;
    end process;

--=============================================================================
-- COUNTER LOGIC
--=============================================================================

    -- Counter starts counting as soon as we enter a full state, so, we only count full cycles of access
    CountENxS      <= '1' when (STATExSP = GRANT_SS0 or STATExSP = GRANT_SS1) else '0';
    CountTimeoutxS <= '1' when (CountxDP = CNT_TIMEOUT - 1) else '0';

    CountxDN <= (others => '0') when (CountCLRxS = '1') else
                CountxDP + 1    when (CountENxS  = '1' and CountTimeoutxS = '0') else
                CountxDP;

--=============================================================================
-- OUTPUT LOGIC
--=============================================================================

RLED0xSO <= '1' when Key0xSI = '1' and GLED0xSO = '0' else '0';
RLED1xSO <= '1' when Key1xSI = '1' and GLED1xSO = '0' else '0';

end rtl;
--=============================================================================
-- ARCHITECTURE END
--=============================================================================
```

## Example for a simple VHDL Testbench (Lab03 Keylock)
```vhdl
--=============================================================================
-- @file toplevel_tb.vhdl
--=============================================================================
-- Standard library
library ieee;
library std;
-- Standard packages
use std.env.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--=============================================================================
--
-- toplevel_tb
--
-- @brief This file specifies the testbench for the toplevel for lab3
--
--=============================================================================

entity toplevel_tb is
end entity toplevel_tb;

architecture tb of toplevel_tb is

--=============================================================================
-- TYPE AND CONSTANT DECLARATIONS
--=============================================================================
  constant CLK_HIGH   : time := 4 ns;
  constant CLK_LOW    : time := 4 ns;
  constant CLK_PERIOD : time := CLK_LOW + CLK_HIGH;
  constant CLK_STIM   : time := 1 ns;

--=============================================================================
-- COMPONENT DECLARATIONS
--=============================================================================
  component toplevel is
    port (
      CLKxCI : in std_logic;
      RSTxRI : in std_logic;

      Push0xSI : in std_logic;
      Push1xSI : in std_logic;
      Push2xSI : in std_logic;
      Push3xSI : in std_logic;

      RLEDxSO : out std_logic;
      GLEDxSO : out std_logic
    );
  end component toplevel;

--=============================================================================
-- SIGNAL DECLARATIONS
--=============================================================================
  signal CLKxC : std_logic;
  signal RSTxR : std_logic;

  signal Push0xS : std_logic;
  signal Push1xS : std_logic;
  signal Push2xS : std_logic;
  signal Push3xS : std_logic;

  signal RLEDxS : std_logic;
  signal GLEDxS : std_logic;

begin

    --=============================================================================
    -- COMPONENT INSTANTIATIONS
    --=============================================================================

    -- Instantiate dut
    dut: toplevel
        port map (
            CLKxCI   => CLKxC,
            RSTxRI   => RSTxR,
            Push0xSI => Push0xS,
            Push1xSI => Push1xS,
            Push2xSI => Push2xS,
            Push3xSI => Push3xS,
            RLEDxSO  => RLEDxS,
            GLEDxSO  => GLEDxS
        );

    --=============================================================================
    -- CLOCK PROCESS
    -- Process for generating the clock signal
    --=============================================================================
    p_clock: process is
    begin
        CLKxC <= '0';
        wait for CLK_LOW;
        CLKxC <= '1';
        wait for CLK_HIGH;
    end process p_clock;

    --=============================================================================
    -- RESET PROCESS
    -- Process for generating the reset signal
    --=============================================================================
    p_reset: process is
    begin
        RSTxR <= '1';
        wait until CLKxC'event and CLKxC = '1'; -- Align to rising-edge
        wait for (2*CLK_PERIOD + CLK_STIM);     -- Wait 2 CC and a little after edge
        RSTxR <= '0';
        wait;
    end process p_reset;

    --=============================================================================
    -- TEST PROCESSS
    --=============================================================================
    p_stim: process is
    begin

        Push0xS <= '0';
        Push1xS <= '0';
        Push2xS <= '0';
        Push3xS <= '0';
        wait until CLKxC'event and CLKxC = '1' and RSTxR = '0';

        -- Press correct buttons
        -----------------------------------

        -- 0
        wait for 0.5ms;
        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;
        Push0xS <= '1';

        wait for 0.25ms;
        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;
        Push0xS <= '0';

        -- 2
        wait for 0.5ms;
        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;
        Push2xS <= '1';

        wait for 0.25ms;
        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;
        Push2xS <= '0';

        -- 1
        wait for 0.5ms;
        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;
        Push1xS <= '1';

        wait for 0.25ms;
        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;
        Push1xS <= '0';

        -- Press wrong buttons
        -----------------------------------
        wait until CLKxC'event and CLKxC = '1' and RLEDxS = '1';

        -- 0
        wait for 0.5ms;
        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;

        Push0xS <= '1';
        wait for 0.25ms;
        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;
        Push0xS <= '0';

        -- 3
        wait for 0.5ms;
        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;

        Push3xS <= '1';
        wait for 0.25ms;
        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;
        Push3xS <= '0';

        -- 1
        wait for 0.5ms;
        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;
        Push1xS <= '1';

        wait for 0.25ms;
        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;
        Push1xS <= '0';

        wait for 0.5ms;
        stop(0);
    end process p_stim;

end architecture tb;
```

## Example for a VHDL Testbench (Lab04 Arbiter)
```vhdl
--=============================================================================
-- @file arbiter_tb.vhdl
--=============================================================================
-- Standard library
library ieee;
library std;
-- Standard packages
use std.env.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--=============================================================================
--
-- arbiter_tb
--
-- @brief This file specifies the testbench of the arbiter
--
--=============================================================================


--=============================================================================
-- ENTITY DECLARATION FOR ARBITER_TB
--=============================================================================
entity arbiter_tb is
end entity arbiter_tb;

--=============================================================================
-- ARCHITECTURE DECLARATION
--=============================================================================
architecture tb of arbiter_tb is

--=============================================================================
-- TYPE AND CONSTANT DECLARATIONS
--=============================================================================
constant CLK_HIGH : time := 4 ns;
constant CLK_LOW  : time := 4 ns;
constant CLK_PER  : time := CLK_LOW + CLK_HIGH;
constant CLK_STIM : time := 1 ns; -- Used to push us a little bit after the clock edge

constant CNT_TIMEOUT    : integer := 25; -- Timeout after 200ns (for simulation) @125 MHz clock
constant CNT_TIMEOUT_NS : time    := 200 ns;

--=============================================================================
-- SIGNAL DECLARATIONS
--=============================================================================
signal CLKxC  : std_logic := '0';
signal RSTxR  : std_logic := '1';
signal Key0xS : std_logic := '0';
signal Key1xS : std_logic := '0';

signal GLED0xS : std_logic;
signal RLED0xS : std_logic;
signal GLED1xS : std_logic;
signal RLED1xS : std_logic;

--=============================================================================
-- COMPONENT DECLARATIONS
--=============================================================================

component arbiter is
    generic (
        CNT_TIMEOUT : integer := 250000000
    );
    port (
        CLKxCI : in std_logic;
        RSTxRI : in std_logic;

        Key0xSI : in std_logic;
        Key1xSI : in std_logic;

        GLED0xSO : out std_logic;
        RLED0xSO : out std_logic;
        GLED1xSO : out std_logic;
        RLED1xSO : out std_logic
    );
end component;

--=============================================================================
-- ARCHITECTURE BEGIN
--=============================================================================
begin

    --=============================================================================
    -- COMPONENT INSTANTIATIONS
    --=============================================================================
    --------------------------------------------------------------------------
    -- The design under test
    --------------------------------------------------------------------------
    dut: arbiter
        generic map (
            CNT_TIMEOUT => CNT_TIMEOUT
        )
        port map (
            CLKxCI => CLKxC,
            RSTxRI => RSTxR,

            Key0xSI => Key0xS,
            Key1xSI => Key1xS,

            GLED0xSO => GLED0xS,
            RLED0xSO => RLED0xS,
            GLED1xSO => GLED1xS,
            RLED1xSO => RLED1xS
        );

    --=============================================================================
    -- CLOCK PROCESS
    -- Process for generating the clock signal
    --=============================================================================
    p_clock: process is
    begin
        CLKxC <= '0';
        wait for CLK_LOW;
        CLKxC <= '1';
        wait for CLK_HIGH;
    end process p_clock;

    --=============================================================================
    -- RESET PROCESS
    -- Process for generating initial reset
    --=============================================================================
    p_reset: process is
    begin
        RSTxR <= '1';
        wait until rising_edge(CLKxC);    -- Align to clock rising edge
        wait for (2*CLK_PER + CLK_STIM);  -- Align to CLK_STIM ns after rising edge
        RSTxR <= '0';
        wait;
    end process p_reset;

    --=============================================================================
    -- TEST PROCESSS
    --=============================================================================
    p_stim: process is
    begin

        -- Initial state
        Key0xS <= '0';
        Key1xS <= '0';

        -- TEST A1
        wait until CLKxC'event and CLKxC = '1' and RSTxR = '0';
        wait for CLK_STIM;

        report
        lf & "************************************************************" &
        lf & "Test A1: U0 requests and access is granted";

        Key0xS <= '1';

        wait until CLKxC'event and CLKxC = '1' and GLED0xS = '1';
        wait for 3*CNT_TIMEOUT_NS;

        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;
        Key0xS <= '0';

        -- TEST A2
        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;

        report
        lf & "************************************************************" &
        lf & "Test A2: U1 requests and access is granted";

        Key1xS <= '1';

        wait until CLKxC'event and CLKxC = '1' and GLED1xS = '1';
        wait for 3*CNT_TIMEOUT_NS;

        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;
        Key1xS <= '0';

        -- TEST B1
        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;

        report
        lf & "************************************************************" &
        lf & "Test B1" &
        lf & "1) U1 requests and access is granted" &
        lf & "2) U0 requests access while U1 continues request, but U0 releases before the timeout";

        Key1xS <= '1';

        wait until CLKxC'event and CLKxC = '1' and GLED1xS = '1';
        wait for CLK_STIM;
        Key0xS <= '1';

        wait for CNT_TIMEOUT_NS/2;
        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;
        Key0xS <= '0';

        wait for 2*CNT_TIMEOUT_NS;
        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;
        Key1xS <= '0';

        -- TEST B2
        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;

        report
        lf & "************************************************************" &
        lf & "Test B2" &
        lf & "1) U0 requests and access is granted" &
        lf & "2) U1 requests access while U0 continues request, but U1 releases before the timeout";

        Key0xS <= '1';

        wait until CLKxC'event and CLKxC = '1' and GLED0xS = '1';
        wait for CLK_STIM;
        Key1xS <= '1';

        wait for CNT_TIMEOUT_NS/2;
        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;
        Key1xS <= '0';

        wait for 2*CNT_TIMEOUT_NS;
        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;
        Key0xS <= '0';

        -- TEST C1
        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;

        report
        lf & "************************************************************" &
        lf & "Test C1" &
        lf & "1) U0 requests and access is granted" &
        lf & "2) U0 release access almost immediately after" &
        lf & "3) U0 requests access again" &
        lf & "4) U1 request access almost immediately after (but has to wait for the timeout)";

        Key0xS <= '1';

        wait until CLKxC'event and CLKxC = '1' and GLED0xS = '1';
        wait for CLK_STIM;
        Key0xS <= '0';

        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;
        Key0xS <= '1';

        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;
        Key1xS <= '1';

        wait for 2*CNT_TIMEOUT_NS;
        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;
        Key0xS <= '0';
        Key1xS <= '0';

        -- TEST D1
        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;

        report
        lf & "************************************************************" &
        lf & "Test D1" &
        lf & "1) U0 requests and access is granted" &
        lf & "2) FSM goes into WAIT_REQ1 where U0 keeps it access request" &
        lf & "3) In WAIT_REQ1, U1 makes a request and keeps this high";

        Key0xS <= '1';

        wait until CLKxC'event and CLKxC = '1' and GLED0xS = '1';
        wait for CLK_STIM;

        wait for (3*CNT_TIMEOUT_NS)/2;
        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;
        Key1xS <= '1';

        wait for 1 us;
        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;
        Key0xS <= '0';
        Key1xS <= '0';

        -- TEST E1
        wait until CLKxC'event and CLKxC = '1';
        wait for CLK_STIM;

        report
        lf & "************************************************************" &
        lf & "Test E1" &
        lf & "1) U0 requests and access is granted" &
        lf & "2) U1 requests access while U0 continues request" &
        lf & "3) At a timeout, U1 is granted access" &
        lf & "We let this run for some time to see the arbitration";

        Key0xS <= '1';

        wait until CLKxC'event and CLKxC = '1' and GLED0xS = '1';
        wait for CLK_STIM;
        Key1xS <= '1';

        wait for 2 us;

        stop(0);

    end process p_stim;


    --=============================================================================
    -- VERIFICATION PROCESSS
    -- Demonstration of how to write a process to verify properties on the inputs
    -- and outputs using assert statements which check the truth of the condition
    -- Note that this process runs in paralell and this makes checking much easier
    --=============================================================================
    p_verif: process is
    begin

        -- Wait until reset has happened
        wait until CLKxC'event and CLKxC = '1' and RSTxR = '0';
        -- Wait to check after 2*CLK_STIM as inputs are applied at 1*CLK_STIM
        wait for 2*CLK_STIM;

        -- Assert that we NEVER (not) observe both GLD0xS and GLED1xS HIGH at the same time
        -- It is generally easier to just write out the condition you don't want to happend and
        -- then write not in front of it
        assert not (GLED0xS = '1' and GLED1xS = '1')
        report "not (GLED0xS = '1' and GLED1xS = '1')" &
            lf & "GLED0xS = " & std_logic'image(GLED0xS) &
            lf & "GLED1xS = " & std_logic'image(GLED1xS) severity error;

        -- Assert that we NEVER (not) observe both RLED0xS and RLED1xS HIGH at the same time
        assert not (RLED0xS = '1' and RLED1xS = '1')
        report "not (RLED0xS = '1' and RLED1xS = '1')" &
            lf & "RLED0xS = " & std_logic'image(RLED0xS) &
            lf & "RLED1xS = " & std_logic'image(RLED1xS) severity error;

        -- Assert that we NEVER (not) observe both GLED0xS and RLED0xS HIGH at the same time
        assert not (GLED0xS = '1' and RLED0xS = '1')
        report "not (GLED0xS = '1' and RLED0xS = '1')" &
            lf & "GLED0xS = " & std_logic'image(GLED0xS) &
            lf & "RLED0xS = " & std_logic'image(RLED0xS) severity error;

        -- Assert that we NEVER (not) observe both GLED1xS and RLED1xS HIGH at the same time
        assert not (GLED1xS = '1' and RLED1xS = '1')
        report "not (GLED1xS = '1' and RLED1xS = '1')" &
            lf & "GLED1xS = " & std_logic'image(GLED1xS) &
            lf & "RLED1xS = " & std_logic'image(RLED1xS) severity error;

        -- Check that if either key is pressed, then a green LED must be HIGH.
        assert not ((Key0xS = '1' or Key1xS = '1') and (GLED0xS = '0' and GLED1xS = '0'))
        report "((Key0xS = '1' or Key1xS = '1') and (GLED0xS = '0' and GLED1xS = '0'))" &
            lf & "Key0xS = " & std_logic'image(Key0xS) &
            lf & "Key1xS = " & std_logic'image(Key1xS) &
            lf & "GLED0xS = " & std_logic'image(GLED0xS) &
            lf & "GLED1xS = " & std_logic'image(GLED1xS) severity error;

    end process p_verif;

end architecture tb;
--=============================================================================
-- ARCHITECTURE END
--=============================================================================
```
