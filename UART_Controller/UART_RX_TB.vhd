-- Engineer: Mohammad Niknam
-- Project Name:  UART_Controller
-- VHDL Test Bench Created by ISE for module: UART_RX
-- CLK_PULSE_NUM : 868 for freq=100Mhz / BUADRATE 115200
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;    
use IEEE.NUMERIC_STD.ALL;
 
ENTITY UART_RX_TB IS
END UART_RX_TB;
 
ARCHITECTURE behavior OF UART_RX_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT UART_RX
    PORT(
         CLK : IN  std_logic;
         nRST : IN  std_logic;
         DATA_OUT : OUT  std_logic_vector(7 downto 0);
         DATA_VLD : OUT  std_logic;
         RX_Busy : OUT  std_logic;
         Received_serial : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal nRST : std_logic := '0';
   signal Received_serial : std_logic := '0';

 	--Outputs
   signal DATA_OUT : std_logic_vector(7 downto 0);
   signal DATA_VLD : std_logic;
   signal RX_Busy : std_logic;

   -- Clock period definitions
   constant CLK_TIME : time := 5 ns;      --DATA_Receive_period : ((868*2)+1) * CLK_TIME ns;

   BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: UART_RX PORT MAP (
          CLK => CLK,
          nRST => nRST,
          DATA_OUT => DATA_OUT,
          DATA_VLD => DATA_VLD,
          RX_Busy => RX_Busy,
          Received_serial => Received_serial
        );
 

   CLK <= not(CLK) after CLK_TIME;
   nRST <= '0', '1' after 400 ns;  -- hold reset state for 400 ns.
   pro: process
   begin
      Received_serial <= '1';
      wait for 5000 ns;		
      Received_serial <= '0'; --START_BIT
      wait for 1737 * CLK_TIME;
      Received_serial <= '0'; --BIT_0
      wait for 1737 * CLK_TIME;
      Received_serial <= '1'; --BIT_1
      wait for 1737 * CLK_TIME;
      Received_serial <= '0'; --BIT_2
      wait for 1737 * CLK_TIME;
      Received_serial <= '1'; --BIT_3
      wait for 1737 * CLK_TIME;
      Received_serial <= '0'; --BIT_4
      wait for 1737 * CLK_TIME;
      Received_serial <= '1'; --BIT_5
      wait for 1737 * CLK_TIME;
      Received_serial <= '0'; --BIT_6
      wait for 1737 * CLK_TIME;
      Received_serial <= '1'; --BIT_7
      wait for 1737 * CLK_TIME;
      Received_serial <= '1'; --STOP_BIT
      wait for 50000 ns;		
      Received_serial <= '0'; --START_BIT
      wait for 1737 * CLK_TIME;
      Received_serial <= '1'; --BIT_0
      wait for 1737 * CLK_TIME;
      Received_serial <= '0'; --BIT_1
      wait for 1737 * CLK_TIME;
      Received_serial <= '1'; --BIT_2
      wait for 1737 * CLK_TIME;
      Received_serial <= '0'; --BIT_3
      wait for 1737 * CLK_TIME;
      Received_serial <= '1'; --BIT_4
      wait for 1737 * CLK_TIME;
      Received_serial <= '0'; --BIT_5
      wait for 1737 * CLK_TIME;
      Received_serial <= '1'; --BIT_6
      wait for 1737 * CLK_TIME;
      Received_serial <= '0'; --BIT_7
      wait for 1737 * CLK_TIME;
      Received_serial <= '1'; --STOP_BIT
      wait;
   end process;
END;
