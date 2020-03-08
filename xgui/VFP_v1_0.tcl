# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set C_rgb_s_axis_TDATA_WIDTH [ipgui::add_param $IPINST -name "C_rgb_s_axis_TDATA_WIDTH" -parent ${Page_0} -widget comboBox]
  set_property tooltip {AXI4Stream sink: Data Width} ${C_rgb_s_axis_TDATA_WIDTH}
  set C_vfpConfig_DATA_WIDTH [ipgui::add_param $IPINST -name "C_vfpConfig_DATA_WIDTH" -parent ${Page_0} -widget comboBox]
  set_property tooltip {Width of S_AXI data bus} ${C_vfpConfig_DATA_WIDTH}
  set C_vfpConfig_ADDR_WIDTH [ipgui::add_param $IPINST -name "C_vfpConfig_ADDR_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of S_AXI address bus} ${C_vfpConfig_ADDR_WIDTH}
  ipgui::add_param $IPINST -name "C_vfpConfig_BASEADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_vfpConfig_HIGHADDR" -parent ${Page_0}
  set C_rgb_m_axis_TDATA_WIDTH [ipgui::add_param $IPINST -name "C_rgb_m_axis_TDATA_WIDTH" -parent ${Page_0} -widget comboBox]
  set_property tooltip {Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.} ${C_rgb_m_axis_TDATA_WIDTH}
  set C_rgb_m_axis_START_COUNT [ipgui::add_param $IPINST -name "C_rgb_m_axis_START_COUNT" -parent ${Page_0}]
  set_property tooltip {Start count is the numeber of clock cycles the master will wait before initiating/issuing any transaction.} ${C_rgb_m_axis_START_COUNT}
  set C_m_axis_mm2s_TDATA_WIDTH [ipgui::add_param $IPINST -name "C_m_axis_mm2s_TDATA_WIDTH" -parent ${Page_0} -widget comboBox]
  set_property tooltip {Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.} ${C_m_axis_mm2s_TDATA_WIDTH}
  set C_m_axis_mm2s_START_COUNT [ipgui::add_param $IPINST -name "C_m_axis_mm2s_START_COUNT" -parent ${Page_0}]
  set_property tooltip {Start count is the numeber of clock cycles the master will wait before initiating/issuing any transaction.} ${C_m_axis_mm2s_START_COUNT}
  ipgui::add_param $IPINST -name "revision_number" -parent ${Page_0}
  ipgui::add_param $IPINST -name "i_data_width" -parent ${Page_0}
  ipgui::add_param $IPINST -name "s_data_width" -parent ${Page_0}
  ipgui::add_param $IPINST -name "b_data_width" -parent ${Page_0}
  ipgui::add_param $IPINST -name "bmp_precision" -parent ${Page_0}
  ipgui::add_param $IPINST -name "F_CGA_FULL_RANGE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "F_TES" -parent ${Page_0}
  ipgui::add_param $IPINST -name "F_LUM" -parent ${Page_0}
  ipgui::add_param $IPINST -name "F_TRM" -parent ${Page_0}
  ipgui::add_param $IPINST -name "F_RGB" -parent ${Page_0}
  ipgui::add_param $IPINST -name "F_SHP" -parent ${Page_0}
  ipgui::add_param $IPINST -name "F_BLU" -parent ${Page_0}
  ipgui::add_param $IPINST -name "F_EMB" -parent ${Page_0}
  ipgui::add_param $IPINST -name "F_YCC" -parent ${Page_0}
  ipgui::add_param $IPINST -name "F_SOB" -parent ${Page_0}
  ipgui::add_param $IPINST -name "F_CGA" -parent ${Page_0}
  ipgui::add_param $IPINST -name "F_HSV" -parent ${Page_0}
  ipgui::add_param $IPINST -name "F_HSL" -parent ${Page_0}
  ipgui::add_param $IPINST -name "conf_data_width" -parent ${Page_0}
  ipgui::add_param $IPINST -name "conf_addr_width" -parent ${Page_0}
  ipgui::add_param $IPINST -name "d5m_frame_width" -parent ${Page_0}
  ipgui::add_param $IPINST -name "d5m_data_width" -parent ${Page_0}


}

