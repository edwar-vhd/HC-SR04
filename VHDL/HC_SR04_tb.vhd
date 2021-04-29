----------------------------------------------------------------------------------------
-- University: Universidad Pedagógica y Tecnológica de Colombia
-- Author: Edwar Javier Patiño Núñez
--
-- Create Date: 25/08/2020
-- Project Name: HC_SR04_tb
----------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity HC_SR04_tb is
end entity;

architecture behav of HC_SR04_tb is
	signal distance	:natural := 840; -- 2cm
	
	signal trig			:std_logic:='0';
	signal echo			:std_logic;
begin
	---------------------------------------------------------
	-- Instantiate and map the design under test 256Kx16
	---------------------------------------------------------	
	DUT: entity work.HC_SR04
		port map(
			distance	=> distance,
			trig		=> trig,
			echo		=> echo
		);
	
	process
	begin
		wait for 10 us;
		
		trig <= '1';
		wait for 10 us;
		trig <= '0';
		
		wait for 50 ms;
		distance <= 5000;
		trig <= '1';
		wait for 10 us;
		trig <= '0';
	end process;
end architecture;