library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity negative_complement is
    Port ( 
        A      : in  STD_LOGIC_VECTOR (3 downto 0); 
        pos_A  : out STD_LOGIC_VECTOR (3 downto 0) 
    );
end negative_complement;

architecture Behavioral of negative_complement is
begin
    process(A)
        variable inv_A : std_logic_vector(3 downto 0);
        variable carry : std_logic;
        variable res   : std_logic_vector(3 downto 0);
    begin
        if A(3) = '0' then
            pos_A <= A;
        else
            inv_A := not A;
            carry := '1'; 
            for i in 0 to 3 loop
                res(i) := inv_A(i) XOR carry;
                carry := inv_A(i) AND carry;
            end loop;
            pos_A <= res;
        end if;
    end process;
end Behavioral;