proc update_PARAM_VALUE.b_data_width { PARAM_VALUE.b_data_width } {
	# Procedure called to update b_data_width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.b_data_width { PARAM_VALUE.b_data_width } {
	# Procedure called to validate b_data_width
	return true
}

proc update_PARAM_VALUE.conf_addr_width { PARAM_VALUE.conf_addr_width } {
	# Procedure called to update conf_addr_width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.conf_addr_width { PARAM_VALUE.conf_addr_width } {
	# Procedure called to validate conf_addr_width
	return true
}

proc update_PARAM_VALUE.conf_data_width { PARAM_VALUE.conf_data_width } {
	# Procedure called to update conf_data_width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.conf_data_width { PARAM_VALUE.conf_data_width } {
	# Procedure called to validate conf_data_width
	return true
}

proc update_PARAM_VALUE.d5m_data_width { PARAM_VALUE.d5m_data_width } {
	# Procedure called to update d5m_data_width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.d5m_data_width { PARAM_VALUE.d5m_data_width } {
	# Procedure called to validate d5m_data_width
	return true
}

proc update_PARAM_VALUE.i_data_width { PARAM_VALUE.i_data_width } {
	# Procedure called to update i_data_width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.i_data_width { PARAM_VALUE.i_data_width } {
	# Procedure called to validate i_data_width
	return true
}

proc update_PARAM_VALUE.F_CGA_FULL_RANGE { PARAM_VALUE.F_CGA_FULL_RANGE } {
	# Procedure called to update F_CGA_FULL_RANGE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.F_CGA_FULL_RANGE { PARAM_VALUE.F_CGA_FULL_RANGE } {
	# Procedure called to validate F_CGA_FULL_RANGE
	return true
}

proc update_PARAM_VALUE.F_TES { PARAM_VALUE.F_TES } {
	# Procedure called to update F_TES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.F_TES { PARAM_VALUE.F_TES } {
	# Procedure called to validate F_TES
	return true
}
proc update_PARAM_VALUE.F_LUM { PARAM_VALUE.F_LUM } {
	# Procedure called to update F_LUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.F_LUM { PARAM_VALUE.F_LUM } {
	# Procedure called to validate F_LUM
	return true
}

proc update_PARAM_VALUE.F_TRM { PARAM_VALUE.F_TRM } {
	# Procedure called to update F_TRM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.F_TRM { PARAM_VALUE.F_TRM } {
	# Procedure called to validate F_TRM
	return true
}

proc update_PARAM_VALUE.F_RGB { PARAM_VALUE.F_RGB } {
	# Procedure called to update F_RGB when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.F_RGB { PARAM_VALUE.F_RGB } {
	# Procedure called to validate F_RGB
	return true
}
proc update_PARAM_VALUE.F_SHP { PARAM_VALUE.F_SHP } {
	# Procedure called to update F_SHP when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.F_SHP { PARAM_VALUE.F_SHP } {
	# Procedure called to validate F_SHP
	return true
}
proc update_PARAM_VALUE.F_BLU { PARAM_VALUE.F_BLU } {
	# Procedure called to update F_BLU when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.F_BLU { PARAM_VALUE.F_BLU } {
	# Procedure called to validate F_BLU
	return true
}

proc update_PARAM_VALUE.F_EMB { PARAM_VALUE.F_EMB } {
	# Procedure called to update F_EMB when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.F_EMB { PARAM_VALUE.F_EMB } {
	# Procedure called to validate F_EMB
	return true
}

proc update_PARAM_VALUE.F_YCC { PARAM_VALUE.F_YCC } {
	# Procedure called to update F_YCC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.F_YCC { PARAM_VALUE.F_YCC } {
	# Procedure called to validate F_YCC
	return true
}

