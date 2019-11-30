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
--------------------------------------------------------------------------------
architecture rtl of processor is
					----------------------------------------------------
					--           DECLARACION DE COMPONENTES           --
					----------------------------------------------------

-- Declaracion componente del banco de registros
	component control_unit is
	   port (
		-- Entrada = codigo de operacion en la instruccion:
		OpCode  : in  std_logic_vector (5 downto 0);
		-- Seniales para el PC
		Branch : out  std_logic; 	 -- 1 = Ejecutandose instruccion branch
		-- Seniales relativas a la memoria
		MemToReg : out  std_logic; -- 1 = Escribir en registro la salida de la mem.
		MemWrite : out  std_logic; -- Escribir la memoria
		MemRead  : out  std_logic; -- Leer la memoria
		-- Seniales para la ALU
		ALUSrc : out  std_logic;                     -- 0 = oper.B es registro, 1 = es valor inm.
		ALUOp  : out  std_logic_vector (2 downto 0); -- Tipo operacion para control de la ALU
		-- Seniales para el GPR
		RegWrite : out  std_logic; -- 1=Escribir registro
		RegDst   : out  std_logic; -- 0=Reg. destino es rt, 1=rd
		-- Senial para salto incondicional
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
		ALUOp  : in std_logic_vector (2 downto 0); 			-- Codigo de control desde la unidad de control
		Funct  : in std_logic_vector (5 downto 0); 			-- Campo "funct" de la instruccion
		-- Salida de control para la ALU:
		ALUControl : out std_logic_vector (3 downto 0) 	-- Define operacion a ejecutar por la ALU
	);
	end component;
--------------------------------------------------------------------------------
					----------------------------------------------------
					--        DECLARACION DE SEÑALES POR FASE         --
					----------------------------------------------------

	-- Senales para fase ID
	signal instruccion_if: std_logic_vector(31 downto 0);
	signal instruccion_id: std_logic_vector(31 downto 0);
	signal instruccion_ex: std_logic_vector(31 downto 0);
	signal PC_mas4_if: std_logic_vector(31 downto 0);
	signal PC_mas4_id: std_logic_vector(31 downto 0);
	signal PC_mas4_ex: std_logic_vector(31 downto 0);

	signal puerto_wt_in0: std_logic_vector(4 downto 0);
	signal puerto_wt_in1: std_logic_vector(4 downto 0);
	signal puerto_wt_ex: std_logic_vector(4 downto 0);
	signal puerto_wt_mem: std_logic_vector(4 downto 0);
	signal puerto_wt_wb: std_logic_vector(4 downto 0);

	signal PC: std_logic_vector(31 downto 0);
	signal PC_sig: std_logic_vector(31 downto 0);

	signal signo_ext_id: std_logic_vector(31 downto 0);
	signal signo_ext_ex: std_logic_vector(31 downto 0);

	-- ALU
	signal rd2_id: std_logic_vector(31 downto 0);
	signal rd2_ex: std_logic_vector(31 downto 0);
	signal rd2_mem: std_logic_vector(31 downto 0);
	signal rd1_id: std_logic_vector(31 downto 0);
	signal rd1_ex: std_logic_vector(31 downto 0);
	signal res_alu_ex: std_logic_vector(31 downto 0);
	signal res_alu_mem: std_logic_vector(31 downto 0);
	signal res_alu_wb: std_logic_vector(31 downto 0);
	signal z_flag_id: std_logic;
	signal z_flag_ex: std_logic;
	signal z_flag_mem: std_logic;
	signal op2: std_logic_vector(31 downto 0);

	--alucontrol
	signal alu_ctrl: std_logic_vector(3 downto 0);

	--write data
	signal write_data: std_logic_vector(31 downto 0);

	--señales contorl unit
	signal reg_dest_id: std_logic;
	signal reg_dest_ex: std_logic;
	signal alusrc_id: std_logic;
	signal alusrc_ex: std_logic;
	signal aluop_id:  std_logic_vector (2 downto 0);
	signal aluop_ex:  std_logic_vector (2 downto 0);

	--señales de control
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

	signal jump: std_logic;

	-- señales salida de la memoria
	signal mem_out_mem: std_logic_vector(31 downto 0);
	signal mem_out_wb: std_logic_vector(31 downto 0);

	--señales add pc
	signal add_in: std_logic_vector(31 downto 0);
	signal add_out_mem: std_logic_vector(31 downto 0);

	--señal puerta and
	signal and_out_id: std_logic;

	--señales jump
	signal aux1: std_logic_vector(27 downto 0);
	signal aux2: std_logic_vector(31 downto 0);

	-- señales forwardin unit
	signal mux_rd1: std_logic_vector(31 downto 0);
	signal mux_rd2: std_logic_vector(31 downto 0);

	-- señales hazard control unit
	signal enable_ctrl_unit: std_logic;
	signal PC_write: std_logic;
	signal IFID_write: std_logic;

	-- señales comparador
	signal aux3: std_logic_vector(31 downto 0);
	signal aux4: std_logic_vector(31 downto 0);



