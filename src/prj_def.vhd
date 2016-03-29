-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 12.02.2015 10:21:10
-- Module Name : prj_def
--
-- Description : project constants define
-- xx_RBIT - bit read only
-- xx_WBIT - bit write only
-- xx_BIT - bit write/read
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.vicg_common_pkg.all;
use work.prj_cfg.all;

package prj_def is

------------------------------------------------------------------
----
------------------------------------------------------------------
--type TWriterPrm is record
--pixcount   : std_logic_vector(15 downto 0);
--linecount  : std_logic_vector(15 downto 0);
--mem_trnlen : std_logic_vector(15 downto 0);--(15 downto 8)/(7 downto 0) - MEMRD_LEN/MEMWR_LEN
--end record;


constant C_FPGA_FIRMWARE_VERSION : integer := C_PCFG_FIRMWARE_VERSION;

--HOST
constant C_HDEV_DWIDTH           : integer := C_PCGF_PCIE_DWIDTH;

----------------------------------------------------------------
--module pcie_main.vhd: (max count HREG - 0x1F)
----------------------------------------------------------------
--Register Map:
constant C_HREG_FIRMWARE                      : integer := 16#00#;--FPGA firmware
constant C_HREG_CTRL                          : integer := 16#01#;--Global control
constant C_HREG_DMAPRM_ADR                    : integer := 16#02#;--Driver BUF(adress) (BYTE)
constant C_HREG_DMAPRM_LEN                    : integer := 16#03#;--Driver BUF(size) (BYTE)
constant C_HREG_DMA_CTRL                      : integer := 16#04#;--device control (fpga module connected to host(pcie))
constant C_HREG_DEV_STATUS                    : integer := 16#05#;--device status (fpga module connected to host(pcie))
constant C_HREG_IRQ                           : integer := 16#07#;--Interrupt
constant C_HREG_MEM_ADR                       : integer := 16#08#;--RAM Adress (module - pcie2mem))
constant C_HREG_MEM_CTRL                      : integer := 16#09#;--Controll (module - pcie2mem))
constant C_HREG_FG_FRMRK                      : integer := 16#0A#;--frame marker
constant C_HREG_PCIE                          : integer := 16#0D#;--PCIE info
constant C_HREG_FUNC                          : integer := 16#0E#;--FPGA module using
constant C_HREG_FUNCPRM                       : integer := 16#0F#;--FPGA module info
constant C_HREG_ETH_HEADER                    : integer := 16#10#;
constant C_HREG_CFG_CTRL                      : integer := 16#11#;--CFG Device (Ctrl)
constant C_HREG_CFG_DATA                      : integer := 16#12#;--CFG Device (Data)
constant C_HREG_TST0                          : integer := 16#1C#;--DBG registers
constant C_HREG_TST1                          : integer := 16#1D#;--(Wr) PWM control
constant C_HREG_TST2                          : integer := 16#1E#;--(Rd) Temperature



--Register C_HREG_FIRMWARE / Bit Map:
constant C_HREG_FRMWARE_LAST_BIT              : integer := 15;


--Register C_HREG_CTRL / Bit Map:
constant C_HREG_CTRL_RST_ALL_BIT              : integer := 0;
constant C_HREG_CTRL_RST_MEM_BIT              : integer := 1;
constant C_HREG_CTRL_RST_ETH_BIT              : integer := 2;
constant C_HREG_CTRL_FG_RDDONE_BIT            : integer := 3;
constant C_HREG_CTRL_LAST_BIT                 : integer := C_HREG_CTRL_FG_RDDONE_BIT;


