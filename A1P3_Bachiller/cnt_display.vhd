library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cnt_display is
  port (
    CLK         : in  std_logic;
    RST         : in  std_logic;
    DATO_BCD    : in  std_logic_vector(15 downto 0);
    DATO_BCD_OK : in  std_logic;
    AND_30      : out std_logic_vector(3 downto 0);
    DP          : out std_logic;
    SEG_AG      : out std_logic_vector(6 downto 0));
end cnt_display;

architecture rtl of cnt_display is
constant CLKDIV      : integer := 30000;   -- para la implementación
--constant CLKDIV      : integer := 30;  -- para la simulación  3ms por display pero son 4   10 kHz * 0.003 s = 30 para simulacion
signal   counter_reg : integer range 0 to CLKDIV-1;
signal pre_out :  std_logic;
signal Unid,Dec,Cen,Mil : unsigned(3 downto 0);
signal DATO_BCD_REG : std_logic_vector(15 downto 0); --Salida del registro
signal DATO_BCD_CC : std_logic_vector(15 downto 0); --Salida del circuito combinacional
signal DATO_BCD_MUL :std_logic_vector(3 downto 0);
signal contador : unsigned(1 downto 0);


begin  -- rtl


--Biestable
process (CLK, RST)
 begin
 if RST = '1' then
 DATO_BCD_REG <= (others=>'0');
 elsif CLK'event and CLK = '1' then
    if  DATO_BCD_OK = '1' then
    DATO_BCD_REG <=  DATO_BCD;
    end if;
 end if;
 end process;

--Verificar los datos circuito combinacionales
process(all)
begin
--x"1234" --> x"1234" --> 1234
--x"A234" --> X"FA1C" --> FAIL
--x"0375" --> X"B375" --> 375
--x"0000"--> X"BBB0" --> 0
--x"9007" --> X"9007" -->9007
 Unid <= unsigned(DATO_BCD_REG(3 downto 0));
 Dec  <= unsigned(DATO_BCD_REG(7 downto 4));
 Cen  <= unsigned(DATO_BCD_REG(11 downto 8));
 Mil  <= unsigned(DATO_BCD_REG(15 downto 12));
 if Mil > 9 or Cen > 9 or Dec > 9 or Unid > 9 then
  DATO_BCD_CC <=  X"FA1C" ;
 elsif Mil = 0 then 
    if Cen = 0 then                                       
       if Dec = 0 then 
        DATO_BCD_CC <= X"B"&X"B"&X"B"&DATO_BCD_REG(3 downto 0) ;  --x"0005" --> X"BBB5" --> 5
       else
        DATO_BCD_CC <= X"B"&X"B"&DATO_BCD_REG(7 downto 0);  --x"0075" --> X"BB75" --> 75
       end if;
    else
    DATO_BCD_CC <= X"B"&DATO_BCD_REG(11 downto 0) ;  --x"0375" --> X"B375" --> 375  
    end if;
 else  
 DATO_BCD_CC <= DATO_BCD_REG;
 end if;
end process;
--Prescaler
 process (clk, rst) 
begin  -- process
           if rst = '1' then
             counter_reg  <= 0;
           elsif clk'event and clk = '1' then
             if counter_reg >= CLKDIV-1 then
               counter_reg <= 0;
             else
               counter_reg <= counter_reg+1;
             end if;
           end if;
        end process;
    
     pre_out <= '1' when counter_reg = CLKDIV-1 else '0';
--Contador 
process(CLK,rst)
begin
if rst = '1' then
contador <= (others=>'0');
elsif CLK'event and CLK = '1' then
    if pre_out = '1' then
        contador <= contador + 1;
    end if;
 end if;
end process;
--Multiplexor
process(DATO_BCD_CC,contador)
begin
if contador = 1 then
DATO_BCD_MUL <= DATO_BCD_CC(15 downto 12);
elsif contador = 2 then
DATO_BCD_MUL <= DATO_BCD_CC(11 downto 8);
elsif contador = 3 then
DATO_BCD_MUL <= DATO_BCD_CC(7 downto 4);
else
DATO_BCD_MUL <= DATO_BCD_CC(3 downto 0);
end if;
end process;
--Decodificador BCD 7 SEGMENTOS
process (DATO_BCD_MUL) is
 begin case DATO_BCD_MUL is --gfedcba
 when x"0" =>
 SEG_AG <= "1000000";
 when x"1" => --Tambien actua como I 
 SEG_AG<= "1111001";
 when x"2" =>
 SEG_AG <= "0100100"; 
 when x"3" =>
 SEG_AG <= "0110000";
 when x"4" =>
 SEG_AG <= "0011001";
 when x"5" =>
 SEG_AG <= "0010010";
  when x"6" =>
 SEG_AG <= "0000010";
 when x"7" =>
 SEG_AG <= "1111000";
 when x"8" =>
 SEG_AG <= "0000000";
 when x"9" =>
 SEG_AG <= "0011000";
 when x"A" =>
 SEG_AG <= "0001000";
 when x"C" => --Cuando me llega una C muestro una L para rellenar FAIL
 SEG_AG <= "1000111";
 when x"F" =>
 SEG_AG <= "0001110"; 
 when others =>
 SEG_AG <= "1111111"; end case;
 end process;

--Decodificador 
process(contador)
begin
 if contador = 1 then
 AND_30 <= "0111";
 elsif contador = 2 then
 AND_30 <= "1011";
 elsif contador =3 then
 AND_30 <= "1101";
 else 
 AND_30 <= "1110";
 end if;
 end process;
 
 DP <= '1';
end rtl;