--------------------------------------------------------------------------------
	begin
					----------------------------------------------------
					--           INSTANCIAS DE COMPONENTES            --
					----------------------------------------------------
	--Unidad de Control
	inst_control: control_unit
	port map(
		-- Entrada = codigo de operacion en la instruccion:
		OpCode		=>  instruccion_id(31 downto 26),
		-- Seniales para el PC
		Branch 		=> branch_id,
		-- Seniales relativas a la memoria
		MemToReg  => memtoreg_id,
		MemWrite  => memwrite_id,
		MemRead  	=> memread_id,
		-- Seniales para la ALU
		ALUSrc  	=> alusrc_id, -- 0 = oper.B es registro, 1 = es valor inm.
		ALUOp  		=> aluop_id,
		-- Seniales para el GPR
		RegWrite 	=> reg_wrt_id,
		RegDst  	=> reg_dest_id,
		Jump 			=> jump
	);

	-- Control ALU
	inst_alucontrol: alu_control
	port map(
		-- Entradas:
		ALUOp => aluop_ex,
		Funct => signo_ext_ex(5 downto 0),
		-- Salida de control para la ALU:
		ALUControl 	=> alu_ctrl
	);

	-- Banco Registros
	inst_regbank: reg_bank
	port map(
		Clk 	=> clk, 													-- Reloj activo en flanco de subida
		Reset => reset, 												-- Reset as�ncrono a nivel alto
		A1    => instruccion_id(25 downto 21),  -- Direcci�n para el puerto Rd1
		Rd1 	=> rd1_id, 												-- Dato del puerto Rd1
		A2    => instruccion_id(20 downto 16),  -- Direcci�n para el puerto Rd2
		Rd2 	=> rd2_id, 												-- Dato del puerto Rd2
		A3    => puerto_wt_wb,   								-- Direcci�n para el puerto Wd3
		Wd3  	=> write_data,  									-- Dato de entrada Wd3
		We3  	=> reg_wrt_wb  										-- Habilitaci�n de la escritura de Wd3
	);

	--ALU
	inst_alu: alu
	port map(
		OpA    	=> mux_rd1,			--
		OpB     => op2,					--
		Control => alu_ctrl,		--
		Result 	=> res_alu_ex,	--
		ZFlag   => z_flag_ex		--
	);

					----------------------------------------------------
					--    DECLARACION DE PROCESOS PARA SEGMENTADO     --
					----------------------------------------------------

	-- PC
	PC_reg: process (clk, reset)
	begin
		if reset = '1' then
			PC <= (others => '0');

		elsif rising_edge(clk) and PC_write = '1' then
			PC <= PC_sig;

		end if;
	end process;

	--  IF/ID  --
	IF_ID: process(clk, reset)
	begin
		if reset = '1' then
			instruccion_id <= (others => '0');
			PC_mas4_id 		 <= (others => '0');

		elsif rising_edge(clk) and IFID_write = '1' then
			if and_out_id = '1' then
				instruccion_id <= (others => '0');
				PC_mas4_id 		 <= (others => '0');
			else
				instruccion_id <= instruccion_if;
				PC_mas4_id 	 	 <= PC_mas4_if;
			end if;
		end if;
	end process;

	-- ID/EX
	ID_EX: process(clk, reset, enable_ctrl_unit)
	begin
		if reset = '1' then
			instruccion_ex <= (others => '0');
			rd1_ex 				<= (others => '0');
			rd2_ex 				<= (others => '0');
			PC_mas4_ex 		<= (others => '0');
			signo_ext_ex 	<= (others => '0');
			puerto_wt_in0 <= (others => '0');
			puerto_wt_in1 <= (others => '0');

			reg_dest_ex 	<= '0';
			branch_ex 		<= '0';
			memread_ex 		<= '0';
			memtoreg_ex 	<= '0';
			aluop_ex 			<= (others => '0');
			memwrite_ex 	<= '0';
			alusrc_ex 		<= '0';
			reg_wrt_ex 		<= '0';

		elsif rising_edge(clk) then
			instruccion_ex <= instruccion_id;
			rd1_ex 				<= rd1_id;
			rd2_ex 				<= rd2_id;
			PC_mas4_ex 		<= PC_mas4_id;
			signo_ext_ex 	<= signo_ext_id;
			puerto_wt_in0 <= instruccion_id(20 downto 16);
			puerto_wt_in1 <= instruccion_id(15 downto 11);

			if  enable_ctrl_unit = '1' then
				reg_dest_ex <= reg_dest_id;
				branch_ex 	<= branch_id;
				memread_ex 	<= memread_id;
				memtoreg_ex <= memtoreg_id;
				aluop_ex 		<= aluop_id;
				memwrite_ex <= memwrite_id;
				alusrc_ex 	<= alusrc_id;
				reg_wrt_ex 	<= reg_wrt_id;
			else
				reg_dest_ex 	<= '0';
				branch_ex 		<= '0';
				memread_ex 		<= '0';
				memtoreg_ex 	<= '0';
				aluop_ex 			<= (others => '0');
				memwrite_ex 	<= '0';
				alusrc_ex 		<= '0';
				reg_wrt_ex 		<= '0';
			end if;
		end if;
	end process;


	-- EX/MEM
	EX_MEM: process(clk, reset)
	begin
		if reset = '1' then
			branch_mem 		<= '0';
			memwrite_mem 	<= '0';
			memread_mem 	<= '0';
			memtoreg_mem 	<= '0';
			reg_wrt_mem 	<= '0';
			res_alu_mem 	<= (others => '0');
			z_flag_mem 		<= '0';
			rd2_mem 			<= (others => '0');
			puerto_wt_mem <= (others => '0');

		elsif rising_edge(clk) then
			branch_mem 		<= branch_ex;
			memwrite_mem 	<= memwrite_ex;
			memread_mem 	<= memread_ex;
			memtoreg_mem 	<= memtoreg_ex;
			reg_wrt_mem 	<= reg_wrt_ex;
			res_alu_mem 	<= res_alu_ex;
			z_flag_mem 		<= z_flag_ex;
			rd2_mem 			<= rd2_ex;
			puerto_wt_mem <= puerto_wt_ex;

		end if;
	end process;

	-- MEM/WB
	MEM_WB: process(clk, reset)
	begin
		if reset = '1' then
			reg_wrt_wb 	 <= '0';
			memtoreg_wb  <= '0';
			res_alu_wb 	 <= (others => '0');
			mem_out_wb 	 <= (others => '0');
			puerto_wt_wb <= (others => '0');

		elsif rising_edge(clk) then
			reg_wrt_wb 	 <= reg_wrt_mem;
			memtoreg_wb  <= memtoreg_mem;
			res_alu_wb   <= res_alu_mem;
			mem_out_wb   <= mem_out_mem;
			puerto_wt_wb <= puerto_wt_mem;

		end if;
	end process;

