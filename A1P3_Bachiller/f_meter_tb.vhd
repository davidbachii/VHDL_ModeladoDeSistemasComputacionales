-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity f_meter_tb is

end f_meter_tb;

-------------------------------------------------------------------------------

architecture sim of f_meter_tb is


  signal CLK_i      : std_logic := '0';
  signal RST_i      : std_logic := '1';
  signal F_OUT_i    : std_logic;
  signal F_MED_OK_i : std_logic;
  signal F_MED_i    : std_logic_vector(15 downto 0);
  signal T          : time      := 100 ns;
  signal F          : integer;
begin  -- sim

  DUT : entity work.f_meter
    port map (
      CLK      => CLK_i,
      RST      => RST_i,
      F_OUT    => F_OUT_i,
      F_MED_OK => F_MED_OK_i,
      F_MED    => F_MED_i);



  CLK_i <= not CLK_i after 5 ns;
  RST_i <= '0'       after 115 ns;

  process
  begin
    F_OUT_i <= '0';
    wait for T-10 ns;
    F_OUT_i <= '1';
    wait for 10 ns;
  end process;

  F <= (1 ms)/T;

  process
begin
  T <= 120 ns;
  wait for 2 ms;
  
  T <= 130 ns;
  wait for 2 ms;
  
  T <= 230 ns;
  wait for 2 ms;
  
  T <= 333 ns;
  wait for 2 ms;
  
  report "FIN CONTROLADO DE LA SIMULACIÓN" severity failure;
  
  wait;
end process;


end sim;

-------------------------------------------------------------------------------
