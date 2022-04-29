package defines_pkg;
//typedef enum logic [2:0] {IDLE, LAYER1_y4y5_MUL, LAYER1_y6y7_MUL, LAYER1_FINAL_ADD, OUTPUT_MUL} dnn_state_t;
typedef enum logic [1:0] {LAYER1_y4y5_MUL, LAYER1_y6y7_MUL, LAYER1_FINAL_ADD, OUTPUT_MUL} dnn_state_t;
endpackage
