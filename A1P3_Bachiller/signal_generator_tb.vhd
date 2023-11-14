-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity signal_generator_tb is

end signal_generator_tb;

-------------------------------------------------------------------------------

architecture sim of signal_generator_tb is



  signal RST_i        : std_logic                     := '1';
  signal CLK_i        : std_logic                     := '0';
  signal DATO_RX_OK_i : std_logic                     := '0';
  signal DATO_RX_i    : std_logic_vector (7 downto 0) := X"F0";
  signal DOUT_i       : std_logic_vector (11 downto 0);
  signal DOUT_OK_i    : std_logic;
  signal F_Out_i      : std_logic;
  signal T            : time                          := 1 ns;
  signal F            : real                          := 1.0;

begin  -- sim

  DUT : entity work.signal_generator
    port map (
      RST        => RST_i,
      CLK        => CLK_i,
      DATO_RX    => DATO_RX_i,
      DATO_RX_OK => DATO_RX_OK_i,
      DOUT       => DOUT_i,
      F_OUT      => F_OUT_i,
      DOUT_OK    => DOUT_OK_i);


  clk_i <= not clk_i after 5 ns;
  rst_i <= '0'       after 233 ns;

  process
    procedure act_dato_vld is

    begin
      wait until CLK_i = '0';
      DATO_RX_OK_i <= '1';
      wait for 1 us;
      DATO_RX_OK_i <= '0';
      wait for 1 us;
    end act_dato_vld;

  begin
    --ganancia inicial
    DATO_RX_i(7 downto 6)  <= "10";
    DATO_RX_i (5 downto 0) <= "100111";
    wait for 0.3 us;
    --forma de onda inicial
    DATO_RX_i(7 downto 6)  <= "00";
    DATO_RX_i (5 downto 0) <= "001110"; --Señal sen
    act_dato_vld;
    wait for 3 ms;
    -- frecuencias distintas
    DATO_RX_i(7 downto 6)  <= "01";
    DATO_RX_i (5 downto 0) <= "100100";
    act_dato_vld;
    wait for 2 ms;
    DATO_RX_i (5 downto 0) <= "111111";
    act_dato_vld;
    wait for 5 ms;
    DATO_RX_i (5 downto 0) <= "010101";
    act_dato_vld;
    wait for 5 ms;
    -- señales diferentes
    DATO_RX_i(7 downto 6)  <= "00";
    DATO_RX_i (5 downto 0) <= "100001";
    act_dato_vld;
    wait for 5 ms;
    DATO_RX_i (5 downto 0) <= "000101";
    act_dato_vld;
    wait for 5 ms;
    DATO_RX_i (5 downto 0) <= "000010";
    act_dato_vld;
    wait for 5 ms;
    DATO_RX_i (5 downto 0) <= "000110";
    act_dato_vld;
    wait for 5 ms;
    -- ganacias diferentes
    DATO_RX_i(7 downto 6)  <= "10";
    DATO_RX_i (5 downto 0) <= "000111";
    act_dato_vld;
    wait for 5 ms;
    DATO_RX_i (5 downto 0) <= "111111";
    act_dato_vld;
    wait for 5 ms;
    -- nivel de continua diferentes
    DATO_RX_i(7 downto 6)  <= "11";
    DATO_RX_i (5 downto 0) <= "000111";
    act_dato_vld;
    wait for 5 ms;
    DATO_RX_i (5 downto 0) <= "100000";
    act_dato_vld;
    wait for 5 ms;

    report "FIN CONTROLADO DE LA SIMULACION" severity failure;
  end process;

  process (F_OUT_i)
    variable t_aux : time := 1 ns;
  begin  -- process    
    if F_OUT_i'event and F_OUT_i = '1' then

      T <= now- t_aux;
      t_aux := now;
    end if;
  end process;

  F <= 1.0e-3*real((1 sec)/T) when T > 0 ns else 1.0;

end sim;

-------------------------------------------------------------------------------
