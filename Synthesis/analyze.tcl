#lappend search_path "../RTL/five_stage"
#
#analyze -library work -format sverilog \
#{	../RTL/five_stage/defines_pkg.sv \
#	../RTL/five_stage/top.sv \
#	../RTL/five_stage/dnn.sv
#}

#lappend search_path "../RTL/optimized"
#
#analyze -library work -format sverilog \
#{	../RTL/optimized/defines_pkg.sv \
#	../RTL/optimized/top.sv \
#	../RTL/optimized/dnn.sv
#}

#lappend search_path "../RTL/unoptimized"
#
#analyze -library work -format sverilog \
#{   ../RTL/unoptimized/top.sv \
#	../RTL/unoptimized/dnn.sv
#}

lappend search_path "../RTL/2dnn"

analyze -library work -format sverilog \
{	../RTL/2dnn/defines_pkg.sv \
	../RTL/2dnn/top.sv \
	../RTL/2dnn/dnn.sv
}