--Register C_HREG_DMA_CTRL / Bit Map:
constant C_HREG_DMA_CTRL_DRDY_BIT             : integer := 0;
constant C_HREG_DMA_CTRL_DMA_START_BIT        : integer := 1; --(Rising_edge)
constant C_HREG_DMA_CTRL_DMA_DIR_BIT          : integer := 2; --1/0 – (PC<-FPGA)/(PC->FPGA)
constant C_HREG_DMA_CTRL_DMABUF_L_BIT         : integer := 3; --Number of start buffer (for DMATRN)
constant C_HREG_DMA_CTRL_DMABUF_M_BIT         : integer := 10;
constant C_HREG_DMA_CTRL_DMABUF_COUNT_L_BIT   : integer := 11;--Count buffer (for DMATRN)
constant C_HREG_DMA_CTRL_DMABUF_COUNT_M_BIT   : integer := 18;
constant C_HREG_DMA_CTRL_ADR_L_BIT            : integer := 19;--device adress (fpga module connected to host(pcie)) - C_HDEV_xxx
constant C_HREG_DMA_CTRL_ADR_M_BIT            : integer := 22;
constant C_HREG_DMA_CTRL_FG_CH_L_BIT          : integer := 23;--number of Frame Grabber channel
constant C_HREG_DMA_CTRL_FG_CH_M_BIT          : integer := 25;
constant C_HREG_DMA_CTRL_LAST_BIT             : integer := C_HREG_DMA_CTRL_FG_CH_M_BIT;--Max 31

--field C_HREG_DMA_CTRL_ADR - user device adress:
constant C_HDEV_MEM                           : integer := 0;--RAM
constant C_HDEV_FG                            : integer := 1;--Frame Grabber
constant C_HDEV_ETH                           : integer := 2;
constant C_HDEV_COUNT                         : integer := C_HDEV_ETH + 1;
constant C_HDEV_COUNT_MAX                     : integer := pwr(2, (C_HREG_DMA_CTRL_ADR_M_BIT - C_HREG_DMA_CTRL_ADR_L_BIT + 1));


--Register C_HOST_REG_STATUS_DEV / Bit Map:
constant C_HREG_DEV_STATUS_DMA_BUSY_BIT       : integer := 0; --PCIE_DMA
constant C_HREG_DEV_STATUS_MEMCTRL_RDY_BIT    : integer := 1;
constant C_HREG_DEV_STATUS_ETH_RDY_BIT        : integer := 2;
constant C_HREG_DEV_STATUS_ETH_LINK_BIT       : integer := 3;
constant C_HREG_DEV_STATUS_ETH_RXRDY_BIT      : integer := 4;
constant C_HREG_DEV_STATUS_ETH_TXRDY_BIT      : integer := 5;
constant C_HREG_DEV_STATUS_FG_VCH0_RDY_BIT    : integer := 6;
constant C_HREG_DEV_STATUS_FG_VCH1_RDY_BIT    : integer := 7;
constant C_HREG_DEV_STATUS_FG_VCH2_RDY_BIT    : integer := 8;
constant C_HREG_DEV_STATUS_FG_VCH3_RDY_BIT    : integer := 9;

constant C_HREG_DEV_STATUS_FST_BIT            : integer := 1;
constant C_HREG_DEV_STATUS_LAST_BIT           : integer := C_HREG_DEV_STATUS_FG_VCH0_RDY_BIT + C_PCFG_FG_VCH_COUNT - 1;


--Register C_HREG_IRQ / Bit Map:
constant C_HREG_IRQ_NUM_L_WBIT                : integer := 0; --IRQ source
constant C_HREG_IRQ_NUM_M_WBIT                : integer := 3;
constant C_HREG_IRQ_EN_WBIT                   : integer := 13;
constant C_HREG_IRQ_STATUS_CLR_WBIT           : integer := 14;
constant C_HREG_IRQ_CLR_WBIT                  : integer := 15;
constant C_HREG_IRQ_LAST_WBIT                 : integer := C_HREG_IRQ_CLR_WBIT;

constant C_HREG_IRQ_STATUS_L_RBIT             : integer := 0; --Status active irq
constant C_HREG_IRQ_STATUS_M_RBIT             : integer := 31;

