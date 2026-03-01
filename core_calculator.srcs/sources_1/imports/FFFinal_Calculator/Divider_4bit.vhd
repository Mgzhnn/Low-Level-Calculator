library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Divider_4bit is
    Port ( 
        Clk      : in  STD_LOGIC;
        Reset    : in  STD_LOGIC;
        Start    : in  STD_LOGIC;
        A_in     : in  STD_LOGIC_VECTOR (3 downto 0); 
        B_in     : in  STD_LOGIC_VECTOR (3 downto 0); 
        Quotient : out STD_LOGIC_VECTOR (3 downto 0);
        Remainder: out STD_LOGIC_VECTOR (3 downto 0);
        Done     : out STD_LOGIC
    );
end Divider_4bit;

architecture Behavioral of Divider_4bit is
    component Signed_Adder_Sub
        Port (
            A       : in  STD_LOGIC_VECTOR (3 downto 0);
            B       : in  STD_LOGIC_VECTOR (3 downto 0);
            Op_Sel  : in  STD_LOGIC;
            Result  : out STD_LOGIC_VECTOR (4 downto 0);
            Co      : out STD_LOGIC 
        );
    end component;

    type State_Type is (
        S_HALT,
        S_INIT,
        S_SHIFT,
        S_SUB,
        S_CHECK,
        S_RESTORE,
        S_NEXT,
        S_FINISH
    );
    signal current_state : State_Type := S_HALT;

    signal Reg_Q : STD_LOGIC_VECTOR (3 downto 0);  
    signal Reg_R : STD_LOGIC_VECTOR (4 downto 0);  
    signal Reg_M : STD_LOGIC_VECTOR (3 downto 0); 
    signal Count : integer range 0 to 5;           
    signal Actual_Op_Sel : STD_LOGIC;

    signal ALU_Op  : STD_LOGIC;                   
    signal ALU_Out : STD_LOGIC_VECTOR (4 downto 0);
    signal ALU_Co  : STD_LOGIC;
    signal ALU_Out_Fixed : STD_LOGIC_VECTOR(4 downto 0);
begin

    Actual_Op_Sel <= ALU_Op XOR Reg_M(3);
    process(ALU_Out, Reg_R, current_state)
        begin
            if (current_state = S_SUB) and (Reg_R(4) = '0' and Reg_R(3) = '1') then
                ALU_Out_Fixed <= (not ALU_Out(4)) & ALU_Out(3 downto 0);
            else
                ALU_Out_Fixed <= ALU_Out;
            end if;
        end process;

    UUT_Adder: Signed_Adder_Sub
        port map (
            A      => Reg_R(3 downto 0),
            B      => Reg_M,
            Op_Sel => Actual_Op_Sel,
            Result => ALU_Out,
            Co     => ALU_Co
        );

    process(Clk, Reset)
    begin
        if Reset = '1' then

            current_state <= S_HALT;
            Reg_Q   <= (others => '0');
            Reg_R   <= (others => '0');
            Reg_M   <= (others => '0');
            Count   <= 0;
            Done    <= '0';
            Quotient  <= (others => '0');
            Remainder <= (others => '0');
            ALU_Op <= '0';

        elsif rising_edge(Clk) then

            Done <= '0';

            case current_state is

                when S_HALT =>
                    if Start = '1' then
                        current_state <= S_INIT;
                    end if;

                when S_INIT =>
                    if B_in = "0000" then
                        Reg_Q <= (others => '0');
                        Reg_R <= (others => '0');
                        current_state <= S_FINISH;
                    else
                        Reg_Q <= A_in;
                        Reg_M <= B_in;
                        Reg_R <= (others => '0');
                        Count <= 0;
                        current_state <= S_SHIFT;
                    end if;

                when S_SHIFT =>
                    Reg_R <= Reg_R(3 downto 0) & Reg_Q(3);
                    Reg_Q <= Reg_Q(2 downto 0) & '0';

                    ALU_Op <= '1'; 
                    current_state <= S_SUB;

                when S_SUB =>
                    Reg_R <= ALU_Out_Fixed;
                    current_state <= S_CHECK;

                when S_CHECK =>
                    if Reg_R(4) = '1' then        
                        Reg_Q(0) <= '0';           
                        ALU_Op   <= '0';          
                        current_state <= S_RESTORE;
                    else
                        Reg_Q(0) <= '1';           
                        current_state <= S_NEXT;
                    end if;

                when S_RESTORE =>
                    Reg_R <= ALU_Out;           
                    current_state <= S_NEXT;

                when S_NEXT =>
                    if Count = 3 then
                        current_state <= S_FINISH;
                    else
                        Count <= Count + 1;
                        current_state <= S_SHIFT;
                    end if;

                when S_FINISH =>
                    Quotient  <= Reg_Q;
                    Remainder <= Reg_R(3 downto 0); 
                    Done      <= '1';
                    current_state <= S_HALT;

                when others =>
                    current_state <= S_HALT;

            end case;
        end if;
    end process;

end Behavioral;
