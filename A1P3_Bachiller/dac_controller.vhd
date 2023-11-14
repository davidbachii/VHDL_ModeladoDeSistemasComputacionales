library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dac_controller is
  port (
    CLK     : in  std_logic;
    RST     : in  std_logic;
    DOUT    : in  std_logic_vector(11 downto 0);
    DOUT_OK : in  std_logic;
    SYNC    : out std_logic;
    SCLK    : out std_logic;
    DIN     : out std_logic);
end dac_controller;

architecture RTL of dac_controller is

    signal dout_reg: std_logic_vector(15 downto 0);
    
    signal ce_shift : std_logic;
    signal ce_cntbits : std_logic;
    signal sync_next: std_logic;
    signal sclk_next : std_logic;

    type FSM is (Q0, Q1,Q2, Q3, Q4);
    signal std_act: FSM;
    
     signal contador: integer range 0 to 16 := 0;
    
    
begin

-- Registro load/ desplazamiento
    process(all)
    begin
        if rst = '1' then
            dout_reg <= (others => '0');
        elsif clk'event and clk='1' then
            if dout_ok = '1' then
                dout_reg <= "0000" & dout;
            elsif ce_shift = '1' then
                dout_reg <= dout_reg rol 1;
            end if;               
        end if;   
    end process;
    
    -- Contador de bits transmitidos
    process(all)
    begin
        if rst = '1' then
            contador <= 0;
        elsif clk'event and clk = '1' then
            if dout_ok = '1' then
                contador <= 0;
            elsif ce_cntbits = '1' then
                contador <= contador + 1;
            end if;
        end if;   
    end process;
    
    -- Registro para dato a transmitir
    process(all)
    begin
        if rst = '1' then
            din <= '0';
        elsif clk'event and clk = '1' then
            din <= dout_reg(15);
        end if;
    end process;
    
        
    -- Biestable Tipo D sync_next
        process(all)
        begin
            if rst = '1' then
                sync <= '1';
            elsif clk'event and clk = '1' then
                sync <= sync_next;
            end if;    
        end process;
        
        
        -- Biestable Tipo D sclk_next
        process(all)
        begin
            if rst = '1' then
                sclk <= '0';
            elsif clk'event and clk = '1' then
                sclk <= sclk_next;
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
                           if DOUT_OK = '1' then
                               std_act <= Q1;
                           else 
                               std_act <= Q0; 
                           end if;
                       when Q1 =>
                           std_act <= Q2;
                       when Q2 =>
                          
                               std_act <= Q3;
                           
                       when Q3 =>
                           std_act <= Q4;
                       when Q4 =>
                           if contador < 16 then
                            std_act <= Q1;    
                           else 
                            std_act <= Q0;
                           end if;
                   end case;
               end if;
           end process;
           
           ce_shift <= '1' when (std_act = Q4) else '0';       
           ce_cntbits <= '1' when (std_act = Q1) else '0';
           sync_next <= '1' when (std_act = Q0) else '0';
           sclk_next <= '1' when (std_act = Q1 or std_act = Q2 ) else '0';
           
           
end RTL;