--field C_HREG_IRQ_NUM - interrupt numbers:
constant C_HIRQ_PCIE_DMA                      : integer := 0;--DONE
constant C_HIRQ_ETH                           : integer := 1;--RxD_RDY
constant C_HIRQ_FG_VCH0                       : integer := 2;
constant C_HIRQ_COUNT                         : integer := C_HIRQ_FG_VCH0 + C_PCFG_FG_VCH_COUNT;
constant C_HIRQ_FST_BIT                       : integer := selval(0, 1, (C_HIRQ_COUNT = 1));
--constant C_HIRQ_COUNT_MAX                     : integer := pwr(2, (C_HREG_IRQ_NUM_M_WBIT - C_HREG_IRQ_NUM_L_WBIT + 1));


--Register C_HREG_MEM_ADR / Bit Map:
constant C_HREG_MEM_ADR_BANK_L_BIT            : integer := 31;--MEM_ADR_OFFSET[30..0]
constant C_HREG_MEM_ADR_BANK_M_BIT            : integer := 31;
constant C_HREG_MEM_ADR_LAST_BIT              : integer := C_HREG_MEM_ADR_BANK_M_BIT;

--Register C_HREG_MEM_CTRL / Bit Map:
constant C_HREG_MEM_CTRL_TRNWR_L_BIT          : integer := 0;
constant C_HREG_MEM_CTRL_TRNWR_M_BIT          : integer := 7;
constant C_HREG_MEM_CTRL_TRNRD_L_BIT          : integer := 8;
constant C_HREG_MEM_CTRL_TRNRD_M_BIT          : integer := 15;
constant C_HREG_MEM_CTRL_LAST_BIT             : integer := C_HREG_MEM_CTRL_TRNRD_M_BIT;


--Register C_HREG_PCIE / Bit Map:
constant C_HREG_PCIE_NEG_LINK_L_RBIT          : integer := 0;
constant C_HREG_PCIE_NEG_LINK_M_RBIT          : integer := 5;
constant C_HREG_PCIE_NEG_MAX_PAYLOAD_L_RBIT   : integer := 6;
constant C_HREG_PCIE_NEG_MAX_PAYLOAD_M_RBIT   : integer := 8;
constant C_HREG_PCIE_NEG_MAX_RD_REQ_L_RBIT    : integer := 9;
constant C_HREG_PCIE_NEG_MAX_RD_REQ_M_RBIT    : integer := 11;
constant C_HREG_PCIE_MASTER_EN_RBIT           : integer := 12;
constant C_HREG_PCIE_SPEED_TESTING_BIT        : integer := 13;
constant C_HREG_PCIE_EN_TESTD_GEN_BIT         : integer := 14;
constant C_HREG_PCIE_LAST_BIT                 : integer := C_HREG_PCIE_EN_TESTD_GEN_BIT;

--Register C_HREG_FUNC / Bit Map:
--1/0 - use/(not use) into project FPGA
constant C_HREG_FUNC_MEM_BIT                  : integer := 0;
constant C_HREG_FUNC_TMR_BIT                  : integer := 1;
constant C_HREG_FUNC_FG_BIT                   : integer := 2;
constant C_HREG_FUNC_ETH_BIT                  : integer := 3;
constant C_HREG_FUNC_LAST_BIT                 : integer := C_HREG_FUNC_ETH_BIT;


--Register C_HREG_FUNCPRM / Bit Map:
constant C_HREG_FUNCPRM_MEMBANK_SIZE_L_BIT    : integer := 0;
constant C_HREG_FUNCPRM_MEMBANK_SIZE_M_BIT    : integer := 2;
constant C_HREG_FUNCPRM_FG_VCH_COUNT_L_BIT    : integer := 3;
constant C_HREG_FUNCPRM_FG_VCH_COUNT_M_BIT    : integer := 5;
constant C_HREG_FUNCPRM_FG_REV_BIT            : integer := 7;
constant C_HREG_FUNCPRM_FG_128_BIT            : integer := 9;
constant C_HREG_FUNCPRM_LAST_BIT              : integer := C_HREG_FUNCPRM_FG_128_BIT;


