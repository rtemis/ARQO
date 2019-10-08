--------------------------------------------------------------------------------
-- Procesador MIPS con pipeline curso Arquitectura 2019-2020
--
-- Sara González Gómez y Leah Hadeed
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity processor is
	port(
		Clk         : in  std_logic; -- Reloj activo en flanco subida
		Reset       : in  std_logic; -- Reset asincrono activo nivel alto
		-- Instruction memory
		IAddr      : out std_logic_vector(31 downto 0); -- Direccion Instr
		IDataIn    : in  std_logic_vector(31 downto 0); -- Instruccion leida
		-- Data memory
		DAddr      : out std_logic_vector(31 downto 0); -- Direccion
		DRdEn      : out std_logic;                     -- Habilitacion lectura
		DWrEn      : out std_logic;                     -- Habilitacion escritura
		DDataOut   : out std_logic_vector(31 downto 0); -- Dato escrito
		DDataIn    : in  std_logic_vector(31 downto 0)  -- Dato leido
	);
end processor;

architecture rtl of processor is
-- Declaracion componente del banco de registros
	component control_unit is
	   port (
		  -- Entrada = codigo de operacion en la instruccion:
		  OpCode  : in  std_logic_vector (5 downto 0);
		  -- Seniales para el PC
		  Branch : out  std_logic; -- 1 = Ejecutandose instruccion branch
		  -- Seniales relativas a la memoria
		  MemToReg : out  std_logic; -- 1 = Escribir en registro la salida de la mem.
		  MemWrite : out  std_logic; -- Escribir la memoria
		  MemRead  : out  std_logic; -- Leer la memoria
		  -- Seniales para la ALU
		  ALUSrc : out  std_logic;                     -- 0 = oper.B es registro, 1 = es valor inm.
		  ALUOp  : out  std_logic_vector (2 downto 0); -- Tipo operacion para control de la ALU
		  -- Seniales para el GPR
		  RegWrite : out  std_logic; -- 1=Escribir registro
		  RegDst   : out  std_logic;  -- 0=Reg. destino es rt, 1=rd

		  Jump : out std_logic -- 1 es jump
	   );
	end component;

-- Declaracion componente del banco de registros
	component reg_bank is
	port (
		Clk   : in std_logic; -- Reloj activo en flanco de subida
		Reset : in std_logic; -- Reset as�ncrono a nivel alto
		A1    : in std_logic_vector(4 downto 0);   -- Direcci�n para el puerto Rd1
		Rd1   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd1
		A2    : in std_logic_vector(4 downto 0);   -- Direcci�n para el puerto Rd2
		Rd2   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd2
		A3    : in std_logic_vector(4 downto 0);   -- Direcci�n para el puerto Wd3
		Wd3   : in std_logic_vector(31 downto 0);  -- Dato de entrada Wd3
		We3   : in std_logic -- Habilitaci�n de la escritura de Wd3
	);
	end component;

-- Declaracion componente de la ALU
	component alu is
	port (
		OpA     : in  std_logic_vector (31 downto 0); -- Operando A
		OpB     : in  std_logic_vector (31 downto 0); -- Operando B
		Control : in  std_logic_vector ( 3 downto 0); -- Codigo de control=op. a ejecutar
		Result  : out std_logic_vector (31 downto 0); -- Resultado
		ZFlag   : out std_logic                       -- Flag Z
	);
	end component;

