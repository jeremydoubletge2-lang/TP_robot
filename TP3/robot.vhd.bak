-- Inputs: SW3−0 are parallel port inputs to the Nios II system.
-- CLOCK_50 is the system clock.
-- KEY0 is the active-low system reset.
-- Outputs: LED3−0 are parallel port outputs from the Nios II system.
-- SDRAM ports correspond to the signals in Figure 2; their names are those
-- used in the DE0-Nano User Manual.
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
ENTITY Lights IS
PORT (
	SW : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	KEY : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	CLOCK_50 : IN STD_LOGIC;
	LED : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	DRAM_CLK, DRAM_CKE : OUT STD_LOGIC;
	DRAM_ADDR : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
	DRAM_BA : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	DRAM_CS_N, DRAM_CAS_N, DRAM_RAS_N, DRAM_WE_N : OUT STD_LOGIC;
	DRAM_DQ : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	DRAM_DQM : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) );
END Lights;
ARCHITECTURE Structure OF lights IS
COMPONENT nios_system
PORT (
	clk_clk : IN STD_LOGIC;
	reset_reset_n : IN STD_LOGIC;
	leds_export : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	switches_export : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	sdram_wire_addr : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
	sdram_wire_ba : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	sdram_wire_cas_n : OUT STD_LOGIC;
	sdram_wire_cke : OUT STD_LOGIC;
	sdram_wire_cs_n : OUT STD_LOGIC;
	sdram_wire_dq : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	sdram_wire_dqm : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	sdram_wire_ras_n : OUT STD_LOGIC;
	sdram_wire_we_n : OUT STD_LOGIC );
END COMPONENT;

BEGIN
NiosII: nios_system
PORT MAP (
	clk_clk => CLOCK_50,
	reset_reset_n => KEY(0),
	leds_export => LED,
	switches_export => SW,
	sdram_wire_addr => DRAM_ADDR,
	sdram_wire_ba => DRAM_BA,
	sdram_wire_cas_n => DRAM_CAS_N,
	sdram_wire_cke => DRAM_CKE,
	sdram_wire_cs_n => DRAM_CS_N,
	sdram_wire_dq => DRAM_DQ,
	sdram_wire_dqm => DRAM_DQM,
	sdram_wire_ras_n => DRAM_RAS_N,
	sdram_wire_we_n => DRAM_WE_N );
	DRAM_CLK <= CLOCK_50;
END Structure;