--Port of module pcie_main.vhd /p_in_dev_option/ Bit Map:
constant C_HDEV_OPTIN_TXFIFO_FULL_BIT         : integer := 0;
constant C_HDEV_OPTIN_RXFIFO_EMPTY_BIT        : integer := 1;
constant C_HDEV_OPTIN_MEM_DONE_BIT            : integer := 2;
constant C_HDEV_OPTIN_FG_FRMRK_L_BIT          : integer := 3;
constant C_HDEV_OPTIN_FG_FRMRK_M_BIT          : integer := 34;
constant C_HDEV_OPTIN_ETH_HEADER_L_BIT        : integer := 35;
constant C_HDEV_OPTIN_ETH_HEADER_M_BIT        : integer := 66;

constant C_HDEV_OPTIN_FST_BIT                 : integer := 0;
constant C_HDEV_OPTIN_LAST_BIT                : integer := C_HDEV_OPTIN_ETH_HEADER_M_BIT;


--Port of module pcie_main.vhd /p_out_dev_option/ Bit Map:
constant C_HDEV_OPTOUT_MEM_ADR_L_BIT          : integer := 0;
constant C_HDEV_OPTOUT_MEM_ADR_M_BIT          : integer := 31;
constant C_HDEV_OPTOUT_MEM_TRNWR_LEN_L_BIT    : integer := 32;
constant C_HDEV_OPTOUT_MEM_TRNWR_LEN_M_BIT    : integer := 32 + (C_HREG_MEM_CTRL_TRNWR_M_BIT - C_HREG_MEM_CTRL_TRNWR_L_BIT);--max(msb..lsb)=16bit
constant C_HDEV_OPTOUT_MEM_TRNRD_LEN_L_BIT    : integer := 48;
constant C_HDEV_OPTOUT_MEM_TRNRD_LEN_M_BIT    : integer := 48 + (C_HREG_MEM_CTRL_TRNRD_M_BIT - C_HREG_MEM_CTRL_TRNRD_L_BIT);--max(msb..lsb)=16bit
constant C_HDEV_OPTOUT_MEM_RQLEN_L_BIT        : integer := 64;
constant C_HDEV_OPTOUT_MEM_RQLEN_M_BIT        : integer := 81;--mem_rqlen: BYTE(max 128KB)

constant C_HDEV_OPTOUT_FST_BIT                : integer := 0;
constant C_HDEV_OPTOUT_LAST_BIT               : integer := C_HDEV_OPTOUT_MEM_RQLEN_M_BIT;


--Register C_HREG_CFGD_CTRL / Bit Map:
constant C_HREG_CFG_CTRL_ADR_L_BIT            : integer := 0;
constant C_HREG_CFG_CTRL_ADR_M_BIT            : integer := 3;
constant C_HREG_CFG_CTRL_REG_L_BIT            : integer := 4;
constant C_HREG_CFG_CTRL_REG_M_BIT            : integer := 11;
constant C_HREG_CFG_CTRL_LAST_BIT             : integer := C_HREG_CFG_CTRL_REG_M_BIT;


--CFG Device Address map:
constant C_CFGDEV_FG                          : integer := 0;
constant C_CFGDEV_SWT                         : integer := 1;
constant C_CFGDEV_TMR                         : integer := 2;
constant C_CFGDEV_ETH                         : integer := 3;
constant C_CFGDEV_COUNT                       : integer := C_CFGDEV_ETH + 1;
constant C_CFGDEV_COUNT_MAX                   : integer := pwr(2, (C_HREG_CFG_CTRL_ADR_M_BIT - C_HREG_CFG_CTRL_ADR_L_BIT + 1));



--CFG Device Register map:
constant C_CFGREG_COUNT_MAX                   : integer := pwr(2, (C_HREG_CFG_CTRL_REG_M_BIT - C_HREG_CFG_CTRL_REG_L_BIT + 1));

----------------------------------------------------------------
--module timers.vhd
----------------------------------------------------------------
constant C_TMR_REG_CTRL                       : integer := 16#000#;
constant C_TMR_REG_CMP                        : integer := 16#001#;

constant C_TMR_ETH                            : integer := 0;
constant C_TMR_COUNT                          : integer := C_TMR_ETH + 1;


