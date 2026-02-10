LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY robot IS
PORT (
    SW : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    KEY : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    CLOCK_50 : IN STD_LOGIC;
    LED : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);

    -- SDRAM
    DRAM_CLK, DRAM_CKE : OUT STD_LOGIC;
    DRAM_ADDR : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
    DRAM_BA : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    DRAM_CS_N, DRAM_CAS_N, DRAM_RAS_N, DRAM_WE_N : OUT STD_LOGIC;
    DRAM_DQ : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    DRAM_DQM : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

    -- Moteurs (pin planner)
    MTRL_N : OUT STD_LOGIC;
    MTRL_P : OUT STD_LOGIC;
    MTRR_N : OUT STD_LOGIC;
    MTRR_P : OUT STD_LOGIC;
    MTR_Sleep_n : OUT STD_LOGIC;
    MTR_Fault_n : IN STD_LOGIC
);
END robot;

ARCHITECTURE Structure OF robot IS

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
            sdram_wire_we_n : OUT STD_LOGIC;

            -- ✅ VRAIS ports exportés par les PIO writedataR / writedataL
            s_writedatar_export : out   std_logic_vector(13 downto 0);
            s_writedatal_export : out   std_logic_vector(13 downto 0)                     -- export				-- export            writedatal_external_connection_export : OUT STD_LOGIC_VECTOR(13 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT PWM_generation
        PORT(
            clk, reset_n : IN std_logic;
            s_writedataR, s_writedataL : IN std_logic_vector(13 downto 0);
            dc_motor_p_R, dc_motor_n_R, dc_motor_p_L, dc_motor_n_L : OUT std_logic
        );
    END COMPONENT;

    signal cmd_R : STD_LOGIC_VECTOR(13 DOWNTO 0);
    signal cmd_L : STD_LOGIC_VECTOR(13 DOWNTO 0);

BEGIN

    -- ✅ Active les moteurs
    MTR_Sleep_n <= '1';

    -- Nios / Qsys
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
            sdram_wire_we_n => DRAM_WE_N,

            -- ✅ liaison commandes PWM (CORRIGÉE)
            s_writedatar_export => cmd_R,
            s_writedatal_export => cmd_L
        );

    -- Clock SDRAM (souvent on met plutôt le clock du PLL SDRAM si présent)
    DRAM_CLK <= CLOCK_50;

    -- PWM externe
    PWM0 : PWM_generation
        PORT MAP (
            clk => CLOCK_50,
            reset_n => KEY(0),

            s_writedataR => cmd_R,
            s_writedataL => cmd_L,

            dc_motor_p_R => MTRR_P,
            dc_motor_n_R => MTRR_N,
            dc_motor_p_L => MTRL_P,
            dc_motor_n_L => MTRL_N
        );

END Structure;
