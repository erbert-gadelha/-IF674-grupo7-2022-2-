onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix decimal /cpu/A
add wave -noupdate /cpu/clock
add wave -noupdate /cpu/reset
add wave -noupdate -color Yellow -radix unsigned -childformat {{{/cpu/PC[31]} -radix unsigned} {{/cpu/PC[30]} -radix unsigned} {{/cpu/PC[29]} -radix unsigned} {{/cpu/PC[28]} -radix unsigned} {{/cpu/PC[27]} -radix unsigned} {{/cpu/PC[26]} -radix unsigned} {{/cpu/PC[25]} -radix unsigned} {{/cpu/PC[24]} -radix unsigned} {{/cpu/PC[23]} -radix unsigned} {{/cpu/PC[22]} -radix unsigned} {{/cpu/PC[21]} -radix unsigned} {{/cpu/PC[20]} -radix unsigned} {{/cpu/PC[19]} -radix unsigned} {{/cpu/PC[18]} -radix unsigned} {{/cpu/PC[17]} -radix unsigned} {{/cpu/PC[16]} -radix unsigned} {{/cpu/PC[15]} -radix unsigned} {{/cpu/PC[14]} -radix unsigned} {{/cpu/PC[13]} -radix unsigned} {{/cpu/PC[12]} -radix unsigned} {{/cpu/PC[11]} -radix unsigned} {{/cpu/PC[10]} -radix unsigned} {{/cpu/PC[9]} -radix unsigned} {{/cpu/PC[8]} -radix unsigned} {{/cpu/PC[7]} -radix unsigned} {{/cpu/PC[6]} -radix unsigned} {{/cpu/PC[5]} -radix unsigned} {{/cpu/PC[4]} -radix unsigned} {{/cpu/PC[3]} -radix unsigned} {{/cpu/PC[2]} -radix unsigned} {{/cpu/PC[1]} -radix unsigned} {{/cpu/PC[0]} -radix unsigned}} -subitemconfig {{/cpu/PC[31]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[30]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[29]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[28]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[27]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[26]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[25]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[24]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[23]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[22]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[21]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[20]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[19]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[18]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[17]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[16]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[15]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[14]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[13]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[12]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[11]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[10]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[9]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[8]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[7]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[6]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[5]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[4]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[3]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[2]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[1]} {-color Yellow -height 15 -radix unsigned} {/cpu/PC[0]} {-color Yellow -height 15 -radix unsigned}} /cpu/PC
add wave -noupdate -group ESTADO -color Red -radix unsigned /cpu/controle_/COUNTER
add wave -noupdate -group ESTADO -color Red -radix unsigned /cpu/controle_/STATE
add wave -noupdate -expand -group read -radix unsigned /cpu/inst_25to21
add wave -noupdate -expand -group read -radix unsigned /cpu/inst_20to16
add wave -noupdate -expand -group instr -radix unsigned /cpu/instrucao_/Instr31_26
add wave -noupdate -expand -group instr -radix unsigned /cpu/instrucao_/Instr25_21
add wave -noupdate -expand -group instr -radix unsigned /cpu/instrucao_/Instr20_16
add wave -noupdate -group A/B -radix decimal /cpu/alu_out
add wave -noupdate -group A/B -color Cyan -radix unsigned /cpu/A
add wave -noupdate -group A/B -color Cyan -radix unsigned /cpu/B
add wave -noupdate -expand -group REG -color {Lime Green} -radix unsigned /cpu/registradores_/WriteReg
add wave -noupdate -expand -group REG -color {Lime Green} -radix unsigned /cpu/registradores_/WriteData
add wave -noupdate /cpu/writes
add wave -noupdate -expand -group mem -radix decimal /cpu/registradores_/Cluster(1)
add wave -noupdate -expand -group mem -radix decimal /cpu/registradores_/Cluster(2)
add wave -noupdate -expand -group mem -radix decimal /cpu/registradores_/Cluster(3)
add wave -noupdate -expand -group mem -radix decimal /cpu/registradores_/Cluster(10)
add wave -noupdate -radix unsigned /cpu/sel_reg_adress_src
add wave -noupdate -radix unsigned /cpu/controle_/M_REG_adress
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3099 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 213
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {576 ps} {2707 ps}