--Register C_TMR_REG_CTRL / Bit Map:
constant C_TMR_REG_CTRL_EN_WBIT                : integer := 0;
constant C_TMR_REG_CTRL_NUM_L_WBIT             : integer := 1;--Number TMR
constant C_TMR_REG_CTRL_NUM_M_WBIT             : integer := 2;
--constant C_TMR_REG_CTRL_STATUS_EN_L_RBIT      : integer := 0;--
--constant C_TMR_REG_CTRL_STATUS_EN_M_RBIT      : integer := xxx;


----------------------------------------------------------------
--module switch_data.vhd
----------------------------------------------------------------
constant C_SWT_REG_CTRL                       : integer := 16#00#;
constant C_SWT_REG_ETH2HOST_FRR0              : integer := 16#01#;
constant C_SWT_REG_ETH2HOST_FRR1              : integer := 16#02#;
constant C_SWT_REG_ETH2FG_FRR0                : integer := 16#03#;
constant C_SWT_REG_ETH2FG_FRR1                : integer := 16#04#;
constant C_SWT_REG_DBG                        : integer := 16#1C#;

--Register C_SWT_REG_DBG / Bit Map:
constant C_SWT_REG_DBG_HOST2FG_BIT            : integer := 0; --HOST(over ETH BUF) -> FG
constant C_SWT_REG_DBG_ETHLOOP_BIT            : integer := 1;
constant C_SWT_REG_DBG_LAST_BIT               : integer := C_SWT_REG_DBG_ETHLOOP_BIT;

--Register C_SWT_REG_CTRL / Bit Map:
constant C_SWT_REG_CTRL_RST_ETH_BUFS_BIT      : integer := 0;
constant C_SWT_REG_CTRL_RST_FG_BUFS_BIT       : integer := 1;
constant C_SWT_REG_CTRL_LAST_BIT              : integer := C_SWT_REG_CTRL_RST_FG_BUFS_BIT;


--Max count rules FRR = 8!!!!
--Count of rule FRR (frame routing):
constant C_SWT_ETH_HOST_FRR_COUNT             : integer := 3;
constant C_SWT_ETH_FG_FRR_COUNT               : integer := C_PCFG_FG_VCH_COUNT;


----------------------------------------------------------------
--module  fg.vhd
----------------------------------------------------------------
constant C_FG_REG_CTRL                     : integer := 16#00#;
constant C_FG_REG_DATA                     : integer := 16#01#;
constant C_FG_REG_MEM_CTRL                 : integer := 16#02#;--(15..8)(7..0) - trn_mem_rd;trn_mem_wr
constant C_FG_REG_DBG                      : integer := 16#1C#;


--Register C_FG_REG_CTRL / Bit Map:
constant C_FG_REG_CTRL_VCH_L_BIT           : integer := 0; --Index of video channel
constant C_FG_REG_CTRL_VCH_M_BIT           : integer := 3;
constant C_FG_REG_CTRL_PRM_L_BIT           : integer := 4; --Index of parameter video channel
constant C_FG_REG_CTRL_PRM_M_BIT           : integer := 6;
constant C_FG_REG_CTRL_DIR_BIT             : integer := 7; --Write/Read parametrs
constant C_FG_REG_CTRL_SET_IDLE_BIT        : integer := 8;
constant C_FG_REG_CTRL_LAST_BIT            : integer := C_FG_REG_CTRL_SET_IDLE_BIT;

--
constant C_FG_REG_CTRL_DIR_WR : std_logic := '1';
constant C_FG_PKT_HD_SIZE_BYTE : integer := 16;

--Index of parametr video channel:
constant C_FG_PRM_ZONE_SKIP             : integer := 0;
constant C_FG_PRM_ZONE_ACTIVE           : integer := 1;
constant C_FG_PRM_OPTIONS               : integer := 2;
constant C_FG_PRM_STEP_RD_LINE          : integer := 3;

constant C_FG_PRM_COUNT_MAX                : integer := pwr(2, (C_FG_REG_CTRL_PRM_M_BIT - C_FG_REG_CTRL_PRM_L_BIT + 1));

