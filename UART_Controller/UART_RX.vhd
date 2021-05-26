-- Engineer: Mohammad Niknam
-- Project Name:  UART_Controller
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_RX is
    Generic(CLK_PULSE_NUM : integer := 868); --868 for freq=100Mhz / BUADRATE 115200
    port (  CLK : in std_logic;
            nRST :in std_logic;
            DATA_OUT : out std_logic_vector(7 downto 0);
            DATA_VLD : out std_logic; -- when DATA_VLD = 1, data reception is completed data on DATA_OUT are valid
            RX_Busy : out std_logic;  --data reception in progress
            Received_serial : in std_logic);
end UART_RX;

architecture Behavioral of UART_RX is
type FSMTYPE is (INIT_STATE, START_BIT_Receive, BIT_0, BIT_1, BIT_2, BIT_3, BIT_4, BIT_5, BIT_6, BIT_7, STOP_BIT_Receive);

signal CSTATE, NSTATE : FSMTYPE;
signal CLK_CNT : unsigned(11 downto 0) ;
signal CLK_CNT_RST : std_logic;
signal DATA_REG : std_logic_vector(7 downto 0);
signal DATA_VALID : std_logic;

begin

data_registration : process( CLK )
begin
    if (CLK'event and CLK = '1') then

            DATA_OUT <= DATA_REG;


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


next_state : process( CSTATE, CLK_CNT, DATA_REG, Received_serial )
begin
    NSTATE <= CSTATE;
    CLK_CNT_RST <= '0';

    DATA_VALID <= '0';

    case( CSTATE ) is
        when INIT_STATE =>
            DATA_REG <= (others => '0');
            CLK_CNT_RST <= '1';
            if (Received_serial = '0') then
                NSTATE <= START_BIT_Receive;
            end if ;

        when START_BIT_Receive =>
            RX_Busy <= '1';
            if (TO_integer(CLK_CNT) = (CLK_PULSE_NUM - 1)) then
                CLK_CNT_RST <= '1';
                NSTATE <= BIT_0 ;
            end if ;
        
        when BIT_0 => 
            DATA_REG(0) <= Received_serial;
            if (to_integer(CLK_CNT) = (CLK_PULSE_NUM - 1)) then
                CLK_CNT_RST <= '1';
                NSTATE <= BIT_1;
            end if;

        when BIT_1 => 
            DATA_REG(1) <= Received_serial;
            if (to_integer(CLK_CNT) = (CLK_PULSE_NUM - 1)) then
                CLK_CNT_RST <= '1';
                NSTATE <= BIT_2;
            end if;
        
        when BIT_2 => 
            DATA_REG(2) <= Received_serial;
            if (to_integer(CLK_CNT) = (CLK_PULSE_NUM - 1)) then
                CLK_CNT_RST <= '1';
                NSTATE <= BIT_3;
            end if;
        
        when BIT_3 => 
            DATA_REG(3) <= Received_serial;
            if (to_integer(CLK_CNT) = (CLK_PULSE_NUM - 1)) then
                CLK_CNT_RST <= '1';
                NSTATE <= BIT_4;
            end if;        
                
        when BIT_4 => 
            DATA_REG(4) <= Received_serial;
            if (to_integer(CLK_CNT) = (CLK_PULSE_NUM - 1)) then
                CLK_CNT_RST <= '1';
                NSTATE <= BIT_5;
            end if;

        when BIT_5 => 
            DATA_REG(5) <= Received_serial;
            if (to_integer(CLK_CNT) = (CLK_PULSE_NUM - 1)) then
                CLK_CNT_RST <= '1';
                NSTATE <= BIT_6;
            end if;

        when BIT_6 => 
            DATA_REG(6) <= Received_serial;
            if (to_integer(CLK_CNT) = (CLK_PULSE_NUM - 1)) then
                CLK_CNT_RST <= '1';
                NSTATE <= BIT_7;
            end if;

        when BIT_7 => 
            DATA_REG(7) <= Received_serial;
            if (to_integer(CLK_CNT) = (CLK_PULSE_NUM - 1)) then
                CLK_CNT_RST <= '1';
                NSTATE <= STOP_BIT_Receive;
            end if;
   
        when STOP_BIT_Receive => 
            if (to_integer(CLK_CNT) = (CLK_PULSE_NUM - 1)) then
                CLK_CNT_RST <= '1';
                NSTATE <= INIT_STATE;
                RX_Busy <= '0';
                if (Received_serial = '1') then
                    DATA_VALID <= '1';
                end if ;
                
            end if;

        when others =>
    end case ;
end process ; -- next_state

end Behavioral;

