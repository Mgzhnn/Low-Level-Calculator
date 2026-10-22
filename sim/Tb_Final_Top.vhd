LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Tb_Final_Top_Calculator IS
END Tb_Final_Top_Calculator;

ARCHITECTURE behavior OF Tb_Final_Top_Calculator IS 
 

    COMPONENT Final_Top_Calculator
    PORT(
         Clk    : IN  std_logic;
         Reset  : IN  std_logic;
         Start  : IN  std_logic;
         Sel    : IN  std_logic_vector(1 downto 0);
         A      : IN  std_logic_vector(3 downto 0);
         B      : IN  std_logic_vector(3 downto 0);
         Done   : OUT std_logic;
         a_to_g : OUT std_logic_vector(7 downto 0);
         an     : OUT std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   signal Clk    : std_logic := '0';
   signal Reset  : std_logic := '0';
   signal Start  : std_logic := '0';
   signal Sel    : std_logic_vector(1 downto 0) := (others => '0');
   signal A      : std_logic_vector(3 downto 0) := (others => '0');
   signal B      : std_logic_vector(3 downto 0) := (others => '0');


   signal Done   : std_logic;
   signal a_to_g : std_logic_vector(7 downto 0);
   signal an     : std_logic_vector(7 downto 0);


   constant Clk_period : time := 10 ns;
 
BEGIN
 

   uut: Final_Top_Calculator PORT MAP (
          Clk => Clk,
          Reset => Reset,
          Start => Start,
          Sel => Sel,
          A => A,
          B => B,
          Done => Done,
          a_to_g => a_to_g,
          an => an
        );


   Clk_process :process
   begin
        Clk <= '0';
        wait for Clk_period/2;
        Clk <= '1';
        wait for Clk_period/2;
   end process;
 



   stim_proc: process
   begin		

      Reset <= '1';
      wait for 100 ns;	
      Reset <= '0';
      wait for 50 ns;





      Sel <= "00"; A <= "0100"; B <= "0100";
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait for 200 ns;


      Sel <= "00"; A <= "0000"; B <= "1011";
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait for 200 ns;


      Sel <= "01"; A <= "0111"; B <= "1111";
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait for 200 ns;


      Sel <= "10"; A <= "0101"; B <= "0000";
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait until Done = '1';
      wait for 200 ns;


      Sel <= "11"; A <= "0000"; B <= "0011";
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait until Done = '1';
      wait for 200 ns;






      Sel <= "00"; A <= "0111"; B <= "1000"; 
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait for 200 ns;


      Sel <= "01"; A <= "1000"; B <= "0111";
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait for 200 ns;


      Sel <= "10"; A <= "1101"; B <= "0110";
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait until Done = '1';
      wait for 200 ns;


      Sel <= "10"; A <= "1100"; B <= "1110";
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait until Done = '1';
      wait for 200 ns;






      Sel <= "01"; A <= "1101"; B <= "1011";
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait for 200 ns;


      Sel <= "01"; A <= "0010"; B <= "1101";
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait for 200 ns;


      Sel <= "10"; A <= "1001"; B <= "0000";
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait until Done = '1';
      wait for 200 ns;



      Sel <= "11"; A <= "1011"; B <= "0011";
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait until Done = '1';
      wait for 200 ns;





      Sel <= "11"; A <= "1000"; B <= "0001";
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait until Done = '1';
      wait for 200 ns;




      


      Sel <= "11"; A <= "1000"; B <= "1111";
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait until Done = '1';
      wait for 100 ns; 
      






      Reset <= '1';
      wait for 50 ns;








      Reset <= '0';
      wait for 50 ns;


      Sel <= "00"; A <= "0001"; B <= "0001";
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait for 200 ns;

      wait;
   end process;

END;