constant C_FG_PIX_L    : integer := 0;
constant C_FG_PIX_M    : integer := 15;
constant C_FG_ROW_L    : integer := 16;
constant C_FG_ROW_M    : integer := 31;

constant C_FG_PRM_OPTIONS_MIRX_BIT      : integer := 0;
constant C_FG_PRM_OPTIONS_MIRY_BIT      : integer := 1;


--Count video channel:
constant C_FG_VBUF_COUNT                   : integer := C_PCFG_FG_VBUF_COUNT;
constant C_FG_VCH_COUNT                    : integer := C_PCFG_FG_VCH_COUNT;
--constant C_FG_VCH_COUNT_MAX                : integer := 2;

--Video memory map:
constant C_FG_MEM_VLINE_L_BIT              : integer := log2(C_PCFG_FG_FR_PIX_COUNT_MAX);
constant C_FG_MEM_VLINE_M_BIT              : integer := C_FG_MEM_VLINE_L_BIT + log2(C_PCFG_FG_FR_ROW_COUNT_MAX) - 1;

constant C_FG_MEM_VFR_L_BIT                : integer := (C_FG_MEM_VLINE_M_BIT + 1);
constant C_FG_MEM_VFR_M_BIT                : integer := C_FG_MEM_VFR_L_BIT + selval(1, log2(C_FG_VBUF_COUNT), ((log2(C_FG_VBUF_COUNT) = 0)
                                                                                                                    or (log2(C_FG_VBUF_COUNT) = 1))) - 1;

constant C_FG_MEM_VCH_L_BIT                : integer := (C_FG_MEM_VFR_M_BIT + 1);
constant C_FG_MEM_VCH_M_BIT                : integer := C_FG_MEM_VCH_L_BIT + selval(1, log2(C_FG_VCH_COUNT), ((log2(C_FG_VCH_COUNT) = 0)
                                                                                                                 or (log2(C_FG_VCH_COUNT) = 1))) - 1;

--Register C_FG_REG_DBG / Bit Map:
constant C_FG_REG_DBG_TBUFRD_BIT      : integer:=0;--Отладка модуля слежения - отображение содержимого RAM/TRACK/TBUF
constant C_FG_REG_DBG_EBUFRD_BIT      : integer:=1;--Отладка модуля слежения - отображение содержимого RAM/TRACK/EBUF
constant C_FG_REG_DBG_SOBEL_BIT       : integer:=2;--1/0 - Отладка модуля собела Выдача Grad/Video
constant C_FG_REG_DBG_ROTRIGHT_BIT    : integer:=3;--Поворот на 90 вправо
constant C_FG_REG_DBG_ROTLEFT_BIT     : integer:=4;--Поворот на 90 влево
constant C_FG_REG_DBG_DIS_DEMCOLOR_BIT: integer:=5;--1/0 - Запретить работу модуля vcoldemosaic_main.vhd
constant C_FG_REG_DBG_DCOUNT_BIT      : integer:=6;--1 - Вместо данных строки вставляется счетчик
constant C_FG_REG_DBG_PICTURE_BIT     : integer:=7;--Запрещаю запись видео в ОЗУ + запрещаю инкрементацию счетчика vbuf,
                                                           --при бит(7)=1 - vbuf=0
constant C_FG_REG_DBG_SKIPFR_CNT_CLR_BIT  : integer:=8;--При 1 - происходит сброс счетчиков пропущеных кадров tst_vfrskip,
                                                           --При 0 - нет
constant C_FG_REG_DBG_TIMESTUMP_BIT   : integer:=9;
constant C_FG_REG_DBG_RDHOLD_BIT      : integer:=10;--Эмуляция захвата видеобуфера модулем чтения
constant C_FG_REG_DBG_TRCHOLD_BIT     : integer:=11;--Эмуляция захвата видеобуфера модулем слежения
constant C_FG_REG_DBG_LAST_BIT        : integer:=C_FG_REG_DBG_TRCHOLD_BIT;


