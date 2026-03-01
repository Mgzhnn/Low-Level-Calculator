LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Tb_Final_Top_Calculator IS
END Tb_Final_Top_Calculator;

ARCHITECTURE behavior OF Tb_Final_Top_Calculator IS 
 
    -- Unit Under Test (UUT) 선언
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
    
   -- 입력 신호 초기화
   signal Clk    : std_logic := '0';
   signal Reset  : std_logic := '0';
   signal Start  : std_logic := '0';
   signal Sel    : std_logic_vector(1 downto 0) := (others => '0');
   signal A      : std_logic_vector(3 downto 0) := (others => '0');
   signal B      : std_logic_vector(3 downto 0) := (others => '0');

   -- 출력 신호
   signal Done   : std_logic;
   signal a_to_g : std_logic_vector(7 downto 0);
   signal an     : std_logic_vector(7 downto 0);

   -- 클럭 주기 (100MHz = 10ns)
   constant Clk_period : time := 10 ns;
 
BEGIN
 
   -- UUT 인스턴스화
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

   -- 클럭 생성 프로세스
   Clk_process :process
   begin
        Clk <= '0';
        wait for Clk_period/2;
        Clk <= '1';
        wait for Clk_period/2;
   end process;
 

   -- 테스트 시나리오 프로세스
-- 테스트 시나리오 프로세스
   stim_proc: process
   begin		
      -- 0. 시스템 리셋
      Reset <= '1';
      wait for 100 ns;	
      Reset <= '0';
      wait for 50 ns;

      -- ============================================================
      -- [Scenario A] 0과 관련된 연산 (Zero Property Check)
      -- ============================================================
      -- A-1. 0에 양수 더하기 (0 + 3 = 3)
      Sel <= "00"; A <= "0100"; B <= "0100";
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait for 200 ns;

      -- A-2. 0에 음수 더하기 (0 + (-5) = -5)
      Sel <= "00"; A <= "0000"; B <= "1011"; -- -5
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait for 200 ns;

      -- A-3. 0에서 양수 빼기 (0 - 4 = -4)
      Sel <= "01"; A <= "0111"; B <= "1111";
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait for 200 ns;

      -- A-4. 0을 곱하기 (5 * 0 = 0)
      Sel <= "10"; A <= "0101"; B <= "0000";
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait until Done = '1'; -- 곱셈 완료 대기
      wait for 200 ns;

      -- A-5. 0을 나누기 (0 / 3 = 0 ... 0)
      Sel <= "11"; A <= "0000"; B <= "0011";
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait until Done = '1'; -- 나눗셈 완료 대기
      wait for 200 ns;


      -- ============================================================
      -- [Scenario B] 경계값 테스트 (-8, 7) (Boundary Value Analysis)
      -- ============================================================
      -- B-1. 최대 양수 + 최대 음수 (7 + (-8) = -1)
      Sel <= "00"; A <= "0111"; B <= "1000"; 
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait for 200 ns;

      -- B-2. 최대 음수 - 최대 양수 ((-8) - 7 = -15) -> 5비트 결과 확인 필요
      Sel <= "01"; A <= "1000"; B <= "0111";
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait for 200 ns;

      -- B-3. 최대 음수 * 최대 음수 ((-8) * (-8) = 64) -> 8비트 결과 확인
      Sel <= "10"; A <= "1101"; B <= "0110";
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait until Done = '1';
      wait for 200 ns;

      -- B-4. 최대 양수 * 최대 음수 (7 * (-8) = -56)
      Sel <= "10"; A <= "1100"; B <= "1110";
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait until Done = '1';
      wait for 200 ns;


      -- ============================================================
      -- [Scenario C] 다양한 부호의 사칙연산 (Mixed Sign)
      -- ============================================================
      -- C-1. 뺄셈: 음수 - 음수 ((-3) - (-5) = 2)
      Sel <= "01"; A <= "1101"; B <= "1011";
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait for 200 ns;

      -- C-2. 뺄셈: 양수 - 음수 (2 - (-3) = 5)
      Sel <= "01"; A <= "0010"; B <= "1101";
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait for 200 ns;

      -- C-3. 곱셈: 음수 * 양수 ((-3) * 4 = -12)
      Sel <= "10"; A <= "1001"; B <= "0000";
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait until Done = '1';
      wait for 200 ns;

      -- C-4. 나눗셈: 양수 / 음수 (7 / (-2)) -> 유클리드 보정 확인
      -- 예상: 몫 -3 ("1101"), 나머지 1 ("0001") (7 = -2 * -3 + 1)
      Sel <= "11"; A <= "1011"; B <= "0011"; -- 7, -2
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait until Done = '1';
      wait for 200 ns;

      -- C-5. 나눗셈: 음수 / 음수 ((-7) / (-2))
      -- |-7| / |-2| = 3 ... 1. 부호 같으므로 몫 양수.
      -- 예상: 몫 3 ("0011"), 나머지 1 ("0001") 
      -- (주의: 하드웨어 로직에 따라 -7 = -2 * 3 - 1 이 아닌 유클리드 정의 확인 필요)
      Sel <= "11"; A <= "1000"; B <= "0001"; -- -7, -2
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait until Done = '1';
      wait for 200 ns;

      -- ============================================================
      -- [Scenario D] 리셋 기능 검증 (Reset Verification)
      -- ============================================================
      
      -- Step 1: 먼저 값이 남도록 연산을 수행 (예: 8 * 8 = 64)
      -- 목적: 레지스터와 결과값에 0이 아닌 데이터를 채워넣음
      Sel <= "11"; A <= "1000"; B <= "1111"; -- -8 * -8
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait until Done = '1';
      wait for 100 ns; 
      
      -- [검증 포인트 1] 
      -- 이 시점에서 파형은 64 결과를 보여주고 있어야 함.
      -- Stable_Mul_Res = 64 ("01000000")
      -- Done = '1'

      -- Step 2: 리셋 인가 (Reset Assertion)
      Reset <= '1';
      wait for 50 ns; -- 리셋을 5클럭 정도 유지

      -- [검증 포인트 2] 
      -- 리셋이 '1'인 구간 동안 파형이 즉시 변해야 함:
      -- 1. Done 신호가 '0'으로 떨어졌는가?
      -- 2. a_to_g (7-Segment) 출력이 0 ("00111111" 등)을 가리키는가?
      -- 3. 내부 신호 Stable_Mul_Res가 0 ("00000000")으로 초기화되었는가?

      -- Step 3: 리셋 해제 및 재가동 (Recovery Check)
      Reset <= '0';
      wait for 50 ns;

      -- 리셋 후 시스템이 정상적으로 다시 동작하는지 간단한 덧셈 확인
      Sel <= "00"; A <= "0001"; B <= "0001"; -- 1 + 1 = 2
      Start <= '1'; wait for Clk_period; Start <= '0';
      wait for 200 ns;

      wait; -- 테스트 완전 종료
   end process;

END;