proc update_PARAM_VALUE.F_SOB { PARAM_VALUE.F_SOB } {
	# Procedure called to update F_SOB when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.F_SOB { PARAM_VALUE.F_SOB } {
	# Procedure called to validate F_SOB
	return true
}
proc update_PARAM_VALUE.F_CGA { PARAM_VALUE.F_CGA } {
	# Procedure called to update F_CGA when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.F_CGA { PARAM_VALUE.F_CGA } {
	# Procedure called to validate F_CGA
	return true
}
proc update_PARAM_VALUE.F_HSV { PARAM_VALUE.F_HSV } {
	# Procedure called to update F_HSV when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.F_HSV { PARAM_VALUE.F_HSV } {
	# Procedure called to validate F_HSV
	return true
}

proc update_PARAM_VALUE.F_HSL { PARAM_VALUE.F_HSL } {
	# Procedure called to update F_HSL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.F_HSL { PARAM_VALUE.F_HSL } {
	# Procedure called to validate F_HSL
	return true
}













proc update_PARAM_VALUE.bmp_precision { PARAM_VALUE.bmp_precision } {
	# Procedure called to update bmp_precision when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.bmp_precision { PARAM_VALUE.bmp_precision } {
	# Procedure called to validate bmp_precision
	return true
}

proc update_PARAM_VALUE.d5m_frame_width { PARAM_VALUE.d5m_frame_width } {
	# Procedure called to update d5m_frame_width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.d5m_frame_width { PARAM_VALUE.d5m_frame_width } {
	# Procedure called to validate d5m_frame_width
	return true
}

proc update_PARAM_VALUE.revision_number { PARAM_VALUE.revision_number } {
	# Procedure called to update revision_number when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.revision_number { PARAM_VALUE.revision_number } {
	# Procedure called to validate revision_number
	return true
}

proc update_PARAM_VALUE.s_data_width { PARAM_VALUE.s_data_width } {
	# Procedure called to update s_data_width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.s_data_width { PARAM_VALUE.s_data_width } {
	# Procedure called to validate s_data_width
	return true
}

proc update_PARAM_VALUE.C_rgb_s_axis_TDATA_WIDTH { PARAM_VALUE.C_rgb_s_axis_TDATA_WIDTH } {
	# Procedure called to update C_rgb_s_axis_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_rgb_s_axis_TDATA_WIDTH { PARAM_VALUE.C_rgb_s_axis_TDATA_WIDTH } {
	# Procedure called to validate C_rgb_s_axis_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_vfpConfig_DATA_WIDTH { PARAM_VALUE.C_vfpConfig_DATA_WIDTH } {
	# Procedure called to update C_vfpConfig_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_vfpConfig_DATA_WIDTH { PARAM_VALUE.C_vfpConfig_DATA_WIDTH } {
	# Procedure called to validate C_vfpConfig_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_vfpConfig_ADDR_WIDTH { PARAM_VALUE.C_vfpConfig_ADDR_WIDTH } {
	# Procedure called to update C_vfpConfig_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_vfpConfig_ADDR_WIDTH { PARAM_VALUE.C_vfpConfig_ADDR_WIDTH } {
	# Procedure called to validate C_vfpConfig_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_vfpConfig_BASEADDR { PARAM_VALUE.C_vfpConfig_BASEADDR } {
	# Procedure called to update C_vfpConfig_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_vfpConfig_BASEADDR { PARAM_VALUE.C_vfpConfig_BASEADDR } {
	# Procedure called to validate C_vfpConfig_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_vfpConfig_HIGHADDR { PARAM_VALUE.C_vfpConfig_HIGHADDR } {
	# Procedure called to update C_vfpConfig_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_vfpConfig_HIGHADDR { PARAM_VALUE.C_vfpConfig_HIGHADDR } {
	# Procedure called to validate C_vfpConfig_HIGHADDR
	return true
}

proc update_PARAM_VALUE.C_rgb_m_axis_TDATA_WIDTH { PARAM_VALUE.C_rgb_m_axis_TDATA_WIDTH } {
	# Procedure called to update C_rgb_m_axis_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_rgb_m_axis_TDATA_WIDTH { PARAM_VALUE.C_rgb_m_axis_TDATA_WIDTH } {
	# Procedure called to validate C_rgb_m_axis_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_rgb_m_axis_START_COUNT { PARAM_VALUE.C_rgb_m_axis_START_COUNT } {
	# Procedure called to update C_rgb_m_axis_START_COUNT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_rgb_m_axis_START_COUNT { PARAM_VALUE.C_rgb_m_axis_START_COUNT } {
	# Procedure called to validate C_rgb_m_axis_START_COUNT
	return true
}

