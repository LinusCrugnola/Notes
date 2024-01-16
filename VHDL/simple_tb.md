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