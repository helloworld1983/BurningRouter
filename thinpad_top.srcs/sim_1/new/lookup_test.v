module lookup_test(
    input wire lku_clk,
    input wire lku_rst,
    output reg succ);

// Lookup Trie Simple Test
reg[31:0] lku_query_in_addr;
reg lku_query_in_ready;
wire[31:0] lku_query_out_nexthop;
wire[1:0] lku_query_out_nextport;
wire lku_query_out_ready;
reg[31:0] lku_modify_in_addr;
reg lku_modify_in_ready;
reg[31:0] lku_modify_in_nexthop;
reg[1:0] lku_modify_in_nextport;
reg[6:0] lku_modify_in_len;
wire lku_modify_finish;
wire lku_full;


parameter STATE_PAUSE = 3'b000;
parameter STATE_GET_TEST = 3'b001;
parameter STATE_INSERT = 3'b010;
parameter STATE_QUERY  = 3'b011;
parameter STATE_FAIL   = 3'b100;
parameter STATE_SUCC   = 3'b101;

reg[31:0] src, dest;
reg[6:0] len;
reg[1:0] port;
reg type;

reg[2:0] state, next_state;
integer cnt, tot_test, cur_test;
integer input_fd;

lookup_table_linear ltt_inst(
    .lku_clk(lku_clk),
    .lku_rst(lku_rst),

    .query_in_addr(lku_query_in_addr),
    .query_in_ready(lku_query_in_ready),
    .query_out_nexthop(lku_query_out_nexthop),
    .query_out_nextport(lku_query_out_nextport),
    .query_out_ready(lku_query_out_ready),
    
    .modify_in_addr(lku_modify_in_addr),
    .modify_in_ready(lku_modify_in_ready),
    .modify_in_nextport(lku_modify_in_nextport),
    .modify_in_nexthop(lku_modify_in_nexthop),
    .modify_in_len(lku_modify_in_len),
    .modify_finish(lku_modify_finish),
    .full(lku_full)
);

initial begin
    input_fd = $fopen("lookup.mem", "r");
end

always @(posedge lku_clk) begin
    if (lku_rst == 1'b1) begin
        state <= STATE_PAUSE;
        $fclose(input_fd);
        input_fd = $fopen("lookup.mem", "r");
    end else begin
        state <= next_state;
    end
end

always @(posedge lku_clk) begin
    if (lku_rst == 1'b1) begin
        lku_query_in_ready <= 0;
        lku_modify_in_ready <= 0;
        cnt <= 0;
        tot_test <= 0;
        cur_test <= 0;
        next_state <= STATE_PAUSE;
    end else begin
        case (next_state)
            STATE_PAUSE: begin
                cnt <= cnt + 1;
                if (cnt == 10) begin
                    next_state <= STATE_GET_TEST;
                    cur_test <= 0;
                    $fscanf(input_fd, "%d", tot_test);
                    $display("[lookup-test] test start, tot test %d", tot_test);
                    $fscanf(input_fd, "%d%h%h%d%d", type, src, dest, port, len);
                    $display("get from file: %d %h %h %d %d", type, src, dest, port, len);
                end
            end
            STATE_GET_TEST: begin
                if (state == STATE_PAUSE || state == STATE_GET_TEST) begin
                    if (cur_test == tot_test)
                        next_state <= STATE_SUCC;
                    else if (type == 0) begin
                        $display("[lookup-test] test %d modify begin", cur_test);
                        lku_modify_in_addr <= src;
                        lku_modify_in_len <= len;
                        lku_modify_in_nexthop <= dest;
                        lku_modify_in_nextport <= port;
                        lku_modify_in_ready <= 1;
                        next_state <= STATE_INSERT;
                    end else begin
                        $display("[lookup-test] test %d query begin", cur_test);
                        lku_query_in_addr <= src;
                        lku_query_in_ready <= 1;
                        next_state <= STATE_QUERY;
                    end
                end else begin
                    cur_test <= cur_test + 1;
                    next_state <= STATE_GET_TEST;
                    $fscanf(input_fd, "%d%h%h%d%d", type, src, dest, port, len);
                    $display("get from file: %d %h %h %d %d", type, src, dest, port, len);
                end
            end
            
            STATE_QUERY: begin
                if (state == STATE_GET_TEST)
                    lku_query_in_ready <= 0;
                if (lku_query_out_ready) begin
                    if (lku_query_out_nexthop != dest ||
                        lku_query_out_nextport != port) begin
                        $display("[lookup-test] fail test %d, get hop %h, port %d", cur_test, lku_query_out_nexthop, lku_query_out_nextport);
                        next_state <= STATE_FAIL;
                    end else begin
                        $display("[lookup-test] pass query %d, get hop %h, port %d", cur_test, lku_query_out_nexthop, lku_query_out_nextport);
                        next_state <= STATE_GET_TEST;
                    end
                end else
                    next_state <= STATE_QUERY;
            end

            STATE_INSERT: begin
                if (state == STATE_GET_TEST)
                    lku_modify_in_ready <= 0;
                if (lku_modify_finish) begin
                    $display("[lookup-test] test %d modify end", cur_test);
                    if (lku_full) begin
                        $display("[lookup-test] full, stop test");
                        next_state <= STATE_SUCC;
                    end else
                        next_state <= STATE_GET_TEST;
                end else
                    next_state <= STATE_INSERT;
            end
            
            STATE_SUCC: begin
                if (state != STATE_SUCC)
                    $display("[lookup-test] Congratulations! All test pass!");
                next_state <= STATE_SUCC;
            end

            STATE_FAIL: begin
                next_state <= STATE_FAIL;
            end
        endcase
    end
end    
   
endmodule