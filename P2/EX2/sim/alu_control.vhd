--------------------------------------------------------------------------------
-- Bloque de control para la ALU. Arq0 2019-2020.
--
-- Sara González Gómez y Leah Hadeed
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity alu_control is
   port (
      -- Entradas:
      ALUOp  : in std_logic_vector (2 downto 0); -- Codigo de control desde la unidad de control
      Funct  : in std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
      -- Salida de control para la ALU:
      ALUControl : out std_logic_vector (3 downto 0) -- Define operacion a ejecutar por la ALU
   );
end alu_control;

architecture rtl of alu_control is

   -- Tipo para los codigos de control de la ALU:
   subtype t_aluControl is std_logic_vector (3 downto 0);

   -- Codigos de control:
   constant ALU_OR   : t_aluControl := "0111";
   constant ALU_NOT  : t_aluControl := "0101";
   constant ALU_XOR  : t_aluControl := "0110";
   constant ALU_AND  : t_aluControl := "0100";
   constant ALU_SUB  : t_aluControl := "0001";
   constant ALU_ADD  : t_aluControl := "0000";
   constant ALU_SLT  : t_aluControl := "1010";
   constant ALU_S16  : t_aluControl := "1101";

begin
    ALU_C: Process (ALUOp, Funct)
    begin
        -- R-Type
        if ALUOp = "010" then
            case Funct is
                when "100000" => ALUControl <= ALU_ADD; -- add
                when "100100" => ALUControl <= ALU_AND; -- and
                when "100101" => ALUControl <= ALU_OR; -- or
                when "100010" => ALUControl <= ALU_SUB; -- sub
                when "100110" => ALUControl <= ALU_XOR; -- xor
                when "101010" => ALUControl <= ALU_SLT; -- slt
                when others => ALUControl <= X"F";

        end case;

        --LW y SW y ADDI
        elsif ALUOp = "000" then
            ALUControl <= ALU_ADD;
        -- Beq
        elsif ALUOp = "001" then
            ALUControl <= ALU_SUB;

        -- LUI
        elsif ALUOp = "011" then
            ALUControl <= ALU_S16;

        --SLTI
        elsif ALUOp = "100" then
            ALUControl <= ALU_SLT;

        end if;
    end process;

end architecture;
