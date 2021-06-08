-- Engineer: Mohammad Niknam
-- Project Name:  UART_Controller
-- Module Name:    UART_Controller - Behavioral 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_Controller is
    port (  CLK : in std_logic;
            nRST :in std_logic;
            Serial_Receiver : in std_logic;
            RX_Busy : out std_logic;  --data reception in progress
            Serial_Sender : out std_logic
            );
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
            TX_Busy : out std_logic;  --data sending in progress
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

type FSMTYPE is (INIT_STATE, DATA_Reception, DATA_send);

signal CSTATE, NSTATE : FSMTYPE;
signal nRST_signal : std_logic;
signal DATA_VLD, DATA_VLD_CNT_RST: std_logic;
signal DATA_VLD_CNT : unsigned(10 downto 0);
signal RAM_ADDRESS, RAM_ADDRESS_WRITE, RAM_ADDRESS_READ : std_logic_vector(9 downto 0);
signal SEND_DONE, SEND_DONE_CNT_RST : std_logic;
signal SEND_DONE_CNT : unsigned(10 downto 0);
signal RX_DATA_OUT, RAM_DOUT: std_logic_vector(7 downto 0);
signal WRITE_EN, RAM_EN : std_logic;
signal TX_Busy, nSTART_signal : std_logic;

begin
    DATA_VLD_counter : process( CLK )
    begin
        if (CLK'event and CLK = '1') then
            if (DATA_VLD_CNT_RST = '1') then
                DATA_VLD_CNT <= (others => '0');
                RAM_EN <= '0';
            else
                if (DATA_VLD = '1') then
                    DATA_VLD_CNT <= DATA_VLD_CNT + 1;
                    RAM_EN <= '1';
                else 
                    RAM_EN <= '0'; 
                end if;
            end if ;
        end if ;
    end process ; -- DATA_VLD_counter

    RAM_ADDRESS_WRITE <= std_logic_vector(DATA_VLD_CNT + "1111111111");  --DATA_VLD_CNT Minus One to address
    
    
    SEND_DONE_counter : process( CLK )
    begin
        if (CLK'event and CLK = '1') then
            if (SEND_DONE_CNT_RST = '1') then
                SEND_DONE_CNT <= (others => '0');
                RAM_EN <= '0';
            else
                if (SEND_DONE = '1') then
                    SEND_DONE_CNT <= SEND_DONE_CNT + 1;
                    RAM_EN <= '1';
                else 
                    RAM_EN <= '0'; 
                end if;
            end if ;
        end if ;
    end process ; -- SEND_DONE_counter

    RAM_ADDRESS_READ <= std_logic_vector(SEND_DONE_CNT(9 downto 0));


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


    next_state : process( CSTATE, RAM_ADDRESS_WRITE, RAM_ADDRESS_READ, DATA_VLD, DATA_VLD_CNT, SEND_DONE_CNT, TX_Busy)
    begin
        NSTATE <= CSTATE;
        nRST_signal <= '1';
        DATA_VLD_CNT_RST <= '0';
        SEND_DONE_CNT_RST <= '0';
        WRITE_EN <= '1';
        RAM_ADDRESS <= (others => '0');
        nSTART_signal <= '1';

        case( CSTATE ) is
            when INIT_STATE =>
                nRST_signal <= '0';
                DATA_VLD_CNT_RST <= '1';
                SEND_DONE_CNT_RST <= '1';
                if (DATA_VLD = '1') then
                    NSTATE <= DATA_Reception;
                end if ;
    
            when DATA_Reception =>
                WRITE_EN <= '1';
                RAM_ADDRESS <= RAM_ADDRESS_WRITE;
                SEND_DONE_CNT_RST <= '1';
                if (DATA_VLD_CNT = "10000000000") then  --10000000000=1024
                    DATA_VLD_CNT_RST <= '1';
                    NSTATE <= DATA_send ;
                end if ;
            
            when DATA_send =>
                WRITE_EN <= '0';
                RAM_ADDRESS <= RAM_ADDRESS_READ;
                DATA_VLD_CNT_RST <= '1';
                if (SEND_DONE_CNT = "10000000000") then  --10000000000=1024
                    SEND_DONE_CNT_RST <= '1';
                    NSTATE <= INIT_STATE ;
                else
                    if (TX_Busy = '0') then
                        nSTART_signal <= '0';
                    else
                        nSTART_signal <= '1';
                    end if;
                end if ;
    
            when others =>
        end case ;
    end process ; -- next_state

    
    UART_RX_Instantiation : UART_RX
    Generic map(CLK_PULSE_NUM => 868)
    port map(
        CLK => CLK,
        nRST => nRST_signal,
        DATA_OUT => RX_DATA_OUT,
        DATA_VLD => DATA_VLD,
        RX_Busy => RX_Busy,
        Received_serial => Serial_Receiver
    );


    UART_TX_Instantiation : UART_TX
    Generic map(CLK_PULSE_NUM => 868)
    port map(
        CLK => CLK,
        nRST => nRST_signal,
        nSTART => nSTART_signal,
        DATA => RAM_DOUT,
        DONE => SEND_DONE,
        TX_Busy => TX_Busy,
        TX => Serial_Sender
    );


    RAM_1024X8_Instantiation : RAM_1024X8
    port map(
        CLK => CLK,
        nRST => nRST_signal,
        EN => RAM_EN,
        WRITE_EN => WRITE_EN,
        ADDRESS => RAM_ADDRESS,
        DIN => RX_DATA_OUT,
        DOUT => RAM_DOUT
    );

end Behavioral;

