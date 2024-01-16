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