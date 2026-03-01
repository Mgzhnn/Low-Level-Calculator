library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

entity Multiplier_4bit is
    Port ( 
        Clk      : in  STD_LOGIC;
        Reset    : in  STD_LOGIC;
        Start    : in  STD_LOGIC;
        A_in     : in  STD_LOGIC_VECTOR (3 downto 0); 
        B_in     : in  STD_LOGIC_VECTOR (3 downto 0); 
        Result   : out STD_LOGIC_VECTOR (7 downto 0); 
        Done     : out STD_LOGIC
    );
end Multiplier_4bit;

architecture Behavioral of Multiplier_4bit is

    component Signed_Adder_Sub
    Port (
        A       : in  STD_LOGIC_VECTOR (3 downto 0);
        B       : in  STD_LOGIC_VECTOR (3 downto 0);
        Op_Sel  : in  STD_LOGIC;
        Result  : out STD_LOGIC_VECTOR (4 downto 0);
        Co      : out std_logic
    );
    end component;

    type State_Type is (S_HALT, S_INIT, S_CHECK, S_ADD, S_SHIFT, S_DONE);
    signal current_state, next_state : State_Type;

    -- 3. 내부 레지스터
    signal Reg_A     : STD_LOGIC_VECTOR (3 downto 0); 
    signal Reg_P     : STD_LOGIC_VECTOR (3 downto 0); 
    signal Reg_Q     : STD_LOGIC_VECTOR (3 downto 0); 
    signal Count     : integer range 0 to 4;          
    signal Carry_Bit : STD_LOGIC;                     

    -- Adder 연결 신호
    signal Adder_Out : STD_LOGIC_VECTOR (4 downto 0);
    signal Raw_Carry : STD_LOGIC;

begin

    UUT_Adder: Signed_Adder_Sub
    port map (
        A      => Reg_A,   
        B      => Reg_P,   
        Op_Sel => '0',     
        Result => Adder_Out,
        Co     => Raw_Carry 
    );

    process(Clk, Reset)
    begin
        if Reset = '1' then
            current_state <= S_HALT;
            Reg_A <= (others => '0');
            Reg_P <= (others => '0');
            Reg_Q <= (others => '0');
            Count <= 0;
            Carry_Bit <= '0';
            Result <= (others => '0');
            Done <= '0';
        elsif rising_edge(Clk) then
            
            case current_state is
                when S_HALT =>
                    Done <= '0';
                    if Start = '1' then
                        current_state <= S_INIT;
                    end if;
                    
                when S_INIT =>
                    Reg_A <= A_in;      
                    Reg_Q <= B_in;      
                    Reg_P <= "0000";    
                    Count <= 0;         
                    Carry_Bit <= '0';
                    current_state <= S_CHECK;

                when S_CHECK =>
                    if Reg_Q(0) = '1' then
                        current_state <= S_ADD; 
                    else
                        Carry_Bit <= '0';      
                        current_state <= S_SHIFT; 
                    end if;

                when S_ADD =>
                    Reg_P <= Adder_Out(3 downto 0); 
                    Carry_Bit <= Raw_Carry;     
                    current_state <= S_SHIFT;

                when S_SHIFT =>
                    Reg_Q <= Reg_P(0) & Reg_Q(3 downto 1);
                    Reg_P <= Carry_Bit & Reg_P(3 downto 1);
                    Count <= Count + 1;
                    if Count = 3 then 
                        current_state <= S_DONE;
                    else
                        current_state <= S_CHECK;
                    end if;

                when S_DONE =>
                    Result <= Reg_P & Reg_Q; 
                    Done <= '1';
                    current_state <= S_HALT; 

                when others =>
                    current_state <= S_HALT;
            end case;
        end if;
    end process;

end Behavioral;