--------------------------------------------------------------------------------
-- EJECUCION CONCURRENTE
--------------------------------------------------------------------------------

	--Processor
	IAddr 			<= PC;
	DAddr    		<= res_alu_mem;
	DRdEn    		<= memread_mem;
	DWrEn    		<= memwrite_mem;
	DDataOut 		<= rd2_mem;
	mem_out_mem <= DDataIn;

	-- Aumento del PC
	PC_mas4_if <= (PC + 4);

	-- Instruction Fetch
	instruccion_if <= IDataIn;

	-- Extensión de signo
	signo_ext_id <= X"0000" & instruccion_id (15 downto 0) WHEN instruccion_id (15) = '0' ELSE
									X"FFFF" & instruccion_id (15 downto 0);

	-- Desplazamiento mux_rd1a la izquierda y suma del pc
	add_in 			<= signo_ext_id (29 downto 0) & "00";
	add_out_mem <= PC_mas4_id + add_in;

	--mux entrada puerto escritura
	puerto_wt_ex <= puerto_wt_in0 WHEN reg_dest_ex ='0' ELSE
									puerto_wt_in1;

	--mux entrada OP2 ALU
	op2 <= mux_rd2 WHEN alusrc_ex ='0' ELSE
				 signo_ext_ex;

	--mux write_data banco registro
	write_data <= mem_out_wb WHEN memtoreg_wb ='1' ELSE
								res_alu_wb;

	-- Puerta and
	and_out_id <= branch_id AND z_flag_id;

	-- Seniales para direccion del jump
	aux1 <= instruccion_id (25 downto 0) & "00";
	aux2 <= PC_mas4_id (31 downto 28) & aux1;

	--mux para Jump, y mux para pc+4 o pc desplazado
	PC_sig <= aux2 WHEN jump = '1' ELSE
						add_out_mem WHEN and_out_id ='1' ELSE
						PC_mas4_if;
