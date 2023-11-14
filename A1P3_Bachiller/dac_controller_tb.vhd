-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-------------------------------------------------------------------------------

entity dac_controller_tb is
end dac_controller_tb;

-------------------------------------------------------------------------------

architecture sim of dac_controller_tb is
  signal   VOUT      : real      := 0.0;
  signal   CLK_i     : std_logic := '0';
  signal   RST_i     : std_logic := '1';
  signal   DOUT_i    : std_logic_vector(11 downto 0);
  signal   DOUT_OK_i : std_logic;
  signal   SYNC_i    : std_logic;
  signal   SCLK_i    : std_logic;
  signal   DIN_i     : std_logic;
  signal   V         : real;
  constant T_DOUT    : time:= 660ns;


begin  -- sim
  dac : entity work.DAC121S101
    port map (
      VOUT => VOUT,
      SYNC => SYNC_i,
      SCLK => SCLK_i,
      DIN  => DIN_i);

  V <= real(to_integer(unsigned(DOUT_i)))*3.3/4096.0;

  DUT : entity work.dac_controller
    port map (
      CLK     => CLK_i,
      RST     => RST_i,
      DOUT    => DOUT_i,
      DOUT_OK => DOUT_OK_i,
      SYNC    => SYNC_i,
      SCLK    => SCLK_i,
      DIN     => DIN_i);



  CLK_i <= not CLK_i after 5 ns;
  RST_i <= '0'       after 177 ns;


  process
  begin  -- process
    DOUT_i    <= x"2e9";                       -- A completar
    DOUT_OK_i <= '0';
    wait for 210 ns;
    wait until CLK_i = '0';
    DOUT_OK_i <= '1';
    wait until CLK_i = '0';
    DOUT_OK_i <= '0';
    wait for T_DOUT;

    wait until CLK_i = '0';
    DOUT_OK_i <= '1';
    DOUT_i    <= x"607";                       -- A completar
    wait until CLK_i = '0';
    DOUT_OK_i <= '0';
    wait for T_DOUT;

    wait until CLK_i = '0';
    DOUT_OK_i <= '1';
    DOUT_i    <=x"aaa";                       -- A completar
    wait until CLK_i = '0';
    DOUT_OK_i <= '0';
    wait for T_DOUT;

    wait until CLK_i = '0';
    DOUT_i    <= x"d05";                       -- A completar
    DOUT_OK_i <= '1';
    wait until CLK_i = '0';
    DOUT_OK_i <= '0';
    wait for T_DOUT;

    wait until CLK_i = '0';
    DOUT_OK_i <= '1';
    DOUT_i    <= x"457";                       -- A completar
    wait until CLK_i = '0';
    DOUT_OK_i <= '0';
    wait for T_DOUT;

    report "FIN CONTROLADO DE LA SIMULACION" severity failure;
  end process;



end sim;

-------------------------------------------------------------------------------
