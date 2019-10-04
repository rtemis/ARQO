--------------------------------------------------------------------------------
-- Procesador MIPS con pipeline curso Arquitectura 2019-2020
--
-- (INCLUIR AQUI LA INFORMACION SOBRE LOS AUTORES)
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


--Señales
	-- Nuevas
	signal instruccion_if: std_logic_vector(31 downto 0);
	signal instruccion_id: std_logic_vector(31 downto 0);
	signal PC_mas4_if: std_logic_vector(31 downto 0);
	signal PC_mas4_id: std_logic_vector(31 downto 0);
	signal PC_mas4_ex: std_logic_vector(31 downto 0);
	signal rd2_id: std_logic_vector(31 downto 0);
	signal rd2_ex: std_logic_vector(31 downto 0);
	signal rd2_mem: std_logic_vector(31 downto 0);

	signal puerto_wt_in0: std_logic_vector(4 downto 0);
	signal puerto_wt_in1: std_logic_vector(4 downto 0);
	signal puerto_wt_ex: std_logic_vector(4 downto 0);
	signal puerto_wt_mem: std_logic_vector(4 downto 0);
	signal puerto_wt_wb: std_logic_vector(4 downto 0);
	
	--Anteriores

	signal PC: std_logic_vector(31 downto 0);
	signal PC_sig: std_logic_vector(31 downto 0);

	-- cables alu
	--nuevas
	signal rd1_id: std_logic_vector(31 downto 0);
	signal rd1_ex: std_logic_vector(31 downto 0);
	signal signo_ext_id: std_logic_vector(31 downto 0);
	signal signo_ext_ex: std_logic_vector(31 downto 0);
	signal res_alu_ex: std_logic_vector(31 downto 0);
	signal res_alu_mem: std_logic_vector(31 downto 0);
	signal res_alu_wb: std_logic_vector(31 downto 0);
	signal z_flag_ex: std_logic;
	signal z_flag_mem: std_logic;
	--ant

	signal op2: std_logic_vector(31 downto 0);
	


	--alucontrol
	signal alu_ctrl: std_logic_vector(3 downto 0);



	-- write data
	signal write_data: std_logic_vector(31 downto 0);

	--señales de control
	--Nuevas
	signal reg_dest_id: std_logic;
	signal reg_dest_ex: std_logic;
	signal alusrc_id: std_logic;
	signal alusrc_ex: std_logic;
	signal aluop_id:  std_logic_vector (2 downto 0);
	signal aluop_ex:  std_logic_vector (2 downto 0);

	signal branch_id: std_logic;
	signal branch_ex: std_logic;
	signal branch_mem: std_logic;
	signal memwrite_id: std_logic;
	signal memwrite_ex: std_logic;
	signal memwrite_mem: std_logic;
	signal memread_id: std_logic;
	signal memread_ex: std_logic;
	signal memread_mem: std_logic;

	signal memtoreg_id: std_logic;
	signal memtoreg_ex: std_logic;
	signal memtoreg_mem: std_logic;
	signal memtoreg_wb: std_logic;
	signal reg_wrt_id: std_logic;
	signal reg_wrt_ex: std_logic;
	signal reg_wrt_mem: std_logic;
	signal reg_wrt_wb: std_logic;


	--ant
	signal jump: std_logic;

	--señal memory
	signal mem_out_mem: std_logic_vector(31 downto 0);
	signal mem_out_wb: std_logic_vector(31 downto 0);

	--señales add pc
	signal add_in: std_logic_vector(31 downto 0);
	signal add_out_ex: std_logic_vector(31 downto 0);
	signal add_out_mem: std_logic_vector(31 downto 0);
	

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
		OpCode =>  instruccion_id(31 downto 26),
		-- Seniales para el PC
		Branch => branch_id,
		-- Seniales relativas a la memoria
		MemToReg  => memtoreg_id,
		MemWrite  => memwrite_id,
		MemRead  => memread_id,
		-- Seniales para la ALU
		ALUSrc  => alusrc_id,                   -- 0 = oper.B es registro, 1 = es valor inm.
		ALUOp  => aluop_id,
		-- Seniales para el GPR
		RegWrite => reg_wrt_id,
		RegDst  => reg_dest_id,
		Jump => jump
	);

	-- Control ALU
	inst_alucontrol: alu_control
	port map(
		-- Entradas:
		ALUOp  =>aluop_ex,
		Funct  => signo_ext_ex(5 downto 0),
		-- Salida de control para la ALU:
		ALUControl => alu_ctrl
	);

	-- Banco Registros
	inst_regbank: reg_bank
	port map(
		Clk => clk, -- Reloj activo en flanco de subida
		Reset  => reset, -- Reset as�ncrono a nivel alto
		A1    => instruccion_id(25 downto 21),   -- Direcci�n para el puerto Rd1
		Rd1 => rd1_id, -- Dato del puerto Rd1
		A2    => instruccion_id(20 downto 16),  -- Direcci�n para el puerto Rd2
		Rd2 => rd2_id  , -- Dato del puerto Rd2
		A3    => puerto_wt,   -- Direcci�n para el puerto Wd3
		Wd3  => write_data ,  -- Dato de entrada Wd3
		We3  => reg_wrt_id  -- Habilitaci�n de la escritura de Wd3
	);

	--ALU
	inst_alu: alu
	port map(
		OpA    => rd1_ex,
		OpB     => op2,
		Control => alu_ctrl,
		Result => res_alu_ex,
		ZFlag   =>  z_flag_ex


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

	-- IF/ID
	IF_ID: process(clk, reset)
	begin
		if rising_edge(clk) then
			instruccion_id <= instruccion_if;
			PC_mas4_id <= PC_mas4_if
		end if;
	end process;

	-- ID/EX
	ID_EX: process(clk, reset)
	begin
		if rising_edge(clk) then
			rd2_ex <= rd2_id;
			rd1_ex <= rd1_id;
			PC_mas4_ex <= PC_mas4_id;
			signo_ext_ex <= signo_ext_id;
			puerto_wt_in0 <= instruccion_id(20 downto 16);
			puerto_wt_in1 <= instruccion_id(15 downto 11);

			reg_dest_ex <= reg_dest_id;
			alusrc_ex <= alusrc_id;
			aluop_ex <= aluop_id;
			branch_ex <= branch_id;
			memwrite_ex <= memwrite_id;
			memread_ex <= memread_id;
			memtoreg_ex <= memtoreg_id;
			reg_wrt_ex <= reg_wrt_id;

		end if;
	end process;

	-- EX/MEM
	EX_MEM: process(clk, reset)
	begin
		if rising_edge(clk) then
			branch_mem <= branch_ex;
			memwrite_mem <= memwrite_ex;
			memread_mem <= memread_ex;
			memtoreg_mem <= memtoreg_ex;
			reg_wrt_mem <= reg_wrt_ex;
			res_alu_mem <= res_alu_ex;
			z_flag_mem <= z_flag_ex;
			rd2_mem <= rd2_ex;
			puerto_wt_mem <= puerto_wt_ex;
			add_out_mem <= add_out_ex;
			
			
		end if;
	end process;

	-- MEM/WB
	MEM_WB: process(clk, reset)
	begin
		if rising_edge(clk) then
			reg_wrt_wb <= reg_wrt_mem;
			memtoreg_wb <= memtoreg_mem;	
			res_alu_wb <= res_alu_mem;
			mem_out_wb <= mem_out_mem;
			puerto_wt_mem <= puerto_wt_wb;
			
			
		end if;
	end process;

	-- Aumento del PC
	PC_mas4_if <= PC + 4;

	instruccion_if <= IDataIn;

	--mux entrada puerto escritura
	puerto_wt_ex <= puerto_wt_in0 WHEN reg_dest_ex ='0' ELSE
					 puerto_wt_in1;


	-- Extensión de signo
	signo_ext_id <= X"0000" & instruccion_id (15 downto 0) when instruccion_id (15) = '0' else
					 X"FFFF" & instruccion_id (15 downto 0);

	--mux entrada OP2 ALU
	op2 <= rd2_ex WHEN alusrc_ex ='0' ELSE signo_ext_ex;



	--Processor
	IAddr <= PC;
	DAddr    <=res_alu_mem;
	DRdEn    <=memread_ex;
	DWrEn    <= memwrite_ex;
	DDataOut <= rd2_ex;
	
	-- esto hay que revisar si da error o no, porque es un in
	mem_out_mem <= DDataIn;


	--mux write_data banco registro
	write_data <= mem_out_wb WHEN memtoreg_wb ='1' ELSE res_alu_wb;

	-- Desplazamiento a la izquierda y suma del pc
	add_in <= signo_ext_ex (29 downto 0) & "00";
	add_out_ex <= PC_mas4_ex + add_in;

	-- Puerta and
	and_out_ex <= branch_mem and z_flag_mem;

	-- Jump
	-- ESTO DEL JUMO FALTA POR HACER
	aux1 <= instruccion (25 downto 0) & "00";
	aux2 <= PC_mas4 (31 downto 28) & aux1;
	--

	PC_sig <= aux2 WHEN jump = '1' ELSE
				 add_out_mem WHEN and_out_ex ='1' ELSE PC_mas4_if;

end architecture;