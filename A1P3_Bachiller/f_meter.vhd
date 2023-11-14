library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity f_meter is
  port(
    CLK      : in  std_logic;
    RST      : in  std_logic;
    F_OUT    : in  std_logic;
    F_MED_OK : out std_logic;
    F_MED    : out std_logic_vector(15 downto 0));
end f_meter;

architecture rtl of f_meter is
    signal Unid,Dec,Cen,Mil : unsigned(3 downto 0);
    signal pre_out :  std_logic;
  constant CLKDIV      : integer := 100e6;   -- para la implementación
 --  constant CLKDIV : integer := 100e3;  -- 100 MHz * 0.001 s = 100000 para simulacion
  signal   counter_reg : integer range 0 to CLKDIV-1;
 
  
begin  -- rtl
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
--Contador BCD
process(clk,rst)
begin 
if rst = '1' then --Salida del prescaler que actua como señal asincrona
   Mil<= (others=>'0');
   Cen<= (others=>'0');
   Dec<= (others=>'0');
   Unid<= (others=>'0');
   Unid<= (others=>'0');
elsif CLK'event and CLK = '1' then
    if pre_out = '1' then  --Actua como reset sincrono
             Mil<= (others=>'0');
             Cen<= (others=>'0');
             Dec<= (others=>'0');
             Unid<= (others=>'0');
            
             
             
          elsif F_OUT = '1' then   --Actua como CE, señal sincrona
                Unid<=Unid+1;
          if Unid=9 then
                Unid<=(others=>'0');
                Dec<=Dec+1;
          if Dec=9 then
                Dec<=(others=>'0');
                Cen <= Cen+1;
          if Cen= 9 then
                Cen <= (others => '0');
                Mil <= Mil+1;
          if Mil = 9 then 
                Mil <= (others =>'0');  
          end if;
          end if;
          end if;
          end if;
          end if;
 end if;
 
end process;

--Biestable tipo D
process (CLK, RST)
begin
if RST = '1' then
 F_MED_OK <= '0';
elsif CLK'event and CLK = '1' then
   F_MED_OK<= pre_out; 
end if;
end process;



process(clk,rst)
begin
if RST = '1' then
    F_MED <= (others =>'0') ;
elsif CLK'event and CLK = '1' then
    if pre_out = '1' then
         F_MED <= std_logic_vector(Mil&Cen&Dec&Unid);
     end if;   
   
end if;
end process;
end rtl;