proc update_PARAM_VALUE.C_m_axis_mm2s_TDATA_WIDTH { PARAM_VALUE.C_m_axis_mm2s_TDATA_WIDTH } {
	# Procedure called to update C_m_axis_mm2s_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_m_axis_mm2s_TDATA_WIDTH { PARAM_VALUE.C_m_axis_mm2s_TDATA_WIDTH } {
	# Procedure called to validate C_m_axis_mm2s_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_m_axis_mm2s_START_COUNT { PARAM_VALUE.C_m_axis_mm2s_START_COUNT } {
	# Procedure called to update C_m_axis_mm2s_START_COUNT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_m_axis_mm2s_START_COUNT { PARAM_VALUE.C_m_axis_mm2s_START_COUNT } {
	# Procedure called to validate C_m_axis_mm2s_START_COUNT
	return true
}


proc update_MODELPARAM_VALUE.C_rgb_s_axis_TDATA_WIDTH { MODELPARAM_VALUE.C_rgb_s_axis_TDATA_WIDTH PARAM_VALUE.C_rgb_s_axis_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_rgb_s_axis_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_rgb_s_axis_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_vfpConfig_DATA_WIDTH { MODELPARAM_VALUE.C_vfpConfig_DATA_WIDTH PARAM_VALUE.C_vfpConfig_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_vfpConfig_DATA_WIDTH}] ${MODELPARAM_VALUE.C_vfpConfig_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_vfpConfig_ADDR_WIDTH { MODELPARAM_VALUE.C_vfpConfig_ADDR_WIDTH PARAM_VALUE.C_vfpConfig_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_vfpConfig_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_vfpConfig_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_rgb_m_axis_TDATA_WIDTH { MODELPARAM_VALUE.C_rgb_m_axis_TDATA_WIDTH PARAM_VALUE.C_rgb_m_axis_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_rgb_m_axis_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_rgb_m_axis_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_rgb_m_axis_START_COUNT { MODELPARAM_VALUE.C_rgb_m_axis_START_COUNT PARAM_VALUE.C_rgb_m_axis_START_COUNT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_rgb_m_axis_START_COUNT}] ${MODELPARAM_VALUE.C_rgb_m_axis_START_COUNT}
}

proc update_MODELPARAM_VALUE.C_m_axis_mm2s_TDATA_WIDTH { MODELPARAM_VALUE.C_m_axis_mm2s_TDATA_WIDTH PARAM_VALUE.C_m_axis_mm2s_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_m_axis_mm2s_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_m_axis_mm2s_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_m_axis_mm2s_START_COUNT { MODELPARAM_VALUE.C_m_axis_mm2s_START_COUNT PARAM_VALUE.C_m_axis_mm2s_START_COUNT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_m_axis_mm2s_START_COUNT}] ${MODELPARAM_VALUE.C_m_axis_mm2s_START_COUNT}
}

proc update_MODELPARAM_VALUE.revision_number { MODELPARAM_VALUE.revision_number PARAM_VALUE.revision_number } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.revision_number}] ${MODELPARAM_VALUE.revision_number}
}

proc update_MODELPARAM_VALUE.i_data_width { MODELPARAM_VALUE.i_data_width PARAM_VALUE.i_data_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.i_data_width}] ${MODELPARAM_VALUE.i_data_width}
}

proc update_MODELPARAM_VALUE.s_data_width { MODELPARAM_VALUE.s_data_width PARAM_VALUE.s_data_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.s_data_width}] ${MODELPARAM_VALUE.s_data_width}
}

proc update_MODELPARAM_VALUE.b_data_width { MODELPARAM_VALUE.b_data_width PARAM_VALUE.b_data_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.b_data_width}] ${MODELPARAM_VALUE.b_data_width}
}

proc update_MODELPARAM_VALUE.bmp_precision { MODELPARAM_VALUE.bmp_precision PARAM_VALUE.bmp_precision } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.bmp_precision}] ${MODELPARAM_VALUE.bmp_precision}
}

