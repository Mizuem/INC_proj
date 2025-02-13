-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): xmalytd00

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
    port(
        CLK      : in std_logic;
        RST      : in std_logic;
        DIN      : in std_logic;
        DOUT     : out std_logic_vector(7 downto 0);
        DOUT_VLD : out std_logic
    );
end entity;



-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is
signal CNT_SAMPLE 	   : std_logic_vector (4 downto 0);
signal CNT_BITS	 	   : std_logic_vector (3 downto 0);
signal SAMPLING_ACTIVE : std_logic; 
signal DATA_VALID : std_logic;
signal CNT_SAMPLING_ACTIVE : std_logic;
begin

    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    port map (
       CLK 				   => CLK,
       RST 				   => RST,
	   DIN 		 		   => DIN,
	   CNT_SAMPLE 		   => CNT_SAMPLE,
	   CNT_BITS   		   => CNT_BITS,
	   SAMPLING_ACTIVE	   => SAMPLING_ACTIVE,
	   DATA_VALID 		   => DATA_VALID,
	   CNT_SAMPLING_ACTIVE => CNT_SAMPLING_ACTIVE
    );

	process (CLK) begin
		
		if rising_edge(CLK) then
			
			if RST = '1' then
				DOUT <= (others => '0');
				DOUT_VLD <= '0';
				CNT_SAMPLE <= "00001";
				CNT_BITS <= "0000";
			end if;
			
			if CNT_SAMPLING_ACTIVE = '0' then
				CNT_SAMPLE <= "00001";
			else
				CNT_SAMPLE <= CNT_SAMPLE + 1;
			end if;
			
			DOUT_VLD <= '0';
			
			if CNT_BITS = "1000" then
				if DATA_VALID = '1' then
					CNT_BITS <= "0000";
					DOUT_VLD <= '1';
				end if;
			end if;
			
			if SAMPLING_ACTIVE = '1' then
				if CNT_SAMPLE(4) = '1' then
					CNT_SAMPLE <= "00001";
					
					case CNT_BITS is
					when "0000" => DOUT(0) <= DIN;
								   CNT_BITS <= "0001";
					when "0001" => DOUT(1) <= DIN;
								   CNT_BITS <= "0010";					
					when "0010" => DOUT(2) <= DIN;
								   CNT_BITS <= "0011";
					when "0011" => DOUT(3) <= DIN;
								   CNT_BITS <= "0100";
					when "0100" => DOUT(4) <= DIN;
								   CNT_BITS <= "0101";
					when "0101" => DOUT(5) <= DIN;
								   CNT_BITS <= "0110";					
					when "0110" => DOUT(6) <= DIN;
								   CNT_BITS <= "0111";
					when "0111" => DOUT(7) <= DIN;
								   CNT_BITS <= "1000";
					when others => null;
					end case;
				end if;
			end if;
		end if;
	end process;



end architecture;
