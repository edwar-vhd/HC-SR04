----------------------------------------------------------------------------------------
-- University: Universidad Pedagógica y Tecnológica de Colombia
-- Author: Edwar Javier Patiño Núñez
--
-- Create Date: 24/08/2020
-- Project Name: HC_SR04
-- Description: 
-- 	This description emulates the behavior of the HC_SR04 sensor
----------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity HC_SR04 is
	port(
		distance		:in natural;
		trig			:in std_logic;
		echo			:out std_logic
	);
end entity;

architecture behav of HC_SR04 is
	-- Signals for FSM
	type state_type is (reset, initiate, pulses, response, idle, oor);
	signal curr_state, nxt_state	:state_type;
	
	signal clk			:std_logic:='0';
	signal rst			:std_logic:='1';
	signal ctr			:natural:=0;
	
	-- Internal signal of pulses
	signal pul			:std_logic:='0';
	signal aux 			:std_logic_vector(31 downto 0);
	
	-- Signal for resolution
	signal dist			:natural:= 0;
begin
	---------------------------------------------------------
	-- Sensor resolution
	---------------------------------------------------------
	process(distance)
	begin
		if (distance >= 20) and (distance <= 4000) then
			for i in 0 to 1328 loop		-- Number of data with 3mm resolution in the measuring range
				if ((distance*10)/(20+(i*3))) >= 10 then
					dist <= 20+(i*3);
				end if;
			end loop;
		end if;
	end process;

	aux <= std_logic_vector(to_unsigned(ctr,32));
	
	---------------------------------------------------------
	-- FSM
	---------------------------------------------------------
	-- Internal reset
	process
	begin	
		wait until rising_edge(Trig);
		rst <= '1';
		wait for 500 ns;
		rst <= '0';
	end process;
	
	-- Clock
	process
	begin	
		wait for 390625 ps;	-- 1.28MHz
		clk <= not clk;
	end process;
	
	-- State transition logic
	process (clk, rst)
	begin
		if rst = '1' then
			curr_state <= reset;
		elsif (falling_edge(clk)) then
			curr_state <= nxt_state;
		end if;
	end process;
	
	-- Next state logic
	process(curr_state, ctr, trig)
	begin
		case curr_state is
			when reset =>
				nxt_state <= initiate;
				
			when initiate =>
				if trig = '0' then
					if ctr >= 11 then			-- Time to initiate 9us (9us + 0.5us reset + 0.5us lag = 10us)
						nxt_state <= pulses;
					else
						nxt_state <= idle;
					end if;
				else
					nxt_state <= initiate;
				end if;
				
			when pulses =>
				if ctr >= 255 then		-- Time of pulses (200 us)
					nxt_state <= response;
				else
					nxt_state <= pulses;
				end if;
				
			when response =>
				if (distance >= 20) and (distance <= 4000) then
					if ctr >= (((dist*128)/17)-1) then		-- Guaranteed time
						nxt_state <= idle;
					else 
						nxt_state <= response;
					end if;
				else
					nxt_state <= oor;
				end if;
			
			when oor =>
				if ctr >= 38399 then		-- 30ms if no "object" detected
					nxt_state <= idle;
				else
					nxt_state <= oor;
				end if;
				
			when idle =>
				nxt_state <= idle;
		end case;
	end process;
	
	-- Timer
	process(clk)
	begin
		if falling_edge(clk) then
			if curr_state /= nxt_state then
				ctr <= 0;
			else
				ctr <= ctr + 1;
			end if;
		end if;
	end process;
	
	-- Output depends solely on the current state
	process (curr_state, aux)
	begin
		case curr_state is
			when reset =>
				echo 	<= '0';
				pul 	<= '0';
			when initiate =>
				echo 	<= '0';
				pul	<= '0';
			when pulses =>
				echo 	<= '0';
				pul 	<= not(aux(4));
			when response =>
				echo 	<= '1';
				pul 	<= '0';
			when oor =>
				echo 	<= '1';
				pul 	<= '0';
			when idle =>
				echo 	<= '0';
				pul 	<= '0';
		end case;
	end process;
end architecture;