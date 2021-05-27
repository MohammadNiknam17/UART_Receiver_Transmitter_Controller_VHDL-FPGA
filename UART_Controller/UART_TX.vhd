-- Engineer: Mohammad Niknam
-- Project Name:  UART_Controller
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_TX is
    Generic(CLK_PULSE_NUM : integer := 868); --868 for freq=100Mhz / BUADRATE 115200
    port (  CLK : in std_logic;
            nRST :in std_logic;
            nSTART : in std_logic;
            DATA : in std_logic_vector(7 downto 0);
            DONE : out std_logic;
            TX : out std_logic);
end UART_TX;

architecture Behavioral of UART_TX is
type FSMTYPE is (INIT_STATE, START_BIT_SEND, BIT_0, BIT_1, BIT_2, BIT_3, BIT_4, BIT_5, BIT_6, BIT_7, STOP_BIT_SEND);

signal CSTATE, NSTATE : FSMTYPE;
signal CLK_CNT : unsigned(11 downto 0) ;
signal CLK_CNT_RST : std_logic;
signal DATA_REG : std_logic_vector(7 downto 0);

begin

data_registration : process( CLK )
begin
    if (CLK'event and CLK = '1') then
        if (nSTART = '0') then
        DATA_REG <= DATA;
        end if ;
    end if ;
end process ; --data_registration


clk_counter : process( CLK )
begin
    if (CLK'event and CLK = '1') then
        if (CLK_CNT_RST = '1') then
            CLK_CNT <= (others => '0');
        else
            CLK_CNT <= CLK_CNT + 1;
        end if ;
    end if ;
end process ; -- clk_counter


state_registration : process( CLK )
begin
    if (CLK'event and CLK = '1') then
        if (nRST = '0') then
            CSTATE <= INIT_STATE;
        else
            CSTATE <= NSTATE;
        end if ;
    end if ;
end process ; -- state_registration


next_state : process( CSTATE, CLK_CNT, DATA_REG, nSTART )
begin
    NSTATE <= CSTATE;
    CLK_CNT_RST <= '0';
    TX <= '1';
    DONE <= '0';

    case( CSTATE ) is
        when INIT_STATE =>
            TX <= '1';
            CLK_CNT_RST <= '1';
            if (nSTART = '0') then
                NSTATE <= START_BIT_SEND;
            end if ;

        when START_BIT_SEND =>
            TX <= '0';
            if (TO_integer(CLK_CNT) = (CLK_PULSE_NUM - 1)) then
                CLK_CNT_RST <= '1';
                NSTATE <= BIT_0 ;
            end if ;
        
        when BIT_0 => 
            TX <= DATA_REG(0);
            if (to_integer(CLK_CNT) = (CLK_PULSE_NUM - 1)) then
                CLK_CNT_RST <= '1';
                NSTATE <= BIT_1;
            end if;

        when BIT_1 => 
            TX <= DATA_REG(1);
            if (to_integer(CLK_CNT) = (CLK_PULSE_NUM - 1)) then
                CLK_CNT_RST <= '1';
                NSTATE <= BIT_2;
            end if;
        
        when BIT_2 => 
            TX <= DATA_REG(2);
            if (to_integer(CLK_CNT) = (CLK_PULSE_NUM - 1)) then
                CLK_CNT_RST <= '1';
                NSTATE <= BIT_3;
            end if;
        
        when BIT_3 => 
            TX <= DATA_REG(3);
            if (to_integer(CLK_CNT) = (CLK_PULSE_NUM - 1)) then
                CLK_CNT_RST <= '1';
                NSTATE <= BIT_4;
            end if;        
                
        when BIT_4 => 
            TX <= DATA_REG(4);
            if (to_integer(CLK_CNT) = (CLK_PULSE_NUM - 1)) then
                CLK_CNT_RST <= '1';
                NSTATE <= BIT_5;
            end if;

        when BIT_5 => 
            TX <= DATA_REG(5);
            if (to_integer(CLK_CNT) = (CLK_PULSE_NUM - 1)) then
                CLK_CNT_RST <= '1';
                NSTATE <= BIT_6;
            end if;

        when BIT_6 => 
            TX <= DATA_REG(6);
            if (to_integer(CLK_CNT) = (CLK_PULSE_NUM - 1)) then
                CLK_CNT_RST <= '1';
                NSTATE <= BIT_7;
            end if;

        when BIT_7 => 
            TX <= DATA_REG(7);
            if (to_integer(CLK_CNT) = (CLK_PULSE_NUM - 1)) then
                CLK_CNT_RST <= '1';
                NSTATE <= STOP_BIT_SEND;
            end if;
   
        when STOP_BIT_SEND => 
            TX <= '1';
            if (to_integer(CLK_CNT) = (CLK_PULSE_NUM - 1)) then
                CLK_CNT_RST <= '1';
                NSTATE <= INIT_STATE;
                DONE <= '1';
            end if;

        when others =>
    end case ;
end process ; -- next_state

end Behavioral;

