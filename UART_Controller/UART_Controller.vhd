-- Engineer: Mohammad Niknam
-- Project Name:  UART_Controller
-- Module Name:    UART_Controller - Behavioral 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_Controller is
end UART_Controller;

architecture Behavioral of UART_Controller is

component UART_RX 
    Generic(CLK_PULSE_NUM : integer := 868); --868 for freq=100Mhz / BUADRATE 115200
    port (  CLK : in std_logic;
            nRST :in std_logic;
            DATA_OUT : out std_logic_vector(7 downto 0);
            DATA_VLD : out std_logic; -- when DATA_VLD = 1, data reception is completed data on DATA_OUT are valid
            RX_Busy : out std_logic;  --data reception in progress
            Received_serial : in std_logic);
end component;

component UART_TX is
    Generic(CLK_PULSE_NUM : integer := 868); --868 for freq=100Mhz / BUADRATE 115200
    port (  CLK : in std_logic;
            nRST :in std_logic;
            nSTART : in std_logic;
            DATA : in std_logic_vector(7 downto 0);
            DONE : out std_logic;
            TX : out std_logic);
end component;

component RAM_1024X8 is
    port (
        CLK : IN std_logic; --Clock Pulse
        nRST :in std_logic;
        EN : IN std_logic; --RAM Enable
        WRITE_EN : IN std_logic; --Write Enable
        ADDRESS : IN std_logic_vector(9 downto 0); --Address BUS for 1024 byte
        DIN : IN std_logic_vector(7 downto 0); --Input Data
        DOUT : OUT std_logic_vector(7 downto 0));
end component;

begin

    
    UART_RX_Instantiation : UART_RX
    Generic map(CLK_PULSE_NUM => 868);
    port map(
        CLK => ,
        nRST => ,
        DATA_OUT => ,
        DATA_VLD => ,
        RX_Busy => ,
        Received_serial => 
    );

    UART_TX_Instantiation : UART_TX
    Generic map(CLK_PULSE_NUM => 868);
    port map(
        CLK => ,
        nRST => ,
        nSTART => ,
        DATA => ,
        DONE => ,
        TX => 
    );

    RAM_1024X8_Instantiation : RAM_1024X8
    port map(
        CLK => ,
        nRST => ,
        EN => ,
        WRITE_EN => ,
        ADDRESS => ,
        DIN => ,
        DOUT => 
    );

end Behavioral;

