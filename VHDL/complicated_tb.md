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