proc update_MODELPARAM_VALUE.F_CGA_FULL_RANGE { MODELPARAM_VALUE.F_CGA_FULL_RANGE PARAM_VALUE.F_CGA_FULL_RANGE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.F_CGA_FULL_RANGE}] ${MODELPARAM_VALUE.F_CGA_FULL_RANGE}
}
proc update_MODELPARAM_VALUE.F_TES { MODELPARAM_VALUE.F_TES PARAM_VALUE.F_TES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.F_TES}] ${MODELPARAM_VALUE.F_TES}
}

proc update_MODELPARAM_VALUE.F_LUM { MODELPARAM_VALUE.F_LUM PARAM_VALUE.F_LUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.F_LUM}] ${MODELPARAM_VALUE.F_LUM}
}

proc update_MODELPARAM_VALUE.F_TRM { MODELPARAM_VALUE.F_TRM PARAM_VALUE.F_TRM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.F_TRM}] ${MODELPARAM_VALUE.F_TRM}
}
proc update_MODELPARAM_VALUE.F_RGB { MODELPARAM_VALUE.F_RGB PARAM_VALUE.F_RGB } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.F_RGB}] ${MODELPARAM_VALUE.F_RGB}
}
proc update_MODELPARAM_VALUE.F_SHP { MODELPARAM_VALUE.F_SHP PARAM_VALUE.F_SHP } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.F_SHP}] ${MODELPARAM_VALUE.F_SHP}
}
proc update_MODELPARAM_VALUE.F_BLU { MODELPARAM_VALUE.F_BLU PARAM_VALUE.F_BLU } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.F_BLU}] ${MODELPARAM_VALUE.F_BLU}
}
proc update_MODELPARAM_VALUE.F_EMB { MODELPARAM_VALUE.F_EMB PARAM_VALUE.F_EMB } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.F_EMB}] ${MODELPARAM_VALUE.F_EMB}
}
proc update_MODELPARAM_VALUE.F_YCC { MODELPARAM_VALUE.F_YCC PARAM_VALUE.F_YCC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.F_YCC}] ${MODELPARAM_VALUE.F_YCC}
}

proc update_MODELPARAM_VALUE.F_SOB { MODELPARAM_VALUE.F_SOB PARAM_VALUE.F_SOB } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.F_SOB}] ${MODELPARAM_VALUE.F_SOB}
}
proc update_MODELPARAM_VALUE.F_CGA { MODELPARAM_VALUE.F_CGA PARAM_VALUE.F_CGA } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.F_CGA}] ${MODELPARAM_VALUE.F_CGA}
}
proc update_MODELPARAM_VALUE.F_HSV { MODELPARAM_VALUE.F_HSV PARAM_VALUE.F_HSV } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.F_HSV}] ${MODELPARAM_VALUE.F_HSV}
}
proc update_MODELPARAM_VALUE.F_HSL { MODELPARAM_VALUE.F_HSL PARAM_VALUE.F_HSL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.F_HSL}] ${MODELPARAM_VALUE.F_HSL}
}

proc update_MODELPARAM_VALUE.conf_data_width { MODELPARAM_VALUE.conf_data_width PARAM_VALUE.conf_data_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.conf_data_width}] ${MODELPARAM_VALUE.conf_data_width}
}

proc update_MODELPARAM_VALUE.conf_addr_width { MODELPARAM_VALUE.conf_addr_width PARAM_VALUE.conf_addr_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.conf_addr_width}] ${MODELPARAM_VALUE.conf_addr_width}
}

proc update_MODELPARAM_VALUE.d5m_frame_width { MODELPARAM_VALUE.d5m_frame_width PARAM_VALUE.d5m_frame_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.d5m_frame_width}] ${MODELPARAM_VALUE.d5m_frame_width}
}

proc update_MODELPARAM_VALUE.d5m_data_width { MODELPARAM_VALUE.d5m_data_width PARAM_VALUE.d5m_data_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.d5m_data_width}] ${MODELPARAM_VALUE.d5m_data_width}
}