---------------------------------------------------
----FORWARDING UNIT
---------------------------------------------------
	-- enable mux rd_1
	mux_rd1 <= res_alu_mem WHEN puerto_wt_mem = instruccion_ex(25 downto 21) AND puerto_wt_mem /= "00000" AND reg_wrt_mem = '1' ELSE
	 						write_data WHEN puerto_wt_wb = instruccion_ex(25 downto 21) AND puerto_wt_wb /= "00000" AND reg_wrt_wb = '1' ELSE
							rd1_ex;

	-- enable mux_rd2
	mux_rd2 <= res_alu_mem WHEN puerto_wt_mem = instruccion_ex(20 downto 16) AND puerto_wt_mem /= "00000" AND reg_wrt_mem = '1' ELSE
	 						write_data WHEN puerto_wt_wb  = instruccion_ex(20 downto 16) AND puerto_wt_wb /= "00000" AND reg_wrt_wb = '1'ELSE
							rd2_ex;

---------------------------------------------------
----HAZARD CONTROL UNIT
---------------------------------------------------
	enable_ctrl_unit <= '0' when memread_ex = '1' and ((puerto_wt_in0 = instruccion_id(20 downto 16) and puerto_wt_in0 /= "00000")
	 															   or (puerto_wt_in0 = instruccion_id(25 downto 21) and puerto_wt_in0 /= "00000"))
 		else '1';

	PC_write <= enable_ctrl_unit;
	IFID_write <= enable_ctrl_unit;

---------------------------------------------------
---- COMPARADOR
---------------------------------------------------

aux3 <= res_alu_ex WHEN puerto_wt_ex = instruccion_id(25 downto 21) AND puerto_wt_ex /= "00000" AND reg_wrt_ex= '1' ELSE
						res_alu_mem WHEN puerto_wt_mem = instruccion_id(25 downto 21) AND puerto_wt_mem /= "00000" AND reg_wrt_mem = '1' ELSE
						rd1_id;

aux4 <= res_alu_ex WHEN puerto_wt_ex = instruccion_id(25 downto 21) AND puerto_wt_ex /= "00000" AND reg_wrt_ex= '1' ELSE
						res_alu_mem WHEN puerto_wt_mem = instruccion_id(25 downto 21) AND puerto_wt_mem /= "00000" AND reg_wrt_mem = '1' ELSE
						rd2_id;

z_flag_id <= '1' when aux3 = aux4 else '0';


end architecture;