----------------------------------------------------------------
--module  eth_main.vhd
----------------------------------------------------------------
constant C_ETH_REG_MAC_PATRN0                 : integer:=16#000#;
constant C_ETH_REG_MAC_PATRN1                 : integer:=16#001#;
constant C_ETH_REG_MAC_PATRN2                 : integer:=16#002#;




--##################################################
type TTmrVal is array (0 to (C_TMR_COUNT - 1)) of unsigned(31 downto 0);

type TTmrCtrl is record
en  : std_logic_vector((C_TMR_COUNT - 1) downto 0);
data : TTmrVal;
end record;


--##################################################
type TEthMacAdr is array (0 to 5) of std_logic_vector(7 downto 0);

type TEthMAC is record
dst : TEthMacAdr;
src : TEthMacAdr;
end record;

type TEthCfg is record
mac : TEthMAC;
end record;

type TEthCtrl is array (0 to 0) of TEthCfg;


--##################################################
Type TFG_FrBufs is array (0 to (C_FG_VCH_COUNT - 1))
  of unsigned(C_FG_MEM_VFR_M_BIT - C_FG_MEM_VFR_L_BIT downto 0);

Type TFG_FrMrks is array (0 to (C_FG_VCH_COUNT - 1)) of std_logic_vector(31 downto 0);

type TFG_FrMirror is record
pix : std_logic;
row : std_logic;
end record;

type TFG_FrXY is record
pixcount : unsigned((C_FG_PIX_M - C_FG_PIX_L) downto 0);
rowcount : unsigned((C_FG_ROW_M - C_FG_ROW_L) downto 0);
end record;
Type TFG_FrXYs is array (0 to (C_FG_VCH_COUNT - 1)) of TFG_FrXY;

type TFG_FrXYPrm is record
skp : TFG_FrXY; --skip zone
act : TFG_FrXY; --active zone
end record;
Type TFG_FrXYPrms is array (0 to (C_FG_VCH_COUNT - 1)) of TFG_FrXYPrm;

type TFG_VCHPrm is record
fr     : TFG_FrXYPrm;
mirror : TFG_FrMirror;
steprd : unsigned((C_FG_ROW_M - C_FG_ROW_L) downto 0); --Step read frame (Count Line)
end record;
type TFG_VCHPrms is array (0 to (C_FG_VCH_COUNT - 1)) of TFG_VCHPrm;

type TFG_Prm is record
memwr_trnlen : std_logic_vector((C_HREG_MEM_CTRL_TRNWR_M_BIT - C_HREG_MEM_CTRL_TRNWR_L_BIT) downto 0);
memrd_trnlen : std_logic_vector((C_HREG_MEM_CTRL_TRNRD_M_BIT - C_HREG_MEM_CTRL_TRNRD_L_BIT) downto 0);
ch : TFG_VCHPrms;
end record;

type TFgCtrl is record
idle : std_logic_vector((C_FG_VCH_COUNT - 1) downto 0);
dbg  : std_logic_vector(C_FG_REG_DBG_LAST_BIT downto 0);
prm  : TFG_Prm;
end record;


--##################################################
type TSwtFrrMasks is array (0 to 7) of std_logic_vector(7 downto 0);

type TSwtFrr is record
eth2h  : TSWTfrrMasks;
eth2fg : TSwtFrrMasks;
end record;

type TSwtCtrl is record
ctrl : std_logic_vector(C_SWT_REG_CTRL_LAST_BIT downto 0);
dbg  : std_logic_vector(C_SWT_REG_DBG_LAST_BIT downto 0);
frr  : TSwtFrr;
end record;


--##################################################
type TDevRegCtrl is record
eth : TEthCtrl;
fg  : TFgCtrl;
swt : TSwtCtrl;
tmr : TTmrCtrl;
end record;

type TDevCtrl is record
dma : std_logic_vector(C_HREG_DMA_CTRL_LAST_BIT downto C_HREG_DMA_CTRL_DRDY_BIT);
reg : TDevRegCtrl;
end record;


end package prj_def;
