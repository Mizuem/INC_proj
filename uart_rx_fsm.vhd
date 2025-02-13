-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): xmalytd00

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



entity UART_RX_FSM is
    port(
       CLK 		 		   : in std_logic;
       RST 		 		   : in std_logic;
	   DIN 		  	       : in std_logic;
	   CNT_SAMPLE 		   : in std_logic_vector (4 downto 0);
	   CNT_BITS   		   : in std_logic_vector (3 downto 0);
	   SAMPLING_ACTIVE	   : out std_logic;
	   DATA_VALID 		   : out std_logic;
	   CNT_SAMPLING_ACTIVE : out std_logic
    );
end entity;



architecture behavioral of UART_RX_FSM is
type STATES is (IDLE, FIRST_BIT, DATA_SAMPLE, STOP);
signal t_state : STATES := IDLE;

begin
	CNT_SAMPLING_ACTIVE <= '0' when t_state = IDLE else '1';
	SAMPLING_ACTIVE <= '1' when t_state = DATA_SAMPLE else '0';
	DATA_VALID <= '1' when t_state = STOP else '0';
	process(CLK) begin
		if rising_edge(CLK) then
			if RST = '1' then
				t_state <= IDLE;
			else
				case t_state is
				when IDLE => if DIN = '0' then 
								t_state <= FIRST_BIT; 
								end if;
				when FIRST_BIT => if CNT_SAMPLE = "10111" then 
									 t_state <= DATA_SAMPLE; 
									 end if;
				when DATA_SAMPLE => if CNT_BITS = "1000" then
									   t_state <= STOP;
									   end if;
				when STOP => if DIN = '1' then
								if CNT_SAMPLE = "01111" then
									t_state <= IDLE;
								end if;	
							 end if;
				when others => null;
				end case;
			end if;
		end if;
	end process;
end architecture;
