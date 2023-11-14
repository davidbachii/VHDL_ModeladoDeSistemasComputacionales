library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity signal_generator is
  port ( RST        : in  std_logic;
         CLK        : in  std_logic;
         DATO_RX    : in  std_logic_vector (7 downto 0);
         DATO_RX_OK : in  std_logic;
         DOUT       : out std_logic_vector (11 downto 0);
         F_OUT      : out std_logic;
         DOUT_OK    : out std_logic);
end signal_generator;

architecture rtl of signal_generator is
    signal FREQ : unsigned(5 downto 0);
    signal GAIN : unsigned(3 downto 0);
    signal DC : unsigned(5 downto 0);
    signal SG_TYPE : unsigned(2 downto 0);
    signal SEL : unsigned(1 downto 0);
    signal dato_rxU :unsigned ( 7 downto 0); 
    
   
    signal add_7: std_logic;
    
    signal onda: unsigned(7 downto 0);
    signal onda_gain: unsigned(11 downto 0);
    signal onda_dc: unsigned(12 downto 0); 
     
    signal Triang : unsigned(7 downto 0);
    signal D_sierra : unsigned(7 downto 0);
    signal Cuadrada25 : unsigned(7 downto 0);
    signal Cuadrada50 : unsigned(7 downto 0);
    signal Cuadrada75 : unsigned(7 downto 0);
    signal Senox : std_logic_vector(7 downto 0);
    
    signal contador: unsigned(19 downto 0);
    signal address: unsigned(7 downto 0);
    
   type FSM is (Q0, Q1, Q2, Q3);
        signal std_act: FSM;  
    
begin
 
 
--Contador 
process(all)
begin
    if rst ='1' then
          contador <= (others => '0');
    elsif clk'event and clk = '1' then
          contador <= contador + FREQ;                
    end if;       
end process;

--Address
 address <= contador(19 downto 12);
 
 
 --Seno
seno: entity work.seno
      port map(
             ADDR => std_logic_vector(address),
             CLK => CLK,
             DOUT => Senox);
             
--Diente de sierra
D_sierra <= address;

--Triangular 
process(all)
    begin
        if(address(7) = '0') then
            Triang <= address(6 downto 0) & '0';
        else
            Triang <= not(address(6 downto 0) & '0');
        end if;        
    end process;
-- cuadrada 50%
process(all)
begin
     if(address >= 128) then
        Cuadrada50 <= x"00";
     else
        Cuadrada50 <= x"ff";
     end if;
 end process;    
        
--cuadrada 25%
process(all)
begin
    if(address >= 64) then
       Cuadrada25 <= x"00";
    else
       Cuadrada25 <= x"ff";
    end if;
end process;  
        
 -- cuadrada 75%
process(all)
begin
    if(address >= 192) then
       Cuadrada75 <= x"00";
    else
       Cuadrada75 <= x"ff";
    end if;
 end process;    
       
       
       
 -- Calculamos f_out   
    process(all)
    begin
        if rst = '1' then
            add_7 <= '0';
        elsif clk'event and clk = '1' then
            add_7 <= std_logic(address(7));
        end if;    
    end process;
    
      process(all)
      begin
          if rst = '1' then
              F_OUT <= '0';
          elsif clk'event and clk = '1' then
              F_OUT <= std_logic(address(7)) and not(add_7);
          end if;    
      end process;
    
    -- Generacion de dout_ok
    process(all)
    begin
        if rst = '1' then
            std_act <= Q0;
        elsif clk'event and clk = '1' then
            case std_act is
                when Q0 =>
                    if address(0) = '1' then
                        std_act <= Q1;
                    end if;
                when Q1 =>
                    std_act <= Q2;
                when Q2 =>
                    if address(0) = '0' then
                        std_act <= Q3;
                    else 
                        std_act <= Q2;
                    end if;
                when Q3 =>
                    std_act <= Q0;
            end case;
        end if;
    end process;
    
    dout_ok <= '1' when (std_act = Q1 or std_act = Q3) else '0';
  
  
  
  
dato_rxU <= unsigned(dato_rx);
SEL <= dato_rxU(7 downto 6);

   
--Registro para capturar los parametros de la se?al a generar
    process(all)
    begin 
        if RST = '1' then
            FREQ <=  "000001";
            GAIN <= "0011";
            DC <= (others => '0');
            SG_TYPE <= "110";
        elsif CLK'event and CLK='1' then 
            if DATO_RX_OK = '1' then 
             case SEL is
                 when "00" =>
                    SG_TYPE <= dato_rxU(2 downto 0);
                when "01" =>
                    FREQ <= dato_rxU(5 downto 0);
                when "10" =>
                    GAIN <= dato_rxU(3 downto 0);
                when others =>
                    DC <= dato_rxU(5 downto 0);
            end case;
         end if;
        end if;
                 
    end process;   
  
    --Siganl type
      process(all)
      begin
      case SG_TYPE is
          when "110" =>
              onda <= unsigned(Senox);
          when "101" =>
              onda <= Triang;
          when "100" =>
              onda <= D_sierra;
          when "011" =>
             onda <= Cuadrada50;
          when "010" =>
             onda <= Cuadrada25;
          when "001" =>
              onda <= Cuadrada75;
          when others =>
              onda <= unsigned(Senox);
          end case;
      end process;
      
   -- Calculamos dout
         onda_gain <= onda*GAIN;
         onda_dc <= (('0' & onda_gain) + unsigned(DC & "000000"));
         process(all)
         begin
             if rst = '1' then
                 dout <= (others => '0');
             elsif clk'event and clk = '1' then
                 dout <= std_logic_vector(onda_dc(11 downto 0));
                 if onda_dc(12) = '1' then
                     dout <= (others => '1');
                 end if;
             end if;
         end process;       
  
    
end rtl;