-- Declaracion componente de la ALU_Control
	component alu_control is
	port (
		-- Entradas:
		ALUOp  : in std_logic_vector (2 downto 0); -- Codigo de control desde la unidad de control
		Funct  : in std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
		-- Salida de control para la ALU:
		ALUControl : out std_logic_vector (3 downto 0) -- Define operacion a ejecutar por la ALU
	);
	end component;


	--Declaracion de señales 

	signal PC: std_logic_vector(31 downto 0);
	signal PC_sig: std_logic_vector(31 downto 0);
	signal PC_mas4: std_logic_vector(31 downto 0);
	signal instruccion: std_logic_vector(31 downto 0);
	signal puerto_wt: std_logic_vector(4 downto 0);

	-- ALU
	signal rd2: std_logic_vector(31 downto 0);
	signal rd1: std_logic_vector(31 downto 0);
	signal op2: std_logic_vector(31 downto 0);
	signal res_alu: std_logic_vector(31 downto 0);
	signal z_flag: std_logic;


	signal signo_ext: std_logic_vector(31 downto 0);

	--alucontrol
	signal alu_ctrl: std_logic_vector(3 downto 0);



	-- write data
	signal write_data: std_logic_vector(31 downto 0);

	--señales de control
	signal branch: std_logic;
	signal memtoreg: std_logic;
	signal memwrite: std_logic;
	signal memread: std_logic;
	signal alusrc: std_logic;
	signal aluop:  std_logic_vector (2 downto 0);
	signal reg_dest: std_logic;
	signal reg_wrt: std_logic;
	signal jump: std_logic;

	--señales add pc
	signal add_in: std_logic_vector(31 downto 0);
	signal add_out: std_logic_vector(31 downto 0);

	--señal puerta and
	signal and_out: std_logic;

	--señal jump
	signal aux1: std_logic_vector(27 downto 0);
	signal aux2: std_logic_vector(31 downto 0);




	--Conexion cables-componentes
	begin

	--Unidad de Control
	inst_control: control_unit
	port map(
		-- Entrada = codigo de operacion en la instruccion:
		OpCode =>  instruccion(31 downto 26),
		-- Seniales para el PC
		Branch => branch,
		-- Seniales relativas a la memoria
		MemToReg  => memtoreg,
		MemWrite  => memwrite,
		MemRead  => memread,
		-- Seniales para la ALU
		ALUSrc  => alusrc,                   -- 0 = oper.B es registro, 1 = es valor inm.
		ALUOp  => aluop,
		-- Seniales para el GPR
		RegWrite => reg_wrt,
		RegDst  => reg_dest,
		Jump => jump
	);

	-- Control ALU
	inst_alucontrol: alu_control
	port map(
		-- Entradas:
		ALUOp  =>aluop,
		Funct  => instruccion(5 downto 0),
		-- Salida de control para la ALU:
		ALUControl => alu_ctrl
	);

	-- Banco Registros
	inst_regbank: reg_bank
	port map(
		Clk => clk, -- Reloj activo en flanco de subida
		Reset  => reset, -- Reset as�ncrono a nivel alto
		A1    => instruccion(25 downto 21),   -- Direcci�n para el puerto Rd1
		Rd1 => rd1, -- Dato del puerto Rd1
		A2    => instruccion(20 downto 16),  -- Direcci�n para el puerto Rd2
		Rd2 => rd2  , -- Dato del puerto Rd2
		A3    => puerto_wt,   -- Direcci�n para el puerto Wd3
		Wd3  => write_data ,  -- Dato de entrada Wd3
		We3  => reg_wrt  -- Habilitaci�n de la escritura de Wd3
	);

	--ALU
	inst_alu: alu
	port map(
		OpA    => rd1,
		OpB     => op2,
		Control => alu_ctrl,
		Result => res_alu,
		ZFlag   =>  z_flag


	);

	-- PC
	PC_reg: process (clk, reset)
	begin
		if reset = '1' then
			PC <= (others => '0');

		elsif rising_edge(clk) then
			PC <= PC_sig;
		end if;
	end process;

	-- Aumento del PC
	PC_mas4 <= PC + 4;

	instruccion <= IDataIn;

	--mux entrada puerto escritura
	puerto_wt <= instruccion(20 downto 16) WHEN reg_dest ='0' ELSE
					 instruccion(15 downto 11);


	-- Extensión de signo
	signo_ext <= X"0000" & instruccion (15 downto 0) when instruccion (15) = '0' else
					 X"FFFF" & instruccion (15 downto 0);

	--mux entrada OP2 ALU
	op2 <= rd2 WHEN alusrc ='0' ELSE signo_ext;



	--Processor
	IAddr <= PC;
	DAddr    <=res_alu;
	DRdEn    <=memread;
	DWrEn    <= memwrite;
	DDataOut <= rd2;


	--mux write_data banco registro
	write_data <= DDataIn WHEN memtoreg ='1' ELSE res_alu;

	-- Desplazamiento a la izquierda y suma del pc
	add_in <= signo_ext (29 downto 0) & "00";
	add_out <= PC_mas4 + add_in;

	-- Puerta and
	and_out <= branch and z_flag;

	--mux para Jump, y mux para pc+4 o pc desplazado
	aux1 <= instruccion (25 downto 0) & "00";
	aux2 <= PC_mas4 (31 downto 28) & aux1;

	PC_sig <= aux2 WHEN jump = '1' ELSE
				 add_out WHEN and_out ='1' ELSE PC_mas4;

end architecture;
