library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--- CODE FOR TASK 3.1

entity task3_1 is
    port(
        CLKxCI, RSTxRI: in std_logic;
        ClearxSI, LoadxSI, UpxSI, DownxSI: in std_logic;
        InputxDI : in unsigned(8-1 downto 0);
        OutputxDO : out unsigned(8-1 downto 0);
    );
end entity task3_1;

architecture rtl of task3_1 is

    signal CntxDP, CntxDN : unsigned(8-1 downto 0) := (others => '0');

begin

    -- Clocked Process, generating a FlipFlop behavior
    p_seq: process (CLKxCI, RSTxRI) is
    begin
        if RSTxRI = '1' then
            CntxDP <= (others => '0');
        elsif CLKxCI’event and CLKxCI = '1' then
            CntxDP <= CntxDN;
        end if;
    end process p_seq;

    comb: process (all) is
    begin
        CntxDN <= CntxDP;
        if ClearxSI = '1' then
            CntxDN <= (others => '0');
        elsif LoadxSI = '1' then
            CntxDN <= InputxDI;
        elsif UpxSI = '1' then
            CntxDN <= CntxDN + 1;
        elsif DownxSI = '1' then
            CntxDN <= CntxDN - 1;
        end if;
    end process comb;

    OutputxDO <= CntxDP;

end architecture;

--- TESTBENCH FOR TASK 3.1

constant CLK_PERIOD : time := 10ns;
constant CLK_HIGH : time := CLK_PERIOD / 2;
constant CLK_LOW : time := CLK_PERIOD / 2;

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