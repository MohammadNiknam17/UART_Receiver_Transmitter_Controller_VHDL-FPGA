-- Engineer: Mohammad Niknam
-- Project Name:  UART_Controller
-- Module Name:   RAM_1024X8 - Behavioral 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RAM_1024X8 is
    port (
        CLK : IN std_logic; --Clock Pulse
        nRST :in std_logic;
        EN : IN std_logic; --RAM Enable
        WRITE_EN : IN std_logic; --Write Enable
        ADDRESS : IN std_logic_vector(9 downto 0); --Address BUS for 1024 byte
        DIN : IN std_logic_vector(7 downto 0); --Input Data
        DOUT : OUT std_logic_vector(7 downto 0));
end RAM_1024X8;

architecture Behavioral of RAM_1024X8 is
    type MEMORY_TYP is array (integer range<>) of std_logic_vector(7 downto 0);
    signal MEM : MEMORY_TYP(1023);
begin

read_or_write: process(clk)
begin
    if (CLK'event and CLK = '1') then
        if (nRST='0') then
            if (EN='1') then
                if (WRITE_EN='1') then
                    MEM(to_integer(unsigned(ADDRESS))) <= DIN;
                else
                    DOUT <= MEM(to_integer(unsigned(ADDRESS)));
                end if;
            end if;   
        else
        MEM <= (others => "00000000");
        end if;
    end if;
end process read_or_write;
end Behavioral;

